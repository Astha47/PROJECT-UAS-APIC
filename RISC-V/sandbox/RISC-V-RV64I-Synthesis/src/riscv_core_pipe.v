module riscv_core_pipe (
	i_pipe_clk,
	i_pipe_rst_n,
	i_pipe_clr,
	i_pipe_en_n,
	i_pipe_in,
	o_pipe_out
);
	parameter W_PIPE_BUS = 32;
	input wire i_pipe_clk;
	input wire i_pipe_rst_n;
	input wire i_pipe_clr;
	input wire i_pipe_en_n;
	input wire [W_PIPE_BUS - 1:0] i_pipe_in;
	output reg [W_PIPE_BUS - 1:0] o_pipe_out;
	always @(posedge i_pipe_clk or negedge i_pipe_rst_n) begin : pipe_proc
		if (!i_pipe_rst_n)
			o_pipe_out <= 'b0;
		else if (i_pipe_clr)
			o_pipe_out <= 'b0;
		else if (!i_pipe_en_n)
			o_pipe_out <= i_pipe_in;
		else
			o_pipe_out <= o_pipe_out;
	end
endmodule
