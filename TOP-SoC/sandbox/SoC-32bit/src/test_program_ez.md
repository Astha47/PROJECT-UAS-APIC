# Test Program Documentation

## Overview
This is a simple RISC-V assembly test program that implements a memory-based counter loop.

## Program Flow
1. **Initialization**: Sets up a memory address pointer at offset 1020
2. **Memory Clear**: Writes zero to the target memory location
3. **Counter Loop**: 
    - Reads the current value from memory
    - Increments the value by 1
    - Writes the updated value back to memory
    - Jumps back to continue the loop indefinitely

## Assembly Code
```assembly
3fc00093    li      x1,1020      # Load immediate 1020 into x1
0000a023    sw      x0,0(x1)     # Store zero to memory[x1]
0000a103    lw      x2,0(x1)     # Load word from memory[x1] to x2
00110113    addi    x2,x2,1      # Add 1 to x2
0020a023    sw      x2,0(x1)     # Store x2 back to memory[x1]
ff5ff06f    j       loop         # Jump back to loop
```

## Memory Usage
- **Base Address**: 1020 (0x3FC)
- **Operation**: Read-modify-write cycle on a single 32-bit word

## Register Usage
- **x1**: Memory address pointer (1020)
- **x2**: Counter value temporary storage

## Purpose
This program appears to be a hardware test routine for:
- Verifying memory read/write operations
- Testing jump/branch functionality
- Creating a continuous activity pattern for debugging or validation
