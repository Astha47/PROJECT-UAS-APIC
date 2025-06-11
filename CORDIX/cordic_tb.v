module cordic_tb;

    parameter WIDTH = 32;

    reg clk, rst, start, mode;
    reg signed [WIDTH-1:0] theta_deg;
    wire signed [WIDTH-1:0] result_out;
    wire done;

    // Instantiate the top-level CORDIC module
    cordic_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .theta_deg(theta_deg),
        .result_out(result_out),
        .done(done)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Test angles in Q16.16 degrees
    localparam signed [WIDTH-1:0] ANG_0     = 32'sd0;
    localparam signed [WIDTH-1:0] ANG_30    = 32'sd1966080;  // 30°
    localparam signed [WIDTH-1:0] ANG_45    = 32'sd2949120;  // 45°
    localparam signed [WIDTH-1:0] ANG_60    = 32'sd3932160;  // 60°
    localparam signed [WIDTH-1:0] ANG_90    = 32'sd5898240;  // 90°
    localparam signed [WIDTH-1:0] ANG_N30   = -32'sd1966080;
    localparam signed [WIDTH-1:0] ANG_N45   = -32'sd2949120;
    localparam signed [WIDTH-1:0] ANG_N60   = -32'sd3932160;
    localparam signed [WIDTH-1:0] ANG_N90   = -32'sd5898240;

    initial begin
        // Dump for waveform viewing
        $dumpfile("cordic_top_tb.vcd");
        $dumpvars(0, cordic_tb);

        // Init
        clk = 0; rst = 1; start = 0; mode = 0; theta_deg = 0;
        #20;
        rst = 0;

        // Run test cases
        theta_deg = ANG_0;    start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_30;   start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_45;   start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_60;   start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_90;   start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_N30;  start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_N45;  start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_N60;  start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        theta_deg = ANG_N90;  start = 1; #10; start = 0; #30; wait(done); #20;
        mode = 1; start = 1; #10; start = 0; #30; wait(done); #20; mode = 0;
        $finish;
    end

endmodule
