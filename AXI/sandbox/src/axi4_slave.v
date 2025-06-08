module axi4_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4
)(
    input wire aclk,
    input wire aresetn,

    // Write address channel
    input  wire [ID_WIDTH-1:0]   s_axi_awid,
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [7:0]            s_axi_awlen,
    input  wire [2:0]            s_axi_awsize,
    input  wire [1:0]            s_axi_awburst,
    input  wire                  s_axi_awvalid,
    output wire                  s_axi_awready,

    // Write data channel
    input  wire [DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                  s_axi_wlast,
    input  wire                  s_axi_wvalid,
    output wire                  s_axi_wready,

    // Write response channel
    output wire [ID_WIDTH-1:0]   s_axi_bid,
    output wire [1:0]            s_axi_bresp,
    output wire                  s_axi_bvalid,
    input  wire                  s_axi_bready,

    // Read address channel
    input  wire [ID_WIDTH-1:0]   s_axi_arid,
    input  wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [7:0]            s_axi_arlen,
    input  wire [2:0]            s_axi_arsize,
    input  wire [1:0]            s_axi_arburst,
    input  wire                  s_axi_arvalid,
    output wire                  s_axi_arready,

    // Read data channel
    output wire [ID_WIDTH-1:0]   s_axi_rid,
    output wire [DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0]            s_axi_rresp,
    output wire                  s_axi_rlast,
    output wire                  s_axi_rvalid,
    input  wire                  s_axi_rready
);
    // Simple RAM
    reg [DATA_WIDTH-1:0] mem [0:1023];
    reg [9:0] addr;

    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_bvalid  = 1'b1;
    assign s_axi_bid     = {ID_WIDTH{1'b0}};
    assign s_axi_bresp   = 2'b00;

    assign s_axi_arready = 1'b1;
    assign s_axi_rvalid  = 1'b1;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rlast   = 1'b1;
    assign s_axi_rdata   = mem[addr];

    always @(posedge aclk) begin
        if (!aresetn)
            addr <= 0;
        else if (s_axi_awvalid && s_axi_wvalid)
            mem[s_axi_awaddr[11:2]] <= s_axi_wdata;
        else if (s_axi_arvalid && s_axi_rready)
            addr <= s_axi_araddr[11:2];
    end
endmodule
