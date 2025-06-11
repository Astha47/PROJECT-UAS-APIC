// module cordic_32 #(
//     parameter WIDTH = 32,
//     parameter ITER = 16
// )(
//     input wire clk,
//     input wire rst,
//     input wire start,
//     input wire signed [WIDTH-1:0] angle,
//     output reg signed [WIDTH-1:0] cos_out,
//     output reg signed [WIDTH-1:0] sin_out,
//     output reg done
// );
//     localparam signed [WIDTH-1:0] k = 32'd39796; // 0.607252935 * 2^32
//     localparam integer scale = 32'd16;

//     function signed [WIDTH-1:0] get_atan;
//         input [3:0] index;  // log2(ITER), assuming ITER = 16
//         begin
//             case (index)
//                 4'd0:    get_atan = 32'd2949120;
//                 4'd1:    get_atan = 32'd1740967;
//                 4'd2:    get_atan = 32'd919879;
//                 4'd3:    get_atan = 32'd466945;
//                 4'd4:    get_atan = 32'd234379;
//                 4'd5:    get_atan = 32'd117304;
//                 4'd6:    get_atan = 32'd58666;
//                 4'd7:    get_atan = 32'd29335;
//                 4'd8:    get_atan = 32'd14668;
//                 4'd9:    get_atan = 32'd7334;
//                 4'd10:    get_atan = 32'd3667;
//                 4'd11:    get_atan = 32'd1833;
//                 4'd12:    get_atan = 32'd917;
//                 4'd13:    get_atan = 32'd458;
//                 4'd14:    get_atan = 32'd229;
//                 4'd15:    get_atan = 32'd115;
//             endcase
//         end
//     endfunction

//     reg signed [WIDTH-1:0] x = 0;
//     reg signed [WIDTH-1:0] y = 0;
//     reg signed [WIDTH-1:0] z = 0;
//     reg signed [WIDTH-1:0] x_next, y_next, z_next;
//     reg [4:0] i = 0;
//     reg busy = 0;

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             x <= 0; y <= 0; z <= 0;
//             i <= 0; busy <= 0; done <= 0;
//         end else if (start && !busy) begin
//             x <= k;
//             y <= 0;
//             z <= angle;
//             i <= 0;
//             busy <= 1;
//             done <= 0;
//         end else if (busy) begin
//             if (i < ITER) begin
//                 if (z >= 0) begin
//                     x_next = x - (y >>> i);
//                     y_next = y + (x >>> i);
//                     z_next = z - get_atan(i);
//                 end else begin
//                     x_next = x + (y >>> i);
//                     y_next = y - (x >>> i);
//                     z_next = z + get_atan(i);
//                 end
//                 x <= x_next;
//                 y <= y_next;
//                 z <= z_next;
//                 i <= i + 1;
//             end else begin
//                 cos_out <= x;
//                 sin_out <= y;
//                 busy <= 0;
//                 done <= 1;
//             end
//         end
//     end
// endmodule

module cordic_32 #(
    parameter WIDTH = 32,
    parameter ITER = 16
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire signed [WIDTH-1:0] angle,
    output reg signed [WIDTH-1:0] cos_out,
    output reg signed [WIDTH-1:0] sin_out,
    output reg done
);

    localparam signed [WIDTH-1:0] k = 32'd39796; // 0.607252935 * 2^16
    localparam IDLE = 2'd0, INIT = 2'd1, ITERATE = 2'd2, DONE = 2'd3;

    reg [1:0] state, next_state;
    reg signed [WIDTH-1:0] x, y, z;
    reg [4:0] i;

    function signed [WIDTH-1:0] get_atan;
        input [3:0] index;
        begin
            case (index)
                4'd0:  get_atan = 32'd2949120;
                4'd1:  get_atan = 32'd1740967;
                4'd2:  get_atan = 32'd919879;
                4'd3:  get_atan = 32'd466945;
                4'd4:  get_atan = 32'd234379;
                4'd5:  get_atan = 32'd117304;
                4'd6:  get_atan = 32'd58666;
                4'd7:  get_atan = 32'd29335;
                4'd8:  get_atan = 32'd14668;
                4'd9:  get_atan = 32'd7334;
                4'd10: get_atan = 32'd3667;
                4'd11: get_atan = 32'd1833;
                4'd12: get_atan = 32'd917;
                4'd13: get_atan = 32'd458;
                4'd14: get_atan = 32'd229;
                4'd15: get_atan = 32'd115;
                default: get_atan = 0;
            endcase
        end
    endfunction

    // FSM State Register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM Next-State Logic
    always @(*) begin
        case (state)
            IDLE:     next_state = (start ? INIT : IDLE);
            INIT:     next_state = ITERATE;
            ITERATE:  next_state = (i < ITER ? ITERATE : DONE);
            DONE:     next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

    // FSM Outputs and Datapath
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            z <= 0;
            i <= 0;
            cos_out <= 0;
            sin_out <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                end
                INIT: begin
                    x <= k;
                    y <= 0;
                    z <= angle;
                    i <= 0;
                    done <= 0;
                end
                ITERATE: begin
                    if (z >= 0) begin
                        x <= x - (y >>> i);
                        y <= y + (x >>> i);
                        z <= z - get_atan(i[3:0]);
                    end else begin
                        x <= x + (y >>> i);
                        y <= y - (x >>> i);
                        z <= z + get_atan(i[3:0]);
                    end
                    i <= i + 1;
                end
                DONE: begin
                    cos_out <= x;
                    sin_out <= y;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
