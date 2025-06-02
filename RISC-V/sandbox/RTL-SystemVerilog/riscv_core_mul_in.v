module riscv_core_mul_in (
	i_mul_in_srcA,
	i_mul_in_srcB,
	i_mul_in_control,
	i_mul_in_isword,
	o_mul_in_multiplicand,
	o_mul_in_multiplier
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_mul_in_srcA;
	input wire [XLEN - 1:0] i_mul_in_srcB;
	input wire [1:0] i_mul_in_control;
	input wire i_mul_in_isword;
	output reg [XLEN - 1:0] o_mul_in_multiplicand;
	output reg [XLEN - 1:0] o_mul_in_multiplier;
	wire [1:0] srcA_srcB_sign;
	wire [1:0] srcA_srcB_word_sign;
	wire [XLEN - 1:0] srcA_comp;
	wire [XLEN - 1:0] srcB_comp;
	wire [XLEN - 1:0] wsrcA_comp;
	wire [XLEN - 1:0] wsrcB_comp;
	localparam [1:0] MUL = 2'b00;
	localparam [1:0] MULH = 2'b01;
	localparam [1:0] MULHSU = 2'b10;
	localparam [1:0] MULHU = 2'b11;
	localparam [1:0] MULW = 2'b00;
	assign srcA_srcB_sign = {i_mul_in_srcA[XLEN - 1], i_mul_in_srcB[XLEN - 1]};
	assign srcA_srcB_word_sign = {i_mul_in_srcA[(XLEN / 2) - 1], i_mul_in_srcB[(XLEN / 2) - 1]};
	assign srcA_comp = ~i_mul_in_srcA + 1'b1;
	assign srcB_comp = ~i_mul_in_srcB + 1'b1;
	assign wsrcA_comp = ~i_mul_in_srcA[(XLEN / 2) - 1:0] + 1'b1;
	assign wsrcB_comp = ~i_mul_in_srcB[(XLEN / 2) - 1:0] + 1'b1;
	always @(*) begin : instr_proc
		if (_sv2v_0)
			;
		if (!i_mul_in_isword)
			case (i_mul_in_control)
				MUL:
					case (srcA_srcB_sign)
						2'b00: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						2'b01: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = srcB_comp;
						end
						2'b10: begin
							o_mul_in_multiplicand = srcA_comp;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						2'b11: begin
							o_mul_in_multiplicand = srcA_comp;
							o_mul_in_multiplier = srcB_comp;
						end
						default: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
					endcase
				MULH:
					case (srcA_srcB_sign)
						2'b00: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						2'b01: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = srcB_comp;
						end
						2'b10: begin
							o_mul_in_multiplicand = srcA_comp;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						2'b11: begin
							o_mul_in_multiplicand = srcA_comp;
							o_mul_in_multiplier = srcB_comp;
						end
						default: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
					endcase
				MULHSU:
					casex (srcA_srcB_sign)
						2'b0x: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						2'b1x: begin
							o_mul_in_multiplicand = srcA_comp;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
						default: begin
							o_mul_in_multiplicand = i_mul_in_srcA;
							o_mul_in_multiplier = i_mul_in_srcB;
						end
					endcase
				MULHU: begin
					o_mul_in_multiplicand = i_mul_in_srcA;
					o_mul_in_multiplier = i_mul_in_srcB;
				end
				default: begin
					o_mul_in_multiplicand = i_mul_in_srcA;
					o_mul_in_multiplier = i_mul_in_srcB;
				end
			endcase
		else
			case (i_mul_in_control)
				MULW:
					case (srcA_srcB_word_sign)
						2'b00: begin
							o_mul_in_multiplicand = i_mul_in_srcA[(XLEN / 2) - 1:0];
							o_mul_in_multiplier = i_mul_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b01: begin
							o_mul_in_multiplicand = i_mul_in_srcA[(XLEN / 2) - 1:0];
							o_mul_in_multiplier = wsrcB_comp;
						end
						2'b10: begin
							o_mul_in_multiplicand = wsrcA_comp;
							o_mul_in_multiplier = i_mul_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b11: begin
							o_mul_in_multiplicand = wsrcA_comp;
							o_mul_in_multiplier = wsrcB_comp;
						end
						default: begin
							o_mul_in_multiplicand = i_mul_in_srcA[(XLEN / 2) - 1:0];
							o_mul_in_multiplier = i_mul_in_srcB[(XLEN / 2) - 1:0];
						end
					endcase
				default: begin
					o_mul_in_multiplicand = i_mul_in_srcA[(XLEN / 2) - 1:0];
					o_mul_in_multiplier = i_mul_in_srcB[(XLEN / 2) - 1:0];
				end
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
