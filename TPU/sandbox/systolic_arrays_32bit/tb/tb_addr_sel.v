`timescale 1ns / 1ps

module tb_addr_sel;

    // Parameter
    localparam ADDR_SERIAL_NUM_WIDTH = 7;
    localparam SRAM_ADDR_WIDTH       = 10;
    // localparam NUM_PORTS             = 32; // Tidak lagi digunakan untuk deklarasi port DUT

    // Inputs untuk addr_sel
    reg clk;
    reg [ADDR_SERIAL_NUM_WIDTH-1:0] addr_serial_num_tb;

    // Outputs dari addr_sel (sekarang sebagai port diskrit)
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w0_dut,  sram_raddr_w1_dut,  sram_raddr_w2_dut,  sram_raddr_w3_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w4_dut,  sram_raddr_w5_dut,  sram_raddr_w6_dut,  sram_raddr_w7_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w8_dut,  sram_raddr_w9_dut,  sram_raddr_w10_dut, sram_raddr_w11_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w12_dut, sram_raddr_w13_dut, sram_raddr_w14_dut, sram_raddr_w15_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w16_dut, sram_raddr_w17_dut, sram_raddr_w18_dut, sram_raddr_w19_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w20_dut, sram_raddr_w21_dut, sram_raddr_w22_dut, sram_raddr_w23_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w24_dut, sram_raddr_w25_dut, sram_raddr_w26_dut, sram_raddr_w27_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_w28_dut, sram_raddr_w29_dut, sram_raddr_w30_dut, sram_raddr_w31_dut;

    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d0_dut,  sram_raddr_d1_dut,  sram_raddr_d2_dut,  sram_raddr_d3_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d4_dut,  sram_raddr_d5_dut,  sram_raddr_d6_dut,  sram_raddr_d7_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d8_dut,  sram_raddr_d9_dut,  sram_raddr_d10_dut, sram_raddr_d11_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d12_dut, sram_raddr_d13_dut, sram_raddr_d14_dut, sram_raddr_d15_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d16_dut, sram_raddr_d17_dut, sram_raddr_d18_dut, sram_raddr_d19_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d20_dut, sram_raddr_d21_dut, sram_raddr_d22_dut, sram_raddr_d23_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d24_dut, sram_raddr_d25_dut, sram_raddr_d26_dut, sram_raddr_d27_dut;
    wire [SRAM_ADDR_WIDTH-1:0] sram_raddr_d28_dut, sram_raddr_d29_dut, sram_raddr_d30_dut, sram_raddr_d31_dut;


    // Instansiasi DUT (Design Under Test) - addr_sel
    addr_sel dut (
        .clk(clk),
        .addr_serial_num(addr_serial_num_tb),

        .sram_raddr_w0(sram_raddr_w0_dut),   .sram_raddr_w1(sram_raddr_w1_dut),
        .sram_raddr_w2(sram_raddr_w2_dut),   .sram_raddr_w3(sram_raddr_w3_dut),
        .sram_raddr_w4(sram_raddr_w4_dut),   .sram_raddr_w5(sram_raddr_w5_dut),
        .sram_raddr_w6(sram_raddr_w6_dut),   .sram_raddr_w7(sram_raddr_w7_dut),
        .sram_raddr_w8(sram_raddr_w8_dut),   .sram_raddr_w9(sram_raddr_w9_dut),
        .sram_raddr_w10(sram_raddr_w10_dut), .sram_raddr_w11(sram_raddr_w11_dut),
        .sram_raddr_w12(sram_raddr_w12_dut), .sram_raddr_w13(sram_raddr_w13_dut),
        .sram_raddr_w14(sram_raddr_w14_dut), .sram_raddr_w15(sram_raddr_w15_dut),
        .sram_raddr_w16(sram_raddr_w16_dut), .sram_raddr_w17(sram_raddr_w17_dut),
        .sram_raddr_w18(sram_raddr_w18_dut), .sram_raddr_w19(sram_raddr_w19_dut),
        .sram_raddr_w20(sram_raddr_w20_dut), .sram_raddr_w21(sram_raddr_w21_dut),
        .sram_raddr_w22(sram_raddr_w22_dut), .sram_raddr_w23(sram_raddr_w23_dut),
        .sram_raddr_w24(sram_raddr_w24_dut), .sram_raddr_w25(sram_raddr_w25_dut),
        .sram_raddr_w26(sram_raddr_w26_dut), .sram_raddr_w27(sram_raddr_w27_dut),
        .sram_raddr_w28(sram_raddr_w28_dut), .sram_raddr_w29(sram_raddr_w29_dut),
        .sram_raddr_w30(sram_raddr_w30_dut), .sram_raddr_w31(sram_raddr_w31_dut),

        .sram_raddr_d0(sram_raddr_d0_dut),   .sram_raddr_d1(sram_raddr_d1_dut),
        .sram_raddr_d2(sram_raddr_d2_dut),   .sram_raddr_d3(sram_raddr_d3_dut),
        .sram_raddr_d4(sram_raddr_d4_dut),   .sram_raddr_d5(sram_raddr_d5_dut),
        .sram_raddr_d6(sram_raddr_d6_dut),   .sram_raddr_d7(sram_raddr_d7_dut),
        .sram_raddr_d8(sram_raddr_d8_dut),   .sram_raddr_d9(sram_raddr_d9_dut),
        .sram_raddr_d10(sram_raddr_d10_dut), .sram_raddr_d11(sram_raddr_d11_dut),
        .sram_raddr_d12(sram_raddr_d12_dut), .sram_raddr_d13(sram_raddr_d13_dut),
        .sram_raddr_d14(sram_raddr_d14_dut), .sram_raddr_d15(sram_raddr_d15_dut),
        .sram_raddr_d16(sram_raddr_d16_dut), .sram_raddr_d17(sram_raddr_d17_dut),
        .sram_raddr_d18(sram_raddr_d18_dut), .sram_raddr_d19(sram_raddr_d19_dut),
        .sram_raddr_d20(sram_raddr_d20_dut), .sram_raddr_d21(sram_raddr_d21_dut),
        .sram_raddr_d22(sram_raddr_d22_dut), .sram_raddr_d23(sram_raddr_d23_dut),
        .sram_raddr_d24(sram_raddr_d24_dut), .sram_raddr_d25(sram_raddr_d25_dut),
        .sram_raddr_d26(sram_raddr_d26_dut), .sram_raddr_d27(sram_raddr_d27_dut),
        .sram_raddr_d28(sram_raddr_d28_dut), .sram_raddr_d29(sram_raddr_d29_dut),
        .sram_raddr_d30(sram_raddr_d30_dut), .sram_raddr_d31(sram_raddr_d31_dut)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // ns
    always #(CLK_PERIOD/2) clk = ~clk;

    // Variabel untuk iterasi
    integer i_asn; // Untuk addr_serial_num

    // Main simulation sequence
    initial begin
        // --- Tambahan untuk GTKWave (VCD dump) ---
        $dumpfile("tb_addr_sel_discrete_ports_sim.vcd"); // Nama file VCD
        $dumpvars(0, tb_addr_sel);   // Dump semua sinyal
        // -----------------------------------------

        clk = 0;
        addr_serial_num_tb = 0;

        #(CLK_PERIOD * 2); // Tunggu inisialisasi

        $display("INFO: Starting tb_addr_sel simulation.");
        $display("INFO: Iterating addr_serial_num from 0 to 126.");
        $display("----------------------------------------------------------------------");
        $display("Time (ns) | ASN | w[0] | d[0] | ... | w[31] | d[31]"); // ASN = addr_serial_num
        $display("----------------------------------------------------------------------");

        for (i_asn = 0; i_asn <= 126; i_asn = i_asn + 1) begin
            addr_serial_num_tb = i_asn;
            #(CLK_PERIOD); 
            
            $display("%0t | %3d | %3h | %3h | ... | %3h  | %3h",
                     $time, addr_serial_num_tb,
                     sram_raddr_w0_dut, sram_raddr_d0_dut,
                     sram_raddr_w31_dut, sram_raddr_d31_dut); // Menampilkan port pertama dan terakhir
        end
        
        $display("--- Specific addr_serial_num checks (using task) ---");
        addr_serial_num_tb = 0;     #(CLK_PERIOD); display_detailed_ports_task;
        addr_serial_num_tb = 1;     #(CLK_PERIOD); display_detailed_ports_task;
        addr_serial_num_tb = 31;    #(CLK_PERIOD); display_detailed_ports_task;
        addr_serial_num_tb = 32;    #(CLK_PERIOD); display_detailed_ports_task;
        addr_serial_num_tb = 62;    #(CLK_PERIOD); display_detailed_ports_task; // Contoh pertengahan
        addr_serial_num_tb = 98;    #(CLK_PERIOD); display_detailed_ports_task;
        addr_serial_num_tb = 126;   #(CLK_PERIOD); display_detailed_ports_task;

        $display("----------------------------------------------------------------------");
        $display("INFO: Simulation finished.");
        $finish;
    end

    // Task untuk menampilkan output beberapa port terpilih
    task display_detailed_ports_task;
        begin
            $display("[%0t ns] ASN=%3d: w[0]=%3h, d[0]=%3h | w[1]=%3h, d[1]=%3h | w[15]=%3h, d[15]=%3h | w[31]=%3h, d[31]=%3h",
                     $time, addr_serial_num_tb,
                     sram_raddr_w0_dut,  sram_raddr_d0_dut,
                     sram_raddr_w1_dut,  sram_raddr_d1_dut,
                     sram_raddr_w15_dut, sram_raddr_d15_dut,
                     sram_raddr_w31_dut, sram_raddr_d31_dut);
        end
    endtask

endmodule