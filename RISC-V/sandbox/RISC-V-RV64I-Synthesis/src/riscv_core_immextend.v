module riscv_core_immextend (
	i_immextend_imm,
	i_immextend_immsrc,
	o_immextend_out
);
	reg _sv2v_0;
	input wire [24:0] i_immextend_imm;
	input wire [2:0] i_immextend_immsrc;
	output reg [63:0] o_immextend_out;
	always @(*) begin : imm_extender
		if (_sv2v_0)
			;
		case (i_immextend_immsrc)
			3'b000: o_immextend_out = {{52 {i_immextend_imm[24]}}, i_immextend_imm[24:13]};
			3'b001: o_immextend_out = {{52 {i_immextend_imm[24]}}, i_immextend_imm[24:18], i_immextend_imm[4:0]};
			3'b010: o_immextend_out = {{52 {i_immextend_imm[24]}}, i_immextend_imm[0], i_immextend_imm[23:18], i_immextend_imm[4:1], 1'b0};
			3'b011: o_immextend_out = {{44 {i_immextend_imm[24]}}, i_immextend_imm[12:5], i_immextend_imm[13], i_immextend_imm[23:14], 1'b0};
			3'b100: o_immextend_out = {{32 {i_immextend_imm[24]}}, i_immextend_imm[24:5], {12 {1'b0}}};
			3'b101: o_immextend_out = 0;
			3'b110: o_immextend_out = {{59 {1'b0}}, i_immextend_imm[12:8]};
			default: o_immextend_out = {64 {1'b0}};
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
