// Module: systolic array for matrix multiplication (32x32) 
// Author: Ahmed Abdelazeem
// Email: a.abdelazeem201@gmail.com
// (Modifikasi untuk DATA_WIDTH 32-bit dan antarmuka SRAM yang sesuai)

module systolic #(
    parameter ARRAY_SIZE = 32,           // Size of the array (32x32)
    parameter SRAM_DATA_WIDTH = 32,      // Data width for SRAM input (sekarang = DATA_WIDTH)
    parameter DATA_WIDTH = 32            // Data width for elements in the matrix (sekarang 32-bit)
)(
    input wire clk,
    input wire rst_n,
    input wire alu_start,
    input wire [8:0] cycle_num,

    // SRAM inputs for 32 weight elements (masing-masing DATA_WIDTH bit)
    input wire [DATA_WIDTH-1:0] sram_rdata_w0,  sram_rdata_w1,  sram_rdata_w2,  sram_rdata_w3,
                                sram_rdata_w4,  sram_rdata_w5,  sram_rdata_w6,  sram_rdata_w7,
                                sram_rdata_w8,  sram_rdata_w9,  sram_rdata_w10, sram_rdata_w11,
                                sram_rdata_w12, sram_rdata_w13, sram_rdata_w14, sram_rdata_w15,
                                sram_rdata_w16, sram_rdata_w17, sram_rdata_w18, sram_rdata_w19,
                                sram_rdata_w20, sram_rdata_w21, sram_rdata_w22, sram_rdata_w23,
                                sram_rdata_w24, sram_rdata_w25, sram_rdata_w26, sram_rdata_w27,
                                sram_rdata_w28, sram_rdata_w29, sram_rdata_w30, sram_rdata_w31,

    // SRAM inputs for 32 data elements (masing-masing DATA_WIDTH bit)
    input wire [DATA_WIDTH-1:0] sram_rdata_d0,  sram_rdata_d1,  sram_rdata_d2,  sram_rdata_d3,
                                sram_rdata_d4,  sram_rdata_d5,  sram_rdata_d6,  sram_rdata_d7,
                                sram_rdata_d8,  sram_rdata_d9,  sram_rdata_d10, sram_rdata_d11,
                                sram_rdata_d12, sram_rdata_d13, sram_rdata_d14, sram_rdata_d15,
                                sram_rdata_d16, sram_rdata_d17, sram_rdata_d18, sram_rdata_d19,
                                sram_rdata_d20, sram_rdata_d21, sram_rdata_d22, sram_rdata_d23,
                                sram_rdata_d24, sram_rdata_d25, sram_rdata_d26, sram_rdata_d27,
                                sram_rdata_d28, sram_rdata_d29, sram_rdata_d30, sram_rdata_d31,
                                
    input wire [5:0] matrix_index,
    // Output width sekarang ARRAY_SIZE * (32+32+5) = ARRAY_SIZE * 69
    output reg signed [(ARRAY_SIZE*(DATA_WIDTH+DATA_WIDTH+5))-1:0] mul_outcome 
);

// Local parameters
localparam FIRST_OUT = 33; // Tetap, terkait dengan latensi array
localparam PARALLEL_START = 65; // Tetap, terkait dengan latensi array
localparam PRODUCT_WIDTH = DATA_WIDTH + DATA_WIDTH; // Lebar hasil perkalian (32+32 = 64 bit)
localparam OUTCOME_WIDTH = PRODUCT_WIDTH + 5;     // Lebar akumulator (64+5 = 69 bit)

// Internal registers
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
reg signed [OUTCOME_WIDTH-1:0] matrix_mul_2D_nx [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
reg signed [DATA_WIDTH-1:0] data_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];    // Elemen sekarang 32-bit
reg signed [DATA_WIDTH-1:0] weight_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];  // Elemen sekarang 32-bit
reg signed [PRODUCT_WIDTH-1:0] mul_result; // Hasil perkalian sekarang 64-bit
reg signed [OUTCOME_WIDTH-1:0] extended_mul_result;


reg [5:0] upper_bound, lower_bound;
integer i, j, k; // Tambahkan k jika diperlukan untuk loop pemuatan
integer k_loop_idx,  i_loop_idx, j_loop_idx;

