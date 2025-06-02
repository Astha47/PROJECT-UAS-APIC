module riscv_core_div_out (
	i_div_out_srcA_Dsign,
	i_div_out_srcB_Dsign,
	i_div_out_srcA_Wsign,
	i_div_out_srcB_Wsign,
	i_div_out_control,
	i_div_out_isword,
	i_div_out_quotient,
	i_div_out_remainder,
	o_div_out_result
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire i_div_out_srcA_Dsign;
	input wire i_div_out_srcB_Dsign;
	input wire i_div_out_srcA_Wsign;
	input wire i_div_out_srcB_Wsign;
	input wire [1:0] i_div_out_control;
	input wire i_div_out_isword;
	input wire [XLEN - 1:0] i_div_out_quotient;
	input wire [XLEN - 1:0] i_div_out_remainder;
	output reg [XLEN - 1:0] o_div_out_result;
	wire [1:0] srcA_srcB_sign;
	wire [1:0] srcA_srcB_word_sign;
	wire [XLEN - 1:0] quotient;
	wire [XLEN - 1:0] comp_quotient;
	wire [XLEN - 1:0] remainder;
	wire [XLEN - 1:0] comp_remainder;
	localparam [1:0] DIV = 2'b00;
	localparam [1:0] DIVU = 2'b01;
	localparam [1:0] REM = 2'b10;
	localparam [1:0] REMU = 2'b11;
	localparam [1:0] DIVW = 2'b00;
	localparam [1:0] DIVUW = 2'b01;
	localparam [1:0] REMW = 2'b10;
	localparam [1:0] REMUW = 2'b11;
	assign srcA_srcB_sign = {i_div_out_srcA_Dsign, i_div_out_srcB_Dsign};
	assign srcA_srcB_word_sign = {i_div_out_srcA_Wsign, i_div_out_srcB_Wsign};
	assign quotient = i_div_out_quotient;
	assign comp_quotient = ~i_div_out_quotient + 1;
	assign remainder = i_div_out_remainder;
	assign comp_remainder = ~i_div_out_remainder + 1;
	always @(*) begin : instr_proc
		if (_sv2v_0)
			;
		if (!i_div_out_isword)
			case (i_div_out_control)
				DIV:
					if (^srcA_srcB_sign)
						o_div_out_result = comp_quotient;
					else
						o_div_out_result = quotient;
				DIVU: o_div_out_result = quotient;
				REM:
					if (srcA_srcB_sign[1])
						o_div_out_result = comp_remainder;
					else
						o_div_out_result = remainder;
				REMU: o_div_out_result = remainder;
				default: o_div_out_result = quotient;
			endcase
		else
			case (i_div_out_control)
				DIVW:
					if (^srcA_srcB_word_sign)
						o_div_out_result = {{XLEN / 2 {comp_quotient[(XLEN / 2) - 1]}}, comp_quotient[(XLEN / 2) - 1:0]};
					else
						o_div_out_result = {{XLEN / 2 {quotient[(XLEN / 2) - 1]}}, quotient[(XLEN / 2) - 1:0]};
				DIVUW: o_div_out_result = {{XLEN / 2 {quotient[(XLEN / 2) - 1]}}, quotient[(XLEN / 2) - 1:0]};
				REMW:
					if (srcA_srcB_word_sign[1])
						o_div_out_result = {{XLEN / 2 {comp_remainder[(XLEN / 2) - 1]}}, comp_remainder[(XLEN / 2) - 1:0]};
					else
						o_div_out_result = {{XLEN / 2 {remainder[(XLEN / 2) - 1]}}, remainder[(XLEN / 2) - 1:0]};
				REMUW: o_div_out_result = {{XLEN / 2 {remainder[(XLEN / 2) - 1]}}, remainder[(XLEN / 2) - 1:0]};
				default: o_div_out_result = {{XLEN / 2 {quotient[(XLEN / 2) - 1]}}, quotient[(XLEN / 2) - 1:0]};
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
