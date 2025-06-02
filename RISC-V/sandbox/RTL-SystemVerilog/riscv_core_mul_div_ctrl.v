module riscv_core_mul_div_ctrl (
	i_mul_div_ctrl_srcA,
	i_mul_div_ctrl_srcB,
	i_mul_div_ctrl_control,
	i_mul_div_ctrl_en,
	i_mul_div_ctrl_isword,
	i_mul_div_ctrl_clk,
	i_mul_div_ctrl_rstn,
	i_mul_div_ctrl_mul_dn,
	i_mul_div_ctrl_div_dn,
	o_mul_div_ctrl_out_fast,
	o_mul_div_ctrl_mul_start,
	o_mul_div_ctrl_div_start,
	o_mul_div_ctrl_busy,
	o_mul_div_ctrl_done,
	o_mul_div_ctrl_div_by_zero,
	o_mul_div_ctrl_overflow,
	o_mul_div_ctrl_mul_div_sel,
	o_mul_div_ctrl_out_sel
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_mul_div_ctrl_srcA;
	input wire [XLEN - 1:0] i_mul_div_ctrl_srcB;
	input wire [2:0] i_mul_div_ctrl_control;
	input wire i_mul_div_ctrl_en;
	input wire i_mul_div_ctrl_isword;
	input wire i_mul_div_ctrl_clk;
	input wire i_mul_div_ctrl_rstn;
	input wire i_mul_div_ctrl_mul_dn;
	input wire i_mul_div_ctrl_div_dn;
	output reg [XLEN - 1:0] o_mul_div_ctrl_out_fast;
	output reg o_mul_div_ctrl_mul_start;
	output reg o_mul_div_ctrl_div_start;
	output reg o_mul_div_ctrl_busy;
	output reg o_mul_div_ctrl_done;
	output reg o_mul_div_ctrl_div_by_zero;
	output reg o_mul_div_ctrl_overflow;
	output wire o_mul_div_ctrl_mul_div_sel;
	output wire o_mul_div_ctrl_out_sel;
	reg [1:0] state_reg;
	reg [1:0] state_next;
	localparam [6:0] OVERFLOW = 7'b0000001;
	localparam [6:0] DIVBYZERO = 7'b0100000;
	wire [6:0] fast_reg;
	wire [6:0] fastw_reg;
	reg fast_sel;
	reg [XLEN - 1:0] out_fast;
	reg div_by_zero;
	reg overflow;
	assign fast_reg = {i_mul_div_ctrl_srcB == -32'sd1, i_mul_div_ctrl_srcB == 32'sd1, i_mul_div_ctrl_srcB == 32'sd0, i_mul_div_ctrl_srcA == -32'sd1, i_mul_div_ctrl_srcA == 32'sd1, i_mul_div_ctrl_srcA == 32'sd0, ((i_mul_div_ctrl_srcA == 64'h8000000000000000) & (i_mul_div_ctrl_srcB == -32'sd1)) & (i_mul_div_ctrl_control == 3'b1x0)};
	assign fastw_reg = {i_mul_div_ctrl_srcB[(XLEN / 2) - 1:0] == -32'sd1, i_mul_div_ctrl_srcB[(XLEN / 2) - 1:0] == 32'sd1, i_mul_div_ctrl_srcB[(XLEN / 2) - 1:0] == 32'sd0, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0] == -32'sd1, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0] == 32'sd1, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0] == 32'sd0, (i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0] == 32'h80000000) & (i_mul_div_ctrl_srcB[(XLEN / 2) - 1:0] == -32'sd1)};
	always @(*) begin : fast_result_proc
		if (_sv2v_0)
			;
		out_fast = 0;
		div_by_zero = 1'b0;
		overflow = 1'b0;
		fast_sel = 1'b0;
		if (!i_mul_div_ctrl_isword)
			casex (fast_reg)
				7'b1000001: begin
					if (i_mul_div_ctrl_control[1])
						out_fast = 0;
					else
						out_fast = 64'h8000000000000000;
					fast_sel = 1;
					overflow = 1;
				end
				7'b001xxx0: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = i_mul_div_ctrl_srcA;
						else
							out_fast = 64'hffffffffffffffff;
					end
					else
						out_fast = 0;
					fast_sel = 1;
					div_by_zero = 1;
				end
				7'bxx00010: begin
					out_fast = 0;
					fast_sel = 1;
				end
				7'b1000000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = ~i_mul_div_ctrl_srcA + 1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = ~i_mul_div_ctrl_srcA + 1;
						fast_sel = 1;
					end
					else begin
						out_fast = 64'hffffffffffffffff;
						fast_sel = 0;
					end
				7'b0100000: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 0;
						else
							out_fast = i_mul_div_ctrl_srcA;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = i_mul_div_ctrl_srcA;
					else
						out_fast = 0;
					fast_sel = 1;
				end
				7'b1001000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = 1;
							fast_sel = 1;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = 1;
						fast_sel = 1;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b01) begin
						out_fast = 0;
						fast_sel = 1;
					end
					else begin
						out_fast = 0;
						fast_sel = 0;
					end
				7'b0100100: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 0;
						else
							out_fast = 1;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = 1;
					else
						out_fast = 0;
					fast_sel = 1;
				end
				7'b1000100:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = -1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = -1;
						fast_sel = 1;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b01) begin
						out_fast = -1;
						fast_sel = 1;
					end
					else begin
						out_fast = 0;
						fast_sel = 1;
					end
				7'b0101000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = -1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = -1;
						fast_sel = 1;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b11) begin
						out_fast = 0;
						fast_sel = 1;
					end
					else begin
						out_fast = -1;
						fast_sel = 1;
					end
				7'b0000100: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 1;
						else
							out_fast = 0;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = i_mul_div_ctrl_srcB;
					else
						out_fast = 0;
					fast_sel = 1;
				end
				default: begin
					out_fast = 0;
					fast_sel = 0;
				end
			endcase
		else
			casex (fastw_reg)
				7'b1000001: begin
					if (i_mul_div_ctrl_control[1])
						out_fast = 0;
					else
						out_fast = 64'hffffffff80000000;
					fast_sel = 1;
					overflow = 1;
				end
				7'b001xxx0: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = {{XLEN / 2 {i_mul_div_ctrl_srcA[(XLEN / 2) - 1]}}, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0]};
						else
							out_fast = 64'hffffffffffffffff;
					end
					else
						out_fast = 0;
					fast_sel = 1;
					div_by_zero = 1;
				end
				7'bxx00010: begin
					out_fast = 0;
					fast_sel = 1;
				end
				7'b1000000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = ~i_mul_div_ctrl_srcA + 1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = ~i_mul_div_ctrl_srcA + 1;
						fast_sel = 1;
					end
					else begin
						out_fast = 64'hffffffffffffffff;
						fast_sel = 0;
					end
				7'b0100000: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 0;
						else
							out_fast = {{XLEN / 2 {i_mul_div_ctrl_srcA[(XLEN / 2) - 1]}}, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0]};
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = {{XLEN / 2 {i_mul_div_ctrl_srcA[(XLEN / 2) - 1]}}, i_mul_div_ctrl_srcA[(XLEN / 2) - 1:0]};
					else
						out_fast = 0;
					fast_sel = 1;
				end
				7'b1001000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = 1;
							fast_sel = 1;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = 1;
						fast_sel = 1;
					end
					else begin
						out_fast = 0;
						fast_sel = 0;
					end
				7'b0100100: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 0;
						else
							out_fast = 1;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = 1;
					else
						out_fast = 0;
					fast_sel = 1;
				end
				7'b1000100:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = -1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = -1;
						fast_sel = 1;
					end
					else begin
						out_fast = -1;
						fast_sel = 0;
					end
				7'b0101000:
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1]) begin
							out_fast = 0;
							fast_sel = 1;
						end
						else begin
							out_fast = -1;
							fast_sel = 0;
						end
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00) begin
						out_fast = -1;
						fast_sel = 1;
					end
					else begin
						out_fast = -1;
						fast_sel = 0;
					end
				7'b0000100: begin
					if (i_mul_div_ctrl_control[2]) begin
						if (i_mul_div_ctrl_control[1])
							out_fast = 1;
						else
							out_fast = 0;
					end
					else if (i_mul_div_ctrl_control[1:0] == 2'b00)
						out_fast = i_mul_div_ctrl_srcB;
					else
						out_fast = 0;
					fast_sel = 1;
				end
				default: begin
					out_fast = 0;
					fast_sel = 0;
				end
			endcase
	end
	always @(posedge i_mul_div_ctrl_clk or negedge i_mul_div_ctrl_rstn) begin : state_register_proc
		if (!i_mul_div_ctrl_rstn)
			state_reg <= 2'd0;
		else
			state_reg <= state_next;
	end
	always @(*) begin : next_state_logic_proc
		if (_sv2v_0)
			;
		o_mul_div_ctrl_mul_start = 1'b0;
		o_mul_div_ctrl_div_start = 1'b0;
		o_mul_div_ctrl_busy = 1'b0;
		case (state_reg)
			2'd0:
				if (i_mul_div_ctrl_en & fast_sel) begin
					state_next = 2'd1;
					o_mul_div_ctrl_busy = 1'b1;
				end
				else if (i_mul_div_ctrl_en & !i_mul_div_ctrl_control[2]) begin
					state_next = 2'd2;
					o_mul_div_ctrl_mul_start = 1'b1;
					o_mul_div_ctrl_busy = 1'b1;
				end
				else if (i_mul_div_ctrl_en & i_mul_div_ctrl_control[2]) begin
					state_next = 2'd3;
					o_mul_div_ctrl_div_start = 1'b1;
					o_mul_div_ctrl_busy = 1'b1;
				end
				else begin
					o_mul_div_ctrl_busy = 1'b0;
					state_next = 2'd0;
				end
			2'd1: state_next = 2'd0;
			2'd2:
				if (i_mul_div_ctrl_mul_dn) begin
					state_next = 2'd0;
					o_mul_div_ctrl_busy = 1'b0;
				end
				else begin
					state_next = 2'd2;
					o_mul_div_ctrl_busy = 1'b1;
				end
			2'd3:
				if (i_mul_div_ctrl_div_dn) begin
					state_next = 2'd0;
					o_mul_div_ctrl_busy = 1'b0;
				end
				else begin
					state_next = 2'd3;
					o_mul_div_ctrl_busy = 1'b1;
				end
			default: state_next = 2'd0;
		endcase
	end
	always @(*) begin : output_logic_proc
		if (_sv2v_0)
			;
		o_mul_div_ctrl_out_fast = 0;
		o_mul_div_ctrl_done = 1'b0;
		o_mul_div_ctrl_div_by_zero = 1'b0;
		o_mul_div_ctrl_overflow = 1'b0;
		case (state_reg)
			2'd0: begin
				o_mul_div_ctrl_out_fast = 0;
				o_mul_div_ctrl_div_by_zero = 0;
				o_mul_div_ctrl_overflow = 0;
			end
			2'd1: begin
				o_mul_div_ctrl_out_fast = out_fast;
				o_mul_div_ctrl_div_by_zero = div_by_zero;
				o_mul_div_ctrl_overflow = overflow;
				o_mul_div_ctrl_done = 1'b1;
			end
			2'd2:
				if (i_mul_div_ctrl_mul_dn)
					o_mul_div_ctrl_done = 1'b1;
				else
					o_mul_div_ctrl_done = 1'b0;
			2'd3:
				if (i_mul_div_ctrl_div_dn)
					o_mul_div_ctrl_done = 1'b1;
				else
					o_mul_div_ctrl_done = 1'b0;
			default: begin
				o_mul_div_ctrl_out_fast = 0;
				o_mul_div_ctrl_done = 1'b0;
				o_mul_div_ctrl_div_by_zero = 1'b0;
				o_mul_div_ctrl_overflow = 1'b0;
			end
		endcase
	end
	assign o_mul_div_ctrl_mul_div_sel = i_mul_div_ctrl_control[2];
	assign o_mul_div_ctrl_out_sel = fast_sel;
	initial _sv2v_0 = 0;
endmodule
