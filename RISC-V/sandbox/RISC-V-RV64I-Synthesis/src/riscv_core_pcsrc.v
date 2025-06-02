module riscv_core_pcsrc (
	i_pcsrc_istaken,
	i_pcsrc_branch_ex,
	i_pcsrc_jump_ex,
	o_pcsrc_pcsrc_ex
);
	input wire i_pcsrc_istaken;
	input wire i_pcsrc_branch_ex;
	input wire i_pcsrc_jump_ex;
	output wire o_pcsrc_pcsrc_ex;
	wire branch_and_istaken;
	assign branch_and_istaken = i_pcsrc_branch_ex && i_pcsrc_istaken;
	assign o_pcsrc_pcsrc_ex = i_pcsrc_jump_ex || branch_and_istaken;
endmodule
