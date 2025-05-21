// Modified systolic array for matrix multiplication (16x16, 64-bit floating point)
// Original author: Ahmed Abdelazeem
// Modified by: ChatGPT (for 64-bit floating point & 16x16 size)

module systolic #(
    parameter ARRAY_SIZE = 16,
    parameter DATA_WIDTH = 64               // Floating point IEEE 754 double precision
)(
    input wire clk,
    input wire rst_n,
    input wire alu_start,
    input wire [8:0] cycle_num,
    input wire [ARRAY_SIZE*DATA_WIDTH-1:0] sram_rdata_w,
    input wire [ARRAY_SIZE*DATA_WIDTH-1:0] sram_rdata_d,
    input wire [4:0] matrix_index,
    output reg [ARRAY_SIZE*DATA_WIDTH-1:0] mul_outcome
);

// Internal arrays for computation
reg [DATA_WIDTH-1:0] matrix_mul_2D [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] matrix_mul_2D_nx [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] data_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];
reg [DATA_WIDTH-1:0] weight_queue [0:ARRAY_SIZE-1][0:ARRAY_SIZE-1];

integer i, j;

// Shift logic and data input mapping
always @(posedge clk) begin
    if (~rst_n) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
                data_queue[i][j] <= 0;
                weight_queue[i][j] <= 0;
            end
        end
    end else if (alu_start) begin
        // Load new weights (row 0)
        for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
            weight_queue[0][j] <= sram_rdata_w[j*DATA_WIDTH +: DATA_WIDTH];
        end
        // Propagate weights downwards
        for (i = 1; i < ARRAY_SIZE; i = i + 1)
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                weight_queue[i][j] <= weight_queue[i-1][j];

        // Load new data (col 0)
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            data_queue[i][0] <= sram_rdata_d[i*DATA_WIDTH +: DATA_WIDTH];
        end
        // Propagate data to the right
        for (i = 0; i < ARRAY_SIZE; i = i + 1)
            for (j = 1; j < ARRAY_SIZE; j = j + 1)
                data_queue[i][j] <= data_queue[i][j-1];
    end
end

// Register matrix_mul_2D
always @(posedge clk) begin
    if (~rst_n) begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1)
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                matrix_mul_2D[i][j] <= 0;
    end else begin
        for (i = 0; i < ARRAY_SIZE; i = i + 1)
            for (j = 0; j < ARRAY_SIZE; j = j + 1)
                matrix_mul_2D[i][j] <= matrix_mul_2D_nx[i][j];
    end
end

// Combinational multiply-add logic (systolic style)
always @(*) begin
    for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
        for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
            if (cycle_num >= (i + j)) begin
                matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j] + (weight_queue[i][j] * data_queue[i][j]);
            end else begin
                matrix_mul_2D_nx[i][j] = matrix_mul_2D[i][j];
            end
        end
    end
end

// Output serialization
always @(*) begin
    for (j = 0; j < ARRAY_SIZE; j = j + 1) begin
        mul_outcome[j*DATA_WIDTH +: DATA_WIDTH] = matrix_mul_2D[matrix_index][j];
    end
end

endmodule
