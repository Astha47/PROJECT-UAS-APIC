module dram_controller #(
    parameter AXI4_ID_WIDTH = 4,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    
    // AXI4 Interface
    // Write Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] M2_AXI4_AWID,
    input  wire [ADDR_WIDTH-1:0]    M2_AXI4_AWADDR,
    input  wire [7:0]               M2_AXI4_AWLEN,
    input  wire [2:0]               M2_AXI4_AWSIZE,
    input  wire [1:0]               M2_AXI4_AWBURST,
    input  wire                     M2_AXI4_AWVALID,
    output reg                      M2_AXI4_AWREADY,
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]    M2_AXI4_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] M2_AXI4_WSTRB,
    input  wire                     M2_AXI4_WLAST,
    input  wire                     M2_AXI4_WVALID,
    output reg                      M2_AXI4_WREADY,
    // Write Response Channel
    output reg  [AXI4_ID_WIDTH-1:0] M2_AXI4_BID,
    output reg  [1:0]               M2_AXI4_BRESP,
    output reg                      M2_AXI4_BVALID,
    input  wire                     M2_AXI4_BREADY,
    // Read Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] M2_AXI4_ARID,
    input  wire [ADDR_WIDTH-1:0]    M2_AXI4_ARADDR,
    input  wire [7:0]               M2_AXI4_ARLEN,
    input  wire [2:0]               M2_AXI4_ARSIZE,
    input  wire [1:0]               M2_AXI4_ARBURST,
    input  wire                     M2_AXI4_ARVALID,
    output wire                     M2_AXI4_ARREADY, // FIX: Changed from reg to wire
    // Read Data Channel
    output reg  [AXI4_ID_WIDTH-1:0] M2_AXI4_RID,
    output reg  [DATA_WIDTH-1:0]    M2_AXI4_RDATA,
    output reg  [1:0]               M2_AXI4_RRESP,
    output reg                      M2_AXI4_RLAST,
    output reg                      M2_AXI4_RVALID,
    input  wire                     M2_AXI4_RREADY,
    
    // LPDDR4 Interface
    output reg                      dram_ck,
    // output wire                      dram_ck,
    output reg                      dram_cs,
    output reg                      dram_we,
    output reg                      dram_ras,
    output reg                      dram_cas,
    output reg  [13:0]              dram_addr,
    output reg  [2:0]               dram_ba,
    inout  wire [31:0]              dram_dq,
    output reg  [3:0]               dram_dm,
    output reg                      dram_dqs
);

    // Internal registers
    reg [AXI4_ID_WIDTH-1:0] write_id;
    reg [AXI4_ID_WIDTH-1:0] read_id;
    reg [ADDR_WIDTH-1:0] current_addr;  // Gunakan satu register alamat
    reg [7:0] write_len;
    reg [7:0] read_len;
    reg [7:0] write_count;
    reg [7:0] read_count;
    
    // State machine parameters
    // localparam IDLE = 3'b000;
    // localparam ADDR_PHASE = 3'b001;
    // localparam DATA_PHASE = 3'b010;
    // localparam WAIT       = 3'b011;
    // localparam RESP_PHASE = 3'b100;

    // new state machine parameters
    localparam IDLE         = 3'b000;
    localparam WDATA_PHASE  = 3'b001;
    localparam WWAIT        = 3'b010;
    localparam WRESP_PHASE  = 3'b011;
    localparam RADDR_PHASE  = 3'b100;
    localparam RDATA_PHASE  = 3'b101;
    
    reg [2:0] state;

    // FIX: Combinatorially assign ARREADY based on state. It's only ready in IDLE.
    assign M2_AXI4_ARREADY = (state == IDLE);
    
    reg executed_status = 1'b0; // Status to indicate if a write has been executed
    
    reg [DATA_WIDTH-1:0] dram_data_out;
    reg dram_data_oe;
    reg [DATA_WIDTH-1:0] read_data_reg;
    reg read_data_valid;
    
    assign dram_dq = dram_data_oe ? dram_data_out : 32'hZ;

    // Read Write state machine
    always @(posedge clk or negedge rst_n) begin    
        if (!rst_n) begin

            // CLC DRAM
            dram_ck <= 1'b0;

            state <= IDLE;

            M2_AXI4_AWREADY <= 1'b0;
            M2_AXI4_WREADY <= 1'b0;
            M2_AXI4_BVALID <= 1'b0;
            M2_AXI4_BRESP <= 2'b00;
            write_count <= 8'h0;
            dram_data_oe <= 1'b0;
            dram_cs <= 1'b1;
            dram_we <= 1'b1;
            dram_ras <= 1'b1;
            dram_cas <= 1'b1;
            dram_addr <= 14'h0; 
            dram_ba <= 3'h0;
            dram_dqs <= 1'b0;
            
            
            M2_AXI4_RVALID <= 1'b0;
            M2_AXI4_RRESP <= 2'b00;
            M2_AXI4_RLAST <= 1'b0;
            read_count <= 8'h0;
            read_data_valid <= 1'b0;
            current_addr <= 32'h0;
        end else begin
            if (dram_ck == 1'b1) begin
                executed_status <= 1'b0;
            end
            dram_ck <= ~dram_ck;

            case (state)
                IDLE: begin
                    M2_AXI4_AWREADY <= 1'b1;
                    dram_cs <= 1'b0;
                    dram_data_oe <= 1'b0;
                    M2_AXI4_RVALID <= 1'b0;
                    if (M2_AXI4_AWVALID && M2_AXI4_AWREADY) begin
                        write_id <= M2_AXI4_AWID;
                        current_addr <= M2_AXI4_AWADDR;  // Set alamat untuk write
                        write_len <= M2_AXI4_AWLEN;
                        write_count <= 8'h0;
                        state <= WDATA_PHASE;
                        M2_AXI4_AWREADY <= 1'b0;
                        M2_AXI4_WREADY <= 1'b1;
                    end else if (M2_AXI4_ARVALID) begin
                        read_id <= M2_AXI4_ARID;
                        current_addr <= M2_AXI4_ARADDR;  // Set alamat untuk read
                        read_len <= M2_AXI4_ARLEN;
                        read_count <= 8'h0;
                        state <= RADDR_PHASE;
                    end
                end
                
                WDATA_PHASE: begin
                    if (M2_AXI4_WREADY) begin
                        dram_cs <= 1'b0;
                        dram_we <= 1'b0;
                        dram_ras <= 1'b0;
                        dram_cas <= 1'b0;
                        executed_status <= 1'b1;
                        dram_addr <= current_addr[15:2];  // Gunakan current_addr  
                        dram_ba <= 3'b000;    
                        dram_data_out <= M2_AXI4_WDATA;
                        dram_data_oe <= 1'b1;
                        dram_dm <= ~M2_AXI4_WSTRB;
                        
                        write_count <= write_count + 1;
                        current_addr <= current_addr + 4; // Update alamat
                        
                        if (M2_AXI4_WLAST) begin
                            state <= WWAIT;
                        end
                    end
                end

                WWAIT: begin
                    if (!executed_status) begin
                        state <= WRESP_PHASE;
                        M2_AXI4_WREADY <= 1'b0;
                    end else begin
                        dram_cs <= 1'b0;
                    end
                end 
                
                WRESP_PHASE: begin
                    dram_cs <= 1'b1;
                    dram_data_oe <= 1'b0;
                    dram_we <= 1'b1;
                    M2_AXI4_BID <= write_id;
                    M2_AXI4_BRESP <= 2'b00; // OKAY
                    M2_AXI4_BVALID <= 1'b1;
                    
                    if (M2_AXI4_BREADY && M2_AXI4_BVALID) begin
                        M2_AXI4_BVALID <= 1'b0;
                        state <= IDLE;
                    end
                end

                RADDR_PHASE: begin
                    dram_cs <= 1'b0;
                    dram_we <= 1'b1;
                    dram_ras <= 1'b0;
                    dram_cas <= 1'b0;
                    dram_addr <= current_addr[15:2];   // Gunakan current_addr
                    dram_ba <= 3'b000;  
                    
                    dram_data_oe <= 1'b0; 
                    executed_status <= 1'b1;
                    state <= RDATA_PHASE;
                end
                
                RDATA_PHASE: begin
                    if (!executed_status) begin
                        M2_AXI4_RID <= read_id;
                        M2_AXI4_RDATA <= dram_dq; 
                        M2_AXI4_RRESP <= 2'b00; 
                        M2_AXI4_RVALID <= 1'b1;
                        M2_AXI4_RLAST <= (read_count == read_len);
                        
                        if (M2_AXI4_RREADY && M2_AXI4_RVALID) begin
                            read_count <= read_count + 1;
                            current_addr <= current_addr + 4;  // Update alamat
                            read_data_valid <= 1'b0;
                            
                            if (M2_AXI4_RLAST) begin
                                state <= IDLE;
                                M2_AXI4_RVALID <= 1'b0;
                                M2_AXI4_RLAST <= 1'b0;
                            end else begin
                                state <= RADDR_PHASE;
                            end
                        end  
                    end
                end
            endcase
        end
    end

endmodule
