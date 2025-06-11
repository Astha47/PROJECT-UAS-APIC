`timescale 1ns / 1ps

`include "top.v"
`include "lpddr4_dummy.v"

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
    
    // Test tracking variables
    reg completed_lui_x4;
    reg completed_addi_x1;
    reg completed_addi_x2;
    reg completed_add_x3;
    reg completed_sw;
    reg completed_lw;
    
    // TAMBAHKAN INI - Variable monitoring baru
    reg store_completed = 1'b0;
    reg load_completed = 1'b0;
    reg [31:0] stored_value = 32'h0;
    reg [31:0] loaded_value = 32'h0;
    reg program_started = 1'b0;
    reg reached_loop = 1'b0;
    reg [31:0] prev_pc = 32'h0;
    
    // Calculate expected result from test program
    integer expected_x1_value;
    integer expected_x2_value;
    integer expected_x3_value;
    
    // Convert simulation time to ms for easier debugging
    real time_ms;
    
    // Initialize test tracking and open log file
    initial begin
        // Open log file at the very beginning of simulation
        log_file = $fopen("top_tb_simulation.log", "w");
        if (log_file == 0) begin
            $display("Error opening log file!");
            $finish;
        end
        $display("Log file opened successfully");
        $fdisplay(log_file, "Log file opened successfully");
        
        completed_lui_x4 = 0;
        completed_addi_x1 = 0;
        completed_addi_x2 = 0;
        completed_add_x3 = 0;
        completed_sw = 0;
        completed_lw = 0;
        
        // TAMBAHKAN INI - Inisialisasi variable baru
        store_completed = 1'b0;
        load_completed = 1'b0;
        stored_value = 32'h0;
        loaded_value = 32'h0;
        program_started = 1'b0;
        reached_loop = 1'b0;
        prev_pc = 32'h0;
        
        expected_x1_value = 10;
        expected_x2_value = 20;
        expected_x3_value = expected_x1_value + expected_x2_value;
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
    
    // Test scenario and monitoring
    initial begin
        // Wait for reset to complete
        wait(reset_n == 1);
        
        // Monitor for CPU trap (error condition)
        forever begin
            @(posedge clk);
            if (trap) begin
                $display("CPU Trap detected at time %t", $time);
                $fdisplay(log_file, "CPU Trap detected at time %t", $time);
                #100 $finish;
            end
        end
    end
    
    // Program is now loaded directly into LPDDR4 dummy memory via test_program.hex
    initial begin
        $display("Test program will be loaded by LPDDR4 dummy memory from test_program.hex");
        $fdisplay(log_file, "Test program will be loaded by LPDDR4 dummy memory from test_program.hex");
        
        // Wait for RAM initialization to complete
        #150;  // Wait for memory initialization
        
        // Display first 10 memory addresses after program loading
        $display("\nMemory Contents (First 10 Addresses):");
        $fdisplay(log_file, "\nMemory Contents (First 10 Addresses):");
        for (integer i = 0; i < 10; i = i + 1) begin
            $display("Mem[0x%08x] = 0x%08x", i*4, ram.memory[i]);
            $fdisplay(log_file, "Mem[0x%08x] = 0x%08x", i*4, ram.memory[i]);
        end
        $display("");
        $fdisplay(log_file, "");
    end
    
    // Enhanced monitoring and debugging
    initial begin
        $display("Starting SoC with PicoRV32 CPU test");
        $fdisplay(log_file, "Starting SoC with PicoRV32 CPU test");
        
        // Enable waveform dumping if the simulator supports it
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        
        // Run for a reasonable amount of time
        #200000; // 200us simulation - longer for CPU testing
        
        $display("Simulation complete at time %t", $time);
        $fdisplay(log_file, "Simulation complete at time %t", $time);
        
        // Final verification
        $display("\nFinal Verification Status:");
        $fdisplay(log_file, "\nFinal Verification Status:");
        $display("  - Test reached end: %s", completed_lw ? "PASS" : "FAIL");
        $fdisplay(log_file, "  - Test reached end: %s", completed_lw ? "PASS" : "FAIL");
        $display("  - PC at end: 0x%08x", dut.cpu.reg_pc);
        $fdisplay(log_file, "  - PC at end: 0x%08x", dut.cpu.reg_pc);
        $display("  - x1 (expected 10): %d", dut.cpu.cpuregs[1]);
        $fdisplay(log_file, "  - x1 (expected 10): %d", dut.cpu.cpuregs[1]);
        $display("  - x2 (expected 20): %d", dut.cpu.cpuregs[2]);
        $fdisplay(log_file, "  - x2 (expected 20): %d", dut.cpu.cpuregs[2]);
        $display("  - x3 (expected 30): %d", dut.cpu.cpuregs[3]);
        $fdisplay(log_file, "  - x3 (expected 30): %d", dut.cpu.cpuregs[3]);
        $display("  - x4 (memory addr): 0x%08x", dut.cpu.cpuregs[4]);
        $fdisplay(log_file, "  - x4 (memory addr): 0x%08x", dut.cpu.cpuregs[4]);
        $display("  - x5 (loaded from memory): %d\n", dut.cpu.cpuregs[5]);
        $fdisplay(log_file, "  - x5 (loaded from memory): %d\n", dut.cpu.cpuregs[5]);
        
        // Close the log file before finishing
        $fclose(log_file);
        $display("Log file closed");
        
        $finish;
    end
    
    // CPU state monitoring
    reg [31:0] last_pc;
    reg [7:0] reset_counter;
    
    initial begin
        reset_counter = 0;
        last_pc = 32'h0;
    end
    
    // Enhanced CPU and memory monitoring - remove invalid DRAM controller references
    always @(posedge clk) begin
        if (!reset_n) begin
            reset_counter <= 0;
        end else begin
            reset_counter <= reset_counter + 1;
            
            // TAMBAHKAN INI - Monitor memory transactions
            // Monitor store operation (SW)
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && |dut.cpu.mem_wstrb && dut.cpu.mem_addr == 32'h1000) begin
                store_completed <= 1'b1;
                stored_value <= dut.cpu.mem_wdata;
                $display("[TESTBENCH %t] *** STORE DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.cpu.mem_addr, dut.cpu.mem_wdata);
                $fdisplay(log_file, "[TESTBENCH %t] *** STORE DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.cpu.mem_addr, dut.cpu.mem_wdata);
            end
            
            // Monitor load operation (LW)  
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && dut.cpu.mem_instr == 1'b0 && dut.cpu.mem_addr == 32'h1000) begin
                load_completed <= 1'b1;
                loaded_value <= dut.cpu.mem_rdata;
                $display("[TESTBENCH %t] *** LOAD DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                $fdisplay(log_file, "[TESTBENCH %t] *** LOAD DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
            end
            
            // TAMBAHKAN INI - Monitor PC progression
            if (dut.cpu.reg_pc != prev_pc && reset_n) begin
                if (dut.cpu.reg_pc != 32'h0) program_started <= 1'b1;
                
                // Check if we've reached the loop (PC jumps back)
                if (dut.cpu.reg_pc < prev_pc && program_started) begin
                    reached_loop <= 1'b1;
                    $display("[TESTBENCH %t] *** PROGRAM LOOP DETECTED - Test completed! ***", $time);
                    $fdisplay(log_file, "[TESTBENCH %t] *** PROGRAM LOOP DETECTED - Test completed! ***", $time);
                end
                
                prev_pc <= dut.cpu.reg_pc;
            end
        end
    end
    
    
    // Memory command monitoring - updated for actual DRAM signals
    always @(posedge clk) begin
        if (dram_cs) begin
            if (!dram_ras && !dram_cas) begin
                if (!dram_we) begin
                    $display("Time %t: DRAM WRITE command - addr=0x%04x, ba=%d", $time, dram_addr, dram_ba);
                end else begin
                    $display("Time %t: DRAM READ command - addr=0x%04x, ba=%d", $time, dram_addr, dram_ba);
                end
            end else if (!dram_ras && dram_cas) begin
                $display("Time %t: DRAM ACTIVATE command - addr=0x%04x, ba=%d", $time, dram_addr, dram_ba);
            end else if (dram_ras && !dram_cas) begin
                $display("Time %t: DRAM PRECHARGE command - addr=0x%04x, ba=%d", $time, dram_addr, dram_ba);
            end
        end
    end
    
    // Register monitoring (sample some registers periodically)
    integer reg_monitor_count = 0;
    always @(posedge clk) begin
        if (reset_n) begin
            reg_monitor_count <= reg_monitor_count + 1;
            if (reg_monitor_count % 1000 == 0) begin // Every 1000 cycles
                $display("Time %t: Register dump:", $time);
                // Note: These paths might need adjustment based on actual hierarchy
                $display("  x1=0x%08x x2=0x%08x x3=0x%08x x4=0x%08x", 
                         dut.cpu.cpuregs[1], dut.cpu.cpuregs[2], 
                         dut.cpu.cpuregs[3], dut.cpu.cpuregs[4]);
                $display("  x5=0x%08x x6=0x%08x x7=0x%08x x8=0x%08x", 
                         dut.cpu.cpuregs[5], dut.cpu.cpuregs[6], 
                         dut.cpu.cpuregs[7], dut.cpu.cpuregs[8]);
            end
        end
    end
    
    // Monitor grant signals and transaction states - updated for actual signals
    always @(posedge clk) begin
        time_ms = $realtime / 1000.0;
        
        if (time_ms >= 90.0 && time_ms <= 110.0) begin
            $display("[DEBUG %t] DRAM Signals: cs=%b, we=%b, ras=%b, cas=%b, addr=0x%h",
                    $time, dram_cs, dram_we, dram_ras, dram_cas, dram_addr);
            $display("[DEBUG %t] DRAM Data: dq=0x%h, dm=0x%h, dqs=%b",
                    $time, dram_dq, dram_dm, dram_dqs);
        end
    end

    // Monitor CPU execution based on PC value and register values
    always @(posedge clk) begin
        if (reset_n) begin
            // Check PC to monitor which instructions have been executed
            case (dut.cpu.reg_pc)
                32'h00000000: if (!completed_lui_x4) 
                              $display("Time %t: Starting execution at PC=0x%08x - lui x4, 0x1", $time, dut.cpu.reg_pc);
                              
                32'h00000004: if (!completed_addi_x1) begin
                              $display("Time %t: Executing PC=0x%08x - addi x1, x0, 10", $time, dut.cpu.reg_pc);
                              completed_lui_x4 = 1;
                              end
                              
                32'h00000008: if (!completed_addi_x2) begin
                              $display("Time %t: Executing PC=0x%08x - addi x2, x0, 20", $time, dut.cpu.reg_pc);
                              completed_addi_x1 = 1;
                              
                              // Check if x1 has correct value
                              if (dut.cpu.cpuregs[1] == expected_x1_value)
                                $display("Time %t: PASS - Register x1=0x%08x, expected=0x%08x", 
                                         $time, dut.cpu.cpuregs[1], expected_x1_value);
                              else
                                $display("Time %t: FAIL - Register x1=0x%08x, expected=0x%08x", 
                                         $time, dut.cpu.cpuregs[1], expected_x1_value);
                              end
                              
                32'h0000000C: if (!completed_add_x3) begin
                              $display("Time %t: Executing PC=0x%08x - add x3, x1, x2", $time, dut.cpu.reg_pc);
                              completed_addi_x2 = 1;
                              
                              // Check if x2 has correct value
                              if (dut.cpu.cpuregs[2] == expected_x2_value)
                                $display("Time %t: PASS - Register x2=0x%08x, expected=0x%08x", 
                                         $time, dut.cpu.cpuregs[2], expected_x2_value);
                              else
                                $display("Time %t: FAIL - Register x2=0x%08x, expected=0x%08x", 
                                         $time, dut.cpu.cpuregs[2], expected_x2_value);
                              end
                              
                32'h00000010: if (!completed_sw) begin
                              $display("Time %t: Executing PC=0x%08x - sw x3, 0(x4)", $time, dut.cpu.reg_pc);
                              completed_add_x3 = 1;
                              
                              // Check if x3 has correct value (sum of x1 and x2)
                              if (dut.cpu.cpuregs[3] == expected_x3_value)
                                $display("Time %t: PASS - Register x3=0x%08x, expected=0x%08x (arithmetic operation successful)", 
                                         $time, dut.cpu.cpuregs[3], expected_x3_value);
                              else
                                $display("Time %t: FAIL - Register x3=0x%08x, expected=0x%08x", 
                                         $time, dut.cpu.cpuregs[3], expected_x3_value);
                              end
                              
                32'h00000014: if (!completed_lw) begin
                              $display("Time %t: Executing PC=0x%08x - lw x5, 0(x4)", $time, dut.cpu.reg_pc);
                              completed_sw = 1;
                              $display("Time %t: Store operation completed, checking memory write via DRAM controller...", $time);
                              end
                              
                32'h00000018: begin
                              if (!completed_lw) begin
                                 $display("Time %t: Reached infinite loop at PC=0x%08x", $time, dut.cpu.reg_pc);
                                 completed_lw = 1;
                                 
                                 // Check if x5 has correct value (loaded from memory)
                                 if (dut.cpu.cpuregs[5] == expected_x3_value)
                                    $display("Time %t: PASS - Register x5=0x%08x, expected=0x%08x (memory load successful)", 
                                             $time, dut.cpu.cpuregs[5], expected_x3_value);
                                 else
                                    $display("Time %t: FAIL - Register x5=0x%08x, expected=0x%08x (memory load failed)", 
                                             $time, dut.cpu.cpuregs[5], expected_x3_value);
                                    
                                 // TAMBAHKAN INI - Enhanced success evaluation
                                 $display("\n=== ENHANCED TEST PROGRAM EVALUATION ===");
                                 $display("1. ADDI x1,x0,10:  %s", (dut.cpu.cpuregs[1] == expected_x1_value) ? "PASS" : "FAIL");
                                 $display("2. ADDI x2,x0,20:  %s", (dut.cpu.cpuregs[2] == expected_x2_value) ? "PASS" : "FAIL"); 
                                 $display("3. ADD x3,x1,x2:   %s", (dut.cpu.cpuregs[3] == expected_x3_value) ? "PASS" : "FAIL");
                                 $display("4. LUI x4,0x1:     %s", (dut.cpu.cpuregs[4] == 32'h1000) ? "PASS" : "FAIL");
                                 $display("5. SW x3,0(x4):    %s", store_completed ? "PASS" : "FAIL");
                                 $display("6. LW x5,0(x4):    %s", load_completed ? "PASS" : "FAIL");
                                 $display("7. Data integrity: %s", (stored_value == loaded_value && stored_value == 32'd30) ? "PASS" : "FAIL");
                                 $display("8. Loop reached:   %s", reached_loop ? "PASS" : "FAIL");
                                 
                                 if ((dut.cpu.cpuregs[1] == expected_x1_value) && 
                                     (dut.cpu.cpuregs[2] == expected_x2_value) && 
                                     (dut.cpu.cpuregs[3] == expected_x3_value) && 
                                     (dut.cpu.cpuregs[4] == 32'h1000) &&
                                     store_completed && load_completed && 
                                     (stored_value == loaded_value) && reached_loop) begin
                                     $display("\n*** ALL TESTS PASSED! CPU is working correctly! ***");
                                     $fdisplay(log_file, "\n*** ALL TESTS PASSED! CPU is working correctly! ***");
                                 end else begin
                                     $display("\n*** SOME TESTS FAILED! Check the implementation! ***");
                                     $fdisplay(log_file, "\n*** SOME TESTS FAILED! Check the implementation! ***");
                                 end
                                 
                                 $display("==========================================\n");
                                 $fdisplay(log_file, "==========================================\n");
                                 
                                 // All tests completed - print summary
                                 $display("\nTime %t: Test Program Execution Summary:", $time);
                                 $display("  - CPU initialization: PASS");
                                 $display("  - Register access: %s", (dut.cpu.cpuregs[1] == expected_x1_value && 
                                                                     dut.cpu.cpuregs[2] == expected_x2_value) ? "PASS" : "FAIL");
                                 $display("  - Arithmetic operation: %s", (dut.cpu.cpuregs[3] == expected_x3_value) ? "PASS" : "FAIL");
                                 $display("  - Memory store/load via AXI/DRAM: %s\n", 
                                          (dut.cpu.cpuregs[5] == expected_x3_value) ? "PASS" : "FAIL");
                              end
                              end
            endcase
        end
    end
    
    // Monitor register file write operations
    always @(posedge clk) begin
        if (reset_n) begin
            // Monitor register write signals
            if (dut.cpu.cpuregs_write && dut.cpu.latched_rd != 0) begin
                $display("Time %t: CPU Register Write - latched_rd=%d, cpuregs_wrdata=0x%08x, resetn=%b", 
                        $time, dut.cpu.latched_rd, dut.cpu.cpuregs_wrdata, dut.cpu.resetn);
            end
            
            // Monitor CPU state machine
            $display("Time %t: CPU State=%s, latched_store=%b, cpuregs_write=%b, latched_rd=%d", 
                    $time, 
                    (dut.cpu.cpu_state == 8'b01000000) ? "FETCH" :
                    (dut.cpu.cpu_state == 8'b00100000) ? "LD_RS1" :
                    (dut.cpu.cpu_state == 8'b00010000) ? "LD_RS2" :
                    (dut.cpu.cpu_state == 8'b00001000) ? "EXEC" :
                    (dut.cpu.cpu_state == 8'b00000100) ? "SHIFT" :
                    (dut.cpu.cpu_state == 8'b00000010) ? "STMEM" :
                    (dut.cpu.cpu_state == 8'b00000001) ? "LDMEM" : "TRAP",
                    dut.cpu.latched_store, dut.cpu.cpuregs_write, dut.cpu.latched_rd);
        end
    end
endmodule
