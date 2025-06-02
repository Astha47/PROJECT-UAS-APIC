module riscv_core_branch_prediction (
	i_clk,
	i_rst_n,
	i_if_pc,
	o_branch_target,
	o_branch_taken,
	o_branch_valid,
	i_ex_pc,
	i_update_branch_target,
	i_valid_branch_update,
	i_valid_branch_taken_update,
	i_jump
);
	reg _sv2v_0;
	parameter PC_LEN = 64;
	parameter TAG_WIDTH = 54;
	parameter BP_DEPTH = 9;
	input wire i_clk;
	input wire i_rst_n;
	input wire [PC_LEN - 1:0] i_if_pc;
	output reg [PC_LEN - 1:0] o_branch_target;
	output reg o_branch_taken;
	output reg o_branch_valid;
	input wire [PC_LEN - 1:0] i_ex_pc;
	input wire [PC_LEN - 1:0] i_update_branch_target;
	input wire i_valid_branch_update;
	input wire i_valid_branch_taken_update;
	input wire i_jump;
	localparam BP_SIZE = (2 ** BP_DEPTH) - 1;
	reg [(0 >= BP_SIZE ? ((1 - BP_SIZE) * ((3 + PC_LEN) + TAG_WIDTH)) + ((BP_SIZE * ((3 + PC_LEN) + TAG_WIDTH)) - 1) : ((BP_SIZE + 1) * ((3 + PC_LEN) + TAG_WIDTH)) - 1):(0 >= BP_SIZE ? BP_SIZE * ((3 + PC_LEN) + TAG_WIDTH) : 0)] bp_mem;
	reg [(0 >= BP_SIZE ? ((1 - BP_SIZE) * ((3 + PC_LEN) + TAG_WIDTH)) + ((BP_SIZE * ((3 + PC_LEN) + TAG_WIDTH)) - 1) : ((BP_SIZE + 1) * ((3 + PC_LEN) + TAG_WIDTH)) - 1):(0 >= BP_SIZE ? BP_SIZE * ((3 + PC_LEN) + TAG_WIDTH) : 0)] bp_next;
	always @(*) begin : PREDICTION_LOGIC
		if (_sv2v_0)
			;
		if ((i_if_pc[63:10] === bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (TAG_WIDTH - 1)-:TAG_WIDTH]) && bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (3 + (PC_LEN + (TAG_WIDTH - 1)))]) begin
			o_branch_valid = 1;
			o_branch_target = bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (PC_LEN + (TAG_WIDTH - 1))-:((PC_LEN + (TAG_WIDTH - 1)) >= (TAG_WIDTH + 0) ? ((PC_LEN + (TAG_WIDTH - 1)) - (TAG_WIDTH + 0)) + 1 : ((TAG_WIDTH + 0) - (PC_LEN + (TAG_WIDTH - 1))) + 1)];
			o_branch_taken = bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))];
		end
		else begin
			o_branch_valid = 0;
			o_branch_target = bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (PC_LEN + (TAG_WIDTH - 1))-:((PC_LEN + (TAG_WIDTH - 1)) >= (TAG_WIDTH + 0) ? ((PC_LEN + (TAG_WIDTH - 1)) - (TAG_WIDTH + 0)) + 1 : ((TAG_WIDTH + 0) - (PC_LEN + (TAG_WIDTH - 1))) + 1)];
			o_branch_taken = bp_mem[((0 >= BP_SIZE ? i_if_pc[9:1] : BP_SIZE - i_if_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))];
		end
	end
	always @(*) begin : UPDATE_PREDICTION_LOGIC
		if (_sv2v_0)
			;
		bp_next = bp_mem;
		if (i_valid_branch_update) begin
			if ((i_ex_pc[63:10] === bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (TAG_WIDTH - 1)-:TAG_WIDTH]) && bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (3 + (PC_LEN + (TAG_WIDTH - 1)))]) begin
				bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (PC_LEN + (TAG_WIDTH - 1))-:((PC_LEN + (TAG_WIDTH - 1)) >= (TAG_WIDTH + 0) ? ((PC_LEN + (TAG_WIDTH - 1)) - (TAG_WIDTH + 0)) + 1 : ((TAG_WIDTH + 0) - (PC_LEN + (TAG_WIDTH - 1))) + 1)] = i_update_branch_target;
				if (i_valid_branch_taken_update) begin
					if (bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] == 2'b11)
						bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = 2'b11;
					else
						bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] + 1;
				end
				else if (bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] == 2'b00)
					bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = 2'b00;
				else
					bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = bp_mem[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] - 1;
			end
			else begin
				bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (PC_LEN + (TAG_WIDTH - 1))-:((PC_LEN + (TAG_WIDTH - 1)) >= (TAG_WIDTH + 0) ? ((PC_LEN + (TAG_WIDTH - 1)) - (TAG_WIDTH + 0)) + 1 : ((TAG_WIDTH + 0) - (PC_LEN + (TAG_WIDTH - 1))) + 1)] = i_update_branch_target;
				bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = (i_valid_branch_taken_update ? 2'b01 : 2'b00);
				bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (3 + (PC_LEN + (TAG_WIDTH - 1)))] = 1;
				bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (TAG_WIDTH - 1)-:TAG_WIDTH] = i_ex_pc[63:10];
			end
		end
		else if (i_jump) begin
			bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (PC_LEN + (TAG_WIDTH - 1))-:((PC_LEN + (TAG_WIDTH - 1)) >= (TAG_WIDTH + 0) ? ((PC_LEN + (TAG_WIDTH - 1)) - (TAG_WIDTH + 0)) + 1 : ((TAG_WIDTH + 0) - (PC_LEN + (TAG_WIDTH - 1))) + 1)] = i_update_branch_target;
			bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] = 2'b11;
			bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (3 + (PC_LEN + (TAG_WIDTH - 1)))] = 1;
			bp_next[((0 >= BP_SIZE ? i_ex_pc[9:1] : BP_SIZE - i_ex_pc[9:1]) * ((3 + PC_LEN) + TAG_WIDTH)) + (TAG_WIDTH - 1)-:TAG_WIDTH] = i_ex_pc[63:10];
		end
	end
	always @(posedge i_clk or negedge i_rst_n) begin : RESET_AND_WRITE_LOGIC
		if (!i_rst_n) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i <= BP_SIZE; i = i + 1)
				begin
					bp_mem[((0 >= BP_SIZE ? i : BP_SIZE - i) * ((3 + PC_LEN) + TAG_WIDTH)) + (2 + (PC_LEN + (TAG_WIDTH - 1)))-:((2 + (PC_LEN + (TAG_WIDTH - 1))) >= (PC_LEN + (TAG_WIDTH + 0)) ? ((2 + (PC_LEN + (TAG_WIDTH - 1))) - (PC_LEN + (TAG_WIDTH + 0))) + 1 : ((PC_LEN + (TAG_WIDTH + 0)) - (2 + (PC_LEN + (TAG_WIDTH - 1)))) + 1)] <= 2'b00;
					bp_mem[((0 >= BP_SIZE ? i : BP_SIZE - i) * ((3 + PC_LEN) + TAG_WIDTH)) + (3 + (PC_LEN + (TAG_WIDTH - 1)))] <= 0;
				end
		end
		else
			bp_mem <= bp_next;
	end
	initial _sv2v_0 = 0;
endmodule
