module riscv_core_rf (
	i_rf_clk,
	i_rf_we3,
	i_rf_a1,
	i_rf_a2,
	i_rf_a3,
	i_rf_wd3,
	o_rf_rd1,
	o_rf_rd2
);
	input wire i_rf_clk;
	input wire i_rf_we3;
	input wire [4:0] i_rf_a1;
	input wire [4:0] i_rf_a2;
	input wire [4:0] i_rf_a3;
	input wire [63:0] i_rf_wd3;
	output wire [63:0] o_rf_rd1;
	output wire [63:0] o_rf_rd2;
	reg [63:0] rf [31:0];
	always @(negedge i_rf_clk)
		if (i_rf_we3 && (i_rf_a3 != 0))
			rf[i_rf_a3] <= i_rf_wd3;
	assign o_rf_rd1 = (i_rf_a1 != 0 ? rf[i_rf_a1] : 0);
	assign o_rf_rd2 = (i_rf_a2 != 0 ? rf[i_rf_a2] : 0);
endmodule
