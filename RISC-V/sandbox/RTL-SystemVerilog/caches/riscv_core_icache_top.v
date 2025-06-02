module riscv_core_icache_top (
	i_clk,
	i_rst_n,
	i_addr_from_core,
	o_stall,
	o_data_to_core,
	o_addr_from_control_to_axi,
	o_mem_req,
	i_mem_done,
	i_block_from_axi
);
	parameter BLOCK_OFFSET_WIDTH = 2;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 20;
	parameter CORE_DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 64;
	parameter AXI_DATA_WIDTH = 256;
	input wire i_clk;
	input wire i_rst_n;
	input wire [ADDR_WIDTH - 1:0] i_addr_from_core;
	output wire o_stall;
	output wire [CORE_DATA_WIDTH - 1:0] o_data_to_core;
	output wire [ADDR_WIDTH - 1:0] o_addr_from_control_to_axi;
	output wire o_mem_req;
	input wire i_mem_done;
	input wire [AXI_DATA_WIDTH - 1:0] i_block_from_axi;
	wire control_to_mem_rd_en;
	wire control_to_mem_wr_en;
	wire control_to_mem_block_replace;
	wire control_to_mem_offset;
	riscv_core_icache_controller #(.TAG_WIDTH(TAG_WIDTH)) icache_controller(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_addr_from_core(i_addr_from_core),
		.o_stall(o_stall),
		.o_rd_en(control_to_mem_rd_en),
		.o_wr_en(control_to_mem_wr_en),
		.o_block_replace(control_to_mem_block_replace),
		.o_addr_from_control_to_axi(o_addr_from_control_to_axi),
		.o_mem_req(o_mem_req),
		.i_mem_done(i_mem_done),
		.o_offset(control_to_mem_offset)
	);
	riscv_core_icache_memory #(.TAG_WIDTH(TAG_WIDTH)) icache_memory(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_addr_from_core(i_addr_from_core),
		.o_data_to_core(o_data_to_core),
		.i_block_from_axi(i_block_from_axi),
		.i_rd_en(control_to_mem_rd_en),
		.i_wr_en(control_to_mem_wr_en),
		.i_block_replace(control_to_mem_block_replace),
		.i_offset(control_to_mem_offset)
	);
endmodule
