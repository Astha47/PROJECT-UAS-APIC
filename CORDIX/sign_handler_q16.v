// module sign_handler_q16 (
//     input wire [1:0] kuadran,
//     input wire isNegative,
//     input wire signed [31:0] cos_in,
//     input wire signed [31:0] sin_in,
//     output reg signed [31:0] cos_out,
//     output reg signed [31:0] sin_out
// );
//     always @(*) begin
//         case (kuadran)
//             2'b00: begin // 1st quadrant
//                 cos_out = cos_in;
//                 sin_out = isNegative ? -sin_in : sin_in;
//             end
//             2'b01: begin // 2nd quadrant
//                 cos_out = -cos_in;
//                 sin_out = isNegative ? -sin_in : sin_in;
//             end
//             2'b10: begin // 3rd quadrant
//                 cos_out = -cos_in;
//                 sin_out = isNegative ? sin_in : -sin_in;
//             end
//             2'b11: begin // 4th quadrant
//                 cos_out = cos_in;
//                 sin_out = isNegative ? sin_in : -sin_in;
//             end
//         endcase
//     end
// endmodule

module sign_handler_q16 (
    input wire clk,
    input wire done,                      // Stays high until start/rst
    input wire [1:0] kuadran,
    input wire isNegative,
    input wire signed [31:0] cos_in,
    input wire signed [31:0] sin_in,
    input wire mode,                      // 0 = cosine, 1 = sine
    output reg signed [31:0] result_out,
    output reg done_out                   // One-cycle pulse
);
    reg signed [31:0] cos_adj, sin_adj;
    reg done_d = 0;

    wire done_pulse = done & ~done_d;

    // Generate adjusted sine/cosine
    always @(*) begin
        case (kuadran)
            2'b00: begin
                cos_adj = cos_in;
                sin_adj = isNegative ? -sin_in : sin_in;
            end
            2'b01: begin
                cos_adj = -cos_in;
                sin_adj = isNegative ? -sin_in : sin_in;
            end
            2'b10: begin
                cos_adj = -cos_in;
                sin_adj = isNegative ? sin_in : -sin_in;
            end
            2'b11: begin
                cos_adj = cos_in;
                sin_adj = isNegative ? sin_in : -sin_in;
            end
        endcase
    end

    // Generate one-cycle done pulse
    always @(posedge clk) begin
        done_d <= done;
        done_out <= done;
        if (done_pulse)
            result_out <= mode ? sin_adj : cos_adj;
    end
endmodule
