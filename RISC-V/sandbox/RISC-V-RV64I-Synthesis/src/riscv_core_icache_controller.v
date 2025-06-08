module riscv_core_icache_controller (
	i_clk,
	i_rst_n,
	i_addr_from_core,
	o_stall,
	o_rd_en,
	o_wr_en,
	o_block_replace,
	o_addr_from_control_to_axi,
	o_mem_req,
	i_mem_done,
	o_offset
);
	reg _sv2v_0;
	parameter BLOCK_OFFSET_WIDTH = 2;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 52;
	parameter CORE_DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 64;
	parameter AXI_DATA_WIDTH = 256;
	input wire i_clk;
	input wire i_rst_n;
	input wire [ADDR_WIDTH - 1:0] i_addr_from_core;
	output reg o_stall;
	output reg o_rd_en;
	output reg o_wr_en;
	output reg o_block_replace;
	output reg [ADDR_WIDTH - 1:0] o_addr_from_control_to_axi;
	output reg o_mem_req;
	input wire i_mem_done;
	output reg o_offset;
	localparam CACHE_DEPTH = 2 ** INDEX_WIDTH;
	reg [TAG_WIDTH - 1:0] TAG_MEM [0:CACHE_DEPTH - 1];
	reg VALID_MEM [0:CACHE_DEPTH - 1];
	reg [1:0] STATE;
	reg [1:0] NEXT;
	reg update_en;
	wire tag_hit_1;
	wire tag_hit_2;
	wire over_f;
	wire s1;
	wire s2;
	wire miss;
	wire [ADDR_WIDTH - 1:0] i_addr_from_core_next_block;
	always @(posedge i_clk or negedge i_rst_n) begin : NEXT_STATE_ASSIGN_FLUSH_UPDATE_BLOCK
		if (!i_rst_n) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < CACHE_DEPTH; i = i + 1)
					VALID_MEM[i] = 0;
			end
			STATE <= 2'b00;
		end
		else begin
			STATE <= NEXT;
			if (update_en) begin
				if (s1) begin
					TAG_MEM[i_addr_from_core[11:5]] <= i_addr_from_core[63:12];
					VALID_MEM[i_addr_from_core[11:5]] <= 1'b1;
				end
				else if (s2) begin
					TAG_MEM[i_addr_from_core_next_block[11:5]] <= i_addr_from_core_next_block[63:12];
					VALID_MEM[i_addr_from_core_next_block[11:5]] <= 1'b1;
				end
			end
		end
	end
	assign tag_hit_1 = (TAG_MEM[i_addr_from_core[11:5]] == i_addr_from_core[63:12]) && VALID_MEM[i_addr_from_core[11:5]];
	assign over_f = (i_addr_from_core[4:2] == 3'b111) && (i_addr_from_core[1:0] == 2'b10);
	assign i_addr_from_core_next_block = i_addr_from_core + 2'b10;
	assign tag_hit_2 = (TAG_MEM[i_addr_from_core_next_block[11:5]] == i_addr_from_core_next_block[63:12]) && VALID_MEM[i_addr_from_core_next_block[11:5]];
	assign s1 = !tag_hit_1;
	assign s2 = over_f && !tag_hit_2;
	assign miss = s1 || s2;
	always @(*) begin : FSM_TRANSITION_BLOCK
		if (_sv2v_0)
			;
		o_rd_en = 0;
		o_wr_en = 0;
		o_block_replace = 0;
		o_stall = 0;
		o_addr_from_control_to_axi = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		o_mem_req = 0;
		update_en = 0;
		o_offset = 0;
		NEXT = STATE;
		case (STATE)
			2'b00: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 0;
				o_mem_req = 0;
				update_en = 0;
				if (!miss)
					o_rd_en = 1;
				else begin
					o_stall = 1;
					o_mem_req = 1;
					if (s1)
						o_addr_from_control_to_axi = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
					else if (s2)
						o_addr_from_control_to_axi = {i_addr_from_core_next_block[63:12], i_addr_from_core_next_block[11:5], 5'b00000};
					NEXT = 2'b01;
				end
			end
			2'b01: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 1;
				if (s1)
					o_addr_from_control_to_axi = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				else if (s2)
					o_addr_from_control_to_axi = {i_addr_from_core_next_block[63:12], i_addr_from_core_next_block[11:5], 5'b00000};
				o_mem_req = 1;
				update_en = 0;
				if (i_mem_done) begin
					o_mem_req = 0;
					NEXT = 2'b10;
				end
			end
			2'b10: begin
				o_rd_en = 0;
				o_wr_en = 1;
				o_block_replace = 1;
				if (s1)
					o_offset = 0;
				else if (s2)
					o_offset = 1'b1;
				else
					o_offset = 0;
				o_stall = 1;
				o_addr_from_control_to_axi = 64'b0000000000000000000000000000000000000000000000000000000000000000;
				o_mem_req = 0;
				update_en = 1;
				NEXT = 2'b00;
			end
			default: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 0;
				o_addr_from_control_to_axi = 64'b0000000000000000000000000000000000000000000000000000000000000000;
				o_mem_req = 0;
				update_en = 0;
				NEXT = 2'b00;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
