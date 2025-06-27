`include "axi4_lite_cordic_controller.v"
`include "cordic_top.v"

module cordic_system (
    // AXI4-Lite Interface
    input  wire         aclk,
    input  wire         aresetn,
    input  wire [31:0]  awaddr,
    input  wire         awvalid,
    output wire         awready,
    input  wire [31:0]  wdata,
    input  wire [3:0]   wstrb,
    input  wire         wvalid,
    output wire         wready,
    output wire [1:0]   bresp,
    output wire         bvalid,
    input  wire         bready,
    input  wire [31:0]  araddr,
    input  wire         arvalid,
    output wire         arready,
    output wire [31:0]  rdata,
    output wire [1:0]   rresp,
    output wire         rvalid,
    input  wire         rready
);

    // Internal connections
    wire signed [31:0] theta_deg;
    wire signed [31:0] result_out;
    wire mode;
    wire start;
    wire rst;
    wire done;

    // AXI4-Lite Controller
    axi4_lite_cordic_controller axi_controller (
        .aclk(aclk),
        .aresetn(aresetn),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),
        .theta_deg(theta_deg),
        .result_out(result_out),
        .mode(mode),
        .start(start),
        .rst(rst),
        .done(done)
    );

    // CORDIC Top Module
    cordic_top cordic_inst (
        .clk(aclk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .theta_deg(theta_deg),
        .result_out(result_out),
        .done(done)
    );

endmodule