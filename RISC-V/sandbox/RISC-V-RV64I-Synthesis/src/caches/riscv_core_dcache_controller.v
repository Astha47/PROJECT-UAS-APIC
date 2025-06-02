module riscv_core_dcache_controller (
	i_clk,
	i_rst_n,
	i_data_from_core,
	i_addr_from_core,
	i_read,
	i_write,
	i_size,
	o_stall,
	o_store_fault,
	o_load_fault,
	o_rd_en,
	o_wr_en,
	o_block_replace,
	o_mem_read_address,
	o_mem_read_req,
	i_mem_read_done,
	i_mem_write_done,
	o_mem_write_valid,
	o_mem_write_data,
	o_mem_write_address,
	o_mem_write_strobe
);
	reg _sv2v_0;
	parameter BLOCK_OFFSET = 2;
	parameter INDEX_WIDTH = 7;
	parameter TAG_WIDTH = 52;
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
	output reg o_stall;
	output wire o_store_fault;
	output wire o_load_fault;
	output reg o_rd_en;
	output reg o_wr_en;
	output reg o_block_replace;
	output reg [ADDR_WIDTH - 1:0] o_mem_read_address;
	output reg o_mem_read_req;
	input wire i_mem_read_done;
	input wire i_mem_write_done;
	output reg o_mem_write_valid;
	output reg [CORE_DATA_WIDTH - 1:0] o_mem_write_data;
	output reg [ADDR_WIDTH - 1:0] o_mem_write_address;
	output reg [7:0] o_mem_write_strobe;
	localparam CACHE_DEPTH = 2 ** INDEX_WIDTH;
	reg [TAG_WIDTH - 1:0] TAG_MEM [0:CACHE_DEPTH - 1];
	reg VALID_MEM [0:CACHE_DEPTH - 1];
	reg [1:0] STATE;
	reg [1:0] NEXT;
	reg update_en;
	wire tag_hit;
	reg fault;
	always @(posedge i_clk or negedge i_rst_n) begin : NEXT_STATE_ASSIGN_FLUSH_UPDATE_BLOCK
		if (!i_rst_n) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < CACHE_DEPTH; i = i + 1)
					VALID_MEM[i] <= 0;
			end
			STATE <= 2'b00;
		end
		else begin
			STATE <= NEXT;
			if (update_en) begin
				TAG_MEM[i_addr_from_core[11:5]] <= i_addr_from_core[63:12];
				VALID_MEM[i_addr_from_core[11:5]] <= 1'b1;
			end
		end
	end
	assign tag_hit = (TAG_MEM[i_addr_from_core[11:5]] == i_addr_from_core[63:12]) && VALID_MEM[i_addr_from_core[11:5]];
	always @(*) begin : FSM_TRANSITION_BLOCK
		if (_sv2v_0)
			;
		o_rd_en = 0;
		o_wr_en = 0;
		o_block_replace = 0;
		o_stall = 0;
		o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
		o_mem_read_req = 0;
		update_en = 0;
		o_mem_write_data = i_data_from_core;
		o_mem_write_address = i_addr_from_core;
		o_mem_write_valid = 0;
		NEXT = STATE;
		case (STATE)
			2'b00: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 0;
				o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				o_mem_read_req = 0;
				update_en = 0;
				o_mem_write_data = i_data_from_core;
				o_mem_write_address = i_addr_from_core;
				o_mem_write_valid = 0;
				if (i_read) begin
					if (tag_hit) begin
						if (!fault)
							o_rd_en = 1;
						else
							o_rd_en = 0;
					end
					else begin
						o_stall = 1;
						o_mem_read_req = 1;
						o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
						NEXT = 2'b01;
					end
				end
				else if (i_write) begin
					if (tag_hit) begin
						if (!fault) begin
							o_wr_en = 1;
							o_mem_write_valid = 1;
							o_stall = 1;
							NEXT = 2'b11;
						end
						else
							o_wr_en = 0;
					end
					else begin
						o_stall = 1;
						o_mem_read_req = 1;
						o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
						NEXT = 2'b01;
					end
				end
			end
			2'b01: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 1;
				o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				o_mem_read_req = 1;
				update_en = 0;
				o_mem_write_data = i_data_from_core;
				o_mem_write_address = i_addr_from_core;
				o_mem_write_valid = 0;
				if (i_mem_read_done) begin
					o_mem_read_req = 0;
					NEXT = 2'b10;
				end
			end
			2'b10: begin
				o_rd_en = 0;
				o_wr_en = 1;
				o_block_replace = 1;
				o_stall = 1;
				o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				o_mem_read_req = 0;
				update_en = 1;
				o_mem_write_data = i_data_from_core;
				o_mem_write_address = i_addr_from_core;
				o_mem_write_valid = 0;
				NEXT = 2'b00;
			end
			2'b11: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 1;
				o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				o_mem_read_req = 0;
				update_en = 0;
				o_mem_write_data = i_data_from_core;
				o_mem_write_address = i_addr_from_core;
				o_mem_write_valid = 1;
				if (i_mem_write_done) begin
					o_mem_write_valid = 0;
					o_stall = 0;
					NEXT = 2'b00;
				end
			end
			default: begin
				o_rd_en = 0;
				o_wr_en = 0;
				o_block_replace = 0;
				o_stall = 0;
				o_mem_read_address = {i_addr_from_core[63:12], i_addr_from_core[11:5], 5'b00000};
				o_mem_read_req = 0;
				update_en = 0;
				NEXT = 2'b00;
				o_mem_write_data = i_data_from_core;
				o_mem_write_address = i_addr_from_core;
				o_mem_write_valid = 0;
			end
		endcase
	end
	always @(*) begin : FAULT_DETECTION
		if (_sv2v_0)
			;
		fault = 1'b0;
		case (i_size)
			2'b00: fault = 1'b0;
			2'b01:
				if (i_addr_from_core[2:0] == 3'b111)
					fault = 1'b1;
				else
					fault = 1'b0;
			2'b10:
				if (((i_addr_from_core[2:0] == 3'b111) || (i_addr_from_core[2:0] == 3'b110)) || (i_addr_from_core[2:0] == 3'b101))
					fault = 1'b1;
				else
					fault = 1'b0;
			2'b11:
				if (i_addr_from_core[2:0] == 3'b000)
					fault = 1'b0;
				else
					fault = 1'b1;
			default: fault = 1'b0;
		endcase
	end
	assign o_load_fault = fault & i_read;
	assign o_store_fault = fault & i_write;
	always @(*) begin : mem_write_strobe_decoder
		if (_sv2v_0)
			;
		o_mem_write_strobe = 8'b00000000;
		case (i_size)
			2'b00: o_mem_write_strobe = 8'b00000001;
			2'b01: o_mem_write_strobe = 8'b00000011;
			2'b10: o_mem_write_strobe = 8'b00001111;
			2'b11: o_mem_write_strobe = 8'b11111111;
			default: o_mem_write_strobe = 8'b00000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
