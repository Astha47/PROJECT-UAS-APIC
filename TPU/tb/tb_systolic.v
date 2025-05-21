`timescale 1ns/1ps

module tb_systolic;

  // Parameters
  parameter ARRAY_SIZE = 32;
  parameter SRAM_DATA_WIDTH = 64;
  parameter DATA_WIDTH = 8;
  parameter OUTCOME_WIDTH = DATA_WIDTH + DATA_WIDTH + 5;

  // Inputs
  reg clk;
  reg rst_n;
  reg alu_start;
  reg [8:0] cycle_num;
  reg [SRAM_DATA_WIDTH-1:0] sram_rdata_w0, sram_rdata_w1, sram_rdata_w2, sram_rdata_w3;
  reg [SRAM_DATA_WIDTH-1:0] sram_rdata_d0, sram_rdata_d1, sram_rdata_d2, sram_rdata_d3;
  reg [5:0] matrix_index;

  // Output
  wire signed [(ARRAY_SIZE * OUTCOME_WIDTH) - 1:0] mul_outcome;

  // Instantiate the DUT
  systolic dut (
    .clk(clk),
    .rst_n(rst_n),
    .alu_start(alu_start),
    .cycle_num(cycle_num),
    .sram_rdata_w0(sram_rdata_w0),
    .sram_rdata_w1(sram_rdata_w1),
    .sram_rdata_w2(sram_rdata_w2),
    .sram_rdata_w3(sram_rdata_w3),
    .sram_rdata_d0(sram_rdata_d0),
    .sram_rdata_d1(sram_rdata_d1),
    .sram_rdata_d2(sram_rdata_d2),
    .sram_rdata_d3(sram_rdata_d3),
    .matrix_index(matrix_index),
    .mul_outcome(mul_outcome)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100MHz clock

  // Stimulus
  integer i;
  initial begin
    // VCD for GTKWave
    $dumpfile("systolic.vcd");
    $dumpvars(0, tb_systolic);
    
    // Initialize
    rst_n = 0;
    alu_start = 0;
    cycle_num = 0;
    matrix_index = 0;
    sram_rdata_w0 = 0;
    sram_rdata_w1 = 0;
    sram_rdata_w2 = 0;
    sram_rdata_w3 = 0;
    sram_rdata_d0 = 0;
    sram_rdata_d1 = 0;
    sram_rdata_d2 = 0;
    sram_rdata_d3 = 0;
    #20;

    rst_n = 1;
    alu_start = 1;

    // Apply test data for 10 cycles
    for (i = 0; i < 10; i = i + 1) begin
      // Use predictable test pattern: 8-bit ramp
      sram_rdata_w0 = {8{8'd1}};
      sram_rdata_w1 = {8{8'd1}};
      sram_rdata_w2 = {8{8'd1}};
      sram_rdata_w3 = {8{8'd1}};

      sram_rdata_d0 = {8{8'd1}};
      sram_rdata_d1 = {8{8'd1}};
      sram_rdata_d2 = {8{8'd1}};
      sram_rdata_d3 = {8{8'd1}};

      cycle_num = i;

      // Wait for 1 clock cycle
      #10;

      // Observe output after pipeline fill (about cycle 35 onward)
      if (i > 35) begin
        $display("Cycle %0d - mul_outcome: %h", i, mul_outcome);
      end
    end

    alu_start = 0;
    #20;

    $finish;
  end

endmodule
