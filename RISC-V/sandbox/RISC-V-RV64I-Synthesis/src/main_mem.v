module main_mem (
	i_clk,
	i_rst_n,
	i_mem_read_address,
	i_mem_read_req,
	o_mem_read_done,
	o_cache_line,
	o_mem_write_done,
	i_mem_write_valid,
	i_mem_write_data,
	i_mem_write_address,
	i_write_strobe
);
	parameter MEM_DEPTH = 12;
	parameter DATA_WIDTH = 64;
	parameter ADDR_WIDTH = 64;
	parameter CACHE_LINE_WIDTH = 256;
	input wire i_clk;
	input wire i_rst_n;
	input wire [ADDR_WIDTH - 1:0] i_mem_read_address;
	input wire i_mem_read_req;
	output reg o_mem_read_done;
	output reg [CACHE_LINE_WIDTH - 1:0] o_cache_line;
	output reg o_mem_write_done;
	input wire i_mem_write_valid;
	input wire [DATA_WIDTH - 1:0] i_mem_write_data;
	input wire [ADDR_WIDTH - 1:0] i_mem_write_address;
	input wire [7:0] i_write_strobe;
	localparam MEM_SIZE = 2 ** MEM_DEPTH;
	(* ram_style = "block" *) reg [63:0] MEM [0:MEM_SIZE - 1];
	always @(posedge i_clk) begin : BLOCK_READ_and_DATA_WRITE
		o_mem_read_done <= 0;
		o_mem_write_done <= 0;
		if (i_mem_read_req) begin
			o_cache_line <= {MEM[i_mem_read_address[14:3] + 3], MEM[i_mem_read_address[14:3] + 2], MEM[i_mem_read_address[14:3] + 1], MEM[i_mem_read_address[14:3] + 0]};
			o_mem_read_done <= 1;
		end
		else if (i_mem_write_valid) begin
			if (i_write_strobe[0])
				MEM[i_mem_write_address[14:3]][7:0] <= i_mem_write_data[7:0];
			if (i_write_strobe[1])
				MEM[i_mem_write_address[14:3]][15:8] <= i_mem_write_data[15:8];
			if (i_write_strobe[2])
				MEM[i_mem_write_address[14:3]][23:16] <= i_mem_write_data[23:16];
			if (i_write_strobe[3])
				MEM[i_mem_write_address[14:3]][31:24] <= i_mem_write_data[31:24];
			if (i_write_strobe[4])
				MEM[i_mem_write_address[14:3]][39:32] <= i_mem_write_data[39:32];
			if (i_write_strobe[5])
				MEM[i_mem_write_address[14:3]][47:40] <= i_mem_write_data[47:40];
			if (i_write_strobe[6])
				MEM[i_mem_write_address[14:3]][55:48] <= i_mem_write_data[55:48];
			if (i_write_strobe[7])
				MEM[i_mem_write_address[14:3]][63:56] <= i_mem_write_data[63:56];
			o_mem_write_done <= 1;
		end
	end
endmodule
