# File: sram_input_config.py

# Nama file output (tanpa ekstensi)
# Ini akan menjadi nama modul Verilog, file .lib, .lef, dll.
output_name = "sram_128x32_sp"

# Jumlah kata (kedalaman memori)
# Kita pilih 128 (2^7) yang cukup untuk queue depth 63 atau 99
num_words = 128

# Lebar kata per lokasi (dalam bit)
# Sesuai dengan DATA_WIDTH 32-bit Anda
word_size = 32

# Jumlah port (Single-Port Read/Write)
num_rw_ports = 1
num_r_ports = 0
num_w_ports = 0

# Teknologi yang digunakan (sesuai dengan direktori skywater-pdk Anda)
tech_name = "sky130"

# Direktori tempat menyimpan semua file hasil generate
output_path = "sram_generated/"