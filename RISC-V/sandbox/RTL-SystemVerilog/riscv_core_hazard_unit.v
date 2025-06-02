module riscv_core_hazard_unit (
	i_hazard_unit_rs1_id,
	i_hazard_unit_rs2_id,
	i_hazard_unit_rs1_ex,
	i_hazard_unit_rs2_ex,
	i_hazard_unit_rd_ex,
	i_hazard_unit_rd_mem,
	i_hazard_unit_rd_wb,
	i_hazard_unit_regwrite_mem,
	i_hazard_unit_regwrite_wb,
	i_hazard_unit_resultsrc_ex,
	i_hazard_unit_pcsrc_ex,
	i_hazard_unit_illegal_instr,
	i_hazard_unit_mdone,
	i_hazard_unit_mbusy,
	i_hazard_unit_dcache_stall,
	i_hazard_unit_icache_stall,
	o_hazard_unit_forwarda_ex,
	o_hazard_unit_forwardb_ex,
	o_hazard_unit_stall_if,
	o_hazard_unit_stall_id,
	o_hazard_unit_stall_ex,
	o_hazard_unit_stall_mem,
	o_hazard_unit_stall_wb,
	o_hazard_unit_flush_id,
	o_hazard_unit_flush_ex,
	o_hazard_unit_flush_mem,
	o_hazard_unit_flush_wb,
	i_hazard_unit_csr_flush_id,
	i_hazard_unit_csr_flush_ex,
	i_hazard_unit_csr_flush_mem,
	i_hazard_unit_csr_flush_wb
);
	reg _sv2v_0;
	input wire [4:0] i_hazard_unit_rs1_id;
	input wire [4:0] i_hazard_unit_rs2_id;
	input wire [4:0] i_hazard_unit_rs1_ex;
	input wire [4:0] i_hazard_unit_rs2_ex;
	input wire [4:0] i_hazard_unit_rd_ex;
	input wire [4:0] i_hazard_unit_rd_mem;
	input wire [4:0] i_hazard_unit_rd_wb;
	input wire i_hazard_unit_regwrite_mem;
	input wire i_hazard_unit_regwrite_wb;
	input wire [1:0] i_hazard_unit_resultsrc_ex;
	input wire i_hazard_unit_pcsrc_ex;
	input wire i_hazard_unit_illegal_instr;
	input wire i_hazard_unit_mdone;
	input wire i_hazard_unit_mbusy;
	input wire i_hazard_unit_dcache_stall;
	input wire i_hazard_unit_icache_stall;
	output reg [1:0] o_hazard_unit_forwarda_ex;
	output reg [1:0] o_hazard_unit_forwardb_ex;
	output reg o_hazard_unit_stall_if;
	output reg o_hazard_unit_stall_id;
	output reg o_hazard_unit_stall_ex;
	output reg o_hazard_unit_stall_mem;
	output reg o_hazard_unit_stall_wb;
	output reg o_hazard_unit_flush_id;
	output reg o_hazard_unit_flush_ex;
	output reg o_hazard_unit_flush_mem;
	output reg o_hazard_unit_flush_wb;
	input wire i_hazard_unit_csr_flush_id;
	input wire i_hazard_unit_csr_flush_ex;
	input wire i_hazard_unit_csr_flush_mem;
	input wire i_hazard_unit_csr_flush_wb;
	reg lwstall_detection;
	reg mstall_detection;
	reg icache_stall_detection;
	reg dcache_stall_detection;
	always @(*) begin : forwarding_proc
		if (_sv2v_0)
			;
		if (((i_hazard_unit_rs1_ex == i_hazard_unit_rd_mem) && i_hazard_unit_regwrite_mem) && (i_hazard_unit_rs1_ex != 5'b00000))
			o_hazard_unit_forwarda_ex = 2'b10;
		else if (((i_hazard_unit_rs1_ex == i_hazard_unit_rd_wb) && i_hazard_unit_regwrite_wb) && (i_hazard_unit_rs1_ex != 5'b00000))
			o_hazard_unit_forwarda_ex = 2'b01;
		else
			o_hazard_unit_forwarda_ex = 2'b00;
		if (((i_hazard_unit_rs2_ex == i_hazard_unit_rd_mem) && i_hazard_unit_regwrite_mem) && (i_hazard_unit_rs2_ex != 5'b00000))
			o_hazard_unit_forwardb_ex = 2'b10;
		else if (((i_hazard_unit_rs2_ex == i_hazard_unit_rd_wb) && i_hazard_unit_regwrite_wb) && (i_hazard_unit_rs2_ex != 5'b00000))
			o_hazard_unit_forwardb_ex = 2'b01;
		else
			o_hazard_unit_forwardb_ex = 2'b00;
	end
	always @(*) begin : stall_proc
		if (_sv2v_0)
			;
		lwstall_detection = (i_hazard_unit_resultsrc_ex == 2'b01) && ((i_hazard_unit_rs1_id == i_hazard_unit_rd_ex) || (i_hazard_unit_rs2_id == i_hazard_unit_rd_ex));
		mstall_detection = i_hazard_unit_mbusy && !i_hazard_unit_mdone;
		icache_stall_detection = i_hazard_unit_icache_stall;
		dcache_stall_detection = i_hazard_unit_dcache_stall;
		o_hazard_unit_stall_if = ((lwstall_detection || mstall_detection) || icache_stall_detection) || dcache_stall_detection;
		o_hazard_unit_stall_id = (lwstall_detection || mstall_detection) || dcache_stall_detection;
		o_hazard_unit_stall_ex = mstall_detection || dcache_stall_detection;
		o_hazard_unit_stall_mem = mstall_detection || dcache_stall_detection;
		o_hazard_unit_stall_wb = mstall_detection;
	end
	always @(*) begin : flush_proc
		if (_sv2v_0)
			;
		o_hazard_unit_flush_ex = (lwstall_detection || i_hazard_unit_pcsrc_ex) || i_hazard_unit_csr_flush_ex;
		o_hazard_unit_flush_id = i_hazard_unit_pcsrc_ex || i_hazard_unit_csr_flush_id;
		o_hazard_unit_flush_mem = i_hazard_unit_csr_flush_mem;
		o_hazard_unit_flush_wb = i_hazard_unit_csr_flush_wb;
	end
	initial _sv2v_0 = 0;
endmodule
