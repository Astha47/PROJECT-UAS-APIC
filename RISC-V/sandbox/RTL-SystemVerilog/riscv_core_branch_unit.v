module riscv_core_branch_unit (
	i_branch_unit_srcA,
	i_branch_unit_srcB,
	i_branch_unit_funct3,
	i_branch_unit_targetPC,
	i_branch_unit_enable,
	o_branch_unit_istaken,
	o_branch_unit_addr_mismatch
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_branch_unit_srcA;
	input wire [XLEN - 1:0] i_branch_unit_srcB;
	input wire [2:0] i_branch_unit_funct3;
	input wire [1:0] i_branch_unit_targetPC;
	input wire i_branch_unit_enable;
	output wire o_branch_unit_istaken;
	output wire o_branch_unit_addr_mismatch;
	reg istaken;
	always @(*) begin : istaken_proc
		if (_sv2v_0)
			;
		if (i_branch_unit_enable)
			case (i_branch_unit_funct3)
				3'b000: istaken = $signed(i_branch_unit_srcA) == $signed(i_branch_unit_srcB);
				3'b001: istaken = $signed(i_branch_unit_srcA) != $signed(i_branch_unit_srcB);
				3'b100: istaken = $signed(i_branch_unit_srcA) < $signed(i_branch_unit_srcB);
				3'b101: istaken = $signed(i_branch_unit_srcA) >= $signed(i_branch_unit_srcB);
				3'b110: istaken = $unsigned(i_branch_unit_srcA) < $unsigned(i_branch_unit_srcB);
				3'b111: istaken = $unsigned(i_branch_unit_srcA) >= $unsigned(i_branch_unit_srcB);
				default: istaken = 1'b0;
			endcase
		else
			istaken = 1'b0;
	end
	assign o_branch_unit_addr_mismatch = istaken && i_branch_unit_targetPC[0];
	assign o_branch_unit_istaken = istaken;
	initial _sv2v_0 = 0;
endmodule
