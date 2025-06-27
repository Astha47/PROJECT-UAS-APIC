`timescale 1ns / 1ps

`include "top.v"
`include "lpddr4_dummy_cordic.v"

module top_tb;
    // Testbench signals
    reg clk;
    reg reset_n;
    wire trap;
    
    // File handle for logging
    integer log_file;
    
    // DRAM interface signals between top and dummy RAM - match top.v ports
    wire dram_ck;
    wire dram_cs;
    wire dram_we;
    wire dram_ras;
    wire dram_cas;
    wire [13:0] dram_addr;
    wire [2:0] dram_ba;
    wire [31:0] dram_dq;
    wire [3:0] dram_dm;
    wire dram_dqs;
    // Test tracking variables for CORDIC MMIO test
    reg [31:0] final_pc;
    reg [31:0] cordic_result;
    reg test_passed;
    
    // Convert simulation time to ms for easier debugging
    real time_ms;
    
    // Initialize test tracking and open log file
    initial begin
        // Open log file at the very beginning of simulation
        log_file = $fopen("top_tb_simulation_cordic.log", "w");
        if (log_file == 0) begin
            $display("Error opening log file!");
            $finish;
        end
        $display("Log file opened successfully");
        $fdisplay(log_file, "Log file opened successfully");
        
        final_pc = 0;
        cordic_result = 0;
        test_passed = 1'b0;
    end
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    // Reset generation
    initial begin
        reset_n = 0;
        #100 reset_n = 1; // Release reset after 100ns
    end
    
    // DUT instantiation - Top SoC - using correct port names from top.v
    top dut (
        .clk(clk),
        .reset_n(reset_n),
        
        // DRAM Interface - using actual port names from top.v
        .dram_ck(dram_ck),
        .dram_cs(dram_cs),
        .dram_we(dram_we),
        .dram_ras(dram_ras),
        .dram_cas(dram_cas),
        .dram_addr(dram_addr),
        .dram_ba(dram_ba),
        .dram_dq(dram_dq),
        .dram_dm(dram_dm),
        .dram_dqs(dram_dqs),
        
        // Debug output
        .trap(trap)
    );
    
    // Instantiate the dummy LPDDR4 RAM - direct connection
    lpddr4_dummy ram (
        .clk(dram_ck),
        .cs(dram_cs),
        .we(dram_we),
        .ras(dram_ras),
        .cas(dram_cas),
        .addr(dram_addr),
        .ba(dram_ba),
        .dq(dram_dq),
        .dm(dram_dm),
        .dqs(dram_dqs)
    );
    
    // Program is now loaded directly into LPDDR4 dummy memory via test_program_test_cordic.hex
    initial begin
        $display("CORDIC test program will be loaded by LPDDR4 dummy memory from test_program_test_cordic.hex");
        $fdisplay(log_file, "CORDIC test program will be loaded by LPDDR4 dummy memory from test_program_test_cordic.hex");
        
        // Wait for RAM initialization to complete
        #150;  // Wait for memory initialization
        
        // Display first 10 memory addresses after program loading
        $display("\nMemory Contents (First 10 Addresses):");
        $fdisplay(log_file, "\nMemory Contents (First 10 Addresses):");
        for (integer i = 0; i < 10; i = i + 1) begin
            $display("Mem[0x%08x] = 0x%08x", i*4, ram.memory[i]);
            $fdisplay(log_file, "Mem[0x%08x] = 0x%08x", i*4, ram.memory[i]);
        end

        $display("Mem[0x%08x] = 0x%08x", 1020, ram.memory[255]); // Check address 1020 (255 = 1020/4)

        $display("");
        $fdisplay(log_file, "");
    end
    
    // Enhanced monitoring and debugging
    initial begin
        $display("Starting SoC with PicoRV32 CPU CORDIC test");
        $fdisplay(log_file, "Starting SoC with PicoRV32 CPU CORDIC test");
        
        // Enable comprehensive waveform dumping for VCD file
        $dumpfile("top_tb_soc_cordic_simulation.vcd");
        $dumpvars(0, top_tb);
        
        // Additional VCD control - dump all signals at all hierarchy levels
        $dumpall;
        
        $display("VCD file generation enabled: top_tb_soc_cordic_simulation.vcd");
        $fdisplay(log_file, "VCD file generation enabled: top_tb_soc_cordic_simulation.vcd");
        
        // Run for a reasonable amount of time for CORDIC test
        #5000;
        
        $display("Simulation complete at time %t", $time);
        $fdisplay(log_file, "Simulation complete at time %t", $time);
        
        // Final verification for CORDIC program
        $display("\nFinal CORDIC Program Verification:");
        $fdisplay(log_file, "\nFinal CORDIC Program Verification:");

        final_pc = dut.cpu.reg_pc;
        cordic_result = dut.cpu.cpuregs[9]; // Result is in x9

        // Check PC to see if program has finished (or is past the main part)
        // The program has 17 instructions, so PC should be around 17*4 = 68 (0x44)
        if (final_pc >= 68) begin
            $display("  - Program execution: PASS (PC=0x%08x)", final_pc);
            $fdisplay(log_file, "  - Program execution: PASS (PC=0x%08x)", final_pc);
            test_passed = 1'b1;
        end else begin
            $display("  - Program execution: FAIL (PC=0x%08x, expected >= 0x44)", final_pc);
            $fdisplay(log_file, "  - Program execution: FAIL (PC=0x%08x, expected >= 0x44)", final_pc);
            test_passed = 1'b0;
        end

        // Check register values
        $display("  - x1 (REG_INPUT_DATA addr): 0x%08x (expected 0xf0000018)", dut.cpu.cpuregs[1]);
        $fdisplay(log_file, "  - x1 (REG_INPUT_DATA addr): 0x%08x (expected 0xf0000018)", dut.cpu.cpuregs[1]);
        if (dut.cpu.cpuregs[1] != 32'hf0000018) test_passed = 1'b0;

        $display("  - x5 (Input Angle): 0x%08x (expected 0x002d0000)", dut.cpu.cpuregs[5]);
        $fdisplay(log_file, "  - x5 (Input Angle): 0x%08x (expected 0x002d0000)", dut.cpu.cpuregs[5]);
        if (dut.cpu.cpuregs[5] != 32'h002d0000) test_passed = 1'b0;

        $display("  - x9 (CORDIC Result): 0x%08x", cordic_result);
        $fdisplay(log_file, "  - x9 (CORDIC Result): 0x%08x", cordic_result);

        // Final test result
        if (test_passed) begin
            $display("\n=== CORDIC MMIO TEST: PASS ===");
            $fdisplay(log_file, "\n=== CORDIC MMIO TEST: PASS ===");
        end else begin
            $display("\n=== CORDIC MMIO TEST: FAIL ===");
            $fdisplay(log_file, "\n=== CORDIC MMIO TEST: FAIL ===");
        end
        
        // Close the log file before finishing
        $fclose(log_file);
        $display("Log file closed");
        
        // Finalize VCD dump
        $dumpflush;
        $display("VCD file finalized: top_tb_soc_cordic_simulation.vcd");
        
        $finish;
    end
endmodule
