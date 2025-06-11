module degree_handler_q16 (
    input wire clk,
    input wire signed [31:0] theta_in,      // Q16.16 degrees (range: -360° to 360°)
    output reg signed [31:0] theta_out,     // Q16.16 degrees, mapped to [0°, 90°]
    output reg [1:0] kuadran,               // 00 to 11 (quadrants 1 to 4)
    output reg isNegative                   // 1 if original angle was negative
);

    // Constants in Q16.16 format
    localparam signed [31:0] DEG_0    = 32'sd0;          // 0°
    localparam signed [31:0] DEG_90   = 32'sd5898240;    // 90°
    localparam signed [31:0] DEG_180  = 32'sd11796480;   // 180°
    localparam signed [31:0] DEG_360  = 32'sd23592960;   // 360°

    reg signed [31:0] theta_norm;   // Normalized to [-180°, 180°]
    reg signed [31:0] theta_abs;    // Absolute value after normalization

    always @(posedge clk) begin
        // Step 1: Normalize theta_in to [-180°, 180°]
        if (theta_in > DEG_180) begin
            theta_norm <= theta_in - DEG_360;  // Reduce to negative equivalent
        end else if (theta_in < -DEG_180) begin
            theta_norm <= theta_in + DEG_360;  // Increase to positive equivalent
        end else begin
            theta_norm <= theta_in;  // Already in range
        end

        // Step 2: Check if the normalized angle is negative
        if (theta_norm < 0) begin
            isNegative <= 1'b1;
            theta_abs <= -theta_norm;  // Work with absolute value
        end else begin
            isNegative <= 1'b0;
            theta_abs <= theta_norm;
        end

        // Step 3: Map to first quadrant (0° to 90°) and determine quadrant
        if (theta_abs <= DEG_90) begin
            kuadran   <= 2'b00;  // 1st Quadrant
            theta_out <= theta_abs;
        end else if (theta_abs <= DEG_180) begin
            kuadran   <= 2'b01;  // 2nd Quadrant
            theta_out <= DEG_180 - theta_abs;
        end else begin
            // Should never happen since theta_norm is in [-180°, 180°]
            kuadran   <= 2'b00;  // Fallback (error case)
            theta_out <= DEG_0;
        end
    end

endmodule