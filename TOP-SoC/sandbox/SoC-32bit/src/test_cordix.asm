lui  x1, 0xF0000       # x1 = 0xF0000000
addi x1, x1, 24        # x1 = 4026531864, x1 = REG_INPUT_DATA
lui  x2, 0xF0000       
addi x2, x2, 28        # x2 = 4026531868, x2 = REG_OUTPUT_DATA
lui  x3, 0xF0000
addi x3, x3, 32        # x3 = 4026531872, x3 = REG_FLAGS_IN
lui  x4, 0xF0000
addi x4, x4, 36        # x4 = 4026531876, x4 = REG_FLAGS_OUT
lui  x5, 0x2D0         # 45 * 2^16 = 2949120 = 0x2D0000
addi x5, x5, 0         # x5 = 2949120, input angle 45 deg in Q16 format
addi x6, x0, 2         # OK, nilai kecil, x6 = flag start computation for mode 0
addi x7, x0, 1         # OK, nilai kecil, x6 = flag finish computation

# Store input data to CORDIC
sw x5, 0(x1)           # Store input angle to REG_INPUT_DATA

# Store flags to start computation
sw x6, 0(x3)           # Store start flag to REG_FLAGS_IN

# Loop to check if computation is finished
loop:
    lw x8, 0(x4)       # Load REG_FLAGS_OUT to x8
    bne x8, x7, loop   # If x8 != 1 (finish flag), continue loop

# Load result when computation is finished
lw x9, 0(x2)           # Load result from REG_OUTPUT_DATA to x9
