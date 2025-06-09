`timescale 1ns / 1ps

`include "top.v"
`include "ramlpddr4_dummy.v"

module top_tb;
    // Testbench signals
    reg clk;
    reg reset_n;
    wire trap;
    
    // File handle for logging
    integer log_file;
    
    // LPDDR4 interface signals between top and dummy RAM
    wire lpddr4_ck_t;
    wire lpddr4_ck_c;
    wire lpddr4_cke;
    wire lpddr4_reset_n;
    wire lpddr4_cs_n;
    wire [5:0] lpddr4_ca;
    wire [31:0] lpddr4_dq;
    wire [3:0] lpddr4_dqs_t;
    wire [3:0] lpddr4_dqs_c;
    
    // Test tracking variables
    reg completed_lui_x4;
    reg completed_addi_x1;
    reg completed_addi_x2;
    reg completed_add_x3;
    reg completed_sw;
    reg completed_lw;
    
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
    
    // DUT instantiation - Top SoC
    top dut (
        .clk(clk),
        .reset_n(reset_n),
        
        // LPDDR4 Interface
        .lpddr4_ck_t(lpddr4_ck_t),
        .lpddr4_ck_c(lpddr4_ck_c),
        .lpddr4_cke(lpddr4_cke),
        .lpddr4_reset_n(lpddr4_reset_n),
        .lpddr4_cs_n(lpddr4_cs_n),
        .lpddr4_ca(lpddr4_ca),
        .lpddr4_dq(lpddr4_dq),
        .lpddr4_dqs_t(lpddr4_dqs_t),
        .lpddr4_dqs_c(lpddr4_dqs_c),
        
        // Debug output
        .trap(trap)
    );
    
    // Instantiate the dummy LPDDR4 RAM
    ramlpddr4_dummy #(
        .CAPACITY_GB(4),
        .SIM_SIZE_KB(64)  // 64KB for simulation
    ) ram (
        // Clock signals
        .ck_t(lpddr4_ck_t),
        .ck_c(lpddr4_ck_c),
        .cke(lpddr4_cke),
        .reset_n(lpddr4_reset_n),
        .cs_n(lpddr4_cs_n),
        
        // Command/Address bus
        .ca(lpddr4_ca),
        
        // Data bus
        .dq(lpddr4_dq),
        .dqs_t(lpddr4_dqs_t),
        .dqs_c(lpddr4_dqs_c)
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
    
    // Enhanced CPU and memory monitoring
    always @(posedge clk) begin
        if (!reset_n) begin
            reset_counter <= 0;
        end else begin
            reset_counter <= reset_counter + 1;
            
            // Debug CPU state after reset
            if (reset_counter < 20) begin
                $display("Time %t: CPU Reset cycle %d - PC=0x%08x, resetn=%b, mem_valid=%b, mem_ready=%b", 
                         $time, reset_counter, dut.cpu.reg_pc, dut.cpu.resetn, dut.cpu.mem_valid, dut.cpu.mem_ready);
                $fdisplay(log_file, "Time %t: CPU Reset cycle %d - PC=0x%08x, resetn=%b, mem_valid=%b, mem_ready=%b", 
                         $time, reset_counter, dut.cpu.reg_pc, dut.cpu.resetn, dut.cpu.mem_valid, dut.cpu.mem_ready);
                
                $display("Time %t: DRAM Controller - init_state=%d, init_timer=%d, init_done=%b, state=%d", 
                         $time, dut.dram_controller_inst.init_state, dut.dram_controller_inst.init_timer, dut.dram_controller_inst.init_done, dut.dram_controller_inst.state);
                $fdisplay(log_file, "Time %t: DRAM Controller - init_state=%d, init_timer=%d, init_done=%b, state=%d", 
                         $time, dut.dram_controller_inst.init_state, dut.dram_controller_inst.init_timer, dut.dram_controller_inst.init_done, dut.dram_controller_inst.state);
            end
            
            // Monitor CPU PC changes
            if (dut.cpu.reg_pc !== last_pc) begin
                $display("Time %t: PC changed: 0x%08x -> 0x%08x", $time, last_pc, dut.cpu.reg_pc);
                $fdisplay(log_file, "Time %t: PC changed: 0x%08x -> 0x%08x", $time, last_pc, dut.cpu.reg_pc);
                last_pc <= dut.cpu.reg_pc;
            end
            
            // Monitor CPU PC and instruction fetches
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && dut.cpu.mem_instr) begin
                $display("Time %t: INSTR FETCH: PC=0x%08x, addr=0x%08x, data=0x%08x", 
                         $time, dut.cpu.reg_pc, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                $fdisplay(log_file, "Time %t: INSTR FETCH: PC=0x%08x, addr=0x%08x, data=0x%08x", 
                         $time, dut.cpu.reg_pc, dut.cpu.mem_addr, dut.cpu.mem_rdata);
            end
            
            // Monitor memory operations (data)
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && !dut.cpu.mem_instr) begin
                if (|dut.cpu.mem_wstrb) begin
                    $display("Time %t: Memory WRITE: addr=0x%08x, data=0x%08x, strobe=0x%01x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_wdata, dut.cpu.mem_wstrb);
                    $fdisplay(log_file, "Time %t: Memory WRITE: addr=0x%08x, data=0x%08x, strobe=0x%01x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_wdata, dut.cpu.mem_wstrb);
                end else begin
                    $display("Time %t: Memory READ:  addr=0x%08x, data=0x%08x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                    $fdisplay(log_file, "Time %t: Memory READ:  addr=0x%08x, data=0x%08x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                end
            end
            
            // Monitor memory interface signals
            if (dut.cpu.mem_valid && !dut.cpu.mem_ready) begin
                $display("Time %t: Memory access waiting - valid=%b ready=%b addr=0x%08x", 
                         $time, dut.cpu.mem_valid, dut.cpu.mem_ready, dut.cpu.mem_addr);
                $fdisplay(log_file, "Time %t: Memory access waiting - valid=%b ready=%b addr=0x%08x", 
                         $time, dut.cpu.mem_valid, dut.cpu.mem_ready, dut.cpu.mem_addr);
                
                $display("Time %t: DRAM Controller state=%d, init_done=%b, init_state=%d", 
                         $time, dut.dram_controller_inst.state, dut.dram_controller_inst.init_done, dut.dram_controller_inst.init_state);
                $fdisplay(log_file, "Time %t: DRAM Controller state=%d, init_done=%b, init_state=%d", 
                         $time, dut.dram_controller_inst.state, dut.dram_controller_inst.init_done, dut.dram_controller_inst.init_state);
            end
            
            // Monitor trap conditions
            if (trap) begin
                $display("Time %t: *** CPU TRAP DETECTED ***", $time);
                $fdisplay(log_file, "Time %t: *** CPU TRAP DETECTED ***", $time);
                $display("PC: 0x%08x", dut.cpu.reg_pc);
                $fdisplay(log_file, "PC: 0x%08x", dut.cpu.reg_pc);
                #100;
                $finish;
            end
        end
    end
    
    // Memory command monitoring
    always @(posedge clk) begin
        if (!lpddr4_cs_n) begin
            case(lpddr4_ca)
                6'b000001: $display("Time %t: LPDDR4 MRW command", $time);
                6'b000010: $display("Time %t: LPDDR4 MRR command", $time);
                6'b000100: $display("Time %t: LPDDR4 REFRESH command", $time);
                6'b001000: $display("Time %t: LPDDR4 PRECHARGE command", $time);
                6'b010000: $display("Time %t: LPDDR4 ACTIVATE command", $time);
                6'b100000: $display("Time %t: LPDDR4 WRITE command", $time);
                6'b100001: $display("Time %t: LPDDR4 READ command", $time);
                default: $display("Time %t: LPDDR4 Unknown command %b", $time, lpddr4_ca);
            endcase
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
    
    // Enhanced AXI read transaction monitoring 
    always @(posedge clk) begin
        if (dut.dram_controller_inst.state == 8) begin // READ_DATA state
            $display("Time %t: READ_DATA state - burst_counter=%d, active_len=%d, timing_counter=%d", 
                     $time, dut.dram_controller_inst.burst_counter, dut.dram_controller_inst.active_len, dut.dram_controller_inst.timing_counter);
            $display("Time %t: AXI4 READ - RVALID=%b, RREADY=%b, RLAST=%b, RDATA=0x%08x", 
                     $time, dut.dram_s_axi_rvalid, dut.dram_s_axi_rready, dut.dram_s_axi_rlast, dut.dram_s_axi_rdata);
        end
        
        // Monitor AXI read address channel
        if (dut.dram_s_axi_arvalid && dut.dram_s_axi_arready) begin
            $display("Time %t: AXI4 READ ADDRESS accepted - addr=0x%08x, len=%d, size=%d", 
                     $time, dut.dram_s_axi_araddr, dut.dram_s_axi_arlen, dut.dram_s_axi_arsize);
        end
        
        // Monitor AXI read data channel
        if (dut.dram_s_axi_rvalid && dut.dram_s_axi_rready) begin
            $display("Time %t: AXI4 READ DATA transferred - data=0x%08x, last=%b", 
                     $time, dut.dram_s_axi_rdata, dut.dram_s_axi_rlast);
        end
        
        // Monitor AXI write address channel
        if (dut.dram_s_axi_awvalid && dut.dram_s_axi_awready) begin
            $display("Time %t: AXI4 WRITE ADDRESS accepted - addr=0x%08x, len=%d, size=%d", 
                     $time, dut.dram_s_axi_awaddr, dut.dram_s_axi_awlen, dut.dram_s_axi_awsize);
        end
        
        // Monitor AXI write data channel
        if (dut.dram_s_axi_wvalid && dut.dram_s_axi_wready) begin
            $display("Time %t: AXI4 WRITE DATA transferred - data=0x%08x, strobe=0x%01x, last=%b", 
                     $time, dut.dram_s_axi_wdata, dut.dram_s_axi_wstrb, dut.dram_s_axi_wlast);
        end
        
        // Monitor AXI write response channel
        if (dut.dram_s_axi_bvalid && dut.dram_s_axi_bready) begin
            $display("Time %t: AXI4 WRITE RESPONSE received - id=0x%01x, resp=0x%01x", 
                     $time, dut.dram_s_axi_bid, dut.dram_s_axi_bresp);
        end
    end
    
    // Debug AXI4 master bridge state
    always @(posedge clk) begin
        if (dut.cpu_axi_master.mem_valid) begin
            $display("Time %t: AXI4 Master - state=%d, mem_valid=%b, mem_ready=%b, m_axi_rready=%b", 
                     $time, dut.cpu_axi_master.state, dut.cpu_axi_master.mem_valid, dut.cpu_axi_master.mem_ready, dut.cpu_axi_master.m_axi_rready);
        end
    end
    
    // Monitor grant signals and transaction states
    always @(posedge clk) begin
        time_ms = $realtime / 1000.0;
        
        if (time_ms >= 90.0 && time_ms <= 110.0) begin
            $display("[DEBUG %t] Grant Signals: s0_dram_read_grant=%b, s1_dram_read_grant=%b",
                    $time, dut.axi_interconnect_inst.s0_dram_read_grant, dut.axi_interconnect_inst.s1_dram_read_grant);
            $display("[DEBUG %t] Transaction flags: s0_read_to_dram=%b, s1_read_to_dram=%b",
                    $time, dut.axi_interconnect_inst.s0_read_to_dram, dut.axi_interconnect_inst.s1_read_to_dram);
            $display("[DEBUG %t] AXI AR Channel: ARVALID=%b, ARREADY=%b, ARADDR=0x%h",
                    $time, dut.axi_interconnect_inst.S0_AXI4_ARVALID, dut.axi_interconnect_inst.S0_AXI4_ARREADY, dut.axi_interconnect_inst.S0_AXI4_ARADDR);
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
endmodule
