`include "degree_handler_q16.v"
`include "cordic_32.v"
`include "sign_handler_q16.v"

    // CORDIC Top Module

module cordic_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire        mode,
    input  wire signed [31:0] theta_deg,
    output wire signed [31:0] result_out,
    output wire        done
);

    // Internal wires and regs
    localparam IDLE = 2'd0,
               WAIT_THETA = 2'd1,
               START_CORDIC = 2'd2;
    reg [1:0] state = IDLE;
    wire done_cordic;
    reg cordic_start;
    wire signed [31:0] theta_mapped;
    wire [1:0] kuadran;
    wire isNegative;
    wire signed [31:0] cos_raw, sin_raw;
    reg done_d;
    wire done_pulse = done & ~done_d;

    // Degree Handler
    degree_handler_q16 deg_handler_inst (
        .clk(clk),
        .theta_in(theta_deg),
        .theta_out(theta_mapped),
        .kuadran(kuadran),
        .isNegative(isNegative)
    );

    // CORDIC
    cordic_32 cordic_inst (
        .clk(clk),
        .rst(rst),
        .start(cordic_start),
        .angle(theta_mapped),
        .cos_out(cos_raw),
        .sin_out(sin_raw),
        .done(done_cordic)
    );

    // Sign Handler
    sign_handler_q16 sign_handler_inst (
        .clk(clk),
        .done(done_cordic),
        .kuadran(kuadran),
        .isNegative(isNegative),
        .cos_in(cos_raw),
        .sin_in(sin_raw),
        .mode(mode),
        .result_out(result_out),
        .done_out(done)
    );

    // FSM to delay cordic_start
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cordic_start <= 0;
            done_d <= 0;
        end else begin
            done_d <= done;
            case (state)
                IDLE: begin
                    if (start)
                        state <= WAIT_THETA;
                    cordic_start <= 0;
                end
                WAIT_THETA: begin
                    // theta_mapped is now updated (1 cycle delay)
                    state <= START_CORDIC;
                    cordic_start <= 1;
                end
                START_CORDIC: begin
                    cordic_start <= 0; // only pulse start once
                    if (done_pulse)
                        state <= IDLE;
                end
            endcase
        end
    end

endmodule
