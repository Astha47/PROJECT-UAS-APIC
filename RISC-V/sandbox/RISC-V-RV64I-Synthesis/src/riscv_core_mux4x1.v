module riscv_core_mux4x1 (
	i_mux4x1_in0,
	i_mux4x1_in1,
	i_mux4x1_in2,
	i_mux4x1_in3,
	i_mux4x1_sel,
	o_mux4x1_out
);
	reg _sv2v_0;
	parameter XLEN = 64;
	input wire [XLEN - 1:0] i_mux4x1_in0;
	input wire [XLEN - 1:0] i_mux4x1_in1;
	input wire [XLEN - 1:0] i_mux4x1_in2;
	input wire [XLEN - 1:0] i_mux4x1_in3;
	input wire [1:0] i_mux4x1_sel;
	output reg [XLEN - 1:0] o_mux4x1_out;
	always @(*) begin : out_proc
		if (_sv2v_0)
			;
		case (i_mux4x1_sel)
			2'b00: o_mux4x1_out = i_mux4x1_in0;
			2'b01: o_mux4x1_out = i_mux4x1_in1;
			2'b10: o_mux4x1_out = i_mux4x1_in2;
			2'b11: o_mux4x1_out = i_mux4x1_in3;
			default: o_mux4x1_out = 'bx;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
