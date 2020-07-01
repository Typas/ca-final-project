.data
    n: .word 10 # You can change this number
    
.text
.globl __start

FUNCTION:
    # Todo: define your own function in HW1

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
    

# Do not modify this part!!! #
__start:                     #
    la   t0, n               #
    lw   x10, 0(t0)          #
    jal  x1,FUNCTION         #
    addi t0, a0, 0
    la   t0, n               #
    sw   x10, 4(t0)          #
    addi a0,x0,10            #
    ecall                    #
##############################
