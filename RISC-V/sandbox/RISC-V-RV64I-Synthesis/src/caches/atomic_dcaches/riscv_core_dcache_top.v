module riscv_core_dcache_top (
	i_clk,
	i_rst_n,
	i_data_from_core,
	i_addr_from_core,
	i_read,
	i_write,
	i_size,
	i_amo_op,
	i_amo,
	i_lr,
	i_sc,
	o_stall,
	o_data_to_core,
	o_store_fault,
	o_load_fault,
	o_amo_fault,
	o_mem_read_address,
	o_mem_read_req,
	i_mem_read_done,
	i_block_from_axi,
	i_mem_write_done,
	o_mem_write_valid,
	o_mem_write_data,
	o_mem_write_address,
	o_mem_write_strobe
);
	parameter BLOCK_OFFSET = 2;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 20;
	parameter CORE_DATA_WIDTH = 64;
	parameter ADDR_WIDTH = 64;
	parameter AXI_DATA_WIDTH = 256;
	input wire i_clk;
	input wire i_rst_n;
	input wire [CORE_DATA_WIDTH - 1:0] i_data_from_core;
	input wire [ADDR_WIDTH - 1:0] i_addr_from_core;
	input wire i_read;
	input wire i_write;
	input wire [1:0] i_size;
	input wire [3:0] i_amo_op;
	input wire i_amo;
	input wire i_lr;
	input wire i_sc;
	output wire o_stall;
	output wire [CORE_DATA_WIDTH - 1:0] o_data_to_core;
	output wire o_store_fault;
	output wire o_load_fault;
	output wire o_amo_fault;
	output wire [ADDR_WIDTH - 1:0] o_mem_read_address;
	output wire o_mem_read_req;
	input wire i_mem_read_done;
	input wire [AXI_DATA_WIDTH - 1:0] i_block_from_axi;
	input wire i_mem_write_done;
	output wire o_mem_write_valid;
	output wire [CORE_DATA_WIDTH - 1:0] o_mem_write_data;
	output wire [ADDR_WIDTH - 1:0] o_mem_write_address;
	output wire [7:0] o_mem_write_strobe;
	wire control_to_mem_rd_en;
	wire control_to_mem_wr_en;
	wire control_to_mem_block_replace;
	wire control_to_mem_amo_wr;
	wire [CORE_DATA_WIDTH - 1:0] amo_alu_result;
	wire [CORE_DATA_WIDTH - 1:0] cache_mem_out;
	wire [CORE_DATA_WIDTH - 1:0] sc_out;
	riscv_core_dcache_controller #(.TAG_WIDTH(TAG_WIDTH)) dcache_controller(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_data_from_core(i_data_from_core),
		.i_addr_from_core(i_addr_from_core),
		.i_read(i_read),
		.i_write(i_write),
		.i_amo(i_amo),
		.i_amo_alu_result(amo_alu_result),
		.o_stall(o_stall),
		.o_rd_en(control_to_mem_rd_en),
		.o_wr_en(control_to_mem_wr_en),
		.o_block_replace(control_to_mem_block_replace),
		.o_amo_wr(control_to_mem_amo_wr),
		.o_mem_read_address(o_mem_read_address),
		.o_mem_read_req(o_mem_read_req),
		.i_mem_read_done(i_mem_read_done),
		.i_mem_write_done(i_mem_write_done),
		.o_mem_write_valid(o_mem_write_valid),
		.o_mem_write_address(o_mem_write_address),
		.o_mem_write_data(o_mem_write_data),
		.o_mem_write_strobe(o_mem_write_strobe),
		.o_store_fault(o_store_fault),
		.o_load_fault(o_load_fault),
		.o_amo_fault(o_amo_fault),
		.i_size(i_size),
		.i_sc(i_sc),
		.i_lr(i_lr),
		.o_sc_result(sc_out)
	);
	riscv_core_mux_2to1 dcache_mux(
		.i_input0(cache_mem_out),
		.i_input1(sc_out),
		.i_sel(i_sc),
		.o_mux_out(o_data_to_core)
	);
	riscv_core_amo_alu amo_alu(
		.i_data_from_mem(cache_mem_out),
		.i_data_from_core(i_data_from_core),
		.i_amo_op(i_amo_op),
		.o_amo_alu_result(amo_alu_result)
	);
	riscv_core_dcache_memory #(.TAG_WIDTH(TAG_WIDTH)) dcache_memory(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_data_from_core(i_data_from_core),
		.i_addr_from_core(i_addr_from_core),
		.i_size(i_size),
		.o_data_to_core(cache_mem_out),
		.i_block_from_axi(i_block_from_axi),
		.i_rd_en(control_to_mem_rd_en),
		.i_wr_en(control_to_mem_wr_en),
		.i_block_replace(control_to_mem_block_replace),
		.i_amo_alu_result(amo_alu_result),
		.i_amo_wr(control_to_mem_amo_wr)
	);
endmodule
