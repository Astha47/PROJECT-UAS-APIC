`timescale 1ns / 1ps

`include "top.v"
`include "ramlpddr4_dummy.v"

module simple_test;
    // Testbench signals
    reg clk;
    reg reset_n;
    wire trap;
    
    // LPDDR4 interface signals
    wire lpddr4_ck_t, lpddr4_ck_c, lpddr4_cke, lpddr4_reset_n, lpddr4_cs_n;
    wire [5:0] lpddr4_ca;
    wire [31:0] lpddr4_dq;
    wire [3:0] lpddr4_dqs_t, lpddr4_dqs_c;
    
    // Clock generation - 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        reset_n = 0;
        #100 reset_n = 1;
    end
    
    // DUT instantiation
    top dut (
        .clk(clk),
        .reset_n(reset_n),
        .lpddr4_ck_t(lpddr4_ck_t),
        .lpddr4_ck_c(lpddr4_ck_c),
        .lpddr4_cke(lpddr4_cke),
        .lpddr4_reset_n(lpddr4_reset_n),
        .lpddr4_cs_n(lpddr4_cs_n),
        .lpddr4_ca(lpddr4_ca),
        .lpddr4_dq(lpddr4_dq),
        .lpddr4_dqs_t(lpddr4_dqs_t),
        .lpddr4_dqs_c(lpddr4_dqs_c),
        .trap(trap)
    );
    
    // Dummy LPDDR4 RAM
    ramlpddr4_dummy #(
        .CAPACITY_GB(4),
        .SIM_SIZE_KB(64)
    ) ram (
        .ck_t(lpddr4_ck_t),
        .ck_c(lpddr4_ck_c),
        .cke(lpddr4_cke),
        .reset_n(lpddr4_reset_n),
        .cs_n(lpddr4_cs_n),
        .ca(lpddr4_ca),
        .dq(lpddr4_dq),
        .dqs_t(lpddr4_dqs_t),
        .dqs_c(lpddr4_dqs_c)
    );
    
    // Simple monitoring focused on program execution
    reg [31:0] last_pc = 0;
    reg [31:0] instruction_count = 0;
    
    initial begin
        $display("=== SoC Boot and Program Execution Test ===");
        $dumpfile("simple_test.vcd");
        $dumpvars(0, simple_test);
        
        // Wait for reset
        wait(reset_n == 1);
        $display("Time %t: Reset released, starting CPU", $time);
        
        // Monitor execution for reasonable time
        #50000; // 50us
        
        $display("\n=== Execution Summary ===");
        $display("Instructions executed: %d", instruction_count);
        $display("Final PC: 0x%08x", dut.cpu.reg_pc);
        $display("Register dump:");
        $display("  x1 = %d (0x%08x)", $signed(dut.cpu.cpuregs[1]), dut.cpu.cpuregs[1]);
        $display("  x2 = %d (0x%08x)", $signed(dut.cpu.cpuregs[2]), dut.cpu.cpuregs[2]);
        $display("  x3 = %d (0x%08x)", $signed(dut.cpu.cpuregs[3]), dut.cpu.cpuregs[3]);
        $display("  x4 = 0x%08x", dut.cpu.cpuregs[4]);
        $display("  x5 = %d (0x%08x)", $signed(dut.cpu.cpuregs[5]), dut.cpu.cpuregs[5]);
        
        $finish;
    end
    
    // Monitor CPU state changes and instruction execution
    always @(posedge clk) begin
        if (reset_n) begin
            // Monitor PC changes (indicates instruction execution)
            if (dut.cpu.reg_pc !== last_pc) begin
                instruction_count <= instruction_count + 1;
                $display("Time %t: [%d] PC: 0x%08x -> 0x%08x", 
                         $time, instruction_count, last_pc, dut.cpu.reg_pc);
                last_pc <= dut.cpu.reg_pc;
            end
            
            // Monitor instruction fetches
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && dut.cpu.mem_instr) begin
                $display("Time %t: FETCH - Addr:0x%08x Data:0x%08x", 
                         $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                
                // Decode basic instruction info
                case (dut.cpu.mem_rdata[6:0])
                    7'b0110111: $display("         -> LUI instruction");
                    7'b0010011: $display("         -> ADDI instruction");
                    7'b0110011: $display("         -> ADD/SUB instruction");
                    7'b0100011: $display("         -> STORE instruction");
                    7'b0000011: $display("         -> LOAD instruction");
                    default: $display("         -> Other instruction (opcode: %b)", dut.cpu.mem_rdata[6:0]);
                endcase
            end
            
            // Monitor memory data operations
            if (dut.cpu.mem_valid && dut.cpu.mem_ready && !dut.cpu.mem_instr) begin
                if (|dut.cpu.mem_wstrb) begin
                    $display("Time %t: STORE - Addr:0x%08x Data:0x%08x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_wdata);
                end else begin
                    $display("Time %t: LOAD  - Addr:0x%08x Data:0x%08x", 
                             $time, dut.cpu.mem_addr, dut.cpu.mem_rdata);
                end
            end
            
            // Monitor for CPU trap
            if (trap) begin
                $display("Time %t: *** CPU TRAP DETECTED ***", $time);
                $display("Final PC: 0x%08x", dut.cpu.reg_pc);
                $finish;
            end
            
            // Monitor DRAM controller state
            if (instruction_count < 5) begin
                $display("Time %t: DRAM state=%d init_done=%b", 
                         $time, dut.dram_controller_inst.state, dut.dram_controller_inst.init_done);
            end
        end
    end

endmodule
