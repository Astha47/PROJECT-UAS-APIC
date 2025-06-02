module riscv_core_dcache_memory (
	i_clk,
	i_rst_n,
	i_addr_from_core,
	i_data_from_core,
	i_size,
	o_data_to_core,
	i_block_from_axi,
	i_rd_en,
	i_wr_en,
	i_block_replace
);
	reg _sv2v_0;
	parameter BLOCK_OFFSET = 2;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 52;
	parameter CORE_DATA_WIDTH = 64;
	parameter ADDR_WIDTH = 64;
	parameter AXI_DATA_WIDTH = 256;
	parameter FIFO_ENTRY_WIDTH = 128;
	input wire i_clk;
	input wire i_rst_n;
	input wire [ADDR_WIDTH - 1:0] i_addr_from_core;
	input wire [CORE_DATA_WIDTH - 1:0] i_data_from_core;
	input wire [1:0] i_size;
	output reg [CORE_DATA_WIDTH - 1:0] o_data_to_core;
	input wire [AXI_DATA_WIDTH - 1:0] i_block_from_axi;
	input wire i_rd_en;
	input wire i_wr_en;
	input wire i_block_replace;
	localparam CACHE_DEPTH = 2 ** INDEX_WIDTH;
	localparam BLOCK_SIZE = 2 ** BLOCK_OFFSET;
	reg [((BLOCK_SIZE * 8) * 8) - 1:0] DATA_MEM [0:CACHE_DEPTH - 1];
	always @(posedge i_clk or negedge i_rst_n) begin : FLUSH_WRITE_REPLACEMENT_BLOCK
		if (!i_rst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < CACHE_DEPTH; i = i + 1)
				DATA_MEM[i] <= 'b0;
		end
		else if (i_wr_en && i_block_replace)
			DATA_MEM[i_addr_from_core[11:5]] <= i_block_from_axi;
		else if (i_wr_en && !i_block_replace)
			(* full_case, parallel_case *)
			case (i_size)
				2'b00: DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8] <= i_data_from_core[7:0];
				2'b01: {DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 1)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8]} <= i_data_from_core[15:0];
				2'b10: {DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 3)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 2)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 1)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8]} <= i_data_from_core[31:0];
				2'b11: DATA_MEM[i_addr_from_core[11:5]][8 * (i_addr_from_core[4:3] * 8)+:64] <= i_data_from_core;
			endcase
	end
	always @(*) begin : READ_MEMORY_BLOCK
		if (_sv2v_0)
			;
		o_data_to_core = 'b0;
		if (i_rd_en)
			(* full_case, parallel_case *)
			case (i_size)
				2'b00: o_data_to_core = DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8];
				2'b01: o_data_to_core = {DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 1)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8]};
				2'b10: o_data_to_core = {DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 3)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 2)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + (i_addr_from_core[2:0] + 1)) * 8+:8], DATA_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:3] * 8) + i_addr_from_core[2:0]) * 8+:8]};
				2'b11: o_data_to_core = DATA_MEM[i_addr_from_core[11:5]][8 * (i_addr_from_core[4:3] * 8)+:64];
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
