module cordic_system_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter WIDTH = 32;
    
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

    // System signals
    reg aclk = 0;
    reg aresetn = 0;
    
    // AXI4-Lite signals
    reg [31:0] awaddr;
    reg awvalid;
    wire awready;
    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg wvalid;
    wire wready;
    wire [1:0] bresp;
    wire bvalid;
    reg bready;
    
    reg [31:0] araddr;
    reg arvalid;
    wire arready;
    wire [31:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    integer test_id = 0;
    
    // Instantiate DUT
    cordic_system dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready)
    );

    // Clock generation
    always #(CLK_PERIOD/2) aclk = ~aclk;

    // Task for AXI4-Lite write
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        input [3:0] strb;
        begin
            // Write address phase
            @(posedge aclk);
            awaddr <= addr;
            awvalid <= 1'b1;
            
            // Wait for address accepted
            wait(awready);
            @(posedge aclk);
            awvalid <= 1'b0;
            
            // Write data phase
            wdata <= data;
            wstrb <= strb;
            wvalid <= 1'b1;
            bready <= 1'b1;
            
            // Wait for data accepted
            wait(wready);
            @(posedge aclk);
            wvalid <= 1'b0;
            
            // Wait for write response
            wait(bvalid);
            @(posedge aclk);
            bready <= 1'b0;
            
            if (bresp != 2'b00) begin
                $display("[ERROR] Write failed at address %h, response: %b", addr, bresp);
            end
        end
    endtask

    // Task for AXI4-Lite read
    task axi_read;
        input [31:0] addr;
        output [31:0] data;
        begin
            // Read address phase
            @(posedge aclk);
            araddr <= addr;
            arvalid <= 1'b1;
            rready <= 1'b1;
            
            // Wait for ready
            wait(arready);
            @(posedge aclk);
            arvalid <= 1'b0;
            
            // Wait for read data
            wait(rvalid);
            data = rdata;
            if (rresp != 2'b00) begin
                $display("[ERROR] Read failed at address %h, response: %b", addr, rresp);
            end
            @(posedge aclk);
            rready <= 1'b0;
        end
    endtask

    // Task to wait for CORDIC operation to complete
    task wait_cordic_done;
        reg [31:0] status;
        begin
            do begin    
                axi_read(32'hC, status); // Read from REG_FLAGS_OUT
            end while (status[0] == 0);
        end
    endtask

    // Main test sequence
    // Function to convert integer degrees to Q16.16 fixed-point
    function signed [31:0] deg2q16_16;
        input integer degrees;
        begin
            deg2q16_16 = degrees * 32'sd65536;
        end
    endfunction

    // Main test sequence
    initial begin
        integer deg;
        reg [31:0] angle_q16_16;
        reg [31:0] result;

        // Initialize signals
        awaddr = 0;
        awvalid = 0;
        wdata = 0;
        wstrb = 4'b1111;
        wvalid = 0;
        bready = 0;
        araddr = 0;
        arvalid = 0;
        rready = 0;

        // Dump waveforms
        $dumpfile("cordic_system_tb.vcd");
        $dumpvars(0, cordic_system_tb);

        // Reset sequence
        #100;
        aresetn = 1;
        #100;

        $display("Starting full angle sweep test...");

        for (deg = -360; deg <= 360; deg += 30) begin
            angle_q16_16 = deg2q16_16(deg);

            // COSINE test
            $display("Testing cosine(%0d°)", deg);
            axi_write(32'h0, angle_q16_16, 4'b1111); // Write angle
            axi_write(32'h8, 32'h0, 4'b0001);        // mode = 0
            axi_write(32'h8, 32'h2, 4'b0001);        // start = 1
            wait_cordic_done();
            axi_read(32'h4, result);
            test_id = test_id + 1;
            $display("cos(%0d°) = %h", deg, result);
            axi_write(32'h8, 32'h0, 4'b0001);        // clear start

            // SINE test
            $display("Testing sine(%0d°)", deg);
            axi_write(32'h8, 32'h4, 4'b0001);        // mode = 1
            axi_write(32'h8, 32'h2, 4'b0001);        // start = 1
            wait_cordic_done();
            axi_read(32'h4, result);
            test_id = test_id + 1;
            $display("sin(%0d°) = %h", deg, result);
            axi_write(32'h8, 32'h0, 4'b0001);        // clear start
        end

        #1000;
        $display("All tests completed");
        $finish;
    end

    // Monitor for errors
    always @(posedge aclk) begin
        if (bvalid && bresp != 2'b00) begin
            $display("[ERROR] Write error detected, response: %b", bresp);
        end
        
        if (rvalid && rresp != 2'b00) begin
            $display("[ERROR] Read error detected, response: %b", rresp);
        end
    end

endmodule