module riscv_core_ldextend (
	i_ldextend_su_extend,
	i_ldextend_r_w_size,
	i_ldextend_rdata,
	o_ldextend_rdata
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire i_ldextend_su_extend;
	input wire [1:0] i_ldextend_r_w_size;
	input wire [XLEN - 1:0] i_ldextend_rdata;
	output reg [XLEN - 1:0] o_ldextend_rdata;
	always @(*) begin : ldextend_proc
		if (_sv2v_0)
			;
		if (!i_ldextend_su_extend)
			case (i_ldextend_r_w_size)
				2'b00: o_ldextend_rdata = {{56 {i_ldextend_rdata[7]}}, i_ldextend_rdata[7:0]};
				2'b01: o_ldextend_rdata = {{48 {i_ldextend_rdata[15]}}, i_ldextend_rdata[15:0]};
				2'b10: o_ldextend_rdata = {{32 {i_ldextend_rdata[31]}}, i_ldextend_rdata[31:0]};
				2'b11: o_ldextend_rdata = i_ldextend_rdata;
				default: o_ldextend_rdata = i_ldextend_rdata;
			endcase
		else
			case (i_ldextend_r_w_size)
				2'b00: o_ldextend_rdata = {{56 {1'b0}}, i_ldextend_rdata[7:0]};
				2'b01: o_ldextend_rdata = {{48 {1'b0}}, i_ldextend_rdata[15:0]};
				2'b10: o_ldextend_rdata = {{32 {1'b0}}, i_ldextend_rdata[31:0]};
				2'b11: o_ldextend_rdata = i_ldextend_rdata;
				default: o_ldextend_rdata = i_ldextend_rdata;
			endcase
	end
	initial _sv2v_0 = 0;
endmodule
