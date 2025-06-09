// tpu_top module for a Tensor Processing Unit (TPU) architecture
// This module integrates various components to perform matrix operations
// using a systolic array architecture with data quantization and address selection.

module tpu_top #(
    parameter ARRAY_SIZE = 32,               // Number of elements in the array
    parameter SRAM_DATA_WIDTH = 32,          // Width of SRAM data
    parameter DATA_WIDTH = 32,                 // Width of input data
    parameter OUTPUT_DATA_WIDTH = 32          // Width of output data
)(
    input clk,                               // Clock signal
    input srstn,                             // Asynchronous reset signal (active low)
    input tpu_start,                         // Start signal for TPU operations

    // Input data for weights and data from 32 SRAMs
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w0,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w1,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w2,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w3,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w4,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w5,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w6,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w7,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w8,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w9,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w10,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w11,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w12,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w13,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w14,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w15,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w16,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w17,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w18,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w19,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w20,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w21,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w22,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w23,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w24,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w25,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w26,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w27,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w28,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w29,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w30,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_w31,
    
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d0,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d1,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d2,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d3,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d4,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d5,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d6,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d7,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d8,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d9,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d10,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d11,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d12,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d13,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d14,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d15,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d16,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d17,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d18,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d19,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d20,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d21,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d22,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d23,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d24,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d25,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d26,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d27,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d28,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d29,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d30,
    input [SRAM_DATA_WIDTH-1:0] sram_rdata_d31,

    // Output addresses for (data, weight) from 64 SRAMs
    output [9:0] sram_raddr_w0,
    output [9:0] sram_raddr_w1,
    output [9:0] sram_raddr_w2,
    output [9:0] sram_raddr_w3,
    output [9:0] sram_raddr_w4,
    output [9:0] sram_raddr_w5,
    output [9:0] sram_raddr_w6,
    output [9:0] sram_raddr_w7,
    output [9:0] sram_raddr_w8,
    output [9:0] sram_raddr_w9,
    output [9:0] sram_raddr_w10,
    output [9:0] sram_raddr_w11,
    output [9:0] sram_raddr_w12,
    output [9:0] sram_raddr_w13,
    output [9:0] sram_raddr_w14,
    output [9:0] sram_raddr_w15,
    output [9:0] sram_raddr_w16,
    output [9:0] sram_raddr_w17,
    output [9:0] sram_raddr_w18,
    output [9:0] sram_raddr_w19,
    output [9:0] sram_raddr_w20,
    output [9:0] sram_raddr_w21,
    output [9:0] sram_raddr_w22,
    output [9:0] sram_raddr_w23,
    output [9:0] sram_raddr_w24,
    output [9:0] sram_raddr_w25,
    output [9:0] sram_raddr_w26,
    output [9:0] sram_raddr_w27,
    output [9:0] sram_raddr_w28,
    output [9:0] sram_raddr_w29,
    output [9:0] sram_raddr_w30,
    output [9:0] sram_raddr_w31,

    output [9:0] sram_raddr_d0,
    output [9:0] sram_raddr_d1,
    output [9:0] sram_raddr_d2,
    output [9:0] sram_raddr_d3,
    output [9:0] sram_raddr_d4,
    output [9:0] sram_raddr_d5,
    output [9:0] sram_raddr_d6,
    output [9:0] sram_raddr_d7,
    output [9:0] sram_raddr_d8,
    output [9:0] sram_raddr_d9,
    output [9:0] sram_raddr_d10,
    output [9:0] sram_raddr_d11,
    output [9:0] sram_raddr_d12,
    output [9:0] sram_raddr_d13,
    output [9:0] sram_raddr_d14,
    output [9:0] sram_raddr_d15,
    output [9:0] sram_raddr_d16,
    output [9:0] sram_raddr_d17,
    output [9:0] sram_raddr_d18,
    output [9:0] sram_raddr_d19,
    output [9:0] sram_raddr_d20,
    output [9:0] sram_raddr_d21,
    output [9:0] sram_raddr_d22,
    output [9:0] sram_raddr_d23,
    output [9:0] sram_raddr_d24,
    output [9:0] sram_raddr_d25,
    output [9:0] sram_raddr_d26,
    output [9:0] sram_raddr_d27,
    output [9:0] sram_raddr_d28,
    output [9:0] sram_raddr_d29,
    output [9:0] sram_raddr_d30,
    output [9:0] sram_raddr_d31,

    // Write control signals for SRAM
    output sram_write_enable_a0,
    output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a,
    output [5:0] sram_waddr_a,

    output sram_write_enable_b0,
    output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b,
    output [5:0] sram_waddr_b,

    output sram_write_enable_c0,
    output [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c,
    output [5:0] sram_waddr_c,
    
    output tpu_done                          // TPU operation done signal
);

// Local parameter for original data width
localparam ORI_WIDTH = DATA_WIDTH + DATA_WIDTH + 5; // Width of the original data including additional bits

// Internal signals
wire [6:0] addr_serial_num;                              // Serial address for selection
wire signed [ARRAY_SIZE*ORI_WIDTH-1:0] ori_data;       // Original data for quantization
wire signed [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] quantized_data; // Quantized output data

// Systolic control signals
wire alu_start;                                        // ALU start signal
wire [8:0] cycle_num;                                  // Number of cycles
wire [5:0] matrix_index;                               // Current matrix index
wire sram_write_enable;                                // SRAM write enable signal
wire [1:0] data_set;                                   // Data set selector

// Address selection module instantiation
addr_sel addr_sel_inst (
    .clk(clk),                                         // Clock signal
    .addr_serial_num(addr_serial_num),                // Serial address input

    // Output addresses for SRAM reads
    .sram_raddr_w0(sram_raddr_w0),
    .sram_raddr_w1(sram_raddr_w1),
    .sram_raddr_w2(sram_raddr_w2),
    .sram_raddr_w3(sram_raddr_w3),
    .sram_raddr_w4(sram_raddr_w4),
    .sram_raddr_w5(sram_raddr_w5),
    .sram_raddr_w6(sram_raddr_w6),
    .sram_raddr_w7(sram_raddr_w7),
    .sram_raddr_w8(sram_raddr_w8),
    .sram_raddr_w9(sram_raddr_w9),
    .sram_raddr_w10(sram_raddr_w10),
    .sram_raddr_w11(sram_raddr_w11),
    .sram_raddr_w12(sram_raddr_w12),
    .sram_raddr_w13(sram_raddr_w13),
    .sram_raddr_w14(sram_raddr_w14),
    .sram_raddr_w15(sram_raddr_w15),
    .sram_raddr_w16(sram_raddr_w16),
    .sram_raddr_w17(sram_raddr_w17),
    .sram_raddr_w18(sram_raddr_w18),
    .sram_raddr_w19(sram_raddr_w19),
    .sram_raddr_w20(sram_raddr_w20),
    .sram_raddr_w21(sram_raddr_w21),
    .sram_raddr_w22(sram_raddr_w22),
    .sram_raddr_w23(sram_raddr_w23),
    .sram_raddr_w24(sram_raddr_w24),
    .sram_raddr_w25(sram_raddr_w25),
    .sram_raddr_w26(sram_raddr_w26),
    .sram_raddr_w27(sram_raddr_w27),
    .sram_raddr_w28(sram_raddr_w28),
    .sram_raddr_w29(sram_raddr_w29),
    .sram_raddr_w30(sram_raddr_w30),
    .sram_raddr_w31(sram_raddr_w31),

    .sram_raddr_d0(sram_raddr_d0),
    .sram_raddr_d1(sram_raddr_d1),
    .sram_raddr_d2(sram_raddr_d2),
    .sram_raddr_d3(sram_raddr_d3),
    .sram_raddr_d4(sram_raddr_d4),
    .sram_raddr_d5(sram_raddr_d5),
    .sram_raddr_d6(sram_raddr_d6),
    .sram_raddr_d7(sram_raddr_d7),
    .sram_raddr_d8(sram_raddr_d8),
    .sram_raddr_d9(sram_raddr_d9),
    .sram_raddr_d10(sram_raddr_d10),
    .sram_raddr_d11(sram_raddr_d11),
    .sram_raddr_d12(sram_raddr_d12),
    .sram_raddr_d13(sram_raddr_d13),
    .sram_raddr_d14(sram_raddr_d14),
    .sram_raddr_d15(sram_raddr_d15),
    .sram_raddr_d16(sram_raddr_d16),
    .sram_raddr_d17(sram_raddr_d17),
    .sram_raddr_d18(sram_raddr_d18),
    .sram_raddr_d19(sram_raddr_d19),
    .sram_raddr_d20(sram_raddr_d20),
    .sram_raddr_d21(sram_raddr_d21),
    .sram_raddr_d22(sram_raddr_d22),
    .sram_raddr_d23(sram_raddr_d23),
    .sram_raddr_d24(sram_raddr_d24),
    .sram_raddr_d25(sram_raddr_d25),
    .sram_raddr_d26(sram_raddr_d26),
    .sram_raddr_d27(sram_raddr_d27),
    .sram_raddr_d28(sram_raddr_d28),
    .sram_raddr_d29(sram_raddr_d29),
    .sram_raddr_d30(sram_raddr_d30),
    .sram_raddr_d31(sram_raddr_d31)
);

//Quantization module instantiation
quantize #(
    .ARRAY_SIZE(ARRAY_SIZE),
    .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
) quantize_inst (
    .ori_data(ori_data),                             // Input original data
    .quantized_data(quantized_data)                 // Output quantized data
);

