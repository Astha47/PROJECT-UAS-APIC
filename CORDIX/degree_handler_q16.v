module degree_handler_q16 (
    input wire clk,
    input wire signed [31:0] theta_in,      // Q16.16 degrees
    output reg signed [31:0] theta_out,     // Q16.16 degrees, mapped to [-90°, +90°]
    output reg [1:0] kuadran,               // 00 to 11
    output reg isNegative                   // Flag for negative theta_in, 1 if theta_in is negative
);

    // Constants in Q16.16 format
    localparam signed [31:0] DEG_0 = 32'sd0;                // 0 degrees
    localparam signed [31:0] DEG_90  = 32'sd5898240;        // 90 degrees
    localparam signed [31:0] DEG_180 = 32'sd11796480;       // 180 degrees

    reg signed [31:0] theta_abs; // Absolute value of theta_in

    always @(posedge clk) begin
        // Check for theta_in sign
        if (theta_in < 0) begin
            isNegative <= 1'b1;
            theta_abs <= -theta_in;
        end else begin
            isNegative <= 1'b0;
            theta_abs <= theta_in;
        end

        // Map theta to only 1st quadrant while keeping track of original quadrant
        if (theta_abs <= DEG_90) begin // 1st Quadrant
            kuadran   <= 2'b00;
            theta_out <= theta_abs;
        end else if (theta_abs <= DEG_180) begin // 2nd Quadrant
            kuadran   <= 2'b01;
            theta_out <= DEG_180 - theta_abs;
        end else if (theta_abs <= (DEG_90 + DEG_180)) begin // 3rd Quadrant
            kuadran   <= 2'b10;
            theta_out <= theta_abs - DEG_180;
        end else begin // 4th Quadrant
            kuadran   <= 2'b11;
            theta_out <= -theta_abs;
        end
    end

endmodule
