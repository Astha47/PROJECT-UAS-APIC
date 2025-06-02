module uart_parity (
	data_in,
	parity_out
);
	reg _sv2v_0;
	parameter DWIDTH = 4'd8;
	parameter PARTYP = 2'b00;
	input wire [DWIDTH - 1:0] data_in;
	output reg parity_out;
	always @(*) begin
		if (_sv2v_0)
			;
		case (PARTYP)
			2'b00, 2'b11: parity_out = 1;
			2'b01: parity_out = (^data_in ? 1'b0 : 1'b1);
			2'b10: parity_out = (^data_in ? 1'b1 : 1'b0);
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
