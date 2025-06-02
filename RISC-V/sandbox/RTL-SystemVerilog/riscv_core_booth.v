module riscv_core_booth (
	i_booth_multiplicand,
	i_booth_multilpier,
	i_booth_en,
	i_booth_clk,
	i_booth_rstn,
	o_booth_done,
	o_booth_product
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_booth_multiplicand;
	input wire [XLEN - 1:0] i_booth_multilpier;
	input wire i_booth_en;
	input wire i_booth_clk;
	input wire i_booth_rstn;
	output reg o_booth_done;
	output reg [(2 * XLEN) - 1:0] o_booth_product;
	reg state_reg;
	reg state_next;
	reg [XLEN - 1:0] multiplier_reg;
	reg [XLEN - 1:0] multiplier_next;
	reg [XLEN - 1:0] accumulator_reg;
	reg [XLEN - 1:0] accumulator_next;
	reg carry_reg;
	reg [$clog2(XLEN):0] cnt_reg;
	reg [$clog2(XLEN):0] cnt_next;
	always @(posedge i_booth_clk or negedge i_booth_rstn) begin : state_register_proc
		if (!i_booth_rstn) begin
			state_reg <= 1'd0;
			multiplier_reg <= 0;
			accumulator_reg <= 0;
			cnt_reg <= 64;
		end
		else begin
			state_reg <= state_next;
			multiplier_reg <= multiplier_next;
			accumulator_reg <= accumulator_next;
			cnt_reg <= cnt_next;
		end
	end
	always @(*) begin : next_state_logic_proc
		if (_sv2v_0)
			;
		multiplier_next = multiplier_reg;
		accumulator_next = accumulator_reg;
		carry_reg = 0;
		state_next = state_reg;
		cnt_next = cnt_reg;
		o_booth_done = 1'b0;
		o_booth_product = 0;
		case (state_reg)
			1'd0:
				if (i_booth_en) begin
					multiplier_next = i_booth_multilpier;
					accumulator_next = 0;
					carry_reg = 0;
					cnt_next = 64;
					state_next = 1'd1;
				end
				else
					state_next = 1'd0;
			1'd1: begin
				if (multiplier_reg[0]) begin
					{carry_reg, accumulator_next} = accumulator_reg + i_booth_multiplicand;
					{carry_reg, accumulator_next, multiplier_next} = {carry_reg, accumulator_next, multiplier_reg} >>> 1;
				end
				else
					{carry_reg, accumulator_next, multiplier_next} = {carry_reg, accumulator_reg, multiplier_reg} >>> 1;
				cnt_next = cnt_reg - 1;
				if (cnt_next == 0) begin
					state_next = 1'd0;
					o_booth_done = 1'b1;
					o_booth_product = {accumulator_next, multiplier_next};
				end
				else
					state_next = 1'd1;
			end
			default: state_next = 1'd0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
