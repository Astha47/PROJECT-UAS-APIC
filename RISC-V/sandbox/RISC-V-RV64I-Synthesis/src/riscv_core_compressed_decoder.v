module riscv_core_compressed_decoder (
	i_compressed_decoder_instr,
	o_compressed_decoder_instr,
	o_compressed_decoder_is_compressed,
	o_compressed_decoder_illegal_instr
);
	reg _sv2v_0;
	input wire [31:0] i_compressed_decoder_instr;
	output reg [31:0] o_compressed_decoder_instr;
	output reg o_compressed_decoder_is_compressed;
	output reg o_compressed_decoder_illegal_instr;
	localparam Q0 = 2'b00;
	localparam Q1 = 2'b01;
	localparam Q2 = 2'b10;
	localparam C_ADDI4SPN = 3'b000;
	localparam C_LW = 3'b010;
	localparam C_LD = 3'b011;
	localparam C_SW = 3'b110;
	localparam C_SD = 3'b111;
	localparam C_ADDI_NOP = 3'b000;
	localparam C_ADDIW = 3'b001;
	localparam C_LI = 3'b010;
	localparam C_ADDIL6SP_LUI = 3'b011;
	localparam C_J = 3'b101;
	localparam C_BEQZ = 3'b110;
	localparam C_BNEZ = 3'b111;
	localparam C_ARTH_LOGIC = 3'b100;
	localparam C_SLLI = 3'b000;
	localparam C_LWSP = 3'b010;
	localparam C_LDSP = 3'b011;
	localparam C_JR_MV_BR_JALR_ADD = 3'b100;
	localparam C_SWSP = 3'b110;
	localparam C_SDSP = 3'b111;
	always @(*) begin
		if (_sv2v_0)
			;
		o_compressed_decoder_is_compressed = 1'b1;
		o_compressed_decoder_illegal_instr = 1'b0;
		o_compressed_decoder_instr = i_compressed_decoder_instr;
		(* full_case, parallel_case *)
		case (i_compressed_decoder_instr[1:0])
			Q0:
				(* full_case, parallel_case *)
				case (i_compressed_decoder_instr[15:13])
					C_ADDI4SPN: begin
						o_compressed_decoder_instr = {2'b00, i_compressed_decoder_instr[10:7], i_compressed_decoder_instr[12:11], i_compressed_decoder_instr[5], i_compressed_decoder_instr[6], 12'h041, i_compressed_decoder_instr[4:2], 7'b0010011};
						if (i_compressed_decoder_instr[12:5] == 8'b00000000)
							o_compressed_decoder_illegal_instr = 1'b1;
					end
					C_LW: o_compressed_decoder_instr = {5'b00000, i_compressed_decoder_instr[5], i_compressed_decoder_instr[12:10], i_compressed_decoder_instr[6], 4'b0001, i_compressed_decoder_instr[9:7], 5'b01001, i_compressed_decoder_instr[4:2], 7'b0000011};
					C_LD: o_compressed_decoder_instr = {4'b0000, i_compressed_decoder_instr[6:5], i_compressed_decoder_instr[12:10], 5'b00001, i_compressed_decoder_instr[9:7], 5'b01101, i_compressed_decoder_instr[4:2], 7'b0000011};
					C_SW: o_compressed_decoder_instr = {5'b00000, i_compressed_decoder_instr[5], i_compressed_decoder_instr[12], 2'b01, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 3'b010, i_compressed_decoder_instr[11:10], i_compressed_decoder_instr[6], 9'b000100011};
					C_SD: o_compressed_decoder_instr = {4'b0000, i_compressed_decoder_instr[6:5], i_compressed_decoder_instr[12], 2'b01, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 3'b011, i_compressed_decoder_instr[11:10], 10'b0000100011};
					default: o_compressed_decoder_illegal_instr = 1'b1;
				endcase
			Q1:
				(* full_case, parallel_case *)
				case (i_compressed_decoder_instr[15:13])
					C_ADDI_NOP: o_compressed_decoder_instr = {{6 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], i_compressed_decoder_instr[11:7], 3'b000, i_compressed_decoder_instr[11:7], 7'b0010011};
					C_ADDIW: o_compressed_decoder_instr = {{6 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], i_compressed_decoder_instr[11:7], 3'b000, i_compressed_decoder_instr[11:7], 7'b0011011};
					C_LI: o_compressed_decoder_instr = {{6 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], 8'b00000000, i_compressed_decoder_instr[11:7], 7'b0010011};
					C_ADDIL6SP_LUI:
						if (i_compressed_decoder_instr[11:7] == 5'h02)
							o_compressed_decoder_instr = {{3 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[4:3], i_compressed_decoder_instr[5], i_compressed_decoder_instr[2], i_compressed_decoder_instr[6], 24'h010113};
						else if (i_compressed_decoder_instr[11:7] != 5'h00)
							o_compressed_decoder_instr = {{14 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], i_compressed_decoder_instr[11:7], 7'b0110111};
					C_ARTH_LOGIC:
						(* full_case, parallel_case *)
						case (i_compressed_decoder_instr[11:10])
							2'b00: o_compressed_decoder_instr = {7'b0000000, i_compressed_decoder_instr[6:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b10101, i_compressed_decoder_instr[9:7], 7'b0010011};
							2'b01: o_compressed_decoder_instr = {7'b0100000, i_compressed_decoder_instr[6:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b10101, i_compressed_decoder_instr[9:7], 7'b0010011};
							2'b10: o_compressed_decoder_instr = {{6 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], 2'b01, i_compressed_decoder_instr[9:7], 7'b0010011};
							2'b11:
								if (i_compressed_decoder_instr[12] == 1'b0)
									(* full_case, parallel_case *)
									case (i_compressed_decoder_instr[6:5])
										2'b00: o_compressed_decoder_instr = {9'b010000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b00001, i_compressed_decoder_instr[9:7], 7'b0110011};
										2'b01: o_compressed_decoder_instr = {9'b000000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b10001, i_compressed_decoder_instr[9:7], 7'b0110011};
										2'b10: o_compressed_decoder_instr = {9'b000000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b11001, i_compressed_decoder_instr[9:7], 7'b0110011};
										2'b11: o_compressed_decoder_instr = {9'b000000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b11101, i_compressed_decoder_instr[9:7], 7'b0110011};
									endcase
								else
									(* full_case, parallel_case *)
									case (i_compressed_decoder_instr[6:5])
										2'b00: o_compressed_decoder_instr = {9'b010000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b00001, i_compressed_decoder_instr[9:7], 7'b0111011};
										2'b01: o_compressed_decoder_instr = {9'b000000001, i_compressed_decoder_instr[4:2], 2'b01, i_compressed_decoder_instr[9:7], 5'b00001, i_compressed_decoder_instr[9:7], 7'b0111011};
										default: o_compressed_decoder_illegal_instr = 1'b1;
									endcase
						endcase
					C_J: o_compressed_decoder_instr = {i_compressed_decoder_instr[12], i_compressed_decoder_instr[8], i_compressed_decoder_instr[10:9], i_compressed_decoder_instr[6], i_compressed_decoder_instr[7], i_compressed_decoder_instr[2], i_compressed_decoder_instr[11], i_compressed_decoder_instr[5:3], {9 {i_compressed_decoder_instr[12]}}, 12'b000001101111};
					C_BEQZ: o_compressed_decoder_instr = {{4 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[6:5], i_compressed_decoder_instr[2], 7'b0000001, i_compressed_decoder_instr[9:7], 3'b000, i_compressed_decoder_instr[11:10], i_compressed_decoder_instr[4:3], i_compressed_decoder_instr[12], 7'b1100011};
					C_BNEZ: o_compressed_decoder_instr = {{4 {i_compressed_decoder_instr[12]}}, i_compressed_decoder_instr[6:5], i_compressed_decoder_instr[2], 7'b0000001, i_compressed_decoder_instr[9:7], 3'b001, i_compressed_decoder_instr[11:10], i_compressed_decoder_instr[4:3], i_compressed_decoder_instr[12], 7'b1100011};
					default: o_compressed_decoder_illegal_instr = 1'b1;
				endcase
			Q2:
				(* full_case, parallel_case *)
				case (i_compressed_decoder_instr[15:13])
					C_SLLI: o_compressed_decoder_instr = {7'b0000000, i_compressed_decoder_instr[6:2], i_compressed_decoder_instr[11:7], 3'b001, i_compressed_decoder_instr[11:7], 7'b0010011};
					C_LWSP: o_compressed_decoder_instr = {4'b0000, i_compressed_decoder_instr[3:2], i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:4], 10'b0000010010, i_compressed_decoder_instr[11:7], 7'b0000011};
					C_LDSP: o_compressed_decoder_instr = {3'b000, i_compressed_decoder_instr[4:2], i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:5], 11'b00000010011, i_compressed_decoder_instr[11:7], 7'b0000011};
					C_JR_MV_BR_JALR_ADD:
						if (i_compressed_decoder_instr[12] == 1'b0) begin
							if (i_compressed_decoder_instr[6:2] == 5'b00000)
								o_compressed_decoder_instr = {12'b000000000000, i_compressed_decoder_instr[11:7], 15'b000000001100111};
							else
								o_compressed_decoder_instr = {7'b0000000, i_compressed_decoder_instr[6:2], 8'b00000000, i_compressed_decoder_instr[11:7], 7'b0110011};
							if (i_compressed_decoder_instr[11:7] == 5'b00000)
								o_compressed_decoder_illegal_instr = 1'b1;
						end
						else if (i_compressed_decoder_instr[11:2] == 5'b00000)
							o_compressed_decoder_instr = 32'h00100073;
						else if ((i_compressed_decoder_instr[11:7] != 5'b00000) && (i_compressed_decoder_instr[6:2] == 5'b00000))
							o_compressed_decoder_instr = {12'b000000000000, i_compressed_decoder_instr[11:7], 15'b000000011100111};
						else if (i_compressed_decoder_instr[11:2] != 5'b00000)
							o_compressed_decoder_instr = {7'b0000000, i_compressed_decoder_instr[6:2], i_compressed_decoder_instr[11:7], 3'b000, i_compressed_decoder_instr[11:7], 7'b0110011};
						else
							o_compressed_decoder_illegal_instr = 1'b1;
					C_SWSP: o_compressed_decoder_instr = {4'b0000, i_compressed_decoder_instr[8:7], i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], 8'b00010010, i_compressed_decoder_instr[11:9], 9'b000100011};
					C_SDSP: o_compressed_decoder_instr = {3'b000, i_compressed_decoder_instr[9:7], i_compressed_decoder_instr[12], i_compressed_decoder_instr[6:2], 8'b00010011, i_compressed_decoder_instr[11:10], 10'b0000100011};
					default: o_compressed_decoder_illegal_instr = 1'b1;
				endcase
			default: o_compressed_decoder_is_compressed = 1'b0;
		endcase
		if (o_compressed_decoder_illegal_instr)
			o_compressed_decoder_instr = i_compressed_decoder_instr;
	end
	initial _sv2v_0 = 0;
endmodule
