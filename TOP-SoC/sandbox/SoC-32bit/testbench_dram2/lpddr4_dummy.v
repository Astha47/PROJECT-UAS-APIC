module lpddr4_dummy (
    input wire clk,
    input wire cs,
    input wire we,
    input wire ras,
    input wire cas,
    input wire [13:0] addr,  // Ini adalah byte address dari AXI
    input wire [2:0] ba,
    inout wire [31:0] dq,
    input wire [3:0] dm,
    input wire dqs
);

    // Memory array - perbesar untuk cover address range yang dibutuhkan
    reg [31:0] memory [0:4095]; // 16KB memory (4096 words)
    reg [31:0] data_out;
    reg output_enable;
    
    // PERBAIKAN: Konversi byte address ke word address
    // addr adalah byte address, kita perlu word address
    wire [11:0] word_addr = addr[13:2];  // Byte address dibagi 4 (shift right 2 bits)
    wire [11:0] mem_addr = (word_addr < 4096) ? word_addr : 12'h000; // Bounds check
    
    assign dq = output_enable ? data_out : 32'hZ;
    
    // Initialize memory from hex file
    initial begin
        $readmemh("test_program.hex", memory);
        data_out = 32'h0;
        output_enable = 1'b0;
        
        // Debug: Show loaded program
        $display("LPDDR4: Memory initialized, showing first few instructions:");
        $display("  Word[0x000] = 0x%08x (byte addr 0x0000)", memory[0]);
        $display("  Word[0x001] = 0x%08x (byte addr 0x0004)", memory[1]);
        $display("  Word[0x002] = 0x%08x (byte addr 0x0008)", memory[2]);
        $display("  Word[0x400] = 0x%08x (byte addr 0x1000)", memory[1024]);
    end
    
    // Memory operations
    always @(posedge clk) begin
        if (!cs && !ras && !cas) begin
            if (!we) begin
                // Write operation
                if (word_addr < 4096) begin
                    memory[mem_addr] <= dq;
                    // $display("LPDDR4: Write - byte_addr=0x%04x, word_addr=0x%03x, data=0x%08x", 
                            // addr, mem_addr, dq);
                end else begin
                    // $display("LPDDR4: Write OUT OF BOUNDS - byte_addr=0x%04x, word_addr=0x%03x", 
                            // addr, word_addr);
                end
                output_enable <= 1'b0;
            end else begin
                // Read operation
                if (word_addr < 4096) begin
                    data_out <= memory[mem_addr];
                    output_enable <= 1'b1;
                    // $display("LPDDR4: Read - byte_addr=0x%04x, word_addr=0x%03x, data=0x%08x", 
                            // addr, mem_addr, memory[mem_addr]);
                end else begin
                    data_out <= 32'hDEADBEEF;
                    output_enable <= 1'b1;
                    $display("LPDDR4: Read OUT OF BOUNDS - byte_addr=0x%04x, word_addr=0x%03x, returning DEADBEEF", 
                            addr, word_addr);
                end
            end
        end else begin
            output_enable <= 1'b0;
        end
    end

endmodule
