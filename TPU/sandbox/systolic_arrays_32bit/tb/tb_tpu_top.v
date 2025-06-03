`timescale 1ns / 1ps

module tpu_top_tb;

    // Parameters (sesuaikan dengan tpu_top.v Anda)
    localparam ARRAY_SIZE        = 32;
    localparam SRAM_DATA_WIDTH   = 32;
    localparam DATA_WIDTH        = 8;  // Lebar data input ke systolic array (elemen matriks)
    localparam OUTPUT_DATA_WIDTH = 16; // Lebar data output setelah kuantisasi

    // Inputs untuk tpu_top
    reg clk;
    reg srstn; // Asynchronous reset (active low)
    reg tpu_start;

    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_w0, sram_rdata_w1, sram_rdata_w2, sram_rdata_w3;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_w4, sram_rdata_w5, sram_rdata_w6, sram_rdata_w7;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_d0, sram_rdata_d1, sram_rdata_d2, sram_rdata_d3;
    reg [SRAM_DATA_WIDTH-1:0] sram_rdata_d4, sram_rdata_d5, sram_rdata_d6, sram_rdata_d7;

    // Outputs dari tpu_top
    wire [9:0] sram_raddr_w0, sram_raddr_w1, sram_raddr_w2, sram_raddr_w3;
    wire [9:0] sram_raddr_w4, sram_raddr_w5, sram_raddr_w6, sram_raddr_w7;
    wire [9:0] sram_raddr_d0, sram_raddr_d1, sram_raddr_d2, sram_raddr_d3;
    wire [9:0] sram_raddr_d4, sram_raddr_d5, sram_raddr_d6, sram_raddr_d7;

    wire sram_write_enable_a0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_a;
    wire [5:0] sram_waddr_a;

    wire sram_write_enable_b0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_b;
    wire [5:0] sram_waddr_b;

    wire sram_write_enable_c0;
    wire [ARRAY_SIZE*OUTPUT_DATA_WIDTH-1:0] sram_wdata_c;
    wire [5:0] sram_waddr_c;

    wire tpu_done;

    // Instansiasi DUT (Design Under Test)
    tpu_top #(
        .ARRAY_SIZE(ARRAY_SIZE),
        .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
    ) dut (
        .clk(clk),
        .srstn(srstn), // Menggunakan srstn dari testbench
        .tpu_start(tpu_start),

        .sram_rdata_w0(sram_rdata_w0), .sram_rdata_w1(sram_rdata_w1),
        .sram_rdata_w2(sram_rdata_w2), .sram_rdata_w3(sram_rdata_w3),
        .sram_rdata_w4(sram_rdata_w4), .sram_rdata_w5(sram_rdata_w5),
        .sram_rdata_w6(sram_rdata_w6), .sram_rdata_w7(sram_rdata_w7),

        .sram_rdata_d0(sram_rdata_d0), .sram_rdata_d1(sram_rdata_d1),
        .sram_rdata_d2(sram_rdata_d2), .sram_rdata_d3(sram_rdata_d3),
        .sram_rdata_d4(sram_rdata_d4), .sram_rdata_d5(sram_rdata_d5),
        .sram_rdata_d6(sram_rdata_d6), .sram_rdata_d7(sram_rdata_d7),

        .sram_raddr_w0(sram_raddr_w0), .sram_raddr_w1(sram_raddr_w1),
        .sram_raddr_w2(sram_raddr_w2), .sram_raddr_w3(sram_raddr_w3),
        .sram_raddr_w4(sram_raddr_w4), .sram_raddr_w5(sram_raddr_w5),
        .sram_raddr_w6(sram_raddr_w6), .sram_raddr_w7(sram_raddr_w7),

        .sram_raddr_d0(sram_raddr_d0), .sram_raddr_d1(sram_raddr_d1),
        .sram_raddr_d2(sram_raddr_d2), .sram_raddr_d3(sram_raddr_d3),
        .sram_raddr_d4(sram_raddr_d4), .sram_raddr_d5(sram_raddr_d5),
        .sram_raddr_d6(sram_raddr_d6), .sram_raddr_d7(sram_raddr_d7),

        .sram_write_enable_a0(sram_write_enable_a0),
        .sram_wdata_a(sram_wdata_a),
        .sram_waddr_a(sram_waddr_a),

        .sram_write_enable_b0(sram_write_enable_b0),
        .sram_wdata_b(sram_wdata_b),
        .sram_waddr_b(sram_waddr_b),

        .sram_write_enable_c0(sram_write_enable_c0),
        .sram_wdata_c(sram_wdata_c),
        .sram_waddr_c(sram_waddr_c),

        .tpu_done(tpu_done)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // ns, contoh periode clock 100 MHz
    always #(CLK_PERIOD/2) clk = ~clk;

    // Tugas Utama Anda di Sini:
    // 1. Memodelkan perilaku SRAM atau menyediakan data untuk sram_rdata_*
    //    (Seperti yang dijelaskan di jawaban sebelumnya)
    //
    // reg [SRAM_DATA_WIDTH-1:0] memory_bank_w0 [0:1023];
    // initial $readmemh("weights_bank0.hex", memory_bank_w0);
    // always @(posedge clk) sram_rdata_w0 <= memory_bank_w0[sram_raddr_w0];
    // ... (ulangi untuk semua bank SRAM yang dibutuhkan)


    // Main simulation sequence
    initial begin
        // --- Tambahan untuk GTKWave (VCD dump) ---
        $dumpfile("tpu_top_sim.vcd"); // Nama file VCD yang akan dihasilkan
        $dumpvars(0, tpu_top_tb);     // Dump semua sinyal di modul testbench ini dan semua modul di dalamnya (termasuk dut)
        // Anda juga bisa spesifik, misal: $dumpvars(0, dut); untuk hanya DUT dan isinya.
        // -----------------------------------------

        clk = 0;
        srstn = 0;      // Assert reset (active low)
        tpu_start = 0;

        // Inisialisasi semua input sram_rdata ke nilai default (misalnya 0)
        sram_rdata_w0 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_w1 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_w2 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_w3 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_w4 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_w5 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_w6 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_w7 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_d0 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_d1 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_d2 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_d3 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_d4 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_d5 = {SRAM_DATA_WIDTH{1'b0}};
        sram_rdata_d6 = {SRAM_DATA_WIDTH{1'b0}}; sram_rdata_d7 = {SRAM_DATA_WIDTH{1'b0}};

        // Tunggu beberapa siklus setelah reset
        repeat(5) @(posedge clk);
        srstn = 1;      // Deassert reset
        repeat(5) @(posedge clk);

        $display("[%0t ns] INFO: Reset deasserted. Starting TPU operation.", $time);

        // TODO: Pastikan data untuk sram_rdata_* sudah siap atau dimuat ke model SRAM testbench
        //       sebelum tpu_start diaktifkan.
        //       Ini sangat penting!

        // Mulai operasi TPU
        tpu_start = 1;
        @(posedge clk);
        tpu_start = 0; // tpu_start biasanya berupa pulsa atau level yang dideteksi FSM

        // Tunggu hingga tpu_done menjadi tinggi
        $display("[%0t ns] INFO: Waiting for tpu_done...", $time);
        wait (dut.tpu_done == 1); // Lebih baik merujuk ke sinyal output DUT secara eksplisit
        $display("[%0t ns] INFO: TPU operation completed (tpu_done asserted).", $time);

        // TODO: Tambahkan pengecekan untuk sram_wdata_a/b/c dan sram_waddr_a/b/c
        //       Bandingkan dengan hasil yang diharapkan.

        // Tambahkan delay untuk melihat sinyal setelah selesai jika perlu
        repeat(10) @(posedge clk);

        $display("[%0t ns] INFO: Simulation finished.", $time);
        $finish;
    end

    // (Opsional) Monitor sinyal penting.
    // Untuk melihat sinyal ini di konsol saat simulasi berjalan.
    // initial begin
    //     // Pastikan Anda merujuk ke sinyal di dalam DUT dengan benar jika ingin memonitor sinyal internal.
    //     // Untuk mengakses sinyal internal, simulator mungkin memerlukan opsi khusus saat kompilasi,
    //     // dan jalur ke sinyal harus lengkap (misal, dut.systolic_controll_inst.cycle_num).
    //     // Lebih mudah memonitor port output dari DUT.
    //     $monitor("[%0t ns] clk=%b, srstn=%b, tpu_start=%b, tpu_done=%b, addr_s0_w0=%h, addr_s0_d0=%h",
    //              $time, clk, srstn, tpu_start, dut.tpu_done, dut.sram_raddr_w0, dut.sram_raddr_d0);
    // end

endmodule