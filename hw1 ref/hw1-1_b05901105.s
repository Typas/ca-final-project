.globl __start

.rodata
    msg0: .string "This is HW1-1: T(n)= 4T(n/2)+2n, T(1)=1\n"
    msg1: .string "Enter a number: "
    msg2: .string "The result is: "

.text

################################################################################
  # You may write function here
T:
    li   t0, 2
    blt  a0, t0, T_small
    
    # 4T(floor(n/2))+2n
    addi sp, sp, -8
    sw   a0, 0(sp)
    sw   ra, 4(sp)
    srli a0, a0, 1
    jal  ra, T       # after which "a0" is T(n/2)
    slli t0, a0, 2   # 4(T(n/2))
    lw   t1, 0(sp)
    slli t1, t1, 1   # 2n
    add  a0, t0, t1
    lw   ra, 4(sp)
    addi sp, sp, 8
    ret

T_small:
    li   a0, 1
    ret

################################################################################

__start:
  # Prints msg0
    addi a0, x0, 4
    la a1, msg0
    ecall
  # Prints msg1
    addi a0, x0, 4
    la a1, msg1
    ecall
  # Reads an int
    addi a0, x0, 5
    ecall

################################################################################ 
  # Write your main function here. 
  # Input n is in a0. You should store the result T(n) into t0
  # HW1-1 T(n)= 4T(n/2)+2n, T(1)=1, round down the result of division
  
  # addi t0, a0, 1
  jal  x1, T
  addi t0, a0, 0

################################################################################

result:
  # Prints msg2
    addi a0, x0, 4
    la a1, msg2
    ecall
  # Prints the result in t0
    addi a0, x0, 1
    add a1, x0, t0
    ecall
  # Ends the program with status code 0
    addi a0, x0, 10
    ecall