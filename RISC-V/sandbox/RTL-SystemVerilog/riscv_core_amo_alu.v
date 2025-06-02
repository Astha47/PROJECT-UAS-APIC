module riscv_core_amo_alu (
	i_data_from_mem,
	i_data_from_core,
	i_amo_op,
	o_amo_alu_result
);
	reg _sv2v_0;
	parameter DATA_WIDTH = 64;
	input wire [DATA_WIDTH - 1:0] i_data_from_mem;
	input wire [DATA_WIDTH - 1:0] i_data_from_core;
	input wire [3:0] i_amo_op;
	output reg [DATA_WIDTH - 1:0] o_amo_alu_result;
	always @(*) begin : amo_operations
		if (_sv2v_0)
			;
		o_amo_alu_result = 'b0;
		case (i_amo_op)
			4'b0000: o_amo_alu_result = i_data_from_core;
			4'b0001: o_amo_alu_result = i_data_from_mem + i_data_from_core;
			4'b0010: o_amo_alu_result = i_data_from_mem & i_data_from_core;
			4'b0011: o_amo_alu_result = i_data_from_mem | i_data_from_core;
			4'b0100: o_amo_alu_result = i_data_from_mem ^ i_data_from_core;
			4'b0101: o_amo_alu_result = ($signed(i_data_from_mem) > $signed(i_data_from_core) ? i_data_from_mem : i_data_from_core);
			4'b0110: o_amo_alu_result = ($signed(i_data_from_mem) < $signed(i_data_from_core) ? i_data_from_mem : i_data_from_core);
			4'b0111: o_amo_alu_result = (i_data_from_mem > i_data_from_core ? i_data_from_mem : i_data_from_core);
			4'b1000: o_amo_alu_result = (i_data_from_mem < i_data_from_core ? i_data_from_mem : i_data_from_core);
			default: o_amo_alu_result = 'b0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
