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
    
    // Alokasi alamat memory untuk Systolic Array

    // Alokasi alamat memory untuk CORDIX

endmodule
