module axi_interconnect#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter AXI4_ID_WIDTH = 4 // Added for AXI4 interfaces
)(
    // Common signals
    input  wire                   ACLK,
    input  wire                   ARESETN,

    // Slave Port 0: AXI4 from RISC-V (S0_AXI4_...)
    // Write Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] S0_AXI4_AWID,
    input  wire [ADDR_WIDTH-1:0]  S0_AXI4_AWADDR,
    input  wire [7:0]             S0_AXI4_AWLEN,
    input  wire [2:0]             S0_AXI4_AWSIZE,
    input  wire [1:0]             S0_AXI4_AWBURST,
    input  wire                   S0_AXI4_AWVALID,
    output wire                   S0_AXI4_AWREADY,
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]  S0_AXI4_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] S0_AXI4_WSTRB,
    input  wire                   S0_AXI4_WLAST,
    input  wire                   S0_AXI4_WVALID,
    output wire                   S0_AXI4_WREADY,
    // Write Response Channel
    output wire [AXI4_ID_WIDTH-1:0] S0_AXI4_BID,
    output wire [1:0]             S0_AXI4_BRESP,
    output wire                   S0_AXI4_BVALID,
    input  wire                   S0_AXI4_BREADY,
    // Read Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] S0_AXI4_ARID,
    input  wire [ADDR_WIDTH-1:0]  S0_AXI4_ARADDR,
    input  wire [7:0]             S0_AXI4_ARLEN,
    input  wire [2:0]             S0_AXI4_ARSIZE,
    input  wire [1:0]             S0_AXI4_ARBURST,
    input  wire                   S0_AXI4_ARVALID,
    output wire                   S0_AXI4_ARREADY,
    // Read Data Channel
    output wire [AXI4_ID_WIDTH-1:0] S0_AXI4_RID,
    output wire [DATA_WIDTH-1:0]  S0_AXI4_RDATA,
    output wire [1:0]             S0_AXI4_RRESP,
    output wire                   S0_AXI4_RLAST,
    output wire                   S0_AXI4_RVALID,
    input  wire                   S0_AXI4_RREADY,

    // Slave Port 1: AXI4 from SA (S1_AXI4_...)
    // Write Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] S1_AXI4_AWID,
    input  wire [ADDR_WIDTH-1:0]  S1_AXI4_AWADDR,
    input  wire [7:0]             S1_AXI4_AWLEN,
    input  wire [2:0]             S1_AXI4_AWSIZE,
    input  wire [1:0]             S1_AXI4_AWBURST,
    input  wire                   S1_AXI4_AWVALID,
    output wire                   S1_AXI4_AWREADY,
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]  S1_AXI4_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] S1_AXI4_WSTRB,
    input  wire                   S1_AXI4_WLAST,
    input  wire                   S1_AXI4_WVALID,
    output wire                   S1_AXI4_WREADY,
    // Write Response Channel
    output wire [AXI4_ID_WIDTH-1:0] S1_AXI4_BID,
    output wire [1:0]             S1_AXI4_BRESP,
    output wire                   S1_AXI4_BVALID,
    input  wire                   S1_AXI4_BREADY,
    // Read Address Channel
    input  wire [AXI4_ID_WIDTH-1:0] S1_AXI4_ARID,
    input  wire [ADDR_WIDTH-1:0]  S1_AXI4_ARADDR,
    input  wire [7:0]             S1_AXI4_ARLEN,
    input  wire [2:0]             S1_AXI4_ARSIZE,
    input  wire [1:0]             S1_AXI4_ARBURST,
    input  wire                   S1_AXI4_ARVALID,
    output wire                   S1_AXI4_ARREADY,
    // Read Data Channel
    output wire [AXI4_ID_WIDTH-1:0] S1_AXI4_RID,
    output wire [DATA_WIDTH-1:0]  S1_AXI4_RDATA,
    output wire [1:0]             S1_AXI4_RRESP,
    output wire                   S1_AXI4_RLAST,
    output wire                   S1_AXI4_RVALID,
    input  wire                   S1_AXI4_RREADY,

    // Master Port 0: AXI4-Lite to CORDIC (M0_AXI4LITE_...)
    // Write Address Channel
    output wire [ADDR_WIDTH-1:0]  M0_AXI4LITE_AWADDR,
    output wire [2:0]             M0_AXI4LITE_AWPROT,
    output wire                   M0_AXI4LITE_AWVALID,
    input  wire                   M0_AXI4LITE_AWREADY,
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]  M0_AXI4LITE_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M0_AXI4LITE_WSTRB,
    output wire                   M0_AXI4LITE_WVALID,
    input  wire                   M0_AXI4LITE_WREADY,
    // Write Response Channel
    input  wire [1:0]             M0_AXI4LITE_BRESP,
    input  wire                   M0_AXI4LITE_BVALID,
    output wire                   M0_AXI4LITE_BREADY,
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]  M0_AXI4LITE_ARADDR,
    output wire [2:0]             M0_AXI4LITE_ARPROT,
    output wire                   M0_AXI4LITE_ARVALID,
    input  wire                   M0_AXI4LITE_ARREADY,
    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]  M0_AXI4LITE_RDATA,
    input  wire [1:0]             M0_AXI4LITE_RRESP,
    input  wire                   M0_AXI4LITE_RVALID,
    output wire                   M0_AXI4LITE_RREADY,

    // Master Port 1: AXI4-Lite to SA (M1_AXI4LITE_...)
    // Write Address Channel
    output wire [ADDR_WIDTH-1:0]  M1_AXI4LITE_AWADDR,
    output wire [2:0]             M1_AXI4LITE_AWPROT,
    output wire                   M1_AXI4LITE_AWVALID,
    input  wire                   M1_AXI4LITE_AWREADY,
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]  M1_AXI4LITE_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M1_AXI4LITE_WSTRB,
    output wire                   M1_AXI4LITE_WVALID,
    input  wire                   M1_AXI4LITE_WREADY,
    // Write Response Channel
    input  wire [1:0]             M1_AXI4LITE_BRESP,
    input  wire                   M1_AXI4LITE_BVALID,
    output wire                   M1_AXI4LITE_BREADY,
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]  M1_AXI4LITE_ARADDR,
    output wire [2:0]             M1_AXI4LITE_ARPROT,
    output wire                   M1_AXI4LITE_ARVALID,
    input  wire                   M1_AXI4LITE_ARREADY,
    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]  M1_AXI4LITE_RDATA,
    input  wire [1:0]             M1_AXI4LITE_RRESP,
    input  wire                   M1_AXI4LITE_RVALID,
    output wire                   M1_AXI4LITE_RREADY,

    // Master Port 2: AXI4 to DRAM Controller (M2_AXI4_...)
    // Write Address Channel
    output wire [AXI4_ID_WIDTH-1:0] M2_AXI4_AWID,
    output wire [ADDR_WIDTH-1:0]  M2_AXI4_AWADDR,
    output wire [7:0]             M2_AXI4_AWLEN,
    output wire [2:0]             M2_AXI4_AWSIZE,
    output wire [1:0]             M2_AXI4_AWBURST,
    output wire                   M2_AXI4_AWVALID,
    input  wire                   M2_AXI4_AWREADY,
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]  M2_AXI4_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M2_AXI4_WSTRB,
    output wire                   M2_AXI4_WLAST,
    output wire                   M2_AXI4_WVALID,
    input  wire                   M2_AXI4_WREADY,
    // Write Response Channel
    input  wire [AXI4_ID_WIDTH-1:0] M2_AXI4_BID,
    input  wire [1:0]             M2_AXI4_BRESP,
    input  wire                   M2_AXI4_BVALID,
    output wire                   M2_AXI4_BREADY,
    // Read Address Channel
    output wire [AXI4_ID_WIDTH-1:0] M2_AXI4_ARID,
    output wire [ADDR_WIDTH-1:0]  M2_AXI4_ARADDR,
    output wire [7:0]             M2_AXI4_ARLEN,
    output wire [2:0]             M2_AXI4_ARSIZE,
    output wire [1:0]             M2_AXI4_ARBURST,
    output wire                   M2_AXI4_ARVALID,
    input  wire                   M2_AXI4_ARREADY,
    // Read Data Channel
    input  wire [AXI4_ID_WIDTH-1:0] M2_AXI4_RID,
    input  wire [DATA_WIDTH-1:0]  M2_AXI4_RDATA,
    input  wire [1:0]             M2_AXI4_RRESP,
    input  wire                   M2_AXI4_RLAST,
    input  wire                   M2_AXI4_RVALID,
    output wire                   M2_AXI4_RREADY
);

    // Sistem 32bit memiliki maksimum memori 
    // Min Address: 0x00000000
    // Max Address: 0xFFFFFFFF
    
    // Alokasi alamat memory untuk Systolic Array
    // Head data    :   0x00000000
    // Data Info    :   0x00000001
    // Head Result  :   0x00000002
    // Flags        :   0x00000003
    // Mode         :   0x00000004
    // Signals      :   0x00000005

    // Alokasi alamat memory untuk CORDIX
    // Data         :   0x00000006
    // Result       :   0x00000007
    // Flags        :   0x00000008
    // Signals      :   0x00000009

    // Alokasi alamat memory untuk DRAM Controller
    // Start        :   0x0000000A
    // End          :   0xFFFFFFFF

    // Define address ranges as parameters
    localparam SA_START_ADDR     = 32'h00000000;
    localparam SA_END_ADDR       = 32'h00000005;
    localparam CORDIC_START_ADDR = 32'h00000006;
    localparam CORDIC_END_ADDR   = 32'h00000009;
    localparam DRAM_START_ADDR   = 32'h0000000A;
    localparam DRAM_END_ADDR     = 32'hFFFFFFFF;

    // Address decode logic
    // Write address decoding for S0 (RISC-V)
    wire s0_write_to_sa     = (S0_AXI4_AWADDR >= SA_START_ADDR && S0_AXI4_AWADDR <= SA_END_ADDR) && S0_AXI4_AWVALID;
    wire s0_write_to_cordic = (S0_AXI4_AWADDR >= CORDIC_START_ADDR && S0_AXI4_AWADDR <= CORDIC_END_ADDR) && S0_AXI4_AWVALID;
    wire s0_write_to_dram   = ((S0_AXI4_AWADDR >= DRAM_START_ADDR) && S0_AXI4_AWVALID) ||
                             (~s0_write_to_sa && ~s0_write_to_cordic && S0_AXI4_AWVALID);
    
    // Read address decoding for S0 (RISC-V)
    wire s0_read_to_sa     = (S0_AXI4_ARADDR >= SA_START_ADDR && S0_AXI4_ARADDR <= SA_END_ADDR) && S0_AXI4_ARVALID;
    wire s0_read_to_cordic = (S0_AXI4_ARADDR >= CORDIC_START_ADDR && S0_AXI4_ARADDR <= CORDIC_END_ADDR) && S0_AXI4_ARVALID;
    wire s0_read_to_dram   = ((S0_AXI4_ARADDR >= DRAM_START_ADDR) && S0_AXI4_ARVALID) ||
                            (~s0_read_to_sa && ~s0_read_to_cordic && S0_AXI4_ARVALID);

    // For S1 (SA), all transactions go to DRAM
    wire s1_write_to_dram = S1_AXI4_AWVALID;
    wire s1_read_to_dram = S1_AXI4_ARVALID;

    // Arbitration between S0 and S1 for DRAM access
    reg s0_dram_write_grant, s1_dram_write_grant;
    reg s0_dram_read_grant, s1_dram_read_grant;
    
    // Simple round-robin arbitration
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            s0_dram_write_grant <= 1'b1; // Default priority to S0
            s1_dram_write_grant <= 1'b0;
            s0_dram_read_grant <= 1'b1;
            s1_dram_read_grant <= 1'b0;
        end else begin
            // Write arbitration
            if (s0_write_to_dram && s1_write_to_dram) begin
                // Toggle grants when both want access
                s0_dram_write_grant <= ~s0_dram_write_grant;
                s1_dram_write_grant <= ~s1_dram_write_grant;
            end else begin
                s0_dram_write_grant <= s0_write_to_dram;
                s1_dram_write_grant <= !s0_write_to_dram && s1_write_to_dram;
            end
            
            // Read arbitration
            if (s0_read_to_dram && s1_read_to_dram) begin
                s0_dram_read_grant <= ~s0_dram_read_grant;
                s1_dram_read_grant <= ~s1_dram_read_grant;
            end else begin
                s0_dram_read_grant <= s0_read_to_dram;
                s1_dram_read_grant <= !s0_read_to_dram && s1_read_to_dram;
            end
        end
    end

    // ----- WRITE ADDRESS CHANNEL ROUTING -----
    
    // M0 (CORDIC - AXI4LITE) Write Address Channel
    assign M0_AXI4LITE_AWADDR = S0_AXI4_AWADDR;  // Pass through address
    assign M0_AXI4LITE_AWPROT = 3'b000;  // Default protection bits
    assign M0_AXI4LITE_AWVALID = s0_write_to_cordic;
    assign S0_AXI4_AWREADY = (s0_write_to_cordic) ? M0_AXI4LITE_AWREADY : 
                            (s0_write_to_sa) ? M1_AXI4LITE_AWREADY :
                            (s0_write_to_dram && s0_dram_write_grant) ? M2_AXI4_AWREADY : 1'b0;
    
    // M1 (SA - AXI4LITE) Write Address Channel
    assign M1_AXI4LITE_AWADDR = S0_AXI4_AWADDR;  // Pass through address
    assign M1_AXI4LITE_AWPROT = 3'b000;  // Default protection bits
    assign M1_AXI4LITE_AWVALID = s0_write_to_sa;
    
    // M2 (DRAM - AXI4) Write Address Channel
    assign M2_AXI4_AWID = (s0_dram_write_grant) ? S0_AXI4_AWID : 
                         (s1_dram_write_grant) ? S1_AXI4_AWID : 'b0;
    assign M2_AXI4_AWADDR = (s0_dram_write_grant) ? S0_AXI4_AWADDR : 
                           (s1_dram_write_grant) ? S1_AXI4_AWADDR : 'b0;
    assign M2_AXI4_AWLEN = (s0_dram_write_grant) ? S0_AXI4_AWLEN : 
                          (s1_dram_write_grant) ? S1_AXI4_AWLEN : 'b0;
    assign M2_AXI4_AWSIZE = (s0_dram_write_grant) ? S0_AXI4_AWSIZE : 
                           (s1_dram_write_grant) ? S1_AXI4_AWSIZE : 'b0;
    assign M2_AXI4_AWBURST = (s0_dram_write_grant) ? S0_AXI4_AWBURST : 
                            (s1_dram_write_grant) ? S1_AXI4_AWBURST : 'b0;
    assign M2_AXI4_AWVALID = (s0_dram_write_grant && s0_write_to_dram) || 
                            (s1_dram_write_grant && s1_write_to_dram);
    assign S1_AXI4_AWREADY = (s1_dram_write_grant) ? M2_AXI4_AWREADY : 1'b0;

    // ----- WRITE DATA CHANNEL ROUTING -----
    
    // M0 (CORDIC - AXI4LITE) Write Data Channel
    assign M0_AXI4LITE_WDATA = S0_AXI4_WDATA;
    assign M0_AXI4LITE_WSTRB = S0_AXI4_WSTRB;
    assign M0_AXI4LITE_WVALID = s0_write_to_cordic && S0_AXI4_WVALID;
    assign S0_AXI4_WREADY = (s0_write_to_cordic) ? M0_AXI4LITE_WREADY :
                           (s0_write_to_sa) ? M1_AXI4LITE_WREADY :
                           (s0_write_to_dram && s0_dram_write_grant) ? M2_AXI4_WREADY : 1'b0;
    
    // M1 (SA - AXI4LITE) Write Data Channel
    assign M1_AXI4LITE_WDATA = S0_AXI4_WDATA;
    assign M1_AXI4LITE_WSTRB = S0_AXI4_WSTRB;
    assign M1_AXI4LITE_WVALID = s0_write_to_sa && S0_AXI4_WVALID;
    
    // M2 (DRAM - AXI4) Write Data Channel
    assign M2_AXI4_WDATA = (s0_dram_write_grant) ? S0_AXI4_WDATA :
                          (s1_dram_write_grant) ? S1_AXI4_WDATA : 'b0;
    assign M2_AXI4_WSTRB = (s0_dram_write_grant) ? S0_AXI4_WSTRB :
                          (s1_dram_write_grant) ? S1_AXI4_WSTRB : 'b0;
    assign M2_AXI4_WLAST = (s0_dram_write_grant) ? S0_AXI4_WLAST :
                          (s1_dram_write_grant) ? S1_AXI4_WLAST : 'b0;
    assign M2_AXI4_WVALID = (s0_dram_write_grant && S0_AXI4_WVALID && s0_write_to_dram) ||
                           (s1_dram_write_grant && S1_AXI4_WVALID);
    assign S1_AXI4_WREADY = (s1_dram_write_grant) ? M2_AXI4_WREADY : 1'b0;

    // ----- WRITE RESPONSE CHANNEL ROUTING -----
    
    // S0 (RISC-V) Write Response Channel
    assign S0_AXI4_BID = (s0_write_to_dram && s0_dram_write_grant) ? M2_AXI4_BID : S0_AXI4_AWID;
    assign S0_AXI4_BRESP = (s0_write_to_cordic) ? {1'b0, M0_AXI4LITE_BRESP[0]} :
                          (s0_write_to_sa) ? {1'b0, M1_AXI4LITE_BRESP[0]} :
                          (s0_write_to_dram && s0_dram_write_grant) ? M2_AXI4_BRESP : 2'b00;
    assign S0_AXI4_BVALID = (s0_write_to_cordic && M0_AXI4LITE_BVALID) ||
                           (s0_write_to_sa && M1_AXI4LITE_BVALID) ||
                           (s0_write_to_dram && s0_dram_write_grant && M2_AXI4_BVALID);
    
    // S1 (SA) Write Response Channel
    assign S1_AXI4_BID = (s1_dram_write_grant) ? M2_AXI4_BID : S1_AXI4_AWID;
    assign S1_AXI4_BRESP = (s1_dram_write_grant) ? M2_AXI4_BRESP : 2'b00;
    assign S1_AXI4_BVALID = (s1_dram_write_grant && M2_AXI4_BVALID);
    
    // M0 (CORDIC - AXI4LITE) Write Response Channel
    assign M0_AXI4LITE_BREADY = (s0_write_to_cordic) ? S0_AXI4_BREADY : 1'b0;
    
    // M1 (SA - AXI4LITE) Write Response Channel
    assign M1_AXI4LITE_BREADY = (s0_write_to_sa) ? S0_AXI4_BREADY : 1'b0;
    
    // M2 (DRAM - AXI4) Write Response Channel
    assign M2_AXI4_BREADY = (s0_dram_write_grant) ? S0_AXI4_BREADY :
                           (s1_dram_write_grant) ? S1_AXI4_BREADY : 1'b0;

    // ----- READ ADDRESS CHANNEL ROUTING -----
    
    // M0 (CORDIC - AXI4LITE) Read Address Channel
    assign M0_AXI4LITE_ARADDR = S0_AXI4_ARADDR;
    assign M0_AXI4LITE_ARPROT = 3'b000;  // Default protection bits
    assign M0_AXI4LITE_ARVALID = s0_read_to_cordic;
    assign S0_AXI4_ARREADY = (s0_read_to_cordic) ? M0_AXI4LITE_ARREADY :
                            (s0_read_to_sa) ? M1_AXI4LITE_ARREADY :
                            (s0_read_to_dram && s0_dram_read_grant) ? M2_AXI4_ARREADY : 1'b0;
    
    // M1 (SA - AXI4LITE) Read Address Channel
    assign M1_AXI4LITE_ARADDR = S0_AXI4_ARADDR;
    assign M1_AXI4LITE_ARPROT = 3'b000;  // Default protection bits
    assign M1_AXI4LITE_ARVALID = s0_read_to_sa;
    
    // M2 (DRAM - AXI4) Read Address Channel
    assign M2_AXI4_ARID = (s0_dram_read_grant) ? S0_AXI4_ARID :
                         (s1_dram_read_grant) ? S1_AXI4_ARID : 'b0;
    assign M2_AXI4_ARADDR = (s0_dram_read_grant) ? S0_AXI4_ARADDR :
                           (s1_dram_read_grant) ? S1_AXI4_ARADDR : 'b0;
    assign M2_AXI4_ARLEN = (s0_dram_read_grant) ? S0_AXI4_ARLEN :
                          (s1_dram_read_grant) ? S1_AXI4_ARLEN : 'b0;
    assign M2_AXI4_ARSIZE = (s0_dram_read_grant) ? S0_AXI4_ARSIZE :
                           (s1_dram_read_grant) ? S1_AXI4_ARSIZE : 'b0;
    assign M2_AXI4_ARBURST = (s0_dram_read_grant) ? S0_AXI4_ARBURST :
                            (s1_dram_read_grant) ? S1_AXI4_ARBURST : 'b0;
    assign M2_AXI4_ARVALID = (s0_dram_read_grant && s0_read_to_dram) ||
                            (s1_dram_read_grant && s1_read_to_dram);
    assign S1_AXI4_ARREADY = (s1_dram_read_grant) ? M2_AXI4_ARREADY : 1'b0;

    // ----- READ DATA CHANNEL ROUTING -----
    
    // S0 (RISC-V) Read Data Channel
    assign S0_AXI4_RID = (s0_read_to_dram && s0_dram_read_grant) ? M2_AXI4_RID : S0_AXI4_ARID;
    assign S0_AXI4_RDATA = (s0_read_to_cordic) ? M0_AXI4LITE_RDATA :
                          (s0_read_to_sa) ? M1_AXI4LITE_RDATA :
                          (s0_read_to_dram && s0_dram_read_grant) ? M2_AXI4_RDATA : 'b0;
    assign S0_AXI4_RRESP = (s0_read_to_cordic) ? {1'b0, M0_AXI4LITE_RRESP[0]} :
                          (s0_read_to_sa) ? {1'b0, M1_AXI4LITE_RRESP[0]} :
                          (s0_read_to_dram && s0_dram_read_grant) ? M2_AXI4_RRESP : 2'b00;
    assign S0_AXI4_RLAST = (s0_read_to_dram && s0_dram_read_grant) ? M2_AXI4_RLAST : 1'b1;
    assign S0_AXI4_RVALID = (s0_read_to_cordic && M0_AXI4LITE_RVALID) ||
                           (s0_read_to_sa && M1_AXI4LITE_RVALID) ||
                           (s0_read_to_dram && s0_dram_read_grant && M2_AXI4_RVALID);
    
    // S1 (SA) Read Data Channel  
    assign S1_AXI4_RID = (s1_dram_read_grant) ? M2_AXI4_RID : S1_AXI4_ARID;
    assign S1_AXI4_RDATA = (s1_dram_read_grant) ? M2_AXI4_RDATA : 'b0;
    assign S1_AXI4_RRESP = (s1_dram_read_grant) ? M2_AXI4_RRESP : 2'b00;
    assign S1_AXI4_RLAST = (s1_dram_read_grant) ? M2_AXI4_RLAST : 1'b1;
    assign S1_AXI4_RVALID = (s1_dram_read_grant && M2_AXI4_RVALID);
    
    // M0 (CORDIC - AXI4LITE) Read Data Channel
    assign M0_AXI4LITE_RREADY = (s0_read_to_cordic) ? S0_AXI4_RREADY : 1'b0;
    
    // M1 (SA - AXI4LITE) Read Data Channel  
    assign M1_AXI4LITE_RREADY = (s0_read_to_sa) ? S0_AXI4_RREADY : 1'b0;
    
    // M2 (DRAM - AXI4) Read Data Channel
    assign M2_AXI4_RREADY = (s0_dram_read_grant) ? S0_AXI4_RREADY :
                           (s1_dram_read_grant) ? S1_AXI4_RREADY : 1'b0;

endmodule
