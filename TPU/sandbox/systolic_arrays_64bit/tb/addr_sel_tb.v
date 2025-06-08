// Testbench for addr_sel module

module addr_sel_tb;

    // Testbench signals
    reg clk;                               // Clock signal
    reg [6:0] addr_serial_num;             // Address serial number
    wire [9:0] sram_raddr_w0, sram_raddr_w1, sram_raddr_w2, sram_raddr_w3;
    wire [9:0] sram_raddr_w4, sram_raddr_w5, sram_raddr_w6, sram_raddr_w7;
    wire [9:0] sram_raddr_d0, sram_raddr_d1, sram_raddr_d2, sram_raddr_d3;
    wire [9:0] sram_raddr_d4, sram_raddr_d5, sram_raddr_d6, sram_raddr_d7;

    // Instantiate the addr_sel module
    addr_sel uut (
        .clk(clk),
        .addr_serial_num(addr_serial_num),
        .sram_raddr_w0(sram_raddr_w0),
        .sram_raddr_w1(sram_raddr_w1),
        .sram_raddr_w2(sram_raddr_w2),
        .sram_raddr_w3(sram_raddr_w3),
        .sram_raddr_w4(sram_raddr_w4),
        .sram_raddr_w5(sram_raddr_w5),
        .sram_raddr_w6(sram_raddr_w6),
        .sram_raddr_w7(sram_raddr_w7),
        .sram_raddr_d0(sram_raddr_d0),
        .sram_raddr_d1(sram_raddr_d1),
        .sram_raddr_d2(sram_raddr_d2),
        .sram_raddr_d3(sram_raddr_d3),
        .sram_raddr_d4(sram_raddr_d4),
        .sram_raddr_d5(sram_raddr_d5),
        .sram_raddr_d6(sram_raddr_d6),
        .sram_raddr_d7(sram_raddr_d7)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate a clock with a period of 10 time units
    end

    // Test sequence
    initial begin
        // Initialize addr_serial_num
        addr_serial_num = 0;

        // Apply test cases
        #10 addr_serial_num = 0;    // Test case: addr_serial_num = 0
        #10 addr_serial_num = 4;    // Test case: addr_serial_num = 4
        #10 addr_serial_num = 8;    // Test case: addr_serial_num = 8
        #10 addr_serial_num = 12;   // Test case: addr_serial_num = 12
        #10 addr_serial_num = 16;   // Test case: addr_serial_num = 16
        #10 addr_serial_num = 20;   // Test case: addr_serial_num = 20
        #10 addr_serial_num = 24;   // Test case: addr_serial_num = 24
        #10 addr_serial_num = 28;   // Test case: addr_serial_num = 28
        #10 addr_serial_num = 98;   // Test case: addr_serial_num = 98
        #10 addr_serial_num = 126;  // Test case: addr_serial_num = 126

        // End simulation
        #10 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | addr_serial_num: %0d | sram_raddr_w0: %0d | sram_raddr_w1: %0d | sram_raddr_w2: %0d | sram_raddr_w3: %0d | sram_raddr_w4: %0d | sram_raddr_w5: %0d | sram_raddr_w6: %0d | sram_raddr_w7: %0d | sram_raddr_d0: %0d | sram_raddr_d1: %0d | sram_raddr_d2: %0d | sram_raddr_d3: %0d | sram_raddr_d4: %0d | sram_raddr_d5: %0d | sram_raddr_d6: %0d | sram_raddr_d7: %0d",
                 $time, addr_serial_num, sram_raddr_w0, sram_raddr_w1, sram_raddr_w2, sram_raddr_w3, sram_raddr_w4, sram_raddr_w5, sram_raddr_w6, sram_raddr_w7,
                 sram_raddr_d0, sram_raddr_d1, sram_raddr_d2, sram_raddr_d3, sram_raddr_d4, sram_raddr_d5, sram_raddr_d6, sram_raddr_d7);
    end

endmodule