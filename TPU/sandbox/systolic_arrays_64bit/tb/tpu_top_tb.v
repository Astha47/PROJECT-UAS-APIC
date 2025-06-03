`timescale 1ns / 1ps

module tb_tpu_top;

    // Parameters
    localparam ARRAY_SIZE        = 32;
    localparam SRAM_DATA_WIDTH   = 64;
    localparam DATA_WIDTH        = 16;
    localparam OUTPUT_DATA_WIDTH = 32;

    // Inputs
    reg clk;
    reg srstn; // Asynchronous reset (active low)
    reg tpu_start;

    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_w0, sram_rdata_w1, sram_rdata_w2, sram_rdata_w3;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_w4, sram_rdata_w5, sram_rdata_w6, sram_rdata_w7;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_d0, sram_rdata_d1, sram_rdata_d2, sram_rdata_d3;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_d4, sram_rdata_d5, sram_rdata_d6, sram_rdata_d7;

    // Outputs
    wire [9:0] sram_raddr_w0, sram_raddr_w1, sram_raddr_w2, sram_raddr_w3;
    wire [9:0] sram_raddr_w4, sram_raddr_w5, sram_raddr_w6, sram_raddr_w7;
    wire [9:0] sram_raddr_d0, sram_raddr_d1, sram_raddr_d2, sram_raddr_d3;
    wire [9:0] sram_raddr_d4, sram_raddr_d5, sram_raddr_d6, sram_raddr_d7;

    wire sram_write_enable_a0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a;
    wire [5:0] sram_waddr_a;

    wire sram_write_enable_b0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b;
    wire [5:0] sram_waddr_b;

    wire sram_write_enable_c0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c;
    wire [5:0] sram_waddr_c;

    wire tpu_done;

    // Instantiate the DUT (Design Under Test)
    tpu_top #(
        .ARRAY_SIZE(ARRAY_SIZE),
        .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
    ) dut (
        .clk(clk),
        .srstn(srstn),
        .tpu_start(tpu_start),

        .sram_rdata_w0(sram_rdata_w0), .sram_rdata_w1(sram_rdata_w1),
        .sram_rdata_w2(sram_rdata_w2), .sram_rdata_w3(sram_rdata_w3),
        .sram_rdata_w4(sram_rdata_w4), .sram_rdata_w5(sram_rdata_w5),
        .sram_rdata_w6(sram_rdata_w6), .sram_rdata_w7(sram_rdata_w7,

        .sram_rdata_d0(sram_rdata_d0), .sram_rdata_d1(sram_rdata_d1),
        .sram_rdata_d2(sram_rdata_d2), .sram_rdata_d3(sram_rdata_d3),
        .sram_rdata_d4(sram_rdata_d4), .sram_rdata_d5(sram_rdata_d5),
        .sram_rdata_d6(sram_rdata_d6), .sram_rdata_d7(sram_rdata_d7),

        .sram_raddr_w0(sram_raddr_w0), .sram_raddr_w1(sram_raddr_w1),
        .sram_raddr_w2(sram_raddr_w2), .sram_raddr_w3(sram_raddr_w3),
        .sram_raddr_w4(sram_raddr_w4), .sram_raddr_w5(sram_raddr_w5),
        .sram_raddr_w6(sram_raddr_w6), .sram_raddr_w7(sram_raddr_w7),

        .sram_raddr_d0(sram_raddr_d0), .sram_raddr_d1(sram_raddr_d1),
        .sram_raddr_d2(sram_raddr_d2), .sram_raddr_d3(sram_raddr_d3),
        .sram_raddr_d4(sram_raddr_d4), .sram_raddr_d5(sram_raddr_d5),
        .sram_raddr_d6(sram_raddr_d6), .sram_raddr_d7(sram_raddr_d7,

        .sram_write_enable_a0(sram_write_enable_a0),
        .sram_wdata_a(sram_wdata_a),
        .sram_waddr_a(sram_waddr_a),

        .sram_write_enable_b0(sram_write_enable_b0),
        .sram_wdata_b(sram_wdata_b),
        .sram_waddr_b(sram_waddr_b),

        .sram_write_enable_c0(sram_write_enable_c0),
        .sram_wdata_c(sram_wdata_c),
        .sram_waddr_c(sram_waddr_c),

        .tpu_done(tpu_done)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // 100 MHz clock
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        srstn = 0; // Assert reset
        tpu_start = 0;

        sram_rdata_w0 = 64'h0000000000000000; sram_rdata_w1 = 64'h0000000000000000;
        sram_rdata_w2 = 64'h0000000000000000; sram_rdata_w3 = 64'h0000000000000000;
        sram_rdata_w4 = 64'h0000000000000000; sram_rdata_w5 = 64'h0000000000000000;
        sram_rdata_w6 = 64'h0000000000000000; sram_rdata_w7 = 64'h0000000000000000;

        sram_rdata_d0 = 64'h0000000000000000; sram_rdata_d1 = 64'h0000000000000000;
        sram_rdata_d2 = 64'h0000000000000000; sram_rdata_d3 = 64'h0000000000000000;
        sram_rdata_d4 = 64'h0000000000000000; sram_rdata_d5 = 64'h0000000000000000;
        sram_rdata_d6 = 64'h0000000000000000; sram_rdata_d7 = 64'h0000000000000000;

        // Deassert reset after a few cycles
        repeat(5) @(posedge clk);
        srstn = 1;

        // Start TPU operation
        repeat(5) @(posedge clk);
        tpu_start = 1;
        @(posedge clk);
        tpu_start = 0;

        // Wait for TPU operation to complete
        wait (tpu_done == 1);
        $display("[%0t ns] TPU operation completed.", $time);

        // End simulation
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("[%0t ns] clk=%b, srstn=%b, tpu_start=%b, tpu_done=%b",
                 $time, clk, srstn, tpu_start, tpu_done);
    end

endmodule