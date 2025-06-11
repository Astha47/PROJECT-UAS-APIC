module axi4_lite_cordic_controller (
    // AXI4-Lite Interface
    input  wire         aclk,
    input  wire         aresetn,
    
    // Write Address Channel
    input  wire [31:0]  awaddr,
    input  wire         awvalid,
    output reg          awready,
    
    // Write Data Channel
    input  wire [31:0]  wdata,
    input  wire [3:0]   wstrb,
    input  wire         wvalid,
    output reg          wready,
    
    // Write Response Channel
    output reg [1:0]    bresp,
    output reg          bvalid,
    input  wire         bready,
    
    // Read Address Channel
    input  wire [31:0]  araddr,
    input  wire         arvalid,
    output reg          arready,
    
    // Read Data Channel
    output reg [31:0]   rdata,
    output reg [1:0]    rresp,
    output reg          rvalid,
    input  wire         rready,
    
    // CORDIC Interface
    output wire signed [31:0] theta_deg,
    input  wire signed [31:0] result_out,
    output wire         mode,
    output wire         start,
    output wire         rst,
    input  wire         done
);

    // Register Map
    localparam REG_INPUT_DATA    = 0;  // W - Input angle (Q16 format)
    localparam REG_OUTPUT_DATA   = 4;  // R - Output result (Q16 format)
    localparam REG_FLAGS_IN      = 8;  // W - Control flags (mode, start, rst)
    localparam REG_FLAGS_OUT     = 12; // R - Status flags (done)
    
    // Internal registers
    reg signed [31:0]   reg_input_data = 0;
    reg signed [31:0]   reg_output_data = 0;
    reg [2:0]           reg_flags_in = 0;  // [0] = rst, [1] = start, [2] = mode
    reg                 reg_flags_out = 0; // [0] = done
    reg                 latched_done = 0;
    
    // FSM states
    localparam [2:0]    IDLE      = 3'b000,
                        WRITE_ADDR = 3'b001,
                        WRITE_DATA = 3'b010,
                        WRITE_RESP = 3'b011,
                        READ_ADDR  = 3'b100,
                        READ_DATA  = 3'b101;
    
    reg [2:0] state;
    
    // AXI4-Lite signals
    reg [31:0] write_addr;
    reg [31:0] read_addr;
    
    // CORDIC connections
    assign theta_deg = reg_input_data;
    assign mode = reg_flags_in[2];
    assign start = reg_flags_in[1];
    assign rst = reg_flags_in[0];
    
    // Update output data register when done

    always @(posedge aclk) begin
        if (!aresetn) begin
            reg_output_data <= 32'b0;
            reg_flags_out <= 1'b0;
            latched_done <= 1'b0;
        end else begin
            // Set done flag when operation completes
            if (done) begin
                reg_output_data <= result_out;
                latched_done <= 1'b1;
            end
            // Clear done flag after read (only if not set in the same cycle)
            else if (state == READ_ADDR && read_addr[3:0] == REG_FLAGS_OUT) begin
                latched_done <= 1'b0;
            end
            reg_flags_out <= latched_done;
        end
    end
    
    // AXI4-Lite FSM
    always @(posedge aclk) begin
        if (!aresetn) begin
            state <= IDLE;
            awready <= 1'b0;
            wready <= 1'b0;
            bvalid <= 1'b0;
            arready <= 1'b0;
            rvalid <= 1'b0;
            bresp <= 2'b00; // OKAY
            rresp <= 2'b00; // OKAY
            
            // Reset registers
            reg_input_data <= 32'b0;
            reg_flags_in <= 3'b0;
        end else begin
            case (state)
                IDLE: begin
                    awready <= 1'b0;
                    wready <= 1'b0;
                    bvalid <= 1'b0;
                    arready <= 1'b0;
                    rvalid <= 1'b0;
                    
                    if (awvalid && !arvalid) begin
                        // Write transaction
                        write_addr <= awaddr;
                        awready <= 1'b1;
                        state <= WRITE_ADDR;
                    end else if (arvalid && !awvalid) begin
                        // Read transaction
                        read_addr <= araddr;
                        arready <= 1'b1;
                        state <= READ_ADDR;
                    end
                end
                
                WRITE_ADDR: begin
                    awready <= 1'b0;
                    if (wvalid) begin
                        wready <= 1'b1;
                        state <= WRITE_DATA;
                    end
                end
                
                WRITE_DATA: begin
                    wready <= 1'b0;
                    
                    // Write to appropriate register
                    case (write_addr[3:0])
                        REG_INPUT_DATA: begin
                            // Only update bytes that are being written
                            if (wstrb[0]) reg_input_data[7:0]   <= wdata[7:0];
                            if (wstrb[1]) reg_input_data[15:8]  <= wdata[15:8];
                            if (wstrb[2]) reg_input_data[23:16] <= wdata[23:16];
                            if (wstrb[3]) reg_input_data[31:24] <= wdata[31:24];
                        end
                        REG_FLAGS_IN: begin
                            // Only lower 3 bits are used
                            if (wstrb[0]) reg_flags_in <= wdata[2:0];
                        end
                        default: begin
                            // Unsupported address
                            bresp <= 2'b10; // SLVERR
                        end
                    endcase
                    
                    bvalid <= 1'b1;
                    state <= WRITE_RESP;
                end
                
                WRITE_RESP: begin
                    if (bready) begin
                        bvalid <= 1'b0;
                        bresp <= 2'b00; // Reset to OKAY
                        state <= IDLE;
                    end
                end
                
                READ_ADDR: begin
                    arready <= 1'b0;
                    rvalid <= 1'b1;
                    
                    // Read from appropriate register
                    case (read_addr[3:0])
                        REG_OUTPUT_DATA: rdata <= reg_output_data;
                        REG_FLAGS_OUT:   rdata <= {31'b0, reg_flags_out};
                        default: begin
                            // Unsupported address
                            rdata <= 32'b0;
                            rresp <= 2'b10; // SLVERR
                        end
                    endcase
                    
                    state <= READ_DATA;
                end
                
                READ_DATA: begin
                    if (rready) begin
                        rvalid <= 1'b0;
                        rresp <= 2'b00; // Reset to OKAY
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule