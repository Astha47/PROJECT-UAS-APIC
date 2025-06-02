module riscv_core_main_decoder (
	i_main_decoder_opcode,
	i_main_decoder_funct3,
	i_main_decoder_funct7,
	o_main_decoder_imsrc,
	o_main_decoder_UCtrl,
	o_main_decoder_resultsrc,
	o_main_decoder_regwrite,
	o_main_decoder_alusrcB,
	o_main_decoder_memwrite,
	o_main_decoder_branch,
	o_main_decoder_jump,
	o_main_decoder_bjreg,
	o_main_decoder_size,
	o_main_decoder_LdExt,
	o_main_decoder_isword,
	o_main_decoder_aluop,
	o_main_decoder_imsel,
	o_main_decoder_new_mux_sel,
	o_main_decoder_amo,
	o_main_decoder_amo_op,
	o_main_decoder_lr,
	o_main_decoder_sc,
	o_main_decoder_src_sel,
	o_main_decoder_op,
	o_main_decoder_illegal,
	o_main_decoder_read
);
	reg _sv2v_0;
	input wire [6:0] i_main_decoder_opcode;
	input wire [2:0] i_main_decoder_funct3;
	input wire [6:0] i_main_decoder_funct7;
	output wire [2:0] o_main_decoder_imsrc;
	output wire o_main_decoder_UCtrl;
	output wire [1:0] o_main_decoder_resultsrc;
	output wire o_main_decoder_regwrite;
	output wire o_main_decoder_alusrcB;
	output wire o_main_decoder_memwrite;
	output wire o_main_decoder_branch;
	output wire o_main_decoder_jump;
	output wire o_main_decoder_bjreg;
	output wire [1:0] o_main_decoder_size;
	output wire o_main_decoder_LdExt;
	output wire o_main_decoder_isword;
	output wire o_main_decoder_aluop;
	output wire o_main_decoder_imsel;
	output reg o_main_decoder_new_mux_sel;
	output wire o_main_decoder_amo;
	output wire [3:0] o_main_decoder_amo_op;
	output wire o_main_decoder_lr;
	output wire o_main_decoder_sc;
	output reg o_main_decoder_src_sel;
	output reg [1:0] o_main_decoder_op;
	output reg o_main_decoder_illegal;
	output reg o_main_decoder_read;
	reg [17:0] control_signals;
	reg [6:0] atomic_signals;
	wire [4:0] funct5;
	assign funct5 = i_main_decoder_funct7[6:2];
	assign {o_main_decoder_amo, o_main_decoder_amo_op, o_main_decoder_lr, o_main_decoder_sc} = atomic_signals;
	assign {o_main_decoder_regwrite, o_main_decoder_imsrc, o_main_decoder_UCtrl, o_main_decoder_alusrcB, o_main_decoder_memwrite, o_main_decoder_resultsrc, o_main_decoder_branch, o_main_decoder_aluop, o_main_decoder_size, o_main_decoder_LdExt, o_main_decoder_isword, o_main_decoder_jump, o_main_decoder_bjreg, o_main_decoder_imsel} = control_signals;
	always @(*) begin : control_signals_proc
		if (_sv2v_0)
			;
		case (i_main_decoder_opcode)
			7'b0110011:
				if (!i_main_decoder_funct7[0])
					control_signals = 18'b100000000010000000;
				else
					control_signals = 18'b100000000010000001;
			7'b0111011: begin
				control_signals = 18'b100000000010001000;
				if (i_main_decoder_funct7[0])
					control_signals[0] = 1;
			end
			7'b0010011: control_signals = 18'b100001000010000000;
			7'b0011011: control_signals = 18'b100001000010001000;
			7'b0000011: begin
				{control_signals[17:7], control_signals[3:0]} = 15'b100001001000000;
				case (i_main_decoder_funct3)
					3'h0: control_signals[6:4] = 3'b000;
					3'h1: control_signals[6:4] = 3'b010;
					3'h2: control_signals[6:4] = 3'b100;
					3'h3: control_signals[6:4] = 3'b110;
					3'h4: control_signals[6:4] = 3'b001;
					3'h5: control_signals[6:4] = 3'b011;
					3'h6: control_signals[6:4] = 3'b101;
					default: control_signals[6:4] = 3'b000;
				endcase
			end
			7'b0100011: begin
				{control_signals[17:7], control_signals[4:0]} = 16'b0001011000000000;
				case (i_main_decoder_funct3)
					3'h0: control_signals[6:5] = 2'b00;
					3'h1: control_signals[6:5] = 2'b01;
					3'h2: control_signals[6:5] = 2'b10;
					3'h3: control_signals[6:5] = 2'b11;
					default: control_signals[6:5] = 2'b00;
				endcase
			end
			7'b1100011: control_signals = 18'b001001000100000000;
			7'b1101111: control_signals = 18'b101101010000000100;
			7'b1100111: control_signals = 18'b100001010000000110;
			7'b0110111: control_signals = 18'b110011000000000000;
			7'b0010111: control_signals = 18'b110001000000000000;
			7'b1110011: control_signals = 18'b111000011000000000;
			7'b0101111: begin
				control_signals = 18'b110101001001000000;
				if (funct5[4:3] == 2'b11)
					control_signals[4] = 1;
				if (i_main_decoder_funct3[0])
					control_signals[6:5] = 2'b11;
			end
			default: control_signals = 18'b000000000000000000;
		endcase
	end
	always @(*) begin : NEW_MUX_SEL_signal_proc
		if (_sv2v_0)
			;
		o_main_decoder_new_mux_sel = 0;
		case (i_main_decoder_opcode)
			7'b0110011: o_main_decoder_new_mux_sel = 0;
			7'b0111011: o_main_decoder_new_mux_sel = 0;
			7'b0010011: o_main_decoder_new_mux_sel = 0;
			7'b0011011: o_main_decoder_new_mux_sel = 0;
			7'b0000011: o_main_decoder_new_mux_sel = 0;
			7'b0100011: o_main_decoder_new_mux_sel = 0;
			7'b1100011: o_main_decoder_new_mux_sel = 1;
			7'b1101111: o_main_decoder_new_mux_sel = 1;
			7'b1100111: o_main_decoder_new_mux_sel = 1;
			7'b0110111: o_main_decoder_new_mux_sel = 1;
			7'b0010111: o_main_decoder_new_mux_sel = 1;
			7'b0101111: o_main_decoder_new_mux_sel = 0;
			7'b1110011: o_main_decoder_new_mux_sel = 0;
			default: o_main_decoder_new_mux_sel = 0;
		endcase
	end
	always @(*) begin : Atomic_Signals_Logic
		if (_sv2v_0)
			;
		atomic_signals = 7'b0000000;
		case (i_main_decoder_opcode)
			7'b0101111:
				case (funct5)
					5'b00010: atomic_signals = 7'b0000010;
					5'b00011: atomic_signals = 7'b0000001;
					5'b00001: atomic_signals = 7'b1000000;
					5'b00000: atomic_signals = 7'b1000100;
					5'b01100: atomic_signals = 7'b1001000;
					5'b01000: atomic_signals = 7'b1001100;
					5'b00100: atomic_signals = 7'b1010000;
					5'b10100: atomic_signals = 7'b1010100;
					5'b10000: atomic_signals = 7'b1011000;
					5'b11100: atomic_signals = 7'b1011100;
					5'b11000: atomic_signals = 7'b1100000;
					default: atomic_signals = 7'b0000000;
				endcase
			default: atomic_signals = 7'b0000000;
		endcase
	end
	always @(*) begin : SRC_SEL_LOGIC
		if (_sv2v_0)
			;
		o_main_decoder_src_sel = 0;
		case (i_main_decoder_opcode)
			7'b1110011: begin
				o_main_decoder_src_sel = 0;
				if (i_main_decoder_funct3[2])
					o_main_decoder_src_sel = 1;
			end
			default: o_main_decoder_src_sel = 0;
		endcase
	end
	always @(*) begin : OP_LOGIC
		if (_sv2v_0)
			;
		o_main_decoder_op = 2'b00;
		case (i_main_decoder_opcode)
			7'b1110011:
				case (i_main_decoder_funct3[1:0])
					2'b01: o_main_decoder_op = 2'b01;
					2'b10: o_main_decoder_op = 2'b10;
					2'b11: o_main_decoder_op = 2'b11;
					default: o_main_decoder_op = 2'b00;
				endcase
			default: o_main_decoder_op = 2'b00;
		endcase
	end
	always @(*) begin : READ_LOGIC
		if (_sv2v_0)
			;
		o_main_decoder_read = 0;
		case (i_main_decoder_opcode)
			7'b0000011: o_main_decoder_read = 1;
			7'b0110111: o_main_decoder_read = 0;
			7'b0101111: o_main_decoder_read = 0;
			default: o_main_decoder_read = 0;
		endcase
	end
	always @(*) begin : ILLEGAL_INSTRUCTION_LOGIC
		if (_sv2v_0)
			;
		o_main_decoder_illegal = 1;
		case (i_main_decoder_opcode)
			7'b0000000: o_main_decoder_illegal = 0;
			7'b0010011: o_main_decoder_illegal = 0;
			7'b0011011: o_main_decoder_illegal = 0;
			7'b0000011: o_main_decoder_illegal = 0;
			7'b0100011: o_main_decoder_illegal = 0;
			7'b1100011: o_main_decoder_illegal = 0;
			7'b1101111: o_main_decoder_illegal = 0;
			7'b1100111: o_main_decoder_illegal = 0;
			7'b0110111: o_main_decoder_illegal = 0;
			7'b0010111: o_main_decoder_illegal = 0;
			7'b0110011: o_main_decoder_illegal = 0;
			7'b0111011: o_main_decoder_illegal = 0;
			7'b0101111: o_main_decoder_illegal = 0;
			7'b1110011: o_main_decoder_illegal = 0;
			default: o_main_decoder_illegal = 1;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
