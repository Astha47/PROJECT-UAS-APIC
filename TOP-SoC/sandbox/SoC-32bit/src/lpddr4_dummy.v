module lpddr4_dummy (
    input wire clk,
    input wire cs,
    input wire we,
    input wire ras,
    input wire cas,
    input wire [13:0] addr,
    input wire [2:0] ba,
    inout wire [31:0] dq,
    input wire [3:0] dm,
    input wire dqs
);

    // Memory array - larger to accommodate 0x1000 address
    reg [31:0] memory [0:65535]; // 256KB memory (64K x 32-bit words)
    reg [31:0] data_out;
    reg output_enable;
    reg [31:0] write_data;

    reg [31:0] debug_reg_write = 32'h0; // Debug register to store data at address 0x0400
    reg [31:0] debug_reg_read = 32'h0;  // Debug register to read data from address 0x0400

    reg debug_status = 0;
    
    // Address calculation - use full 14-bit address
    wire [13:0] mem_addr = addr;  // Use full address directly
    
    assign dq = output_enable ? data_out : 32'hZ;
    
    // Initialize memory from hex file
    initial begin
        // Initialize all memory to zero first
        for (integer i = 0; i < 65536; i = i + 1) begin
            memory[i] = 32'h0;
        end
        
        // Load program from hex file
        $readmemh("test_program.hex", memory);
        data_out = 32'h0;
        output_enable = 1'b0;
        write_data = 32'h0;
        
        $display("LPDDR4: Memory initialized, size = %d words", 65536);
    end
    
    // Memory operations
    always @(posedge clk) begin
        if (!cs && !ras && !cas) begin
            debug_status <= 1; // Indicate debug mode is active
            if (!we) begin
                // Write operation - capture data immediately
                memory[mem_addr] <= dq;
                if (mem_addr == 14'h0400) begin
                    debug_reg_write <= dq; // Store debug data
                    $display("ALERTT !!!! LPDDR4: Write addr=%04x data=%08x (AXI_addr would be: 0x%08x)", mem_addr, dq, mem_addr * 4);
                end
                $display("LPDDR4: Write addr=%04x data=%08x (AXI_addr would be: 0x%08x)", mem_addr, dq, mem_addr * 4);
                output_enable <= 1'b0;
            end else begin
                // Read operation - output data immediately
                data_out <= memory[mem_addr];
                output_enable <= 1'b1;
                debug_reg_read <= memory[mem_addr]; // Store debug data
                $display("LPDDR4: Read addr=%04x data=%08x (AXI_addr would be: 0x%08x)", mem_addr, memory[mem_addr], mem_addr * 4);
            end
        end else begin
            debug_status <= 0; // Indicate debug mode is inactive
            output_enable <= 1'b0;
        end
    end

endmodule
