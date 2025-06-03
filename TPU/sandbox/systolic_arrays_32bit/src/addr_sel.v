//------- Ahmed Abdelazeem -------
// Email: a.abdelazeem201@gmail.com
// (Modifikasi untuk mengakomodasi DATA_WIDTH 32-bit dengan 32x SRAM untuk weights dan 32x SRAM untuk data)
// (Revisi untuk kompatibilitas Verilog standar: port diskrit, perbaikan reg/wire)

//-------Address Selection Module-------s
// This module performs address selection for 32 weight queues and 32 data queues.
// Each queue is assumed to provide one 32-bit element per read.
// It generates the read addresses for SRAM based on the `addr_serial_num` input.
// The module calculates and outputs the addresses for 32 weight (w) banks and 32 data (d) banks.

module addr_sel
(
    input wire clk,                       // Clock signal
    input wire [6:0] addr_serial_num,     // Address serial number (max value = 126, 0-126)
    
    // Output addresses for 32 weight queues (w0~w31) - Port diskrit
    output reg [9:0] sram_raddr_w0,  sram_raddr_w1,  sram_raddr_w2,  sram_raddr_w3,
                     sram_raddr_w4,  sram_raddr_w5,  sram_raddr_w6,  sram_raddr_w7,
                     sram_raddr_w8,  sram_raddr_w9,  sram_raddr_w10, sram_raddr_w11,
                     sram_raddr_w12, sram_raddr_w13, sram_raddr_w14, sram_raddr_w15,
                     sram_raddr_w16, sram_raddr_w17, sram_raddr_w18, sram_raddr_w19,
                     sram_raddr_w20, sram_raddr_w21, sram_raddr_w22, sram_raddr_w23,
                     sram_raddr_w24, sram_raddr_w25, sram_raddr_w26, sram_raddr_w27,
                     sram_raddr_w28, sram_raddr_w29, sram_raddr_w30, sram_raddr_w31,
    
    // Output addresses for 32 data queues (d0~d31) - Port diskrit
    output reg [9:0] sram_raddr_d0,  sram_raddr_d1,  sram_raddr_d2,  sram_raddr_d3,
                     sram_raddr_d4,  sram_raddr_d5,  sram_raddr_d6,  sram_raddr_d7,
                     sram_raddr_d8,  sram_raddr_d9,  sram_raddr_d10, sram_raddr_d11,
                     sram_raddr_d12, sram_raddr_d13, sram_raddr_d14, sram_raddr_d15,
                     sram_raddr_d16, sram_raddr_d17, sram_raddr_d18, sram_raddr_d19,
                     sram_raddr_d20, sram_raddr_d21, sram_raddr_d22, sram_raddr_d23,
                     sram_raddr_d24, sram_raddr_d25, sram_raddr_d26, sram_raddr_d27,
                     sram_raddr_d28, sram_raddr_d29, sram_raddr_d30, sram_raddr_d31
);

    // Internal wires for the next addresses (sebagai array untuk kemudahan di generate block)
    wire [9:0] sram_raddr_w_nx [0:31];
    wire [9:0] sram_raddr_d_nx [0:31];

    //--------Sequential Logic--------
    // Mendaftarkan nilai _nx ke output diskrit pada posedge clk.
    always @(posedge clk) begin
        sram_raddr_w0  <= sram_raddr_w_nx[0];  sram_raddr_w1  <= sram_raddr_w_nx[1];
        sram_raddr_w2  <= sram_raddr_w_nx[2];  sram_raddr_w3  <= sram_raddr_w_nx[3];
        sram_raddr_w4  <= sram_raddr_w_nx[4];  sram_raddr_w5  <= sram_raddr_w_nx[5];
        sram_raddr_w6  <= sram_raddr_w_nx[6];  sram_raddr_w7  <= sram_raddr_w_nx[7];
        sram_raddr_w8  <= sram_raddr_w_nx[8];  sram_raddr_w9  <= sram_raddr_w_nx[9];
        sram_raddr_w10 <= sram_raddr_w_nx[10]; sram_raddr_w11 <= sram_raddr_w_nx[11];
        sram_raddr_w12 <= sram_raddr_w_nx[12]; sram_raddr_w13 <= sram_raddr_w_nx[13];
        sram_raddr_w14 <= sram_raddr_w_nx[14]; sram_raddr_w15 <= sram_raddr_w_nx[15];
        sram_raddr_w16 <= sram_raddr_w_nx[16]; sram_raddr_w17 <= sram_raddr_w_nx[17];
        sram_raddr_w18 <= sram_raddr_w_nx[18]; sram_raddr_w19 <= sram_raddr_w_nx[19];
        sram_raddr_w20 <= sram_raddr_w_nx[20]; sram_raddr_w21 <= sram_raddr_w_nx[21];
        sram_raddr_w22 <= sram_raddr_w_nx[22]; sram_raddr_w23 <= sram_raddr_w_nx[23];
        sram_raddr_w24 <= sram_raddr_w_nx[24]; sram_raddr_w25 <= sram_raddr_w_nx[25];
        sram_raddr_w26 <= sram_raddr_w_nx[26]; sram_raddr_w27 <= sram_raddr_w_nx[27];
        sram_raddr_w28 <= sram_raddr_w_nx[28]; sram_raddr_w29 <= sram_raddr_w_nx[29];
        sram_raddr_w30 <= sram_raddr_w_nx[30]; sram_raddr_w31 <= sram_raddr_w_nx[31];

        sram_raddr_d0  <= sram_raddr_d_nx[0];  sram_raddr_d1  <= sram_raddr_d_nx[1];
        sram_raddr_d2  <= sram_raddr_d_nx[2];  sram_raddr_d3  <= sram_raddr_d_nx[3];
        sram_raddr_d4  <= sram_raddr_d_nx[4];  sram_raddr_d5  <= sram_raddr_d_nx[5];
        sram_raddr_d6  <= sram_raddr_d_nx[6];  sram_raddr_d7  <= sram_raddr_d_nx[7];
        sram_raddr_d8  <= sram_raddr_d_nx[8];  sram_raddr_d9  <= sram_raddr_d_nx[9];
        sram_raddr_d10 <= sram_raddr_d_nx[10]; sram_raddr_d11 <= sram_raddr_d_nx[11];
        sram_raddr_d12 <= sram_raddr_d_nx[12]; sram_raddr_d13 <= sram_raddr_d_nx[13];
        sram_raddr_d14 <= sram_raddr_d_nx[14]; sram_raddr_d15 <= sram_raddr_d_nx[15];
        sram_raddr_d16 <= sram_raddr_d_nx[16]; sram_raddr_d17 <= sram_raddr_d_nx[17];
        sram_raddr_d18 <= sram_raddr_d_nx[18]; sram_raddr_d19 <= sram_raddr_d_nx[19];
        sram_raddr_d20 <= sram_raddr_d_nx[20]; sram_raddr_d21 <= sram_raddr_d_nx[21];
        sram_raddr_d22 <= sram_raddr_d_nx[22]; sram_raddr_d23 <= sram_raddr_d_nx[23];
        sram_raddr_d24 <= sram_raddr_d_nx[24]; sram_raddr_d25 <= sram_raddr_d_nx[25];
        sram_raddr_d26 <= sram_raddr_d_nx[26]; sram_raddr_d27 <= sram_raddr_d_nx[27];
        sram_raddr_d28 <= sram_raddr_d_nx[28]; sram_raddr_d29 <= sram_raddr_d_nx[29];
        sram_raddr_d30 <= sram_raddr_d_nx[30]; sram_raddr_d31 <= sram_raddr_d_nx[31];
    end

    //--------Combinational Logic--------
    localparam MAX_ADDR_SERIAL_NUM   = 126;
    // Jika setiap antrian/SRAM memiliki kedalaman 63 (alamat 0-62), maka durasi aktifnya adalah 63 siklus.
    // Komentar asli: "each queue having a size of 32+32-1 (63)"
    localparam QUEUE_ACTIVE_DURATION = 63; 
    localparam INACTIVE_SRAM_ADDR    = 10'd127; // Nilai default jika tidak aktif (sesuai kode asli)

    generate
        for (genvar j = 0; j < 32; j = j + 1) begin : addr_gen_per_port
            wire current_port_active;
            wire [6:0] effective_sram_page_addr; // Cukup 6 bit jika kedalaman 0-62
            wire [9:0] calculated_sram_addr;
            
            // Perbaikan: upper_bound_asn_for_port harus wire karena diisi oleh assign
            wire [6:0] upper_bound_asn_for_port; 

            // Hitung batas atas addr_serial_num untuk port j ini
            assign upper_bound_asn_for_port = ((j + QUEUE_ACTIVE_DURATION - 1) > MAX_ADDR_SERIAL_NUM) ? 
                                              MAX_ADDR_SERIAL_NUM : 
                                              (j + QUEUE_ACTIVE_DURATION - 1);

            assign current_port_active = (addr_serial_num >= j) && (addr_serial_num <= upper_bound_asn_for_port);
            // effective_sram_page_addr adalah alamat di dalam SRAM bank tersebut (0 hingga QUEUE_ACTIVE_DURATION-1)
            assign effective_sram_page_addr = addr_serial_num - j; 
            
            // Bentuk alamat SRAM 10-bit.
            // Jika effective_sram_page_addr hanya butuh 6 bit (0-62), maka paddingnya 4 bit.
            assign calculated_sram_addr = {4'b0000, effective_sram_page_addr[5:0]}; // Gunakan 6 bit LSB

            assign sram_raddr_w_nx[j] = current_port_active ? calculated_sram_addr : INACTIVE_SRAM_ADDR;
            assign sram_raddr_d_nx[j] = current_port_active ? calculated_sram_addr : INACTIVE_SRAM_ADDR;
        end
    endgenerate

endmodule