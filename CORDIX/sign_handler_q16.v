module sign_handler_q16 (
    input wire [1:0] kuadran,
    input wire isNegative,
    input wire signed [31:0] cos_in,
    input wire signed [31:0] sin_in,
    output reg signed [31:0] cos_out,
    output reg signed [31:0] sin_out
);
    always @(*) begin
        case (kuadran)
            2'b00: begin // 1st quadrant
                cos_out = cos_in;
                sin_out = isNegative ? -sin_in : sin_in;
            end
            2'b01: begin // 2nd quadrant
                cos_out = -cos_in;
                sin_out = isNegative ? -sin_in : sin_in;
            end
            2'b10: begin // 3rd quadrant
                cos_out = -cos_in;
                sin_out = isNegative ? sin_in : -sin_in;
            end
            2'b11: begin // 4th quadrant
                cos_out = cos_in;
                sin_out = isNegative ? sin_in : -sin_in;
            end
        endcase
    end
endmodule