// Shift weight and data queues
always @(posedge clk) begin
    if (~rst_n) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                weight_queue[i][j] <= {(DATA_WIDTH){1'b0}}; // Inisialisasi dengan lebar yang benar
                data_queue[i][j] <= {(DATA_WIDTH){1'b0}};   // Inisialisasi dengan lebar yang benar
            end
        end
    end
    else if (alu_start) begin
        // --- MODIFIKASI LOGIKA PEMUATAN DATA ---
        // Shift weight queue - Memuat 32 elemen 32-bit ke baris pertama
        // Asumsi sram_rdata_w0 untuk weight_queue[0][0], w1 untuk [0][1], dst.
        // Ini adalah cara paling langsung jika ada 32 port input diskrit.
        weight_queue[0][0]  <= sram_rdata_w0;  weight_queue[0][1]  <= sram_rdata_w1;
        weight_queue[0][2]  <= sram_rdata_w2;  weight_queue[0][3]  <= sram_rdata_w3;
        weight_queue[0][4]  <= sram_rdata_w4;  weight_queue[0][5]  <= sram_rdata_w5;
        weight_queue[0][6]  <= sram_rdata_w6;  weight_queue[0][7]  <= sram_rdata_w7;
        weight_queue[0][8]  <= sram_rdata_w8;  weight_queue[0][9]  <= sram_rdata_w9;
        weight_queue[0][10] <= sram_rdata_w10; weight_queue[0][11] <= sram_rdata_w11;
        weight_queue[0][12] <= sram_rdata_w12; weight_queue[0][13] <= sram_rdata_w13;
        weight_queue[0][14] <= sram_rdata_w14; weight_queue[0][15] <= sram_rdata_w15;
        weight_queue[0][16] <= sram_rdata_w16; weight_queue[0][17] <= sram_rdata_w17;
        weight_queue[0][18] <= sram_rdata_w18; weight_queue[0][19] <= sram_rdata_w19;
        weight_queue[0][20] <= sram_rdata_w20; weight_queue[0][21] <= sram_rdata_w21;
        weight_queue[0][22] <= sram_rdata_w22; weight_queue[0][23] <= sram_rdata_w23;
        weight_queue[0][24] <= sram_rdata_w24; weight_queue[0][25] <= sram_rdata_w25;
        weight_queue[0][26] <= sram_rdata_w26; weight_queue[0][27] <= sram_rdata_w27;
        weight_queue[0][28] <= sram_rdata_w28; weight_queue[0][29] <= sram_rdata_w29;
        weight_queue[0][30] <= sram_rdata_w30; weight_queue[0][31] <= sram_rdata_w31;
        
        for (i = 1; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                weight_queue[i][j] <= weight_queue[i-1][j];
            end
        end
                
        // Shift data queue - Memuat 32 elemen 32-bit ke kolom pertama
        // Asumsi sram_rdata_d0 untuk data_queue[0][0], d1 untuk [1][0], dst.
        data_queue[0][0]  <= sram_rdata_d0;  data_queue[1][0]  <= sram_rdata_d1;
        data_queue[2][0]  <= sram_rdata_d2;  data_queue[3][0]  <= sram_rdata_d3;
        data_queue[4][0]  <= sram_rdata_d4;  data_queue[5][0]  <= sram_rdata_d5;
        data_queue[6][0]  <= sram_rdata_d6;  data_queue[7][0]  <= sram_rdata_d7;
        data_queue[8][0]  <= sram_rdata_d8;  data_queue[9][0]  <= sram_rdata_d9;
        data_queue[10][0] <= sram_rdata_d10; data_queue[11][0] <= sram_rdata_d11;
        data_queue[12][0] <= sram_rdata_d12; data_queue[13][0] <= sram_rdata_d13;
        data_queue[14][0] <= sram_rdata_d14; data_queue[15][0] <= sram_rdata_d15;
        data_queue[16][0] <= sram_rdata_d16; data_queue[17][0] <= sram_rdata_d17;
        data_queue[18][0] <= sram_rdata_d18; data_queue[19][0] <= sram_rdata_d19;
        data_queue[20][0] <= sram_rdata_d20; data_queue[21][0] <= sram_rdata_d21;
        data_queue[22][0] <= sram_rdata_d22; data_queue[23][0] <= sram_rdata_d23;
        data_queue[24][0] <= sram_rdata_d24; data_queue[25][0] <= sram_rdata_d25;
        data_queue[26][0] <= sram_rdata_d26; data_queue[27][0] <= sram_rdata_d27;
        data_queue[28][0] <= sram_rdata_d28; data_queue[29][0] <= sram_rdata_d29;
        data_queue[30][0] <= sram_rdata_d30; data_queue[31][0] <= sram_rdata_d31;

        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 1; j < ARRAY_SIZE; j = j + 1) begin
                data_queue[i][j] <= data_queue[i][j-1];
            end
        end
    end
end

// Multiplication unit - Logika sekuensialnya sama
always @(posedge clk) begin
    if (~rst_n) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                matrix_mul_2D[i][j] <= {(OUTCOME_WIDTH){1'b0}}; // Inisialisasi dengan lebar yang benar
            end
        end
    end
    else begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                matrix_mul_2D[i][j] <= matrix_mul_2D_nx[i][j];
            end
        end
    end
end

// Combinational logic for multiplication and accumulation
always @(*) begin
    // Default assignment untuk matrix_mul_2D_nx
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
        for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
            matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j]; // Pertahankan nilai jika tidak ada update
        end
    end
    mul_result = {(PRODUCT_WIDTH){1'b0}}; // Default mul_result

    if (alu_start) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                // Perkalian 32-bit * 32-bit menghasilkan 64-bit
                mul_result = weight_queue[i][j] * data_queue[i][j];
                
                // --- MODIFIKASI SIGN EXTENSION ---
                // mul_result adalah 64-bit (PRODUCT_WIDTH). OUTCOME_WIDTH adalah 69-bit.
                // Perlu sign-extend 5 bit dari MSB mul_result (bit ke-63).
                extended_mul_result = {{5{mul_result[PRODUCT_WIDTH-1]}}, mul_result};

                if ((cycle_num >= FIRST_OUT && (i+j) == (cycle_num - FIRST_OUT) % (2*ARRAY_SIZE)) || // Modulo disesuaikan
                    (cycle_num >= PARALLEL_START && (i+j) == (cycle_num - PARALLEL_START) % (2*ARRAY_SIZE))) begin // Modulo disesuaikan
                    matrix_mul_2D_nx[i][j] = extended_mul_result; // Inisialisasi akumulator
                end
                else if (cycle_num >= 1 && i + j <= (cycle_num - 1)) begin
                    matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j] + extended_mul_result; // Akumulasi hasil
                end
                // else: matrix_mul_2D_nx[i][j] sudah di-assign nilai matrix_mul_2D[i][j] di awal always block
            end
        end
    end
    // else: matrix_mul_2D_nx[i][j] sudah di-assign nilai matrix_mul_2D[i][j] dan mul_result=0
end

// Output generation - Logika ini sebagian besar tetap, hanya lebar data yang berubah
always @(*) begin
    // Inisialisasi output
    for (k_loop_idx = 0; k_loop_idx < ARRAY_SIZE * OUTCOME_WIDTH; k_loop_idx = k_loop_idx + 1) begin
        mul_outcome[k_loop_idx] = 1'b0;
    end

    if (matrix_index < ARRAY_SIZE) begin
        upper_bound = matrix_index;
        lower_bound = matrix_index + ARRAY_SIZE;
    end
    else begin
        upper_bound = matrix_index - ARRAY_SIZE;
        lower_bound = matrix_index;
    end

    // Fetch data from the multiplication result matrix
    // Menggunakan i_loop_idx dan j_loop_idx untuk menghindari konflik dengan i, j global
    for (i_loop_idx = 0; i_loop_idx < ARRAY_SIZE; i_loop_idx = i_loop_idx + 1) begin
        for (j_loop_idx = 0; j_loop_idx < ARRAY_SIZE - i_loop_idx; j_loop_idx = j_loop_idx + 1) begin
            if (i_loop_idx + j_loop_idx == upper_bound) begin
                mul_outcome[i_loop_idx * OUTCOME_WIDTH +: OUTCOME_WIDTH] = matrix_mul_2D[i_loop_idx][j_loop_idx];
            end
        end
    end

    for (i_loop_idx = 1; i_loop_idx < ARRAY_SIZE; i_loop_idx = i_loop_idx + 1) begin
        for (j_loop_idx = ARRAY_SIZE - i_loop_idx; j_loop_idx < ARRAY_SIZE; j_loop_idx = j_loop_idx + 1) begin
            if (i_loop_idx + j_loop_idx == lower_bound) begin
                mul_outcome[i_loop_idx * OUTCOME_WIDTH +: OUTCOME_WIDTH] = matrix_mul_2D[i_loop_idx][j_loop_idx];
            end
        end
    end
end

endmodule