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

    // Memory array
    reg [31:0] memory [0:1023]; // 4KB memory
    reg [31:0] data_out;
    reg output_enable;
    reg [31:0] write_data;
    
    // Address calculation - simplified to use only the address bits
    wire [9:0] mem_addr = addr[9:0];  // Use lower 10 bits of address directly
    
    assign dq = output_enable ? data_out : 32'hZ;
    
    // Initialize memory from hex file
    initial begin
        $readmemh("test_program.hex", memory);
        data_out = 32'h0;
        output_enable = 1'b0;
        write_data = 32'h0;
    end
    
    // Memory operations
    always @(posedge clk) begin
        if (!cs && !ras && !cas) begin
            if (!we) begin
                // Write operation - capture data immediately
                memory[mem_addr] <= dq;
                $display("LPDDR4: Write addr=%03x data=%08x (AXI_addr would be: 0x%08x)", mem_addr, dq, mem_addr * 4);
                output_enable <= 1'b0;
            end else begin
                // Read operation - output data immediately
                data_out <= memory[mem_addr];
                output_enable <= 1'b1;
                $display("LPDDR4: Read addr=%03x data=%08x (AXI_addr would be: 0x%08x)", mem_addr, memory[mem_addr], mem_addr * 4);
            end
        end else begin
            output_enable <= 1'b0;
        end
    end

endmodule
