`timescale 1ns / 1ps

//------- Ahmed Abdelazeem -------
// Email: a.abdelazeem201@gmail.com
// (Modifikasi untuk kuantisasi dari 69-bit ke 32-bit Q16.16)
// (Revisi FINAL v5 - Sesuai Standar Verilog)

module quantize#(
    parameter ARRAY_SIZE = 32,
    parameter SRAM_DATA_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter OUTPUT_DATA_WIDTH = 32
)
(
    input signed [ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5)-1:0] ori_data,
    output reg signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data
);

    // --- Parameter Internal ---
    localparam INPUT_ELEMENT_WIDTH = DATA_WIDTH + DATA_WIDTH + 5; // 69 bit
    localparam NUM_INTEGER_BITS_OUT    = 16;
    localparam NUM_FRACTIONAL_BITS_OUT = 16;
    localparam NUM_FRACTIONAL_BITS_IN  = 32;
    localparam SHIFT_AMOUNT = NUM_FRACTIONAL_BITS_IN - NUM_FRACTIONAL_BITS_OUT; // 16

    localparam signed [OUTPUT_DATA_WIDTH-1:0] Q16_16_MAX_VAL = 32'h7FFFFFFF;
    localparam signed [OUTPUT_DATA_WIDTH-1:0] Q16_16_MIN_VAL = 32'h80000000;
    
    localparam signed [15:0] MAX_INT_16 = 32767;
    localparam signed [15:0] MIN_INT_16 = -32768;
    
    // --- PERBAIKAN: Deklarasi semua variabel di level modul ---
    integer i; // Variabel loop
    
    // Variabel perantara ini dideklarasikan sebagai 'reg' karena di-assign di dalam always@*
    // Meskipun hanya ada satu set, synthesizer akan mengerti ini sebagai logika kombinasional
    // yang direplikasi untuk setiap iterasi loop (unrolling).
    reg signed [INPUT_ELEMENT_WIDTH-1:0] current_input_element;
    reg signed [INPUT_ELEMENT_WIDTH-1:0] scaled_value;
    reg signed [INPUT_ELEMENT_WIDTH-1:0] rounded_value;
    reg signed [OUTPUT_DATA_WIDTH-1:0]  final_result_q16_16;
    reg                                 round_add_bit;
    reg signed [INPUT_ELEMENT_WIDTH-NUM_FRACTIONAL_BITS_OUT-1:0] integer_part_of_rounded;

    // --- Logika Kombinasional ---
    always @(*) begin
        // Loop ini mendeskripsikan 32 blok logika kombinasional paralel
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            
            // Ekstrak elemen 69-bit saat ini
            current_input_element = ori_data[i*INPUT_ELEMENT_WIDTH +: INPUT_ELEMENT_WIDTH];

            // 1. Scaling (Pergeseran Bit)
            if (SHIFT_AMOUNT >= INPUT_ELEMENT_WIDTH)
                scaled_value = (current_input_element < 0) ? -1 : 0;
            else
                scaled_value = current_input_element >>> SHIFT_AMOUNT;

            // 2. Rounding (Pembulatan)
            if (SHIFT_AMOUNT > 0)
                round_add_bit = current_input_element[SHIFT_AMOUNT - 1];
            else
                round_add_bit = 1'b0;
            
            rounded_value = scaled_value + round_add_bit;

            // 3. Saturasi (Logika yang disederhanakan dan robust)
            // Ambil bagian integer dari hasil presisi tinggi 69-bit
            integer_part_of_rounded = rounded_value[INPUT_ELEMENT_WIDTH-1 : NUM_FRACTIONAL_BITS_OUT];

            // Bandingkan bagian integer ini dengan batas integer 16-bit
            if (integer_part_of_rounded > MAX_INT_16) begin
                final_result_q16_16 = Q16_16_MAX_VAL;
            end else if (integer_part_of_rounded < MIN_INT_16) begin
                final_result_q16_16 = Q16_16_MIN_VAL;
            end else begin
                // Jika tidak ada overflow, ambil 32 bit yang relevan dari `rounded_value`
                final_result_q16_16 = rounded_value[OUTPUT_DATA_WIDTH-1:0];
            end
            
            // Assign hasil akhir ke slice output yang sesuai
            quantized_data[i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = final_result_q16_16;
        end
    end

endmodule