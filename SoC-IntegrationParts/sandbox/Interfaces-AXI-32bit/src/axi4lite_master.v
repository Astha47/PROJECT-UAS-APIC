module axi4lite_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire aclk,
    input wire aresetn,

    // Write address channel
    output wire [ADDR_WIDTH-1:0] m_axi_awaddr,
    output wire [2:0]            m_axi_awprot,
    output wire                  m_axi_awvalid,
    input  wire                  m_axi_awready,

    // Write data channel
    output wire [DATA_WIDTH-1:0] m_axi_wdata,
    output wire [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output wire                  m_axi_wvalid,
    input  wire                  m_axi_wready,

    // Write response channel
    input  wire [1:0]            m_axi_bresp,
    input  wire                  m_axi_bvalid,
    output wire                  m_axi_bready,

    // Read address channel
    output wire [ADDR_WIDTH-1:0] m_axi_araddr,
    output wire [2:0]            m_axi_arprot,
    output wire                  m_axi_arvalid,
    input  wire                  m_axi_arready,

    // Read data channel
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire [1:0]            m_axi_rresp,
    input  wire                  m_axi_rvalid,
    output wire                  m_axi_rready
);
    // Your AXI-Lite master logic here (e.g., simple state machine)
endmodule
