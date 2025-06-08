module axi_interconnect#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Master port (from RISC-V)
    input  wire                   ACLK,
    input  wire                   ARESETN,

    input  wire [ADDR_WIDTH-1:0]  M_AWADDR,
    input  wire                   M_AWVALID,
    output wire                   M_AWREADY,

    input  wire [DATA_WIDTH-1:0]  M_WDATA,
    input  wire                   M_WVALID,
    output wire                   M_WREADY,

    output wire                   M_BVALID,
    input  wire                   M_BREADY,

    input  wire [ADDR_WIDTH-1:0]  M_ARADDR,
    input  wire                   M_ARVALID,
    output wire                   M_ARREADY,

    output wire [DATA_WIDTH-1:0]  M_RDATA,
    output wire                   M_RVALID,
    input  wire                   M_RREADY,

    // Slave 0: CORDIC
    output wire [ADDR_WIDTH-1:0]  S0_AWADDR,
    output wire                   S0_AWVALID,
    input  wire                   S0_AWREADY,

    output wire [DATA_WIDTH-1:0]  S0_WDATA,
    output wire                   S0_WVALID,
    input  wire                   S0_WREADY,

    input  wire                   S0_BVALID,
    output wire                   S0_BREADY,

    output wire [ADDR_WIDTH-1:0]  S0_ARADDR,
    output wire                   S0_ARVALID,
    input  wire                   S0_ARREADY,

    input  wire [DATA_WIDTH-1:0]  S0_RDATA,
    input  wire                   S0_RVALID,
    output wire                   S0_RREADY

    // Tambahkan slave lain seperti S1 untuk SA jika perlu
);

    // Routing address decoding (example 0x40000000 - 0x40000FFF for CORDIC)
    wire select_s0 = (M_AWADDR[31:12] == 20'h40000);

    assign S0_AWADDR  = M_AWADDR;
    assign S0_AWVALID = M_AWVALID & select_s0;
    assign M_AWREADY  = S0_AWREADY & select_s0;

    assign S0_WDATA   = M_WDATA;
    assign S0_WVALID  = M_WVALID & select_s0;
    assign M_WREADY   = S0_WREADY & select_s0;

    assign M_BVALID   = S0_BVALID;
    assign S0_BREADY  = M_BREADY;

    assign S0_ARADDR  = M_ARADDR;
    assign S0_ARVALID = M_ARVALID & select_s0;
    assign M_ARREADY  = S0_ARREADY & select_s0;

    assign M_RDATA    = S0_RDATA;
    assign M_RVALID   = S0_RVALID;
    assign S0_RREADY  = M_RREADY;

endmodule
