module riscv_core_main_decoder_top (
	i_instr,
	i_main_decoder_if_illegal,
	o_csr_control_ecall,
	o_csr_control_ebreak,
	o_csr_control_mret,
	o_csr_control_sret,
	o_csr_control_csr_wen,
	o_main_decoder_imsrc,
	o_main_decoder_UCtrl,
	o_main_decoder_resultsrc,
	o_main_decoder_regwrite,
	o_main_decoder_alusrcB,
	o_main_decoder_memwrite,
	o_main_decoder_branch,
	o_main_decoder_jump,
	o_main_decoder_bjreg,
	o_main_decoder_size,
	o_main_decoder_LdExt,
	o_main_decoder_isword,
	o_main_decoder_aluop,
	o_main_decoder_imsel,
	o_main_decoder_new_mux_sel,
	o_main_decoder_amo,
	o_main_decoder_amo_op,
	o_main_decoder_lr,
	o_main_decoder_sc,
	o_main_decoder_src_sel,
	o_main_decoder_op,
	o_main_decoder_illegal,
	o_main_decoder_read
);
	input wire [31:0] i_instr;
	input wire i_main_decoder_if_illegal;
	output wire o_csr_control_ecall;
	output wire o_csr_control_ebreak;
	output wire o_csr_control_mret;
	output wire o_csr_control_sret;
	output wire o_csr_control_csr_wen;
	output wire [2:0] o_main_decoder_imsrc;
	output wire o_main_decoder_UCtrl;
	output wire [1:0] o_main_decoder_resultsrc;
	output wire o_main_decoder_regwrite;
	output wire o_main_decoder_alusrcB;
	output wire o_main_decoder_memwrite;
	output wire o_main_decoder_branch;
	output wire o_main_decoder_jump;
	output wire o_main_decoder_bjreg;
	output wire [1:0] o_main_decoder_size;
	output wire o_main_decoder_LdExt;
	output wire o_main_decoder_isword;
	output wire o_main_decoder_aluop;
	output wire o_main_decoder_imsel;
	output wire o_main_decoder_new_mux_sel;
	output wire o_main_decoder_amo;
	output wire [3:0] o_main_decoder_amo_op;
	output wire o_main_decoder_lr;
	output wire o_main_decoder_sc;
	output wire o_main_decoder_src_sel;
	output wire [1:0] o_main_decoder_op;
	output wire o_main_decoder_illegal;
	output wire o_main_decoder_read;
	wire [6:0] i_main_decoder_opcode;
	wire [2:0] i_main_decoder_funct3;
	wire [6:0] i_main_decoder_funct7;
	assign i_main_decoder_opcode = i_instr[6:0];
	assign i_main_decoder_funct3 = i_instr[14:12];
	assign i_main_decoder_funct7 = i_instr[31:25];
	wire o_id_illegal;
	wire o_csr_illegal;
	riscv_core_main_decoder u1(
		.i_main_decoder_opcode(i_main_decoder_opcode),
		.i_main_decoder_funct3(i_main_decoder_funct3),
		.i_main_decoder_funct7(i_main_decoder_funct7),
		.o_main_decoder_imsrc(o_main_decoder_imsrc),
		.o_main_decoder_UCtrl(o_main_decoder_UCtrl),
		.o_main_decoder_resultsrc(o_main_decoder_resultsrc),
		.o_main_decoder_regwrite(o_main_decoder_regwrite),
		.o_main_decoder_alusrcB(o_main_decoder_alusrcB),
		.o_main_decoder_memwrite(o_main_decoder_memwrite),
		.o_main_decoder_branch(o_main_decoder_branch),
		.o_main_decoder_jump(o_main_decoder_jump),
		.o_main_decoder_bjreg(o_main_decoder_bjreg),
		.o_main_decoder_size(o_main_decoder_size),
		.o_main_decoder_LdExt(o_main_decoder_LdExt),
		.o_main_decoder_isword(o_main_decoder_isword),
		.o_main_decoder_aluop(o_main_decoder_aluop),
		.o_main_decoder_imsel(o_main_decoder_imsel),
		.o_main_decoder_new_mux_sel(o_main_decoder_new_mux_sel),
		.o_main_decoder_amo(o_main_decoder_amo),
		.o_main_decoder_amo_op(o_main_decoder_amo_op),
		.o_main_decoder_lr(o_main_decoder_lr),
		.o_main_decoder_sc(o_main_decoder_sc),
		.o_main_decoder_src_sel(o_main_decoder_src_sel),
		.o_main_decoder_op(o_main_decoder_op),
		.o_main_decoder_illegal(o_id_illegal),
		.o_main_decoder_read(o_main_decoder_read)
	);
	assign o_main_decoder_illegal = (o_id_illegal || i_main_decoder_if_illegal) || o_csr_illegal;
	riscv_core_csr_control_signals u2(
		.i_csr_control_instr(i_instr),
		.o_csr_control_csr_wen(o_csr_control_csr_wen),
		.o_csr_control_mret(o_csr_control_mret),
		.o_csr_control_sret(o_csr_control_sret),
		.o_csr_control_ecall(o_csr_control_ecall),
		.o_csr_control_ebreak(o_csr_control_ebreak),
		.o_csr_illegal(o_csr_illegal)
	);
endmodule
