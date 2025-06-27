# Nama file output (tanpa ekstensi)
# Ini akan menjadi nama modul Verilog, file .lib, .lef, dll.
output_name = "sram_64x32_out"

# Jumlah kata (kedalaman memori)
# Kita pilih 128 (2^7) yang cukup untuk queue depth 63 atau 99
num_words = 64

# Lebar kata per lokasi (dalam bit)
# Sesuai dengan DATA_WIDTH 32-bit Anda
word_size = 32
num_banks = 1

# Jumlah port (Single-Port Read/Write)
num_rw_ports = 1
num_r_ports = 0
num_w_ports = 0

# Additional customizations
num_spare_cols = 1
num_spare_rows = 1
words_per_row = 2
analytical_delay = True
check_lvsdrc = False
inline_lvsdrc = False
output_datasheet_info = True

# Teknologi yang digunakan (sesuai dengan direktori skywater-pdk Anda)
tech_name = "sky130"
# Process corners to characterize
process_corners = [ "TT" ]
# Voltage corners to characterize
supply_voltages = [ 1.8 ]
# Temperature corners to characterize
temperatures = [ 100 ]
# Direktori tempat menyimpan semua file hasil generate
output_path = "sram_output_generated/"

# To force this to use magic and netgen for DRC/LVS/PEX
drc_name = "magic"
lvs_name = "netgen"
pex_name = "magic"