// Systolic array module instantiation
systolic #(
    .ARRAY_SIZE(ARRAY_SIZE),
    .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) systolic_inst (
    .clk(clk),                                       // Clock signal
    .rst_n(srstn),                                   // Reset signal
    .alu_start(alu_start),                           // ALU start signal
    .cycle_num(cycle_num),                           // Cycle count

    // Input data from SRAM for weights and data
    .sram_rdata_w0(sram_rdata_w0),
    .sram_rdata_w1(sram_rdata_w1),
    .sram_rdata_w2(sram_rdata_w2),
    .sram_rdata_w3(sram_rdata_w3),
    .sram_rdata_w4(sram_rdata_w4),
    .sram_rdata_w5(sram_rdata_w5),
    .sram_rdata_w6(sram_rdata_w6),
    .sram_rdata_w7(sram_rdata_w7),
    .sram_rdata_w8(sram_rdata_w8),
    .sram_rdata_w9(sram_rdata_w9),
    .sram_rdata_w10(sram_rdata_w10),
    .sram_rdata_w11(sram_rdata_w11),
    .sram_rdata_w12(sram_rdata_w12),
    .sram_rdata_w13(sram_rdata_w13),
    .sram_rdata_w14(sram_rdata_w14),
    .sram_rdata_w15(sram_rdata_w15),
    .sram_rdata_w16(sram_rdata_w16),
    .sram_rdata_w17(sram_rdata_w17),
    .sram_rdata_w18(sram_rdata_w18),
    .sram_rdata_w19(sram_rdata_w19),
    .sram_rdata_w20(sram_rdata_w20),
    .sram_rdata_w21(sram_rdata_w21),
    .sram_rdata_w22(sram_rdata_w22),
    .sram_rdata_w23(sram_rdata_w23),
    .sram_rdata_w24(sram_rdata_w24),
    .sram_rdata_w25(sram_rdata_w25),
    .sram_rdata_w26(sram_rdata_w26),
    .sram_rdata_w27(sram_rdata_w27),
    .sram_rdata_w28(sram_rdata_w28),
    .sram_rdata_w29(sram_rdata_w29),
    .sram_rdata_w30(sram_rdata_w30),
    .sram_rdata_w31(sram_rdata_w31),

    .sram_rdata_d0(sram_rdata_d0),
    .sram_rdata_d1(sram_rdata_d1),
    .sram_rdata_d2(sram_rdata_d2),
    .sram_rdata_d3(sram_rdata_d3),
    .sram_rdata_d4(sram_rdata_d4),
    .sram_rdata_d5(sram_rdata_d5),
    .sram_rdata_d6(sram_rdata_d6),
    .sram_rdata_d7(sram_rdata_d7),
    .sram_rdata_d8(sram_rdata_d8),
    .sram_rdata_d9(sram_rdata_d9),
    .sram_rdata_d10(sram_rdata_d10),
    .sram_rdata_d11(sram_rdata_d11),
    .sram_rdata_d12(sram_rdata_d12),
    .sram_rdata_d13(sram_rdata_d13),
    .sram_rdata_d14(sram_rdata_d14),
    .sram_rdata_d15(sram_rdata_d15),
    .sram_rdata_d16(sram_rdata_d16),
    .sram_rdata_d17(sram_rdata_d17),
    .sram_rdata_d18(sram_rdata_d18),
    .sram_rdata_d19(sram_rdata_d19),
    .sram_rdata_d20(sram_rdata_d20),
    .sram_rdata_d21(sram_rdata_d21),
    .sram_rdata_d22(sram_rdata_d22),
    .sram_rdata_d23(sram_rdata_d23),
    .sram_rdata_d24(sram_rdata_d24),
    .sram_rdata_d25(sram_rdata_d25),
    .sram_rdata_d26(sram_rdata_d26),
    .sram_rdata_d27(sram_rdata_d27),
    .sram_rdata_d28(sram_rdata_d28),
    .sram_rdata_d29(sram_rdata_d29),
    .sram_rdata_d30(sram_rdata_d30),
    .sram_rdata_d31(sram_rdata_d31),

    .matrix_index(matrix_index),                     // Current matrix index
    
    // Output original data after multiplication
    .mul_outcome(ori_data)
);

