module riscv_core_alu (
	i_alu_srcA,
	i_alu_srcB,
	i_alu_control,
	i_alu_isword,
	o_alu_result
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_alu_srcA;
	input wire [XLEN - 1:0] i_alu_srcB;
	input wire [3:0] i_alu_control;
	input wire i_alu_isword;
	output reg [XLEN - 1:0] o_alu_result;
	reg [31:0] o_alu_resultword;
	always @(*) begin : result_proc
		if (_sv2v_0)
			;
		if (!i_alu_isword)
			case (i_alu_control)
				4'b0000: o_alu_result = i_alu_srcA + i_alu_srcB;
				4'b0001: o_alu_result = i_alu_srcA - i_alu_srcB;
				4'b0110: o_alu_result = i_alu_srcA ^ i_alu_srcB;
				4'b0011: o_alu_result = i_alu_srcA | i_alu_srcB;
				4'b0010: o_alu_result = i_alu_srcA & i_alu_srcB;
				4'b0100: o_alu_result = $signed(i_alu_srcA) << i_alu_srcB[5:0];
				4'b0111: o_alu_result = $signed(i_alu_srcA) >> i_alu_srcB[5:0];
				4'b1111: o_alu_result = $signed(i_alu_srcA) >>> i_alu_srcB[5:0];
				4'b0101: o_alu_result = $signed(i_alu_srcA) < $signed(i_alu_srcB);
				4'b1000: o_alu_result = $unsigned(i_alu_srcA) < $unsigned(i_alu_srcB);
				default: o_alu_result = 'hx;
			endcase
		else begin
			case (i_alu_control)
				4'b0000: o_alu_resultword = i_alu_srcA + i_alu_srcB;
				4'b0001: o_alu_resultword = i_alu_srcA - i_alu_srcB;
				4'b0100: o_alu_resultword = $signed(i_alu_srcA[31:0]) << i_alu_srcB[4:0];
				4'b0111: o_alu_resultword = $signed(i_alu_srcA[31:0]) >> i_alu_srcB[4:0];
				4'b1111: o_alu_resultword = $signed(i_alu_srcA[31:0]) >>> i_alu_srcB[4:0];
				default: o_alu_resultword = 'hx;
			endcase
			o_alu_result = {{32 {o_alu_resultword[31]}}, o_alu_resultword};
		end
	end
	initial _sv2v_0 = 0;
endmodule
