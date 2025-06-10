`timescale 1ns/1ps

`include "dram_controller.v"
`include "lpddr4_dummy.v"

module tb_dram_controller;
    parameter AXI4_ID_WIDTH = 4;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    
    // Clock and reset
    reg clk;
    reg rst_n;
    
    // AXI4 signals
    reg  [AXI4_ID_WIDTH-1:0] M2_AXI4_AWID;
    reg  [ADDR_WIDTH-1:0]    M2_AXI4_AWADDR;
    reg  [7:0]               M2_AXI4_AWLEN;
    reg  [2:0]               M2_AXI4_AWSIZE;
    reg  [1:0]               M2_AXI4_AWBURST;
    reg                      M2_AXI4_AWVALID;
    wire                     M2_AXI4_AWREADY;
    
    reg  [DATA_WIDTH-1:0]    M2_AXI4_WDATA;
    reg  [(DATA_WIDTH/8)-1:0] M2_AXI4_WSTRB;
    reg                      M2_AXI4_WLAST;
    reg                      M2_AXI4_WVALID;
    wire                     M2_AXI4_WREADY;
    
    wire [AXI4_ID_WIDTH-1:0] M2_AXI4_BID;
    wire [1:0]               M2_AXI4_BRESP;
    wire                     M2_AXI4_BVALID;
    reg                      M2_AXI4_BREADY;
    
    reg  [AXI4_ID_WIDTH-1:0] M2_AXI4_ARID;
    reg  [ADDR_WIDTH-1:0]    M2_AXI4_ARADDR;
    reg  [7:0]               M2_AXI4_ARLEN;
    reg  [2:0]               M2_AXI4_ARSIZE;
    reg  [1:0]               M2_AXI4_ARBURST;
    reg                      M2_AXI4_ARVALID;
    wire                     M2_AXI4_ARREADY;
    
    wire [AXI4_ID_WIDTH-1:0] M2_AXI4_RID;
    wire [DATA_WIDTH-1:0]    M2_AXI4_RDATA;
    wire [1:0]               M2_AXI4_RRESP;
    wire                     M2_AXI4_RLAST;
    wire                     M2_AXI4_RVALID;
    reg                      M2_AXI4_RREADY;
    
    // DRAM interface
    wire dram_ck;
    wire dram_cs;
    wire dram_we;
    wire dram_ras;
    wire dram_cas;
    wire [13:0] dram_addr;
    wire [2:0] dram_ba;
    wire [31:0] dram_dq;
    wire [3:0] dram_dm;
    wire dram_dqs;
    
    // Instantiate DUT
    dram_controller #(
        .AXI4_ID_WIDTH(AXI4_ID_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .M2_AXI4_AWID(M2_AXI4_AWID),
        .M2_AXI4_AWADDR(M2_AXI4_AWADDR),
        .M2_AXI4_AWLEN(M2_AXI4_AWLEN),
        .M2_AXI4_AWSIZE(M2_AXI4_AWSIZE),
        .M2_AXI4_AWBURST(M2_AXI4_AWBURST),
        .M2_AXI4_AWVALID(M2_AXI4_AWVALID),
        .M2_AXI4_AWREADY(M2_AXI4_AWREADY),
        .M2_AXI4_WDATA(M2_AXI4_WDATA),
        .M2_AXI4_WSTRB(M2_AXI4_WSTRB),
        .M2_AXI4_WLAST(M2_AXI4_WLAST),
        .M2_AXI4_WVALID(M2_AXI4_WVALID),
        .M2_AXI4_WREADY(M2_AXI4_WREADY),
        .M2_AXI4_BID(M2_AXI4_BID),
        .M2_AXI4_BRESP(M2_AXI4_BRESP),
        .M2_AXI4_BVALID(M2_AXI4_BVALID),
        .M2_AXI4_BREADY(M2_AXI4_BREADY),
        .M2_AXI4_ARID(M2_AXI4_ARID),
        .M2_AXI4_ARADDR(M2_AXI4_ARADDR),
        .M2_AXI4_ARLEN(M2_AXI4_ARLEN),
        .M2_AXI4_ARSIZE(M2_AXI4_ARSIZE),
        .M2_AXI4_ARBURST(M2_AXI4_ARBURST),
        .M2_AXI4_ARVALID(M2_AXI4_ARVALID),
        .M2_AXI4_ARREADY(M2_AXI4_ARREADY),
        .M2_AXI4_RID(M2_AXI4_RID),
        .M2_AXI4_RDATA(M2_AXI4_RDATA),
        .M2_AXI4_RRESP(M2_AXI4_RRESP),
        .M2_AXI4_RLAST(M2_AXI4_RLAST),
        .M2_AXI4_RVALID(M2_AXI4_RVALID),
        .M2_AXI4_RREADY(M2_AXI4_RREADY),
        .dram_ck(dram_ck),
        .dram_cs(dram_cs),
        .dram_we(dram_we),
        .dram_ras(dram_ras),
        .dram_cas(dram_cas),
        .dram_addr(dram_addr),
        .dram_ba(dram_ba),
        .dram_dq(dram_dq),
        .dram_dm(dram_dm),
        .dram_dqs(dram_dqs)
    );
    
    // Instantiate LPDDR4 dummy
    lpddr4_dummy lpddr4_inst (
        .clk(dram_ck),
        .cs(dram_cs),
        .we(dram_we),
        .ras(dram_ras),
        .cas(dram_cas),
        .addr(dram_addr),
        .ba(dram_ba),
        .dq(dram_dq),
        .dm(dram_dm),
        .dqs(dram_dqs)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test tasks
    task axi_read;
        input [ADDR_WIDTH-1:0] addr;
        input [AXI4_ID_WIDTH-1:0] id;
        begin
            @(posedge clk);
            M2_AXI4_ARID = id;
            M2_AXI4_ARADDR = addr;
            M2_AXI4_ARLEN = 8'h0;
            M2_AXI4_ARSIZE = 3'b010;
            M2_AXI4_ARBURST = 2'b01;
            M2_AXI4_ARVALID = 1'b1;
            M2_AXI4_RREADY = 1'b1;
            
            wait(M2_AXI4_ARREADY == 1'b1);
            @(posedge clk);
            M2_AXI4_ARVALID = 1'b0;
            
            wait(M2_AXI4_RVALID == 1'b1);
            @(posedge clk);
            $display("Read: addr=%h data=%h", addr, M2_AXI4_RDATA);
            
            @(posedge clk);
            M2_AXI4_RREADY = 1'b0;
        end
    endtask
    
    task axi_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        input [AXI4_ID_WIDTH-1:0] id;
        begin
            @(posedge clk);
            M2_AXI4_AWID = id;
            M2_AXI4_AWADDR = addr;
            M2_AXI4_AWLEN = 8'h0;
            M2_AXI4_AWSIZE = 3'b010;
            M2_AXI4_AWBURST = 2'b01;
            M2_AXI4_AWVALID = 1'b1;
            
            wait(M2_AXI4_AWREADY == 1'b1);
            @(posedge clk);
            M2_AXI4_AWVALID = 1'b0;
            M2_AXI4_WDATA = data;
            M2_AXI4_WSTRB = 4'hF;
            M2_AXI4_WLAST = 1'b1;
            M2_AXI4_WVALID = 1'b1;
            M2_AXI4_BREADY = 1'b1;
            
            wait(M2_AXI4_WREADY == 1'b1);
            @(posedge clk);
            M2_AXI4_WVALID = 1'b0;
            M2_AXI4_WLAST = 1'b0;
            
            wait(M2_AXI4_BVALID == 1'b1);
            @(posedge clk);
            $display("Write: addr=%h data=%h resp=%h", addr, data, M2_AXI4_BRESP);
            
            @(posedge clk);
            M2_AXI4_BREADY = 1'b0;
        end
    endtask
    
    // Test stimulus
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        M2_AXI4_AWVALID = 0;
        M2_AXI4_WVALID = 0;
        M2_AXI4_BREADY = 0;
        M2_AXI4_ARVALID = 0;
        M2_AXI4_RREADY = 0;
        
        // Reset
        #20 rst_n = 1;
        #10;
        
        $display("Starting DRAM Controller Test...");
        
        // Test read from initial data - read each location to verify correct addressing
        $display("\n--- Testing Initial Data Read ---");
        axi_read(32'h00000000, 4'h1); // Should read 00000000
        axi_read(32'h00000004, 4'h2); // Should read 11111111
        axi_read(32'h00000008, 4'h3); // Should read 22222222
        axi_read(32'h0000000C, 4'h4); // Should read 33333333
        axi_read(32'h00000010, 4'h5); // Should read 44444444
        axi_read(32'h00000014, 4'h6); // Should read 55555555
        
        // Test write and read back - verify we can write to specific addresses
        $display("\n--- Testing Write and Read Back ---");
        axi_write(32'h00000020, 32'hDEADBEEF, 4'h7);
        #20; // Add delay to ensure write completes
        axi_read(32'h00000020, 4'h8); // Should read DEADBEEF
        
        axi_write(32'h00000024, 32'hCAFEBABE, 4'h9);
        #20; // Add delay to ensure write completes
        axi_read(32'h00000024, 4'hA); // Should read CAFEBABE
        
        // Additional test: verify written data persists
        $display("\n--- Verifying Data Persistence ---");
        axi_read(32'h00000020, 4'hB); // Should read DEADBEEF again
        axi_read(32'h00000024, 4'hC); // Should read CAFEBABE again
        
        #100;
        $display("\nTest completed!");
        $finish;
    end
    
    // Monitor
    initial begin
        $dumpfile("tb_dram_controller.vcd");
        $dumpvars(0, tb_dram_controller);
    end

endmodule
