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
    // Alamat dari Interconnect:
    // Data         :   0xF0000018
    // Result       :   0xF000001C
    // Flags        :   0xF0000020
    // Signals      :   0xF0000024

    // Register Map (PERBAIKAN: Gunakan notasi Hex)
    localparam REG_INPUT_DATA    = 32'hF0000018;  // W - Input angle
    localparam REG_OUTPUT_DATA   = 32'hF000001C;  // R - Output result
    localparam REG_FLAGS_IN      = 32'hF0000020;  // W - Control flags (mode, start, rst)
    localparam REG_FLAGS_OUT     = 32'hF0000024;  // R - Status flags (done)
    
    // Internal registers
    reg signed [31:0]   reg_input_data = 0;
    // reg signed [31:0]   reg_output_data = 0; // Dihapus, akan di-assign langsung dari result_out
    reg [2:0]           reg_flags_in = 0;  // [0] = rst, [1] = start, [2] = mode
    reg                 reg_done_flag = 0; // Flag internal untuk status 'done'
    
    // PERBAIKAN: Pulse generator untuk sinyal start
    reg start_pulse_reg;
    wire start_pulse = start_pulse_reg && !reg_done_flag; // Hanya start jika tidak sedang 'done'
    
    // FSM states (RESTRUCTURED for robustness)
    localparam [2:0]    IDLE       = 3'b000,
                        WRITE_DATA = 3'b001,
                        WRITE_RESP = 3'b010,
                        READ_DATA  = 3'b100;
    
    reg [2:0] state;
    
    // AXI4-Lite signals
    reg [31:0] write_addr_reg; // Gunakan register untuk menahan alamat
    reg [31:0] read_addr_reg;  // Gunakan register untuk menahan alamat
    
    // CORDIC connections
    assign theta_deg = reg_input_data;
    assign mode = reg_flags_in[2];
    assign start = start_pulse; // PERBAIKAN: Gunakan sinyal pulsa
    assign rst = reg_flags_in[0];
    
    // Update output data register when done
    always @(posedge aclk) begin
        if (!aresetn) begin
            reg_done_flag <= 1'b0;
            start_pulse_reg <= 1'b0;
        end else begin
            // Generate start pulse
            start_pulse_reg <= 1'b0; // Default ke 0
            if (state == WRITE_DATA && wvalid && write_addr_reg == REG_FLAGS_IN && wstrb[0] && wdata[1]) begin
                start_pulse_reg <= 1'b1;
            end

            // Latch and clear done signal (Clear-on-Read logic)
            if (rst) begin
                reg_done_flag <= 1'b0;
            end else if (start_pulse) begin
                reg_done_flag <= 1'b0; // Clear done when starting a new operation
            end else if (done) begin
                reg_done_flag <= 1'b1; // Set done when CORDIC core is finished
            end else if (state == READ_DATA && rready && read_addr_reg == REG_FLAGS_OUT) begin
                // **PERBAIKAN: Clear-on-read for the done flag**
                reg_done_flag <= 1'b0;
            end
        end
    end
    
    // AXI4-Lite FSM (RESTRUCTURED)
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
                    // Default state: ready to accept a new address (read or write)
                    awready <= 1'b1;
                    arready <= 1'b1;
                    wready  <= 1'b1; // PERBAIKAN: Siap menerima data dan alamat
                    bvalid  <= 1'b0;
                    rvalid  <= 1'b0;
                    bresp   <= 2'b00;
                    rresp   <= 2'b00;

                    if (awvalid) begin // Write has priority
                        arready <= 1'b0; // Jangan terima alamat baca selama transaksi tulis
                        if (wvalid) begin // Kasus 1: Alamat dan data datang bersamaan
                            awready <= 1'b0;
                            wready  <= 1'b0;
                            bresp   <= 2'b00; // Default to OKAY
                            
                            // Lakukan penulisan data langsung menggunakan awaddr
                            case (awaddr)
                                REG_INPUT_DATA: begin
                                    if (wstrb[0]) reg_input_data[7:0]   <= wdata[7:0];
                                    if (wstrb[1]) reg_input_data[15:8]  <= wdata[15:8];
                                    if (wstrb[2]) reg_input_data[23:16] <= wdata[23:16];
                                    if (wstrb[3]) reg_input_data[31:24] <= wdata[31:24];
                                end
                                REG_FLAGS_IN: begin
                                    if (wstrb[0]) reg_flags_in <= wdata[2:0];
                                end
                                default: begin
                                    bresp <= 2'b10; // SLVERR
                                end
                            endcase
                            
                            state <= WRITE_RESP;
                        end else begin // Kasus 2: Hanya alamat yang datang, tunggu data
                            awready <= 1'b0;
                            write_addr_reg <= awaddr;
                            state <= WRITE_DATA;
                        end
                    end else if (arvalid) begin
                        arready <= 1'b0;
                        awready <= 1'b0; // Jangan terima alamat tulis selama transaksi baca
                        wready  <= 1'b0;
                        read_addr_reg <= araddr;
                        state <= READ_DATA;
                    end
                end
                
                WRITE_DATA: begin
                    wready <= 1'b1; // Ready to accept write data
                    if (wvalid) begin
                        wready <= 1'b0; // De-assert for next cycle
                        bresp <= 2'b00; // Default to OKAY
                        
                        // Lakukan penulisan data
                        case (write_addr_reg)
                            REG_INPUT_DATA: begin
                                if (wstrb[0]) reg_input_data[7:0]   <= wdata[7:0];
                                if (wstrb[1]) reg_input_data[15:8]  <= wdata[15:8];
                                if (wstrb[2]) reg_input_data[23:16] <= wdata[23:16];
                                if (wstrb[3]) reg_input_data[31:24] <= wdata[31:24];
                            end
                            REG_FLAGS_IN: begin
                                if (wstrb[0]) reg_flags_in <= wdata[2:0];
                            end
                            default: begin
                                bresp <= 2'b10; // SLVERR
                            end
                        endcase
                        
                        state <= WRITE_RESP;
                    end
                end
                
                WRITE_RESP: begin
                    if (bready && bvalid) begin
                        bvalid <= 1'b0;
                        state <= IDLE;
                    end else begin
                        bvalid <= 1'b1; // Signal write response
                    end
                end
                
                READ_DATA: begin
                    rresp  <= 2'b00; // Default to OKAY

                    // Drive read data based on latched address
                    case (read_addr_reg)
                        REG_OUTPUT_DATA: rdata <= result_out;
                        REG_FLAGS_OUT:   rdata <= {31'b0, reg_done_flag};
                        default: begin
                            rdata <= 32'b0;
                            rresp <= 2'b10; // SLVERR
                        end
                    endcase
                    
                    if (rready && rvalid) begin
                        rvalid <= 1'b0;
                        state <= IDLE;
                    end else begin
                        rvalid <= 1'b1; // Signal read data valid
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule