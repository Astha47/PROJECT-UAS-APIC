module riscv_core_mux_2to1 (
	i_input0,
	i_input1,
	i_sel,
	o_mux_out
);
	reg _sv2v_0;
	parameter DATA_WIDTH = 64;
	input wire [DATA_WIDTH - 1:0] i_input0;
	input wire [DATA_WIDTH - 1:0] i_input1;
	input wire i_sel;
	output reg [DATA_WIDTH - 1:0] o_mux_out;
	always @(*) begin : MUX_PROC
		if (_sv2v_0)
			;
		o_mux_out = 0;
		case (i_sel)
			1'b0: o_mux_out = i_input0;
			1'b1: o_mux_out = i_input1;
			default: o_mux_out = 0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
