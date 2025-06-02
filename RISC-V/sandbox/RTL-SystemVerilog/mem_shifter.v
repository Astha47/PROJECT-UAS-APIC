module mem_shifter (
	i_write_strobe,
	i_mem_write_req,
	i_data,
	o_data,
	o_mem_write_req
);
	reg _sv2v_0;
	parameter DATA_WIDTH = 64;
	input wire [7:0] i_write_strobe;
	input wire i_mem_write_req;
	input wire [DATA_WIDTH - 1:0] i_data;
	output reg [DATA_WIDTH - 1:0] o_data;
	output reg o_mem_write_req;
	always @(*) begin : SHIFTER
		if (_sv2v_0)
			;
		if (i_write_strobe[0])
			o_data = i_data;
		else if (i_write_strobe[1])
			o_data = i_data << 8;
		else if (i_write_strobe[2])
			o_data = i_data << 16;
		else if (i_write_strobe[3])
			o_data = i_data << 24;
		else if (i_write_strobe[4])
			o_data = i_data << 32;
		else if (i_write_strobe[5])
			o_data = i_data << 40;
		else if (i_write_strobe[6])
			o_data = i_data << 48;
		else if (i_write_strobe[7])
			o_data = i_data << 56;
		else
			o_data = i_data;
		o_mem_write_req = i_mem_write_req;
	end
	initial _sv2v_0 = 0;
endmodule
