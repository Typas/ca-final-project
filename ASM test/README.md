# Simple Test for ASM results

## How?

`simple test.c` is a simple ASM tester.
You would need a riscv C compiler such as [GNU RISCV Toolchain](https://github.com/riscv/riscv-gnu-toolchain),
a simulator such as [Spike](https://github.com/riscv/riscv-isa-sim),
and probably a `proxy kernel` such as [PK](https://github.com/riscv/riscv-pk) as dependency.

## What does it do?

Just outputs results of these commands.
`MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, `REMU`.

## How to run?

`spike pk ./a.out <number 1> <number 2> <times>`
or
`spike pk ./a.out`

The program would take 2 numbers, take the operations listed above,
and then output results possbily several times as specified.
Each time the latter operand would be `+=1`.
