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
		if (_sv2v_0) // This line is likely an artifact and can be removed if it serves no purpose
			;

		// Default assignments to prevent latches
		o_alu_result = {XLEN{1'bx}};
		o_alu_resultword = 32'hx;

		if (!i_alu_isword) begin // Explicit begin for clarity
			// o_alu_resultword keeps its default 'hx in this path
			case (i_alu_control)
				4'b0000: o_alu_result = i_alu_srcA + i_alu_srcB;
				4'b0001: o_alu_result = i_alu_srcA - i_alu_srcB;
				4'b0110: o_alu_result = i_alu_srcA ^ i_alu_srcB;
				4'b0011: o_alu_result = i_alu_srcA | i_alu_srcB;
				4'b0010: o_alu_result = i_alu_srcA & i_alu_srcB;
				4'b0100: o_alu_result = $signed(i_alu_srcA) << i_alu_srcB[5:0];
				4'b0111: o_alu_result = $signed(i_alu_srcA) >> i_alu_srcB[5:0]; // Assumed Arithmetic Shift Right
				4'b1111: o_alu_result = i_alu_srcA >>> i_alu_srcB[5:0];       // Assumed Logical Shift Right (>>> ignores signedness)
				4'b0101: o_alu_result = ($signed(i_alu_srcA) < $signed(i_alu_srcB)) ? {{XLEN-1{1'b0}}, 1'b1} : {XLEN{1'b0}};
				4'b1000: o_alu_result = ($unsigned(i_alu_srcA) < $unsigned(i_alu_srcB)) ? {{XLEN-1{1'b0}}, 1'b1} : {XLEN{1'b0}};
				default: o_alu_result = {XLEN{1'bx}};
			endcase
		end else begin
			case (i_alu_control)
				4'b0000: o_alu_resultword = i_alu_srcA[31:0] + i_alu_srcB[31:0]; // Use 32-bit operands
				4'b0001: o_alu_resultword = i_alu_srcA[31:0] - i_alu_srcB[31:0]; // Use 32-bit operands
				4'b0100: o_alu_resultword = $signed(i_alu_srcA[31:0]) << i_alu_srcB[4:0];
				4'b0111: o_alu_resultword = $signed(i_alu_srcA[31:0]) >> i_alu_srcB[4:0]; // Assumed Arithmetic Shift Right for word
				4'b1111: o_alu_resultword = i_alu_srcA[31:0] >>> i_alu_srcB[4:0];       // Assumed Logical Shift Right for word
				// Consider if XOR, OR, AND, SLT, SLTU are needed for word operations.
				// If they were intended, they are missing here.
				// Current default will make o_alu_resultword 'hx for those controls in word mode.
				default: o_alu_resultword = 32'hx;
			endcase
			o_alu_result = {{XLEN-32{o_alu_resultword[31]}}, o_alu_resultword}; // Sign-extend 32-bit result to XLEN
		end
	end
	initial _sv2v_0 = 0; // This line is likely an artifact
endmodule
