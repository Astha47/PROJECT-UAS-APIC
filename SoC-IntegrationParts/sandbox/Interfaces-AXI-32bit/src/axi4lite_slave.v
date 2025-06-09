module axi4lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                  aclk,
    input  wire                  aresetn,

    // Write address channel
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                  s_axi_awvalid,
    output wire                  s_axi_awready,

    // Write data channel
    input  wire [DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                  s_axi_wvalid,
    output wire                  s_axi_wready,

    // Write response channel
    output wire [1:0]            s_axi_bresp,
    output wire                  s_axi_bvalid,
    input  wire                  s_axi_bready,

    // Read address channel
    input  wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                  s_axi_arvalid,
    output wire                  s_axi_arready,

    // Read data channel
    output wire [DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0]            s_axi_rresp,
    output wire                  s_axi_rvalid,
    input  wire                  s_axi_rready
);

    // Implement your register map logic here
    // Contoh dummy reg
    reg [31:0] reg0;
    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_bvalid  = 1'b1;
    assign s_axi_bresp   = 2'b00;

    assign s_axi_arready = 1'b1;
    assign s_axi_rdata   = reg0;
    assign s_axi_rvalid  = 1'b1;
    assign s_axi_rresp   = 2'b00;

    always @(posedge aclk) begin
        if (!aresetn)
            reg0 <= 32'h0;
        else if (s_axi_awvalid && s_axi_wvalid)
            reg0 <= s_axi_wdata;
    end
endmodule
