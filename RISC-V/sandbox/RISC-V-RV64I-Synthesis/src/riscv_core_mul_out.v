module riscv_core_mul_out (
	i_mul_out_srcA_Dsign,
	i_mul_out_srcB_Dsign,
	i_mul_out_srcA_Wsign,
	i_mul_out_srcB_Wsign,
	i_mul_out_control,
	i_mul_out_isword,
	i_mul_out_product,
	o_mul_out_result
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire i_mul_out_srcA_Dsign;
	input wire i_mul_out_srcB_Dsign;
	input wire i_mul_out_srcA_Wsign;
	input wire i_mul_out_srcB_Wsign;
	input wire [1:0] i_mul_out_control;
	input wire i_mul_out_isword;
	input wire [(2 * XLEN) - 1:0] i_mul_out_product;
	output reg [XLEN - 1:0] o_mul_out_result;
	wire [1:0] srcA_srcB_sign;
	wire [1:0] srcA_srcB_word_sign;
	wire [(2 * XLEN) - 1:0] product;
	wire [(2 * XLEN) - 1:0] comp_product;
	localparam [1:0] MUL = 2'b00;
	localparam [1:0] MULH = 2'b01;
	localparam [1:0] MULHSU = 2'b10;
	localparam [1:0] MULHU = 2'b11;
	localparam [1:0] MULW = 2'b00;
	assign srcA_srcB_sign = {i_mul_out_srcA_Dsign, i_mul_out_srcB_Dsign};
	assign srcA_srcB_word_sign = {i_mul_out_srcA_Wsign, i_mul_out_srcB_Wsign};
	assign product = i_mul_out_product;
	assign comp_product = ~i_mul_out_product + 1;
	always @(*) begin : instr_proc
		if (_sv2v_0)
			;
		if (!i_mul_out_isword)
			case (i_mul_out_control)
				MUL:
					if (^srcA_srcB_sign)
						o_mul_out_result = comp_product[XLEN - 1:0];
					else
						o_mul_out_result = product[XLEN - 1:0];
				MULH:
					if (^srcA_srcB_sign)
						o_mul_out_result = comp_product[(2 * XLEN) - 1:XLEN];
					else
						o_mul_out_result = product[(2 * XLEN) - 1:XLEN];
				MULHSU:
					casex (srcA_srcB_sign)
						2'b0x: o_mul_out_result = product[(2 * XLEN) - 1:XLEN];
						2'b1x: o_mul_out_result = comp_product[(2 * XLEN) - 1:XLEN];
						default: o_mul_out_result = product[(2 * XLEN) - 1:XLEN];
					endcase
				MULHU: o_mul_out_result = product[(2 * XLEN) - 1:XLEN];
				default: o_mul_out_result = product[XLEN - 1:0];
			endcase
		else
			case (i_mul_out_control)
				MULW:
					if (^srcA_srcB_word_sign)
						o_mul_out_result = {{XLEN / 2 {comp_product[(XLEN / 2) - 1]}}, comp_product[(XLEN / 2) - 1:0]};
					else
						o_mul_out_result = {{XLEN / 2 {product[(XLEN / 2) - 1]}}, product[(XLEN / 2) - 1:0]};
				default: o_mul_out_result = {{XLEN / 2 {product[(XLEN / 2) - 1]}}, product[(XLEN / 2) - 1:0]};
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
