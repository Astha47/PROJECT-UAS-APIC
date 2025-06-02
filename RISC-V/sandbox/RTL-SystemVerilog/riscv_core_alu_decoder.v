module riscv_core_alu_decoder (
	i_alu_decoder_funct3,
	i_alu_decoder_aluop,
	i_alu_decoder_funct7_5,
	i_alu_decoder_funct7_0,
	i_alu_decoder_opcode_5,
	o_alu_decoder_alucontrol
);
	reg _sv2v_0;
	input wire [2:0] i_alu_decoder_funct3;
	input wire i_alu_decoder_aluop;
	input wire i_alu_decoder_funct7_5;
	input wire i_alu_decoder_funct7_0;
	input wire i_alu_decoder_opcode_5;
	output wire [3:0] o_alu_decoder_alucontrol;
	reg [3:0] control_signals;
	assign o_alu_decoder_alucontrol = control_signals;
	always @(*) begin : write_alucontrol_proc
		if (_sv2v_0)
			;
		control_signals = 4'b0000;
		case (i_alu_decoder_aluop)
			1'b0: control_signals = 4'b0000;
			1'b1:
				if (!i_alu_decoder_funct7_0 && i_alu_decoder_opcode_5)
					case (i_alu_decoder_funct3)
						3'h0: control_signals = (i_alu_decoder_funct7_5 ? 4'b0001 : 4'b0000);
						3'h1: control_signals = 4'b0100;
						3'h2: control_signals = 4'b0101;
						3'h3: control_signals = 4'b1000;
						3'h4: control_signals = 4'b0110;
						3'h5: control_signals = (i_alu_decoder_funct7_5 ? 4'b1111 : 4'b0111);
						3'h6: control_signals = 4'b0011;
						3'h7: control_signals = 4'b0010;
						default: control_signals = 4'b0000;
					endcase
				else if (i_alu_decoder_funct7_0 && i_alu_decoder_opcode_5)
					case (i_alu_decoder_funct3)
						3'h0: control_signals = 4'b0000;
						3'h1: control_signals = 4'b0001;
						3'h2: control_signals = 4'b0010;
						3'h3: control_signals = 4'b0011;
						3'h4: control_signals = 4'b0100;
						3'h5: control_signals = 4'b0101;
						3'h6: control_signals = 4'b0110;
						3'h7: control_signals = 4'b0111;
						default: control_signals = 4'b0000;
					endcase
				else if (!i_alu_decoder_opcode_5)
					case (i_alu_decoder_funct3)
						3'h0: control_signals = 4'b0000;
						3'h1: control_signals = 4'b0100;
						3'h2: control_signals = 4'b0101;
						3'h3: control_signals = 4'b1000;
						3'h4: control_signals = 4'b0110;
						3'h5: control_signals = (i_alu_decoder_funct7_5 ? 4'b1111 : 4'b0111);
						3'h6: control_signals = 4'b0011;
						3'h7: control_signals = 4'b0010;
						default: control_signals = 4'b0000;
					endcase
			default: control_signals = 4'b0000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
