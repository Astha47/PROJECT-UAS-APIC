module riscv_core_next_PC_logic (
	i_next_PC_logic_misprediction,
	i_next_PC_logic_valid,
	i_next_PC_logic_isTaken_BP,
	i_next_PC_logic_predictedAddr,
	i_next_PC_logic_recoveredAddr,
	i_next_PC_logic_PC_plus_offset,
	o_next_PC_logic_next_PC
);
	reg _sv2v_0;
	parameter ADDRLEN = 64;
	input wire i_next_PC_logic_misprediction;
	input wire i_next_PC_logic_valid;
	input wire i_next_PC_logic_isTaken_BP;
	input wire [ADDRLEN - 1:0] i_next_PC_logic_predictedAddr;
	input wire [ADDRLEN - 1:0] i_next_PC_logic_recoveredAddr;
	input wire [ADDRLEN - 1:0] i_next_PC_logic_PC_plus_offset;
	output reg [ADDRLEN - 1:0] o_next_PC_logic_next_PC;
	wire BP_sel;
	assign BP_sel = i_next_PC_logic_valid & i_next_PC_logic_isTaken_BP;
	always @(*) begin
		if (_sv2v_0)
			;
		if (i_next_PC_logic_misprediction)
			o_next_PC_logic_next_PC = i_next_PC_logic_recoveredAddr;
		else if (BP_sel)
			o_next_PC_logic_next_PC = i_next_PC_logic_predictedAddr;
		else
			o_next_PC_logic_next_PC = i_next_PC_logic_PC_plus_offset;
	end
	initial _sv2v_0 = 0;
endmodule
