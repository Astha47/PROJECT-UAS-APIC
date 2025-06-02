module uart_rx (
	uart_clk,
	uart_rst_n,
	m_axis_tdata,
	m_axis_tvalid,
	m_axis_tlast,
	m_axis_tready,
	uart_rxd,
	uart_busy,
	uart_parity_err,
	uart_frame_err
);
	reg _sv2v_0;
	parameter DWIDTH = 8;
	parameter PARTYP = 2'b00;
	input wire uart_clk;
	input wire uart_rst_n;
	output wire [DWIDTH - 1:0] m_axis_tdata;
	output wire m_axis_tvalid;
	output wire m_axis_tlast;
	input wire m_axis_tready;
	input wire uart_rxd;
	output wire uart_busy;
	output wire uart_parity_err;
	output wire uart_frame_err;
	reg [DWIDTH - 1:0] m_axis_tdata_reg;
	reg [DWIDTH - 1:0] m_axis_tdata_comb;
	reg m_axis_tvalid_reg;
	reg m_axis_tvalid_comb;
	reg m_axis_tlast_reg;
	reg m_axis_tlast_comb;
	reg uart_busy_reg;
	reg uart_busy_comb;
	reg start_bit_reg;
	reg start_bit_comb;
	reg stop_bit_reg;
	reg stop_bit_comb;
	reg parity_bit_reg;
	reg parity_bit_comb;
	wire parity_check;
	reg uart_parity_err_reg;
	reg uart_parity_err_comb;
	reg [$clog2(DWIDTH) + 1:0] frame_count_reg;
	reg [$clog2(DWIDTH) + 1:0] frame_count_comb;
	(* fsm_encoding = "none" *) reg state_crnt;
	(* fsm_encoding = "none" *) reg state_nxt;
	uart_parity #(
		.DWIDTH(DWIDTH),
		.PARTYP(PARTYP)
	) check(
		.data_in(m_axis_tdata),
		.parity_out(parity_check)
	);
	always @(posedge uart_clk or negedge uart_rst_n) begin : rx_block
		if (!uart_rst_n) begin
			m_axis_tdata_reg <= 'b0;
			m_axis_tvalid_reg <= 1'b0;
			m_axis_tlast_reg <= 1'b0;
			uart_busy_reg <= 1'b0;
			frame_count_reg <= 'h0;
			start_bit_reg <= 1'b0;
			stop_bit_reg <= 1'b1;
			parity_bit_reg <= 1'b1;
			uart_parity_err_reg <= 1'b0;
			state_crnt <= 1'd0;
		end
		else begin
			m_axis_tdata_reg <= m_axis_tdata_comb;
			m_axis_tvalid_reg <= m_axis_tvalid_comb;
			m_axis_tlast_reg <= m_axis_tlast_comb;
			uart_busy_reg <= uart_busy_comb;
			frame_count_reg <= frame_count_comb;
			start_bit_reg <= start_bit_comb;
			stop_bit_reg <= start_bit_comb;
			parity_bit_reg <= parity_bit_comb;
			uart_parity_err_reg <= uart_parity_err_comb;
			state_crnt <= state_nxt;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		state_nxt = state_crnt;
		m_axis_tvalid_comb = m_axis_tvalid_reg;
		m_axis_tdata_comb = m_axis_tdata_reg;
		m_axis_tlast_comb = 1'b0;
		uart_busy_comb = uart_busy_reg;
		frame_count_comb = frame_count_reg;
		start_bit_comb = start_bit_reg;
		stop_bit_comb = stop_bit_reg;
		parity_bit_comb = parity_bit_reg;
		uart_parity_err_comb = uart_parity_err_reg;
		(* full_case, parallel_case *)
		case (state_crnt)
			1'd0: begin
				m_axis_tdata_comb = m_axis_tdata_reg;
				m_axis_tvalid_comb = 1'b0;
				uart_busy_comb = 1'b0;
				frame_count_comb = DWIDTH + 'd3;
				if (m_axis_tready) begin
					state_nxt = 1'd1;
					uart_busy_comb = 1'b1;
				end
			end
			1'd1: begin
				state_nxt = 1'd1;
				m_axis_tdata_comb = m_axis_tdata_reg;
				parity_bit_comb = parity_bit_reg;
				m_axis_tlast_comb = m_axis_tlast_reg;
				uart_busy_comb = 1'b1;
				frame_count_comb = frame_count_reg - 'b1;
				if (frame_count_reg == 'b0) begin
					stop_bit_comb = uart_rxd;
					uart_busy_comb = 1'b0;
					state_nxt = 1'd0;
					frame_count_comb = frame_count_reg;
					m_axis_tvalid_comb = 1'b1;
					if (parity_bit_reg == parity_check)
						uart_parity_err_comb = 1'b0;
					else
						uart_parity_err_comb = 1'b1;
				end
				else
					{parity_bit_comb, m_axis_tlast_comb, m_axis_tdata_comb, start_bit_comb} = {uart_rxd, parity_bit_reg, m_axis_tlast_reg, m_axis_tdata_reg[DWIDTH - 1:1], start_bit_reg};
			end
		endcase
	end
	assign m_axis_tvalid = m_axis_tvalid_reg;
	assign m_axis_tdata = (m_axis_tvalid_reg && m_axis_tready ? m_axis_tdata_reg : 'h0);
	assign m_axis_tlast = (m_axis_tvalid_reg ? m_axis_tlast_reg : 1'b0);
	assign uart_busy = uart_busy_reg;
	assign uart_parity_err = uart_parity_err_reg;
	assign uart_frame_err = !start_bit_reg && start_bit_reg;
	initial _sv2v_0 = 0;
endmodule
