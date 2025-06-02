module data_mem_top (
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
	output wire o_mem_read_done;
	output wire [CACHE_LINE_WIDTH - 1:0] o_cache_line;
	output wire o_mem_write_done;
	input wire i_mem_write_valid;
	input wire [DATA_WIDTH - 1:0] i_mem_write_data;
	input wire [ADDR_WIDTH - 1:0] i_mem_write_address;
	input wire [7:0] i_write_strobe;
	wire [DATA_WIDTH - 1:0] shifted_data;
	wire shifted_mem_write_req;
	mem_shifter u_mem_shifter(
		.i_write_strobe(i_write_strobe),
		.i_mem_write_req(i_mem_write_valid),
		.i_data(i_mem_write_data),
		.o_data(shifted_data),
		.o_mem_write_req(shifted_mem_write_req)
	);
	main_mem u_main_mem(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_mem_read_address(i_mem_read_address),
		.i_mem_read_req(i_mem_read_req),
		.o_mem_read_done(o_mem_read_done),
		.o_cache_line(o_cache_line),
		.o_mem_write_done(o_mem_write_done),
		.i_mem_write_valid(shifted_mem_write_req),
		.i_mem_write_data(shifted_data),
		.i_mem_write_address(i_mem_write_address),
		.i_write_strobe(i_write_strobe)
	);
endmodule
