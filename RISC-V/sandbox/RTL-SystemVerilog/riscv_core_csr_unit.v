module riscv_core_csr_unit (
	i_csr_unit_clk,
	i_csr_unit_rst_n,
	i_csr_unit_pc,
	i_csr_unit_mem_wen,
	i_csr_unit_fault_addr,
	i_csr_unit_instr,
	i_csr_unit_mexternal,
	i_csr_unit_sexternal,
	o_csr_unit_ack,
	i_csr_unit_csr_wen,
	i_csr_unit_op,
	i_csr_unit_src,
	i_csr_unit_csr_addr,
	o_csr_unit_csr_rdata,
	o_csr_unit_irq_handler,
	o_csr_unit_rtrn_addr,
	o_csr_unit_addr_ctrl,
	o_csr_unit_mux1,
	i_csr_unit_mret_wb,
	i_csr_unit_ecall,
	i_csr_unit_ebreak,
	i_csr_unit_sret,
	i_csr_unit_illegal_instr_id,
	i_csr_unit_illegal_instr_exe,
	i_csr_unit_instr_addr_misaligned,
	i_csr_unit_lw_access_fault,
	i_csr_unit_sw_access_fault,
	o_csr_unit_if_flush,
	o_csr_unit_id_flush,
	o_csr_unit_exe_flush,
	o_csr_unit_mem_flush
);
	reg _sv2v_0;
	input wire i_csr_unit_clk;
	input wire i_csr_unit_rst_n;
	input wire [63:0] i_csr_unit_pc;
	input wire i_csr_unit_mem_wen;
	input wire [63:0] i_csr_unit_fault_addr;
	input wire [31:0] i_csr_unit_instr;
	input wire i_csr_unit_mexternal;
	input wire i_csr_unit_sexternal;
	output reg o_csr_unit_ack;
	input wire i_csr_unit_csr_wen;
	input wire [1:0] i_csr_unit_op;
	input wire [63:0] i_csr_unit_src;
	input wire [11:0] i_csr_unit_csr_addr;
	output reg [63:0] o_csr_unit_csr_rdata;
	output wire [63:0] o_csr_unit_irq_handler;
	output reg [63:0] o_csr_unit_rtrn_addr;
	output wire o_csr_unit_addr_ctrl;
	output wire o_csr_unit_mux1;
	input wire i_csr_unit_mret_wb;
	input wire i_csr_unit_ecall;
	input wire i_csr_unit_ebreak;
	input wire i_csr_unit_sret;
	input wire i_csr_unit_illegal_instr_id;
	input wire i_csr_unit_illegal_instr_exe;
	input wire i_csr_unit_instr_addr_misaligned;
	input wire i_csr_unit_lw_access_fault;
	input wire i_csr_unit_sw_access_fault;
	output wire o_csr_unit_if_flush;
	output wire o_csr_unit_id_flush;
	output wire o_csr_unit_exe_flush;
	output wire o_csr_unit_mem_flush;
	wire [63:0] mstatus;
	wire [63:0] misa;
	wire [63:0] mie;
	wire [63:0] mip;
	reg [63:0] mcause;
	reg [63:0] mepc;
	reg [63:0] mtval;
	reg [63:0] mtinst;
	reg [63:0] mtvec;
	reg [63:0] mscratch;
	reg [63:0] mtimecmp;
	reg [63:0] medeleg;
	reg [63:0] mideleg;
	wire [63:0] sstatus;
	wire [63:0] sip;
	wire [63:0] sie;
	reg [63:0] stvec;
	reg [63:0] sepc;
	reg [63:0] scause;
	reg [63:0] stval;
	wire [63:0] satp;
	reg [63:0] sscratch;
	reg [63:0] stimecmp;
	reg [63:0] counter;
	reg [63:0] op_result;
	reg [1:0] current_mode;
	reg [63:0] tvec;
	reg [63:0] cause;
	reg current_state;
	wire [63:0] direct_addr;
	wire [63:0] vector_addr;
	wire [63:0] intrr_addr;
	wire [63:0] expn_addr;
	wire pending_exception;
	wire csr_flush_mem;
	wire csr_flush_exe;
	wire csr_flush_id;
	wire csr_flush_if;
	reg mstatus_mie;
	reg mstatus_mpie;
	reg mstatus_sie;
	reg mstatus_spie;
	reg [1:0] mstatus_mpp;
	reg mstatus_spp;
	reg sstatus_sie;
	reg sstatus_spie;
	reg sstatus_spp;
	reg mip_meip;
	reg mip_mtip;
	reg ip_seip;
	reg ip_stip;
	reg mie_meie;
	reg mie_seie;
	reg mie_stie;
	reg mie_mtie;
	reg [47:0] mie_reserved;
	reg [47:0] sie_reserved;
	reg sie_seie;
	reg sie_stie;
	assign misa = 64'b1000000000000000000000000000000000000000000001000001000100000101;
	assign mstatus = {51'b000000000000000000000000000000000000000000000000000, mstatus_mpp, 2'b00, mstatus_spp, mstatus_mpie, 1'b0, mstatus_spie, 1'b0, mstatus_mie, 1'b0, mstatus_sie, 1'b0};
	assign sstatus = {55'b0000000000000000000000000000000000000000000000000000000, sstatus_spp, 2'b00, sstatus_spie, 3'b000, sstatus_sie, 1'b0};
	assign mip = {52'b0000000000000000000000000000000000000000000000000000, mip_meip, 1'b0, ip_seip, 1'b0, mip_mtip, 1'b0, ip_stip, 5'b00000};
	assign sip = {54'b000000000000000000000000000000000000000000000000000000, ip_seip, 3'b000, ip_stip, 5'b00000};
	assign sie = {sie_reserved, 6'b000000, sie_seie, 3'b000, sie_stie, 5'b00000};
	assign mie = {mie_reserved, 4'b0000, mie_meie, 1'b0, mie_seie, 1'b0, mie_mtie, 1'b0, mie_stie, 5'b00000};
	assign satp = 64'b0000000000000000000000000000000000000000000000000000000000000000;
	always @(*) begin
		if (_sv2v_0)
			;
		case (i_csr_unit_op)
			2'h1: op_result = i_csr_unit_src;
			2'h2: op_result = o_csr_unit_csr_rdata | i_csr_unit_src;
			2'h3: op_result = o_csr_unit_csr_rdata & ~i_csr_unit_src;
			default: op_result = 64'h0000000000000000;
		endcase
	end
	always @(*) begin : output_assignment_proc
		if (_sv2v_0)
			;
		if (!i_csr_unit_rst_n)
			o_csr_unit_csr_rdata = 64'b0000000000000000000000000000000000000000000000000000000000000000;
		else
			case (i_csr_unit_csr_addr)
				12'hf11: o_csr_unit_csr_rdata = 32'b00000000000000000000000000000000;
				12'hf12: o_csr_unit_csr_rdata = 64'b0000000000000000000000000000000000000000000000000000000000000000;
				12'hf14: o_csr_unit_csr_rdata = 64'b0000000000000000000000000000000000000000000000000000000000000000;
				12'hf13: o_csr_unit_csr_rdata = 64'b0000000000000000000000000000000000000000000000000000000000000000;
				12'h301: o_csr_unit_csr_rdata = misa;
				12'h302: o_csr_unit_csr_rdata = medeleg;
				12'h303: o_csr_unit_csr_rdata = mideleg;
				12'h300: o_csr_unit_csr_rdata = mstatus;
				12'h304: o_csr_unit_csr_rdata = mie;
				12'h344: o_csr_unit_csr_rdata = mip;
				12'h342: o_csr_unit_csr_rdata = mcause;
				12'h305: o_csr_unit_csr_rdata = mtvec;
				12'h341: o_csr_unit_csr_rdata = mepc;
				12'h343: o_csr_unit_csr_rdata = mtval;
				12'h34a: o_csr_unit_csr_rdata = mtinst;
				12'h340: o_csr_unit_csr_rdata = mscratch;
				12'hc01: o_csr_unit_csr_rdata = counter;
				12'hc00: o_csr_unit_csr_rdata = counter;
				12'hbbf: o_csr_unit_csr_rdata = mtimecmp;
				12'h100: o_csr_unit_csr_rdata = sstatus;
				12'h104: o_csr_unit_csr_rdata = sie;
				12'h144: o_csr_unit_csr_rdata = sip;
				12'h142: o_csr_unit_csr_rdata = scause;
				12'h105: o_csr_unit_csr_rdata = stvec;
				12'h141: o_csr_unit_csr_rdata = sepc;
				12'h143: o_csr_unit_csr_rdata = stval;
				12'h140: o_csr_unit_csr_rdata = sscratch;
				12'h180: o_csr_unit_csr_rdata = satp;
				12'h14d: o_csr_unit_csr_rdata = stimecmp;
				default: o_csr_unit_csr_rdata = 64'b0000000000000000000000000000000000000000000000000000000000000000;
			endcase
	end
	always @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n) begin : trap_setup_proc
		if (!i_csr_unit_rst_n) begin
			current_state <= 1'd0;
			mstatus_mpp <= 2'b11;
			mstatus_spp <= 1'b0;
			sstatus_spp <= 1'b0;
			mcause <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			scause <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mepc = 64'b0000000000000000000000000000000000000000000000000000000000000000;
			sepc = 64'b0000000000000000000000000000000000000000000000000000000000000000;
			stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
		end
		else
			case (current_state)
				1'd0: begin
					if (i_csr_unit_csr_wen) begin
						if (i_csr_unit_mret_wb)
							mstatus_mpp <= 2'b00;
						else if (i_csr_unit_sret)
							sstatus_spp <= 1'b0;
						else if (i_csr_unit_csr_addr == 12'h300) begin
							mstatus_mpp <= op_result[12:11];
							mstatus_spp <= op_result[8];
						end
						else if (i_csr_unit_csr_addr == 12'h100)
							sstatus_spp <= op_result[8];
						else if (i_csr_unit_csr_addr == 12'h342)
							mcause <= op_result;
						else if (i_csr_unit_csr_addr == 12'h343)
							mtval <= op_result;
						else if (i_csr_unit_csr_addr == 12'h34a)
							mtinst <= op_result;
						else if (i_csr_unit_csr_addr == 12'h142)
							scause <= op_result;
						else if (i_csr_unit_csr_addr == 12'h143)
							stval <= op_result;
					end
					if ((mstatus_mie & mie_meie) & mip_meip) begin
						mepc = i_csr_unit_pc;
						current_state <= 1'd1;
						mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
						mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
						mcause[63] <= 1'b1;
						mcause[62:0] <= 63'h000000000000000b;
						o_csr_unit_ack <= 1'b1;
						mstatus_mpp <= current_mode;
					end
					else if ((mstatus_mie & mie_mtie) & mip_mtip) begin
						mepc = i_csr_unit_pc;
						current_state <= 1'd1;
						mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
						mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
						mcause[63] <= 1'b1;
						mcause[62:0] <= 63'h0000000000000007;
						mstatus_mpp <= current_mode;
					end
					else if ((mstatus_sie & mie_seie) & ip_seip) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mcause[63] <= 1'b1;
								mcause[62:0] <= 63'h0000000000000009;
								o_csr_unit_ack <= 1'b1;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (mideleg[9]) begin
									sepc = i_csr_unit_pc;
									stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									scause[63] <= 1'b1;
									scause[62:0] <= 63'h0000000000000009;
									o_csr_unit_ack <= 1'b1;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mcause[63] <= 1'b1;
									mcause[62:0] <= 63'h0000000000000009;
									o_csr_unit_ack <= 1'b1;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if ((mstatus_sie & mie_stie) & ip_stip) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mcause[63] <= 1'b1;
								mcause[62:0] <= 63'h0000000000000005;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (mideleg[5]) begin
									sepc = i_csr_unit_pc;
									stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									scause[63] <= 1'b1;
									scause[62:0] <= 63'h0000000000000005;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mtinst <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mcause[63] <= 1'b1;
									mcause[62:0] <= 63'h0000000000000005;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if (i_csr_unit_illegal_instr_id || i_csr_unit_illegal_instr_exe) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mtinst <= i_csr_unit_instr;
								mcause[63] <= 1'b0;
								mcause[62:0] <= 63'h0000000000000002;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (medeleg[2]) begin
									sepc = i_csr_unit_pc;
									stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									scause[63] <= 1'b0;
									scause[62:0] <= 63'h0000000000000002;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mtinst <= i_csr_unit_instr;
									mcause[63] <= 1'b0;
									mcause[62:0] <= 63'h0000000000000002;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if (i_csr_unit_instr_addr_misaligned) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mtinst <= i_csr_unit_instr;
								mcause[63] <= 1'b0;
								mcause[62:0] <= 63'h0000000000000000;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (medeleg[0]) begin
									sepc = i_csr_unit_pc;
									stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									scause[63] <= 1'b0;
									scause[62:0] <= 63'h0000000000000000;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mtinst <= i_csr_unit_instr;
									mcause[63] <= 1'b0;
									mcause[62:0] <= 63'h0000000000000000;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if (i_csr_unit_ecall) begin
						current_state <= 1'd1;
						mepc = i_csr_unit_pc;
						mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
						mtinst <= i_csr_unit_instr;
						mcause[63] <= 1'b0;
						mcause[62:0] <= 63'h000000000000000b;
						mstatus_mpp <= 2'b11;
					end
					else if (i_csr_unit_ebreak) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
								mtinst <= i_csr_unit_instr;
								mcause[63] <= 1'b0;
								mcause[62:0] <= 63'h0000000000000003;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (medeleg[3]) begin
									sepc = i_csr_unit_pc;
									stval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									scause[63] <= 1'b0;
									scause[62:0] <= 63'h0000000000000003;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
									mtinst <= i_csr_unit_instr;
									mcause[63] <= 1'b0;
									mcause[62:0] <= 63'h0000000000000003;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if (i_csr_unit_sw_access_fault) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= i_csr_unit_fault_addr;
								mtinst <= i_csr_unit_instr;
								mcause[63] <= 1'b0;
								mcause[62:0] <= 63'h0000000000000007;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (medeleg[7]) begin
									sepc = i_csr_unit_pc;
									stval <= i_csr_unit_fault_addr;
									scause[63] <= 1'b0;
									scause[62:0] <= 63'h0000000000000007;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= i_csr_unit_fault_addr;
									mtinst <= i_csr_unit_instr;
									mcause[63] <= 1'b0;
									mcause[62:0] <= 63'h0000000000000007;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
					else if (i_csr_unit_lw_access_fault) begin
						current_state <= 1'd1;
						case (current_mode)
							2'b11: begin
								mepc = i_csr_unit_pc;
								mtval <= i_csr_unit_fault_addr;
								mtinst <= i_csr_unit_instr;
								mcause[63] <= 1'b0;
								mcause[62:0] <= 63'h0000000000000005;
								mstatus_mpp <= 2'b11;
							end
							2'b01:
								if (medeleg[5]) begin
									sepc = i_csr_unit_pc;
									stval <= i_csr_unit_fault_addr;
									scause[63] <= 1'b0;
									scause[62:0] <= 63'h0000000000000005;
									mstatus_spp <= 1'b1;
									sstatus_spp <= 1'b1;
								end
								else begin
									mepc = i_csr_unit_pc;
									mtval <= i_csr_unit_fault_addr;
									mtinst <= i_csr_unit_instr;
									mcause[63] <= 1'b0;
									mcause[62:0] <= 63'h0000000000000005;
									mstatus_mpp <= 2'b01;
								end
						endcase
					end
				end
				1'd1: begin
					current_state <= 1'd0;
					o_csr_unit_ack <= 1'b0;
				end
			endcase
	end
	always @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n) begin : csr_assignment_proc
		if (!i_csr_unit_rst_n) begin
			mstatus_sie <= 1'b0;
			mstatus_mie <= 1'b0;
			mstatus_spie <= 1'b0;
			mstatus_mpie <= 1'b0;
			sstatus_sie <= 1'b0;
			sstatus_spie <= 1'b0;
			mie_reserved <= 48'b000000000000000000000000000000000000000000000000;
			mie_meie <= 1'b0;
			mie_seie <= 1'b0;
			mie_stie <= 1'b0;
			mie_mtie <= 1'b0;
			medeleg <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mideleg <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			sie_reserved <= 48'b000000000000000000000000000000000000000000000000;
			sie_seie <= 1'b0;
			sie_stie <= 1'b0;
			mtvec <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			stvec <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mscratch <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			mtimecmp <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			stimecmp <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
			sscratch <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
		end
		else if (i_csr_unit_csr_wen) begin
			if (i_csr_unit_mret_wb) begin
				mstatus_mie <= mstatus_mpie;
				mstatus_mpie <= 1'b1;
			end
			else if (i_csr_unit_sret) begin
				sstatus_sie <= sstatus_spie;
				sstatus_spie <= 1'b1;
			end
			else
				case (i_csr_unit_csr_addr)
					12'h300: begin
						mstatus_mie <= op_result[3];
						mstatus_mpie <= op_result[7];
						mstatus_sie <= op_result[1];
						mstatus_spie <= op_result[5];
					end
					12'h100: begin
						sstatus_sie <= op_result[1];
						sstatus_spie <= op_result[5];
					end
					12'h304: begin
						mie_meie <= op_result[11];
						mie_mtie <= op_result[7];
						mie_seie <= op_result[9];
						mie_stie <= op_result[5];
						mie_reserved <= op_result[63:16];
					end
					12'h305: mtvec <= op_result;
					12'h340: mscratch <= op_result;
					12'h302: medeleg <= op_result;
					12'h303: mideleg <= op_result;
					12'hbbf: mtimecmp <= op_result;
					12'h104: begin
						sie_seie <= op_result[9];
						sie_stie <= op_result[5];
						sie_reserved <= op_result[63:16];
					end
					12'h105: stvec <= op_result;
					12'h140: sscratch <= op_result;
					12'h14d: stimecmp <= op_result;
				endcase
		end
		else
			case (current_state)
				1'd1: begin
					mstatus_mpie <= mstatus_mie;
					mstatus_spie <= mstatus_sie;
					mstatus_mie <= 1'b0;
					mstatus_sie <= 1'b0;
					sstatus_spie <= sstatus_sie;
					sstatus_sie <= 1'b0;
				end
			endcase
	end
	always @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n)
		if (!i_csr_unit_rst_n) begin
			mip_meip <= 1'b0;
			mip_mtip <= 1'b0;
			ip_stip <= 1'b0;
			ip_seip <= 1'b0;
		end
		else begin
			mip_meip <= i_csr_unit_mexternal;
			ip_seip <= i_csr_unit_sexternal;
			mip_mtip <= counter >= mtimecmp;
			ip_stip <= counter >= stimecmp;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		current_mode = mstatus_mpp;
		if (i_csr_unit_mret_wb)
			current_mode = mstatus_mpp;
		else if (i_csr_unit_sret)
			current_mode = 2'b01;
	end
	always @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n) begin : timer_proc
		if (!i_csr_unit_rst_n)
			counter <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
		else
			counter <= counter + 1;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (i_csr_unit_mret_wb)
			o_csr_unit_rtrn_addr = mepc;
		else if (i_csr_unit_sret)
			o_csr_unit_rtrn_addr = sepc;
		else
			o_csr_unit_rtrn_addr = stvec;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (mstatus_spp) begin
			tvec = stvec;
			cause = scause;
		end
		else begin
			tvec = mtvec;
			cause = mcause;
		end
	end
	assign pending_exception = (((i_csr_unit_illegal_instr_id | i_csr_unit_illegal_instr_exe) | i_csr_unit_instr_addr_misaligned) | i_csr_unit_ecall) | i_csr_unit_ebreak;
	assign o_csr_unit_irq_handler = (tvec[0] ? vector_addr : direct_addr);
	assign direct_addr = tvec;
	assign vector_addr = (cause[63] ? intrr_addr : expn_addr);
	assign expn_addr = {tvec[63:1], 1'b0};
	assign intrr_addr = {tvec[63:1], 1'b0} + (cause << 2);
	assign o_csr_unit_addr_ctrl = i_csr_unit_mret_wb | i_csr_unit_sret;
	assign o_csr_unit_mux1 = ((current_state == 1'd1) | i_csr_unit_mret_wb) | i_csr_unit_sret;
	assign csr_flush_mem = ((i_csr_unit_lw_access_fault | i_csr_unit_sw_access_fault) | ((mstatus_mie | mstatus_sie) & i_csr_unit_mem_wen)) | (i_csr_unit_mret_wb | i_csr_unit_sret);
	assign csr_flush_exe = ((csr_flush_mem | i_csr_unit_illegal_instr_exe) | i_csr_unit_instr_addr_misaligned) | (mstatus_mie | mstatus_sie);
	assign csr_flush_id = (csr_flush_exe | pending_exception) | (mstatus_mie | mstatus_sie);
	assign csr_flush_if = (((pending_exception | (current_state == 1'd1)) | mstatus_mie) | mstatus_sie) | (i_csr_unit_mret_wb | i_csr_unit_sret);
	assign o_csr_unit_mem_flush = csr_flush_mem;
	assign o_csr_unit_exe_flush = csr_flush_exe;
	assign o_csr_unit_id_flush = csr_flush_id;
	assign o_csr_unit_if_flush = csr_flush_if;
	initial _sv2v_0 = 0;
endmodule
