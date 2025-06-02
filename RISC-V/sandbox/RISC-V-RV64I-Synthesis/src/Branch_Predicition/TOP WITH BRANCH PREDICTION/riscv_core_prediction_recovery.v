module riscv_core_prediction_recovery (
	branch,
	jump,
	i_valid,
	i_btanch_Taken,
	i_target_address,
	i_ex_address,
	i_pc_plus_offset,
	i_is_taken,
	o_mis_prediction,
	o_recovery_address
);
	reg _sv2v_0;
	parameter ALEN = 64;
	input wire branch;
	input wire jump;
	input wire i_valid;
	input wire i_btanch_Taken;
	input wire [ALEN - 1:0] i_target_address;
	input wire [ALEN - 1:0] i_ex_address;
	input wire [ALEN - 1:0] i_pc_plus_offset;
	input wire i_is_taken;
	output reg o_mis_prediction;
	output reg [ALEN - 1:0] o_recovery_address;
	localparam branch_instr = 2'b10;
	localparam jump_instr = 2'b01;
	wire address_matched;
	wire [1:0] branch_jump;
	always @(*) begin : recovery_proc
		if (_sv2v_0)
			;
		case (branch_jump)
			branch_instr:
				if (i_valid) begin
					if ((i_btanch_Taken == 0) & (i_is_taken == 0)) begin
						o_mis_prediction = 1'b0;
						o_recovery_address = 'b0;
					end
					else if ((i_btanch_Taken == 0) & (i_is_taken == 1)) begin
						o_mis_prediction = 1'b1;
						o_recovery_address = i_ex_address;
					end
					else if ((i_btanch_Taken == 1) & (i_is_taken == 0)) begin
						o_mis_prediction = 1'b1;
						o_recovery_address = i_pc_plus_offset;
					end
					else if ((i_btanch_Taken == 1) & (i_is_taken == 1)) begin
						if (address_matched) begin
							o_mis_prediction = 1'b0;
							o_recovery_address = 'b0;
						end
						else begin
							o_mis_prediction = 1'b1;
							o_recovery_address = i_ex_address;
						end
					end
					else begin
						o_mis_prediction = 1'b0;
						o_recovery_address = 'b0;
					end
				end
				else if (i_is_taken) begin
					o_mis_prediction = 1'b1;
					o_recovery_address = i_ex_address;
				end
				else begin
					o_mis_prediction = 1'b0;
					o_recovery_address = 'b0;
				end
			jump_instr:
				if (!i_btanch_Taken || (i_btanch_Taken & !address_matched)) begin
					o_mis_prediction = 1'b1;
					o_recovery_address = i_ex_address;
				end
				else begin
					o_mis_prediction = 1'b0;
					o_recovery_address = 'b0;
				end
			default: begin
				o_mis_prediction = 1'b0;
				o_recovery_address = 'b0;
			end
		endcase
	end
	assign branch_jump = {branch, jump};
	assign address_matched = (i_ex_address == i_target_address ? 1 : 0);
	initial _sv2v_0 = 0;
endmodule
