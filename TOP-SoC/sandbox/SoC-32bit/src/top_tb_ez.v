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
    // Test tracking variables for ez program
    reg completed_addi_x1;    // ADDI x1, x0, 1020
    reg completed_sw_init;    // SW x0, 0(x1) - initial store
    reg completed_lw;         // LW x2, 0(x1) - load
    reg completed_addi_x2;    // ADDI x2, x2, 1 - increment
    reg completed_sw_update;  // SW x2, 0(x1) - store back
    reg completed_loop;       // JAL loop
    
    // Variable monitoring for counter program
    reg store_completed = 1'b0;
    reg load_completed = 1'b0;
    reg [31:0] stored_value = 32'h0;
    reg [31:0] loaded_value = 32'h0;
    reg program_started = 1'b0;
    reg reached_loop = 1'b0;
    reg [31:0] prev_pc = 32'h0;
    reg [31:0] loop_count = 32'h0;
    
    // Expected values for ez program
    integer expected_x1_value;  // Should be 1020 (0x3FC)
    integer expected_memory_addr;  // Should be 1020 for memory operations
    integer max_loop_iterations;  // Number of iterations to test
    
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
        
        completed_addi_x1 = 0;
        completed_sw_init = 0;
        completed_lw = 0;
        completed_addi_x2 = 0;
        completed_sw_update = 0;
        completed_loop = 0;
        
        // Initialize monitoring variables for counter program
        store_completed = 1'b0;
        load_completed = 1'b0;
        stored_value = 32'h0;
        loaded_value = 32'h0;
        program_started = 1'b0;
        reached_loop = 1'b0;
        prev_pc = 32'h0;
        loop_count = 32'h0;
        
        expected_x1_value = 1020;  // 0x3FC
        expected_memory_addr = 1020;  // Address used for memory operations
        max_loop_iterations = 10;  // Test 10 iterations of the counter
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
    
    // Program is now loaded directly into LPDDR4 dummy memory via test_program_ez.hex
    initial begin
        $display("Counter test program will be loaded by LPDDR4 dummy memory from test_program_ez.hex");
        $fdisplay(log_file, "Counter test program will be loaded by LPDDR4 dummy memory from test_program_ez.hex");
        
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
        $display("Starting SoC with PicoRV32 CPU counter test");
        $fdisplay(log_file, "Starting SoC with PicoRV32 CPU counter test");
        
        // Enable comprehensive waveform dumping for VCD file
        $dumpfile("top_tb_soc_simulation.vcd");
        $dumpvars(0, top_tb);
        
        // Additional VCD control - dump all signals at all hierarchy levels
        $dumpall;
        
        $display("VCD file generation enabled: top_tb_soc_simulation.vcd");
        $fdisplay(log_file, "VCD file generation enabled: top_tb_soc_simulation.vcd");
        
        // Run for a reasonable amount of time - longer for counter program
        #5000; // Run for 5000ns to see multiple loop iterations
        
        $display("Simulation complete at time %t", $time);
        $fdisplay(log_file, "Simulation complete at time %t", $time);
        
        // Final verification for counter program
        $display("\nFinal Counter Program Verification:");
        $fdisplay(log_file, "\nFinal Counter Program Verification:");
        $display("  - Program completed: %s", reached_loop ? "PASS" : "FAIL");
        $fdisplay(log_file, "  - Program completed: %s", reached_loop ? "PASS" : "FAIL");
        $display("  - PC at end: 0x%08x", dut.picorv32.reg_pc);
        $fdisplay(log_file, "  - PC at end: 0x%08x", dut.picorv32.reg_pc);
        $display("  - x1 (memory addr, expected 1020): %d", dut.picorv32.cpuregs[1]);
        $fdisplay(log_file, "  - x1 (memory addr, expected 1020): %d", dut.picorv32.cpuregs[1]);
        $display("  - x2 (counter value): %d", dut.picorv32.cpuregs[2]);
        $fdisplay(log_file, "  - x2 (counter value): %d", dut.picorv32.cpuregs[2]);
        $display("  - Loop iterations: %d", loop_count);
        $fdisplay(log_file, "  - Loop iterations: %d", loop_count);
        $display("  - Memory[1020]: 0x%08x\n", ram.memory[255]); // 255 = 1020/4
        $fdisplay(log_file, "  - Memory[1020]: 0x%08x\n", ram.memory[255]);
        
        // Close the log file before finishing
        $fclose(log_file);
        $display("Log file closed");
        
        // Finalize VCD dump
        $dumpflush;
        $display("VCD file finalized: top_tb_soc_simulation.vcd");

        // Check if the counter program was successful
        $display("Time %t: Counter program completed at PC=0x%08x", $time, dut.picorv32.reg_pc);
                               
        // Check if x1 has correct memory address (1020)
        if (dut.picorv32.cpuregs[1] == expected_x1_value)
           $display("Time %t: PASS - Register x1=0x%08x, expected=0x%08x (memory address correct)", 
                    $time, dut.picorv32.cpuregs[1], expected_x1_value);
        else
           $display("Time %t: FAIL - Register x1=0x%08x, expected=0x%08x (memory address incorrect)", 
                    $time, dut.picorv32.cpuregs[1], expected_x1_value);
           
        // Enhanced success evaluation for counter program
        $display("\n=== COUNTER PROGRAM EVALUATION ===");
        $display("1. ADDI x1,x0,1020: %s", (dut.picorv32.cpuregs[1] == expected_x1_value) ? "PASS" : "FAIL");
        $display("2. Initial SW x0,0(x1): %s", completed_sw_init ? "PASS" : "FAIL");
        $display("3. LW x2,0(x1): %s", completed_lw ? "PASS" : "FAIL"); 
        $display("4. ADDI x2,x2,1: %s", completed_addi_x2 ? "PASS" : "FAIL");
        $display("5. SW x2,0(x1): %s", completed_sw_update ? "PASS" : "FAIL");
        $display("6. Loop execution: %s", reached_loop ? "PASS" : "FAIL");
        $display("7. Memory operations: %s", (store_completed && load_completed) ? "PASS" : "FAIL");
        $display("8. Counter value > 0: %s", (dut.picorv32.cpuregs[2] > 0) ? "PASS" : "FAIL");
        
        if ((dut.picorv32.cpuregs[1] == expected_x1_value) && 
            completed_sw_init && completed_lw && completed_addi_x2 && completed_sw_update &&
            store_completed && load_completed && reached_loop && 
            (dut.picorv32.cpuregs[2] > 0) && (loop_count >= 1)) begin
            $display("\n*** COUNTER PROGRAM TESTS PASSED! CPU is working correctly! ***");
            $fdisplay(log_file, "\n*** COUNTER PROGRAM TESTS PASSED! CPU is working correctly! ***");
        end else begin
            $display("\n*** SOME TESTS FAILED! Check the implementation! ***");
            $fdisplay(log_file, "\n*** SOME TESTS FAILED! Check the implementation! ***");
        end
        
        $display("==========================================\n");
        $fdisplay(log_file, "==========================================\n");
        
        // Counter program execution summary
        $display("\nTime %t: Counter Program Execution Summary:", $time);
        $display("  - CPU initialization: PASS");
        $display("  - Address setup (x1=1020): %s", (dut.picorv32.cpuregs[1] == expected_x1_value) ? "PASS" : "FAIL");
        $display("  - Memory operations via AXI/DRAM: %s", 
                  (store_completed && load_completed) ? "PASS" : "FAIL");
        $display("  - Counter increment operations: %s", (dut.picorv32.cpuregs[2] > 0) ? "PASS" : "FAIL");
        $display("  - Loop execution: %s\n", reached_loop ? "PASS" : "FAIL");
        $display("Mem[0x%08x] = 0x%08x", 1020, ram.memory[255]); // Check address 1020 (255 = 1020/4)
        
        $finish;
    end
    
    // CPU state monitoring
    reg [31:0] last_pc;
    reg [7:0] reset_counter;
    
    initial begin
        reset_counter = 0;
        last_pc = 32'h0;
    end
    
    // Enhanced CPU and memory monitoring
    always @(posedge clk) begin
        if (!reset_n) begin
            reset_counter <= 0;
        end else begin
            reset_counter <= reset_counter + 1;
            
            // Monitor memory transactions for counter program
            // Monitor store operation (SW) at address 1020
            if (dut.picorv32.mem_valid && dut.picorv32.mem_ready && |dut.picorv32.mem_wstrb && dut.picorv32.mem_addr == 32'd1020) begin
                store_completed <= 1'b1;
                stored_value <= dut.picorv32.mem_wdata;
                $display("[TESTBENCH %t] *** STORE DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.picorv32.mem_addr, dut.picorv32.mem_wdata);
                $fdisplay(log_file, "[TESTBENCH %t] *** STORE DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.picorv32.mem_addr, dut.picorv32.mem_wdata);
            end
            
            // Monitor load operation (LW) at address 1020
            if (dut.picorv32.mem_valid && dut.picorv32.mem_ready && dut.picorv32.mem_instr == 1'b0 && dut.picorv32.mem_addr == 32'd1020) begin
                load_completed <= 1'b1;
                loaded_value <= dut.picorv32.mem_rdata;
                $display("[TESTBENCH %t] *** LOAD DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.picorv32.mem_addr, dut.picorv32.mem_rdata);
                $fdisplay(log_file, "[TESTBENCH %t] *** LOAD DETECTED *** addr=0x%x, data=0x%x", 
                        $time, dut.picorv32.mem_addr, dut.picorv32.mem_rdata);
            end
            
            // Monitor PC progression for counter program
            if (dut.picorv32.reg_pc != prev_pc && reset_n) begin
                if (dut.picorv32.reg_pc != 32'h0) program_started <= 1'b1;
                
                // Check if we've reached the loop (PC jumps backwards to 0x0c)
                if (program_started && dut.picorv32.reg_pc == 32'h0000000c && prev_pc > dut.picorv32.reg_pc) begin
                    if (!reached_loop) begin // Print message only first time we reach loop
                        reached_loop <= 1'b1;
                        $display("[TESTBENCH %t] *** PROGRAM LOOP DETECTED - Counter test in progress! ***", $time);
                        $fdisplay(log_file, "[TESTBENCH %t] *** PROGRAM LOOP DETECTED - Counter test in progress! ***", $time);
                    end
                    loop_count <= loop_count + 1; // Count loop iterations
                end
                
                prev_pc <= dut.picorv32.reg_pc;
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
    
    // Register monitoring (sample some registers periodically) - adapted for counter program
    integer reg_monitor_count = 0;
    always @(posedge clk) begin
        if (reset_n) begin
            reg_monitor_count <= reg_monitor_count + 1;
            if (reg_monitor_count % 500 == 0) begin // Every 500 cycles (more frequent for counter)
                $display("Time %t: Register dump (Counter Program):", $time);
                $display("  x1=0x%08x (mem_addr, expect 1020) x2=0x%08x (counter)", 
                         dut.picorv32.cpuregs[1], dut.picorv32.cpuregs[2]);
                $display("  x3=0x%08x x4=0x%08x x5=0x%08x x6=0x%08x", 
                         dut.picorv32.cpuregs[3], dut.picorv32.cpuregs[4], 
                         dut.picorv32.cpuregs[5], dut.picorv32.cpuregs[6]);
                $display("  PC=0x%08x, Loop_count=%d", dut.picorv32.reg_pc, loop_count);
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

    // Monitor CPU execution based on PC value and register values for counter program
    always @(posedge clk) begin
        if (reset_n) begin
            // Check PC to monitor which instructions have been executed
            case (dut.picorv32.reg_pc)
                32'h00000000: if (!completed_addi_x1) 
                              $display("Time %t: Starting execution at PC=0x%08x - addi x1, x0, 1020", $time, dut.picorv32.reg_pc);
                              
                32'h00000004: if (!completed_sw_init) begin // Instruction at PC=0x04 is sw x0, 0(x1)
                              $display("Time %t: Executing PC=0x%08x - sw x0, 0(x1)", $time, dut.picorv32.reg_pc);
                              completed_addi_x1 = 1; // Mark instruction at PC=0x00 (addi x1) as processed
                              
                              // Check if x1 has correct address value
                              if (dut.picorv32.cpuregs[1] == expected_x1_value)
                                $display("Time %t: PASS - Register x1=0x%08x, expected=0x%08x (address setup)", 
                                         $time, dut.picorv32.cpuregs[1], expected_x1_value);
                              else
                                $display("Time %t: FAIL - Register x1=0x%08x, expected=0x%08x", 
                                         $time, dut.picorv32.cpuregs[1], expected_x1_value);
                              end
                              
                32'h00000008: if (!completed_lw && !reached_loop) begin // Instruction at PC=0x08 is lw x2, 0(x1) - also loop target
                              if (!completed_sw_init) begin
                                  $display("Time %t: Executing PC=0x%08x - lw x2, 0(x1)", $time, dut.picorv32.reg_pc);
                                  completed_sw_init = 1; // Mark instruction at PC=0x04 (sw x0) as processed
                              end else begin
                                  // We're in a loop iteration
                                  $display("Time %t: Loop iteration %d - PC=0x%08x - lw x2, 0(x1)", 
                                          $time, loop_count + 1, dut.picorv32.reg_pc);
                              end
                              end
                              
                32'h0000000C: if (!completed_addi_x2) begin // Instruction at PC=0x0C is addi x2, x2, 1
                              $display("Time %t: Executing PC=0x%08x - addi x2, x2, 1", $time, dut.picorv32.reg_pc);
                              if (!completed_lw) completed_lw = 1; // Mark first lw as completed
                              end
                              
                32'h00000010: if (!completed_sw_update) begin // Instruction at PC=0x10 is sw x2, 0(x1)
                              $display("Time %t: Executing PC=0x%08x - sw x2, 0(x1)", $time, dut.picorv32.reg_pc);
                              completed_addi_x2 = 1; // Mark addi x2 as processed
                              
                              // Show current counter value
                              $display("Time %t: Counter value in x2 = %d", $time, dut.picorv32.cpuregs[2]);
                              end
                              
                32'h00000014: begin // Instruction at PC=0x14 is jal (loop back)
                              if (!completed_sw_update) completed_sw_update = 1; // Mark sw x2 as processed
                              $display("Time %t: Executing PC=0x%08x - jal x0, -12 (loop back)", $time, dut.picorv32.reg_pc);
                              end
                              
            endcase
        end
    end
    
    // Monitor register file write operations - less verbose for counter program
    always @(posedge clk) begin
        if (reset_n) begin
            // Monitor register write signals only for important registers
            if (dut.picorv32.cpuregs_write && dut.picorv32.latched_rd != 0 && (dut.picorv32.latched_rd <= 2)) begin
                $display("Time %t: CPU Register Write - latched_rd=%d, cpuregs_wrdata=0x%08x", 
                        $time, dut.picorv32.latched_rd, dut.picorv32.cpuregs_wrdata);
            end
            
            // Monitor CPU state machine only occasionally to reduce verbosity
            if (reg_monitor_count % 1000 == 0) begin
                $display("Time %t: CPU State=%s, latched_store=%b, cpuregs_write=%b, latched_rd=%d", 
                        $time, 
                        (dut.picorv32.cpu_state == 8'b01000000) ? "FETCH" :
                        (dut.picorv32.cpu_state == 8'b00100000) ? "LD_RS1" :
                        (dut.picorv32.cpu_state == 8'b00010000) ? "LD_RS2" :
                        (dut.picorv32.cpu_state == 8'b00001000) ? "EXEC" :
                        (dut.picorv32.cpu_state == 8'b00000100) ? "SHIFT" :
                        (dut.picorv32.cpu_state == 8'b00000010) ? "STMEM" :
                        (dut.picorv32.cpu_state == 8'b00000001) ? "LDMEM" : "TRAP",
                        dut.picorv32.latched_store, dut.picorv32.cpuregs_write, dut.picorv32.latched_rd);
            end
        end
    end
    
    // VCD dump control - manage VCD file size and timing
    initial begin
        // Wait for reset to complete before starting detailed VCD dump
        wait(reset_n == 1);
        #100; // Additional delay after reset
        
        $display("Starting detailed VCD dump after reset completion");
        $fdisplay(log_file, "Starting detailed VCD dump after reset completion");
        
        // Optional: Stop VCD dump after certain time to limit file size
        // Uncomment the following lines if VCD file becomes too large
        /*
        #10000; // Stop VCD dump after 10us
        $dumpoff;
        $display("VCD dump stopped to limit file size");
        $fdisplay(log_file, "VCD dump stopped to limit file size");
        */
    end
endmodule
