module axi4_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4
)(
    input wire aclk,
    input wire aresetn,

    // Write address channel
    output reg [ID_WIDTH-1:0]   m_axi_awid,
    output reg [ADDR_WIDTH-1:0] m_axi_awaddr,
    output reg [7:0]            m_axi_awlen,
    output reg [2:0]            m_axi_awsize,
    output reg [1:0]            m_axi_awburst,
    output reg                  m_axi_awvalid,
    input  wire                 m_axi_awready,

    // Write data channel
    output reg [DATA_WIDTH-1:0] m_axi_wdata,
    output reg [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output reg                  m_axi_wlast,
    output reg                  m_axi_wvalid,
    input  wire                 m_axi_wready,

    // Write response channel
    input  wire [ID_WIDTH-1:0]  m_axi_bid,
    input  wire [1:0]           m_axi_bresp,
    input  wire                 m_axi_bvalid,
    output reg                  m_axi_bready,

    // Read address channel
    output reg [ID_WIDTH-1:0]   m_axi_arid,
    output reg [ADDR_WIDTH-1:0] m_axi_araddr,
    output reg [7:0]            m_axi_arlen,
    output reg [2:0]            m_axi_arsize,
    output reg [1:0]            m_axi_arburst,
    output reg                  m_axi_arvalid,
    input  wire                 m_axi_arready,

    // Read data channel
    input  wire [ID_WIDTH-1:0]  m_axi_rid,
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire [1:0]           m_axi_rresp,
    input  wire                 m_axi_rlast,
    input  wire                 m_axi_rvalid,
    output reg                  m_axi_rready,

    // PicoRV32 memory interface
    input  wire                 mem_valid,
    input  wire                 mem_instr,
    output reg                  mem_ready,
    input  wire [ADDR_WIDTH-1:0] mem_addr,
    input  wire [DATA_WIDTH-1:0] mem_wdata,
    input  wire [3:0]           mem_wstrb,
    output reg [DATA_WIDTH-1:0] mem_rdata
);
    // AXI transaction IDs (can be used for more advanced features)
    localparam INSTR_READ_ID = 4'h1;  // Instruction fetch
    localparam DATA_READ_ID = 4'h2;   // Data read
    localparam DATA_WRITE_ID = 4'h3;  // Data write

    // State machine states
    localparam IDLE = 3'b000;
    localparam READING = 3'b001;
    localparam WRITING = 3'b010;
    localparam WRITE_RESP = 3'b011;
    localparam READ_DONE = 3'b100;
    localparam WRITE_DONE = 3'b101;
    
    reg [2:0] state;
    reg aw_handshake_done, w_handshake_done;

    reg [1:0] debug_state_writing;
    
    // Helper signals
    wire is_write = mem_valid && (|mem_wstrb);
    wire is_read = mem_valid && !(|mem_wstrb);

    // Initialize all AXI outputs
    initial begin
        m_axi_awid = 0;
        m_axi_awaddr = 0;
        m_axi_awlen = 0;
        m_axi_awsize = 0;
        m_axi_awburst = 0;
        m_axi_awvalid = 0;
        
        m_axi_wdata = 0;
        m_axi_wstrb = 0;
        m_axi_wlast = 0;
        m_axi_wvalid = 0;
        
        m_axi_bready = 0;
        
        m_axi_arid = 0;
        m_axi_araddr = 0;
        m_axi_arlen = 0;
        m_axi_arsize = 0;
        m_axi_arburst = 0;
        m_axi_arvalid = 0;
        
        m_axi_rready = 0;
        
        mem_ready = 0;
        mem_rdata = 0;

        aw_handshake_done = 0;
        w_handshake_done = 0;

        debug_state_writing = 0;
        
        state = IDLE;
    end

    // State machine for AXI transactions
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axi_awid <= 0;
            m_axi_awaddr <= 0;
            m_axi_awlen <= 0;
            m_axi_awsize <= 0;
            m_axi_awburst <= 0;
            m_axi_awvalid <= 0;
            
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
            m_axi_wlast <= 0;
            m_axi_wvalid <= 0;
            
            m_axi_bready <= 0;
            
            m_axi_arid <= 0;
            m_axi_araddr <= 0;
            m_axi_arlen <= 0;
            m_axi_arsize <= 0;
            m_axi_arburst <= 0;
            m_axi_arvalid <= 0;
            
            m_axi_rready <= 0;
            
            mem_ready <= 0;
            mem_rdata <= 0;

            aw_handshake_done <= 0;
            w_handshake_done <= 0;
            
            state <= IDLE;
        end else begin
            // Add debug output
            // $display("Time %t: AXI_MASTER state=%s, mem_valid=%b, mem_ready=%b, ARVALID=%b, ARREADY=%b, RVALID=%b, RREADY=%b", 
            //          $time, 
            //          (state == IDLE) ? "   IDLE" : 
            //          (state == READING) ? "READING" : 
            //          (state == WRITING) ? "WRITING" : "WR_RESP",
            //          mem_valid, mem_ready, m_axi_arvalid, m_axi_arready, m_axi_rvalid, m_axi_rready);
            
            case (state)
                IDLE: begin
                    // Clear ready signal and handshake flags
                    mem_ready <= 0;
                    aw_handshake_done <= 0;
                    w_handshake_done <= 0;
                    
                    if (mem_valid) begin
                        if (is_write) begin
                            // Start write transaction
                            m_axi_awid <= DATA_WRITE_ID;
                            m_axi_awaddr <= mem_addr;
                            m_axi_awlen <= 8'b0; // Single transfer
                            m_axi_awsize <= 3'b010; // 4 bytes
                            m_axi_awburst <= 2'b01; // INCR burst type
                            m_axi_awvalid <= 1'b1;
                            
                            m_axi_wdata <= mem_wdata;
                            m_axi_wstrb <= mem_wstrb;
                            m_axi_wlast <= 1'b1; // Single transfer
                            m_axi_wvalid <= 1'b1;
                            
                            m_axi_bready <= 1'b1;

                            debug_state_writing <= 2'b01;
                            
                            state <= WRITING;
                            // $display("Time %t: AXI_MASTER IDLE->WRITING: addr=0x%h, wdata=0x%h", $time, mem_addr, mem_wdata);
                        end else if (is_read) begin
                            // Start read transaction
                            m_axi_arid <= mem_instr ? INSTR_READ_ID : DATA_READ_ID;
                            m_axi_araddr <= mem_addr;
                            m_axi_arlen <= 8'b0; // Single transfer
                            m_axi_arsize <= 3'b010; // 4 bytes
                            m_axi_arburst <= 2'b01; // INCR burst type
                            m_axi_arvalid <= 1'b1;
                            m_axi_rready <= 1'b1;
                            
                            state <= READING;
                            // $display("Time %t: AXI_MASTER IDLE->READING: addr=0x%h. Asserting m_axi_rready.", $time, mem_addr);
                        end
                    end
                end
                
                READING: begin
                    // Read address channel handshake
                    if (m_axi_arready && m_axi_arvalid) begin
                        // $display("Time %t: AXI_MASTER READING: AR handshake. m_axi_araddr=0x%h", $time, m_axi_araddr);
                        m_axi_arvalid <= 0;
                    end
                    
                    // Read data channel handshake
                    if (m_axi_rvalid && m_axi_rready) begin
                        mem_rdata <= m_axi_rdata;
                        mem_ready <= 1;
                        m_axi_rready <= 0; // Deassert RREADY after accepting data for this beat
                        state <= READ_DONE;
                        // $display("Time %t: AXI_MASTER READING->READ_DONE: R handshake. m_axi_rdata=0x%h. Asserting mem_ready.", $time, m_axi_rdata);
                    end
                end

                READ_DONE: begin
                    mem_ready <= 0; // De-assert mem_ready to create a pulse
                    // Wait for CPU to de-assert mem_valid
                    if (!mem_valid) begin
                        state <= IDLE;
                    end
                end
                
                WRITING: begin
                    // Write address channel handshake
                    if (m_axi_awready && m_axi_awvalid) begin
                        // $display("Time %t: AXI_MASTER WRITING: AW handshake. m_axi_awaddr=0x%h", $time, m_axi_awaddr);
                        m_axi_awvalid <= 0;
                        debug_state_writing <= 2'b10;
                        aw_handshake_done <= 1; // Mark AW handshake as done
                    end
                    
                    // Write data channel handshake
                    if (m_axi_wready && m_axi_wvalid) begin
                        // $display("Time %t: AXI_MASTER WRITING: W handshake. m_axi_wdata=0x%h", $time, m_axi_wdata);
                        m_axi_wvalid <= 0;
                        debug_state_writing <= 2'b11;
                        w_handshake_done <= 1; // Mark W handshake as done
                    end
                    
                    // When both address and data are accepted, wait for response
                    if (aw_handshake_done && w_handshake_done) begin
                        // $display("Time %t: AXI_MASTER WRITING->WRITE_RESP: AW and W accepted.", $time);
                        state <= WRITE_RESP;
                        debug_state_writing <= 2'b00;
                    end
                end
                
                WRITE_RESP: begin
                    // Write response channel handshake
                    if (m_axi_bvalid && m_axi_bready) begin
                        mem_ready <= 1;
                        m_axi_bready <= 0;
                        state <= WRITE_DONE;
                        // $display("Time %t: AXI_MASTER WRITE_RESP->WRITE_DONE: B handshake. m_axi_bresp=%b. Asserting mem_ready.", $time, m_axi_bresp);
                    end
                end

                WRITE_DONE: begin
                    mem_ready <= 0; // De-assert mem_ready to create a pulse
                    // Wait for CPU to de-assert mem_valid
                    if (!mem_valid) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
