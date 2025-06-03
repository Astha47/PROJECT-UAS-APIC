//------- Modul Kuantisasi dengan Scaling, Rounding, Saturation -------
// Deskripsi:
// Modul ini mengkuantisasi data input dengan lebar bit besar (misalnya, dari akumulator systolic array)
// ke format output integer bertanda dengan lebar bit yang lebih kecil (target 32-bit).
// Tahapan yang dilakukan:
// 1. Scaling: Pergeseran aritmatika ke kanan pada data input.
// 2. Rounding: Pembulatan round-half-up sederhana berdasarkan MSB dari bit yang dibuang.
// 3. Saturation: Menjepit hasil ke rentang nilai minimum/maksimum format output.

module quantize #(
    parameter ARRAY_SIZE          = 32,  // Jumlah elemen dalam bus input/output
    parameter INPUT_ELEMENT_WIDTH = 133, // Lebar bit setiap elemen input (misal, output akumulator systolic)
    parameter OUTPUT_DATA_WIDTH   = 32,  // Lebar bit target untuk setiap elemen output
    parameter SHIFT_AMOUNT        = 101  // Jumlah bit untuk digeser ke kanan saat scaling
                                         // CONTOH: (133 - 32) = 101. NILAI INI SANGAT KRITIS & PERLU PENYESUAIAN.
                                         // Jika SHIFT_AMOUNT = 0, tidak ada scaling.
) (
    input wire signed [ARRAY_SIZE * INPUT_ELEMENT_WIDTH - 1 : 0] ori_data,
    output reg signed [ARRAY_SIZE * OUTPUT_DATA_WIDTH - 1 : 0] quantized_data
);

    // Batas saturasi untuk format OUTPUT_DATA_WIDTH (signed)
    localparam signed [OUTPUT_DATA_WIDTH-1:0] MAX_VAL = {1'b0, {(OUTPUT_DATA_WIDTH-1){1'b1}}}; // Nilai positif terbesar
    localparam signed [OUTPUT_DATA_WIDTH-1:0] MIN_VAL = {1'b1, {(OUTPUT_DATA_WIDTH-1){1'b0}}}; // Nilai negatif terkecil

    integer i;

    // Validasi parameter (akan memberikan error saat elaborasi jika tidak valid)
    // initial begin
    //     if (SHIFT_AMOUNT < 0) begin
    //         $error("quantize: SHIFT_AMOUNT tidak boleh negatif."); $finish;
    //     end
    //     if (SHIFT_AMOUNT >= INPUT_ELEMENT_WIDTH) begin
    //         $error("quantize: SHIFT_AMOUNT terlalu besar, akan menghasilkan 0 atau -1 bit."); $finish;
    //     end
    // end

    always @* begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            signed [INPUT_ELEMENT_WIDTH-1:0] current_input_element;
            signed [INPUT_ELEMENT_WIDTH-1:0] scaled_value;    // Hasil setelah scaling
            signed [INPUT_ELEMENT_WIDTH-1:0] rounded_value;   // Hasil setelah rounding, lebar dijaga untuk carry
            signed [OUTPUT_DATA_WIDTH-1:0]   saturated_output; // Hasil akhir setelah saturasi
            logic                            round_add_term;    // Bit untuk ditambahkan saat rounding

            current_input_element = ori_data[i * INPUT_ELEMENT_WIDTH +: INPUT_ELEMENT_WIDTH];

            // 1. Scaling (Pergeseran Aritmatika ke Kanan)
            // Menggeser bit ke kanan sebanyak SHIFT_AMOUNT.
            // Operator '>>>' melakukan pergeseran aritmatika (mempertahankan bit tanda).
            if (SHIFT_AMOUNT >= INPUT_ELEMENT_WIDTH) begin // Mencegah pergeseran yang berlebihan
                scaled_value = (current_input_element < 0) ? -1 : 0; // Hasilnya akan 0 atau -1
            end else begin
                scaled_value = current_input_element >>> SHIFT_AMOUNT;
            end

            // 2. Rounding (Round-half-up sederhana)
            // Memeriksa bit paling signifikan yang tergeser keluar (guard bit).
            if (SHIFT_AMOUNT > 0 && SHIFT_AMOUNT <= INPUT_ELEMENT_WIDTH) begin
                round_add_term = current_input_element[SHIFT_AMOUNT - 1];
            end else begin
                round_add_term = 1'b0; // Tidak ada bit untuk rounding jika tidak ada pergeseran
            end
            rounded_value = scaled_value + round_add_term; // Tambahkan bit rounding

            // 3. Saturation (Penjepitan ke rentang OUTPUT_DATA_WIDTH)
            // Perbandingan dilakukan dengan `rounded_value` yang mungkin masih lebih lebar dari OUTPUT_DATA_WIDTH.
            // MAX_VAL dan MIN_VAL akan di-sign-extend secara otomatis saat perbandingan.
            if (rounded_value >= MAX_VAL) begin
                saturated_output = MAX_VAL;
            end else if (rounded_value <= MIN_VAL) begin
                saturated_output = MIN_VAL;
            end else begin
                // Jika nilai berada dalam rentang, ambil OUTPUT_DATA_WIDTH bit yang relevan.
                // Karena `rounded_value` sudah di-scale dan di-round,
                // kita ambil bagian LSB yang sesuai dengan OUTPUT_DATA_WIDTH.
                saturated_output = rounded_value[OUTPUT_DATA_WIDTH-1:0];
            end
            
            quantized_data[i * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = saturated_output;
        end
    end

endmodule