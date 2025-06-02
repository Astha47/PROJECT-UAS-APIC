module riscv_core_div_in (
	i_div_in_srcA,
	i_div_in_srcB,
	i_div_in_control,
	i_div_in_isword,
	o_div_in_dividend,
	o_div_in_divisor
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_div_in_srcA;
	input wire [XLEN - 1:0] i_div_in_srcB;
	input wire [1:0] i_div_in_control;
	input wire i_div_in_isword;
	output reg [XLEN - 1:0] o_div_in_dividend;
	output reg [XLEN - 1:0] o_div_in_divisor;
	wire [1:0] srcA_srcB_sign;
	wire [1:0] srcA_srcB_word_sign;
	wire [XLEN - 1:0] srcA_comp;
	wire [XLEN - 1:0] srcB_comp;
	wire [XLEN - 1:0] wsrcA_comp;
	wire [XLEN - 1:0] wsrcB_comp;
	localparam [1:0] DIV = 2'b00;
	localparam [1:0] DIVU = 2'b01;
	localparam [1:0] REM = 2'b10;
	localparam [1:0] REMU = 2'b11;
	localparam [1:0] DIVW = 2'b00;
	localparam [1:0] DIVUW = 2'b01;
	localparam [1:0] REMW = 2'b10;
	localparam [1:0] REMUW = 2'b11;
	assign srcA_srcB_sign = {i_div_in_srcA[XLEN - 1], i_div_in_srcB[XLEN - 1]};
	assign srcA_srcB_word_sign = {i_div_in_srcA[(XLEN / 2) - 1], i_div_in_srcB[(XLEN / 2) - 1]};
	assign srcA_comp = ~i_div_in_srcA + 1'b1;
	assign srcB_comp = ~i_div_in_srcB + 1'b1;
	assign wsrcA_comp = ~i_div_in_srcA[(XLEN / 2) - 1:0] + 1'b1;
	assign wsrcB_comp = ~i_div_in_srcB[(XLEN / 2) - 1:0] + 1'b1;
	always @(*) begin : instr_proc
		if (_sv2v_0)
			;
		if (!i_div_in_isword)
			case (i_div_in_control)
				DIV:
					case (srcA_srcB_sign)
						2'b00: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = i_div_in_srcB;
						end
						2'b01: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = srcB_comp;
						end
						2'b10: begin
							o_div_in_dividend = srcA_comp;
							o_div_in_divisor = i_div_in_srcB;
						end
						2'b11: begin
							o_div_in_dividend = srcA_comp;
							o_div_in_divisor = srcB_comp;
						end
						default: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = i_div_in_srcB;
						end
					endcase
				DIVU: begin
					o_div_in_dividend = i_div_in_srcA;
					o_div_in_divisor = i_div_in_srcB;
				end
				REM:
					case (srcA_srcB_sign)
						2'b00: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = i_div_in_srcB;
						end
						2'b01: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = srcB_comp;
						end
						2'b10: begin
							o_div_in_dividend = srcA_comp;
							o_div_in_divisor = i_div_in_srcB;
						end
						2'b11: begin
							o_div_in_dividend = srcA_comp;
							o_div_in_divisor = srcB_comp;
						end
						default: begin
							o_div_in_dividend = i_div_in_srcA;
							o_div_in_divisor = i_div_in_srcB;
						end
					endcase
				REMU: begin
					o_div_in_dividend = i_div_in_srcA;
					o_div_in_divisor = i_div_in_srcB;
				end
				default: begin
					o_div_in_dividend = i_div_in_srcA;
					o_div_in_divisor = i_div_in_srcB;
				end
			endcase
		else
			case (i_div_in_control)
				DIVW:
					case (srcA_srcB_word_sign)
						2'b00: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b01: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = wsrcB_comp;
						end
						2'b10: begin
							o_div_in_dividend = wsrcA_comp;
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b11: begin
							o_div_in_dividend = wsrcA_comp;
							o_div_in_divisor = wsrcB_comp;
						end
						default: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
					endcase
				DIVUW: begin
					o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
					o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
				end
				REMW:
					case (srcA_srcB_sign)
						2'b00: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b01: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = wsrcB_comp;
						end
						2'b10: begin
							o_div_in_dividend = wsrcA_comp;
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
						2'b11: begin
							o_div_in_dividend = wsrcA_comp;
							o_div_in_divisor = wsrcB_comp;
						end
						default: begin
							o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
							o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
						end
					endcase
				REMUW: begin
					o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
					o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
				end
				default: begin
					o_div_in_dividend = i_div_in_srcA[(XLEN / 2) - 1:0];
					o_div_in_divisor = i_div_in_srcB[(XLEN / 2) - 1:0];
				end
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
