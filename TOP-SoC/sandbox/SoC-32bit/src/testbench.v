`timescale 1ns/1ps

module testbench();
    
    // Memory array to store hex program (reduced size)
    reg [31:0] memory [0:10];  
    reg [31:0] pc;
    reg clk, rst;
    integer i;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        pc = 0;
        
        // Initialize memory to zero
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
        
        // Load hex file into memory with error checking
        if ($fopen("test_program.hex", "r") != 0) begin
            $readmemh("test_program.hex", memory);
            $display("Loaded test_program.hex successfully");
        end else begin
            $display("Warning: test_program.hex not found, using initialized memory");
        end
        
        // Reset release
        #10 rst = 0;
        
        // Run for some cycles
        #100;
        
        // Display first 7 words
        $display("=== First 7 Words from Memory ===");
        for (i = 0; i < 7; i = i + 1) begin
            $display("Word[%0d]: 0x%08h", i, memory[i]);
        end
        
        // End simulation
        $finish;
    end
    
    // Simple program counter increment
    always @(posedge clk) begin
        if (rst)
            pc <= 0;
        else
            pc <= pc + 4;
    end
    
endmodule
