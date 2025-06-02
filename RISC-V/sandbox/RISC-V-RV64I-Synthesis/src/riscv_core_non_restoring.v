module riscv_core_non_restoring (
	i_non_restoring_dividend,
	i_non_restoring_divisor,
	i_non_restoring_en,
	i_non_restoring_clk,
	i_non_restoring_rstn,
	o_non_restoring_done,
	o_non_restoring_quotient,
	o_non_restoring_remainder
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_non_restoring_dividend;
	input wire [XLEN - 1:0] i_non_restoring_divisor;
	input wire i_non_restoring_en;
	input wire i_non_restoring_clk;
	input wire i_non_restoring_rstn;
	output reg o_non_restoring_done;
	output reg [XLEN - 1:0] o_non_restoring_quotient;
	output reg [XLEN - 1:0] o_non_restoring_remainder;
	reg state_reg;
	reg state_next;
	reg [XLEN - 1:0] dividend_reg;
	reg [XLEN - 1:0] dividend_next;
	reg [XLEN:0] accumulator_reg;
	reg [XLEN:0] accumulator_next;
	reg [$clog2(XLEN):0] cnt_reg;
	reg [$clog2(XLEN):0] cnt_next;
	always @(posedge i_non_restoring_clk or negedge i_non_restoring_rstn) begin : state_register_proc
		if (!i_non_restoring_rstn) begin
			state_reg <= 1'd0;
			dividend_reg <= 0;
			accumulator_reg <= 0;
			cnt_reg <= 64;
		end
		else begin
			state_reg <= state_next;
			dividend_reg <= dividend_next;
			accumulator_reg <= accumulator_next;
			cnt_reg <= cnt_next;
		end
	end
	always @(*) begin : next_state_logic_proc
		if (_sv2v_0)
			;
		dividend_next = dividend_reg;
		accumulator_next = accumulator_reg;
		cnt_next = cnt_reg;
		o_non_restoring_done = 1'b0;
		o_non_restoring_quotient = 0;
		o_non_restoring_remainder = 0;
		case (state_reg)
			1'd0:
				if (i_non_restoring_en) begin
					dividend_next = i_non_restoring_dividend;
					accumulator_next = 0;
					cnt_next = 64;
					state_next = 1'd1;
				end
				else
					state_next = 1'd0;
			1'd1: begin
				if (accumulator_reg[XLEN]) begin
					{accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
					accumulator_next = accumulator_next + i_non_restoring_divisor;
				end
				else begin
					{accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
					accumulator_next = accumulator_next - i_non_restoring_divisor;
				end
				if (accumulator_next[XLEN])
					dividend_next[0] = 1'b0;
				else
					dividend_next[0] = 1'b1;
				cnt_next = cnt_reg - 1;
				if (cnt_next == 0) begin
					if (accumulator_next[XLEN])
						accumulator_next = accumulator_next + i_non_restoring_divisor;
					else
						accumulator_next = accumulator_reg;
					o_non_restoring_done = 1'b1;
					o_non_restoring_quotient = dividend_next;
					o_non_restoring_remainder = accumulator_next;
					state_next = 1'd0;
				end
				else
					state_next = 1'd1;
			end
			default: state_next = 1'd0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
