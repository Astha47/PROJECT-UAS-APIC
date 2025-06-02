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
    localparam signed [WIDTH-1:0] k = 32'd39796; // 0.607252935 * 2^32
    localparam integer scale = 32'd16;

    reg signed [WIDTH-1:0] atan_table [0:ITER-1];
    initial begin
        atan_table[ 0] = 32'd2949120;
        atan_table[ 1] = 32'd1740967;
        atan_table[ 2] = 32'd919879;
        atan_table[ 3] = 32'd466945;
        atan_table[ 4] = 32'd234379;
        atan_table[ 5] = 32'd117304;
        atan_table[ 6] = 32'd58666;
        atan_table[ 7] = 32'd29335;
        atan_table[ 8] = 32'd14668;
        atan_table[ 9] = 32'd7334;
        atan_table[10] = 32'd3667;
        atan_table[11] = 32'd1833;
        atan_table[12] = 32'd917;
        atan_table[13] = 32'd458;
        atan_table[14] = 32'd229;
        atan_table[15] = 32'd115;
    end

    reg signed [WIDTH-1:0] x, y, z;
    reg signed [WIDTH-1:0] x_next, y_next, z_next;
    reg [4:0] i;
    reg busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0; y <= 0; z <= 0;
            i <= 0; busy <= 0; done <= 0;
        end else if (start && !busy) begin
            x <= k;
            y <= 0;
            z <= angle;
            i <= 0;
            busy <= 1;
            done <= 0;
        end else if (busy) begin
            if (i < ITER) begin
                if (z >= 0) begin
                    x_next = x - (y >>> i);
                    y_next = y + (x >>> i);
                    z_next = z - atan_table[i];
                end else begin
                    x_next = x + (y >>> i);
                    y_next = y - (x >>> i);
                    z_next = z + atan_table[i];
                end
                x <= x_next;
                y <= y_next;
                z <= z_next;
                i <= i + 1;
            end else begin
                cos_out <= x;
                sin_out <= y;
                busy <= 0;
                done <= 1;
            end
        end
    end
endmodule