// Systolic controller module instantiation
systolic_controller #(
    .ARRAY_SIZE(ARRAY_SIZE)
) systolic_controller_inst (
    .clk(clk),                                       // Clock signal
    .rst_n(srstn),                                   // Reset signal
    .tpu_start(tpu_start),                           // Start signal for TPU

    // Output signals from controller
    .sram_write_enable(sram_write_enable),           // SRAM write enable signal
    .addr_serial_num(addr_serial_num),               // Serial address for selection
    .alu_start(alu_start),                           // ALU start signal
    .cycle_num(cycle_num),                           // Cycle count
    .matrix_index(matrix_index),                     // Current matrix index
    .data_set(data_set),                             // Data set selector
    .tpu_done(tpu_done)                             // TPU done signal
);

// Write-out module instantiation
write_out #(
    .ARRAY_SIZE(ARRAY_SIZE),
    .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
) write_out_inst (
    .clk(clk),                                       // Clock signal
    .srstn(srstn),                                   // Reset signal
    .sram_write_enable(sram_write_enable),          // SRAM write enable signal
    .data_set(data_set),                             // Data set selector
    .matrix_index(matrix_index),                     // Current matrix index
    .quantized_data(quantized_data),                 // Input quantized data

    // Output write control signals for SRAM
    .sram_write_enable_a0(sram_write_enable_a0),
    .sram_wdata_a(sram_wdata_a),
    .sram_waddr_a(sram_waddr_a),

    .sram_write_enable_b0(sram_write_enable_b0),
    .sram_wdata_b(sram_wdata_b),
    .sram_waddr_b(sram_waddr_b),

    .sram_write_enable_c0(sram_write_enable_c0),
    .sram_wdata_c(sram_wdata_c),
    .sram_waddr_c(sram_waddr_c)
);

endmodule