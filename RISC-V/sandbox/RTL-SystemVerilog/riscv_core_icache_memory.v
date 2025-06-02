module riscv_core_icache_memory (
	i_clk,
	i_rst_n,
	i_addr_from_core,
	o_data_to_core,
	i_block_from_axi,
	i_rd_en,
	i_wr_en,
	i_block_replace,
	i_offset
);
	reg _sv2v_0;
	parameter BLOCK_OFFSET_WIDTH = 3;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 52;
	parameter CORE_DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 64;
	parameter AXI_DATA_WIDTH = 256;
	input wire i_clk;
	input wire i_rst_n;
	input wire [ADDR_WIDTH - 1:0] i_addr_from_core;
	output reg [CORE_DATA_WIDTH - 1:0] o_data_to_core;
	input wire [AXI_DATA_WIDTH - 1:0] i_block_from_axi;
	input wire i_rd_en;
	input wire i_wr_en;
	input wire i_block_replace;
	input wire i_offset;
	localparam CACHE_DEPTH = 2 ** INDEX_WIDTH;
	localparam BLOCK_SIZE = 2 ** BLOCK_OFFSET_WIDTH;
	wire [ADDR_WIDTH - 1:0] i_addr_from_core_1;
	wire [ADDR_WIDTH - 1:0] i_addr_from_core_2;
	wire [ADDR_WIDTH - 1:0] i_addr_from_core_3;
	reg [((BLOCK_SIZE * 4) * 8) - 1:0] INSTR_MEM [0:CACHE_DEPTH - 1];
	assign i_addr_from_core_1 = i_addr_from_core + 1'b1;
	assign i_addr_from_core_2 = i_addr_from_core + 2'b10;
	assign i_addr_from_core_3 = i_addr_from_core + 2'b11;
	always @(posedge i_clk or negedge i_rst_n) begin : FLUSH_WRITE_REPLACEMENT_BLOCK
		if (!i_rst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < CACHE_DEPTH; i = i + 1)
				INSTR_MEM[i] <= 'b0;
		end
		else if (i_wr_en && i_block_replace) begin
			if (!i_offset)
				INSTR_MEM[i_addr_from_core[11:5]] <= i_block_from_axi;
			else
				INSTR_MEM[i_addr_from_core_2[11:5]] <= i_block_from_axi;
		end
	end
	always @(*) begin : READ_MEMORY_BLOCK
		if (_sv2v_0)
			;
		o_data_to_core = 'b0;
		if (i_rd_en)
			o_data_to_core = {INSTR_MEM[i_addr_from_core_3[11:5]][((i_addr_from_core_3[4:2] * 4) + i_addr_from_core_3[1:0]) * 8+:8], INSTR_MEM[i_addr_from_core_2[11:5]][((i_addr_from_core_2[4:2] * 4) + i_addr_from_core_2[1:0]) * 8+:8], INSTR_MEM[i_addr_from_core_1[11:5]][((i_addr_from_core_1[4:2] * 4) + i_addr_from_core_1[1:0]) * 8+:8], INSTR_MEM[i_addr_from_core[11:5]][((i_addr_from_core[4:2] * 4) + i_addr_from_core[1:0]) * 8+:8]};
	end
	initial _sv2v_0 = 0;
endmodule
