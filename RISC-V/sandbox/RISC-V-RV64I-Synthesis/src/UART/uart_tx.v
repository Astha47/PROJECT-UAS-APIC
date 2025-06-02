module uart_tx (
	uart_clk,
	uart_rst_n,
	s_axis_tdata,
	s_axis_tvalid,
	s_axis_tlast,
	s_axis_tready,
	uart_txd,
	uart_busy
);
	reg _sv2v_0;
	parameter DWIDTH = 4'd8;
	parameter PARTYP = 2'b01;
	input wire uart_clk;
	input wire uart_rst_n;
	input wire [DWIDTH - 1:0] s_axis_tdata;
	input wire s_axis_tvalid;
	input wire s_axis_tlast;
	output wire s_axis_tready;
	output wire uart_txd;
	output wire uart_busy;
	reg s_axis_tready_comb;
	reg s_axis_tlast_reg;
	reg uart_tx_comb;
	reg uart_busy_comb;
	wire parity_bit;
	reg [DWIDTH - 1:0] data_reg;
	reg [DWIDTH - 1:0] data_comb;
	reg [DWIDTH - 1:0] parity_check_reg;
	reg [$clog2(DWIDTH):0] frame_count_reg;
	reg [$clog2(DWIDTH):0] frame_count_comb;
	(* fsm_encoding = "gray" *) reg [1:0] state_crnt;
	(* fsm_encoding = "gray" *) reg [1:0] state_nxt;
	uart_parity #(
		.DWIDTH(DWIDTH),
		.PARTYP(PARTYP)
	) check(
		.data_in(parity_check_reg),
		.parity_out(parity_bit)
	);
	always @(posedge uart_clk or negedge uart_rst_n)
		if (!uart_rst_n) begin
			data_reg <= 'b0;
			parity_check_reg <= 'b0;
			frame_count_reg <= 'b0;
			s_axis_tlast_reg <= 1'b0;
			state_crnt <= 2'd0;
		end
		else begin
			if (s_axis_tvalid && s_axis_tready_comb) begin
				parity_check_reg <= s_axis_tdata;
				s_axis_tlast_reg <= s_axis_tlast;
			end
			data_reg <= data_comb;
			frame_count_reg <= frame_count_comb;
			state_crnt <= state_nxt;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		uart_tx_comb = 1'b1;
		uart_busy_comb = 1'b1;
		s_axis_tready_comb = 1'b0;
		data_comb = data_reg;
		frame_count_comb = frame_count_reg;
		state_nxt = state_crnt;
		(* full_case, parallel_case *)
		case (state_crnt)
			2'd0: begin
				uart_busy_comb = 1'b0;
				frame_count_comb = DWIDTH + 4'd1;
				if (s_axis_tvalid) begin
					s_axis_tready_comb = 1'b1;
					data_comb = s_axis_tdata;
					state_nxt = 2'd1;
				end
			end
			2'd1: begin
				uart_tx_comb = 1'b0;
				state_nxt = 2'd2;
			end
			2'd2: begin
				state_nxt = 2'd2;
				frame_count_comb = frame_count_reg - 'b1;
				{data_comb, uart_tx_comb} = {1'b1, data_reg};
				if (frame_count_reg == 'b0) begin
					uart_tx_comb = parity_bit;
					state_nxt = 2'd3;
				end
				else if (frame_count_reg == 'd1)
					uart_tx_comb = s_axis_tlast_reg;
			end
			2'd3: state_nxt = 2'd0;
		endcase
	end
	assign uart_txd = uart_tx_comb;
	assign uart_busy = uart_busy_comb;
	assign s_axis_tready = s_axis_tready_comb;
	initial _sv2v_0 = 0;
endmodule
