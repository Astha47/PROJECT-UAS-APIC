`timescale 1ns / 1ps

module tb_systolic;

    // Parameters (sesuaikan dengan systolic.v Anda)
    localparam ARRAY_SIZE        = 32;
    localparam SRAM_DATA_WIDTH   = 32; // Sesuai dengan DATA_WIDTH sekarang
    localparam DATA_WIDTH        = 32; // Elemen data sekarang 32-bit
    
    localparam PRODUCT_WIDTH     = DATA_WIDTH + DATA_WIDTH;       // 64
    localparam OUTCOME_WIDTH     = PRODUCT_WIDTH + 5;           // 69
    localparam MUL_OUTCOME_WIDTH = ARRAY_SIZE * OUTCOME_WIDTH;    // 32 * 69

    // Inputs untuk systolic.v
    reg clk;
    reg rst_n;
    reg alu_start;
    reg [8:0] cycle_num_tb;
    reg [5:0] matrix_index_tb;

    // 32x Input data weights 32-bit
    reg [DATA_WIDTH-1:0] sram_rdata_w0_tb, sram_rdata_w1_tb, sram_rdata_w2_tb, sram_rdata_w3_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w4_tb, sram_rdata_w5_tb, sram_rdata_w6_tb, sram_rdata_w7_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w8_tb, sram_rdata_w9_tb, sram_rdata_w10_tb, sram_rdata_w11_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w12_tb, sram_rdata_w13_tb, sram_rdata_w14_tb, sram_rdata_w15_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w16_tb, sram_rdata_w17_tb, sram_rdata_w18_tb, sram_rdata_w19_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w20_tb, sram_rdata_w21_tb, sram_rdata_w22_tb, sram_rdata_w23_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w24_tb, sram_rdata_w25_tb, sram_rdata_w26_tb, sram_rdata_w27_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_w28_tb, sram_rdata_w29_tb, sram_rdata_w30_tb, sram_rdata_w31_tb;

    // 32x Input data inputs 32-bit
    reg [DATA_WIDTH-1:0] sram_rdata_d0_tb, sram_rdata_d1_tb, sram_rdata_d2_tb, sram_rdata_d3_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d4_tb, sram_rdata_d5_tb, sram_rdata_d6_tb, sram_rdata_d7_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d8_tb, sram_rdata_d9_tb, sram_rdata_d10_tb, sram_rdata_d11_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d12_tb, sram_rdata_d13_tb, sram_rdata_d14_tb, sram_rdata_d15_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d16_tb, sram_rdata_d17_tb, sram_rdata_d18_tb, sram_rdata_d19_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d20_tb, sram_rdata_d21_tb, sram_rdata_d22_tb, sram_rdata_d23_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d24_tb, sram_rdata_d25_tb, sram_rdata_d26_tb, sram_rdata_d27_tb;
    reg [DATA_WIDTH-1:0] sram_rdata_d28_tb, sram_rdata_d29_tb, sram_rdata_d30_tb, sram_rdata_d31_tb;

    // Output dari systolic.v
    wire signed [MUL_OUTCOME_WIDTH-1:0] mul_outcome_dut;

    // Instansiasi DUT (Design Under Test) - systolic
    systolic #(
        .ARRAY_SIZE(ARRAY_SIZE),
        .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH), // Seharusnya sama dengan DATA_WIDTH jika 1 elemen per port SRAM
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .alu_start(alu_start),
        .cycle_num(cycle_num_tb),
        .matrix_index(matrix_index_tb),

        .sram_rdata_w0(sram_rdata_w0_tb),   .sram_rdata_w1(sram_rdata_w1_tb),   .sram_rdata_w2(sram_rdata_w2_tb),   .sram_rdata_w3(sram_rdata_w3_tb),
        .sram_rdata_w4(sram_rdata_w4_tb),   .sram_rdata_w5(sram_rdata_w5_tb),   .sram_rdata_w6(sram_rdata_w6_tb),   .sram_rdata_w7(sram_rdata_w7_tb),
        .sram_rdata_w8(sram_rdata_w8_tb),   .sram_rdata_w9(sram_rdata_w9_tb),   .sram_rdata_w10(sram_rdata_w10_tb), .sram_rdata_w11(sram_rdata_w11_tb),
        .sram_rdata_w12(sram_rdata_w12_tb), .sram_rdata_w13(sram_rdata_w13_tb), .sram_rdata_w14(sram_rdata_w14_tb), .sram_rdata_w15(sram_rdata_w15_tb),
        .sram_rdata_w16(sram_rdata_w16_tb), .sram_rdata_w17(sram_rdata_w17_tb), .sram_rdata_w18(sram_rdata_w18_tb), .sram_rdata_w19(sram_rdata_w19_tb),
        .sram_rdata_w20(sram_rdata_w20_tb), .sram_rdata_w21(sram_rdata_w21_tb), .sram_rdata_w22(sram_rdata_w22_tb), .sram_rdata_w23(sram_rdata_w23_tb),
        .sram_rdata_w24(sram_rdata_w24_tb), .sram_rdata_w25(sram_rdata_w25_tb), .sram_rdata_w26(sram_rdata_w26_tb), .sram_rdata_w27(sram_rdata_w27_tb),
        .sram_rdata_w28(sram_rdata_w28_tb), .sram_rdata_w29(sram_rdata_w29_tb), .sram_rdata_w30(sram_rdata_w30_tb), .sram_rdata_w31(sram_rdata_w31_tb),

        .sram_rdata_d0(sram_rdata_d0_tb),   .sram_rdata_d1(sram_rdata_d1_tb),   .sram_rdata_d2(sram_rdata_d2_tb),   .sram_rdata_d3(sram_rdata_d3_tb),
        .sram_rdata_d4(sram_rdata_d4_tb),   .sram_rdata_d5(sram_rdata_d5_tb),   .sram_rdata_d6(sram_rdata_d6_tb),   .sram_rdata_d7(sram_rdata_d7_tb),
        .sram_rdata_d8(sram_rdata_d8_tb),   .sram_rdata_d9(sram_rdata_d9_tb),   .sram_rdata_d10(sram_rdata_d10_tb), .sram_rdata_d11(sram_rdata_d11_tb),
        .sram_rdata_d12(sram_rdata_d12_tb), .sram_rdata_d13(sram_rdata_d13_tb), .sram_rdata_d14(sram_rdata_d14_tb), .sram_rdata_d15(sram_rdata_d15_tb),
        .sram_rdata_d16(sram_rdata_d16_tb), .sram_rdata_d17(sram_rdata_d17_tb), .sram_rdata_d18(sram_rdata_d18_tb), .sram_rdata_d19(sram_rdata_d19_tb),
        .sram_rdata_d20(sram_rdata_d20_tb), .sram_rdata_d21(sram_rdata_d21_tb), .sram_rdata_d22(sram_rdata_d22_tb), .sram_rdata_d23(sram_rdata_d23_tb),
        .sram_rdata_d24(sram_rdata_d24_tb), .sram_rdata_d25(sram_rdata_d25_tb), .sram_rdata_d26(sram_rdata_d26_tb), .sram_rdata_d27(sram_rdata_d27_tb),
        .sram_rdata_d28(sram_rdata_d28_tb), .sram_rdata_d29(sram_rdata_d29_tb), .sram_rdata_d30(sram_rdata_d30_tb), .sram_rdata_d31(sram_rdata_d31_tb),

        .mul_outcome(mul_outcome_dut)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // ns
    always #(CLK_PERIOD/2) clk = ~clk;

    // Variabel untuk iterasi
    integer k;

    // Main simulation sequence
    initial begin
        // --- Tambahan untuk GTKWave (VCD dump) ---
        $dumpfile("tb_systolic_32bit_sim.vcd");
        $dumpvars(0, tb_systolic);
        // -----------------------------------------

        clk = 0;
        rst_n = 0; // Assert reset
        alu_start = 0;
        cycle_num_tb = 0;
        matrix_index_tb = 0;

        // Input data
        sram_rdata_w0_tb = 32'd1; sram_rdata_w1_tb = 32'd1;
        sram_rdata_w2_tb = 32'd1; sram_rdata_w3_tb = 32'd1;
        sram_rdata_w4_tb = 32'd1; sram_rdata_w5_tb = 32'd1;
        sram_rdata_w6_tb = 32'd1; sram_rdata_w7_tb = 32'd1;
        sram_rdata_w8_tb = 32'd1; sram_rdata_w9_tb = 32'd1;
        sram_rdata_w10_tb = 32'd1; sram_rdata_w11_tb = 32'd1;
        sram_rdata_w12_tb = 32'd1; sram_rdata_w13_tb = 32'd1;
        sram_rdata_w14_tb = 32'd1; sram_rdata_w15_tb = 32'd1;
        sram_rdata_w16_tb = 32'd2; sram_rdata_w17_tb = 32'd2;
        sram_rdata_w18_tb = 32'd2; sram_rdata_w19_tb = 32'd2;
        sram_rdata_w20_tb = 32'd2; sram_rdata_w21_tb = 32'd2;
        sram_rdata_w22_tb = 32'd2; sram_rdata_w23_tb = 32'd2;
        sram_rdata_w24_tb = 32'd2; sram_rdata_w25_tb = 32'd2;
        sram_rdata_w26_tb = 32'd2; sram_rdata_w27_tb = 32'd2;
        sram_rdata_w28_tb = 32'd2; sram_rdata_w29_tb = 32'd2;
        sram_rdata_w30_tb = 32'd2; sram_rdata_w31_tb = 32'd2;

        sram_rdata_d0_tb = 32'd1; sram_rdata_d1_tb = 32'd1;
        sram_rdata_d2_tb = 32'd1; sram_rdata_d3_tb = 32'd1;
        sram_rdata_d4_tb = 32'd1; sram_rdata_d5_tb = 32'd1;
        sram_rdata_d6_tb = 32'd1; sram_rdata_d7_tb = 32'd1;
        sram_rdata_d8_tb = 32'd1; sram_rdata_d9_tb = 32'd1;
        sram_rdata_d10_tb = 32'd1; sram_rdata_d11_tb = 32'd1;
        sram_rdata_d12_tb = 32'd1; sram_rdata_d13_tb = 32'd1;
        sram_rdata_d14_tb = 32'd1; sram_rdata_d15_tb = 32'd1;
        sram_rdata_d16_tb = 32'd3; sram_rdata_d17_tb = 32'd3;
        sram_rdata_d18_tb = 32'd3; sram_rdata_d19_tb = 32'd3;
        sram_rdata_d20_tb = 32'd3; sram_rdata_d21_tb = 32'd3;
        sram_rdata_d22_tb = 32'd3; sram_rdata_d23_tb = 32'd3;
        sram_rdata_d24_tb = 32'd3; sram_rdata_d25_tb = 32'd3;
        sram_rdata_d26_tb = 32'd3; sram_rdata_d27_tb = 32'd3;
        sram_rdata_d28_tb = 32'd3; sram_rdata_d29_tb = 32'd3;
        sram_rdata_d30_tb = 32'd3; sram_rdata_d31_tb = 32'd3;

        #(CLK_PERIOD * 2);
        rst_n = 1;      // Deassert reset
        #(CLK_PERIOD * 2);
        $display("[%0t ns] INFO: Reset deasserted.", $time);

        // Mulai operasi
        alu_start = 1'b1;
        cycle_num_tb = 0; // Mulai cycle_num dari 0 saat alu_start
        matrix_index_tb = 0; // Mulai dengan matrix_index 0

        $display("[%0t ns] INFO: alu_start asserted. cycle_num = %d", $time, cycle_num_tb);

        // Jalankan untuk sejumlah siklus yang cukup
        // Systolic array 32x32 membutuhkan sekitar 3*N-2 siklus untuk hasil pertama yang stabil
        // N=32, K=32. Pipelining: N-1 untuk data, N-1 untuk weight, N-1 untuk hasil keluar.
        // Atau lihat FIRST_OUT (33), PARALLEL_START (65)
        // Kita jalankan hingga sekitar 100-150 siklus untuk melihat sesuatu
        for (k = 0; k < 300; k = k + 1) begin
            #(CLK_PERIOD);
            cycle_num_tb = cycle_num_tb + 1;

            if (cycle_num_tb == 33) begin // Sesuai FIRST_OUT
                 $display("[%0t ns] INFO: cycle_num reached FIRST_OUT (%d). Checking mul_outcome for matrix_index %d.", $time, cycle_num_tb, matrix_index_tb);
                 // $display("mul_outcome = %h", mul_outcome_dut); // Terlalu panjang
            end
            if (cycle_num_tb == 65) begin // Sesuai PARALLEL_START
                 $display("[%0t ns] INFO: cycle_num reached PARALLEL_START (%d).", $time, cycle_num_tb);
            end
            if (cycle_num_tb == 70) begin // Coba ganti matrix_index
                matrix_index_tb = 1;
                $display("[%0t ns] INFO: matrix_index changed to %d.", $time, matrix_index_tb);
            end
             if (cycle_num_tb == 80) begin
                matrix_index_tb = 31;
                $display("[%0t ns] INFO: matrix_index changed to %d.", $time, matrix_index_tb);
            end
            if (cycle_num_tb == 90) begin
                matrix_index_tb = 32;
                $display("[%0t ns] INFO: matrix_index changed to %d.", $time, matrix_index_tb);
            end
             if (cycle_num_tb == 100) begin
                matrix_index_tb = 63;
                $display("[%0t ns] INFO: matrix_index changed to %d.", $time, matrix_index_tb);
            end

        end

        alu_start = 1'b0; // Hentikan operasi
        $display("[%0t ns] INFO: alu_start deasserted.", $time);
        #(CLK_PERIOD * 5);

        $display("[%0t ns] INFO: Simulation finished.", $time);
        $finish;
    end

    // (Opsional) Monitor sinyal
    // initial begin
    //     $monitor("[%0t ns] clk=%b, rst_n=%b, alu_start=%b, cycle_num=%3d, matrix_index=%2d, w[0]=%h, d[0]=%h, mul_outcome[68:0]=%h",
    //              $time, clk, rst_n, alu_start, cycle_num_tb, matrix_index_tb,
    //              sram_rdata_w0_tb, sram_rdata_d0_tb, mul_outcome_dut[OUTCOME_WIDTH-1:0]); // Hanya elemen pertama dari mul_outcome
    // end

endmodule