.data
    addr: .word 10
    
.text
.globl __start

FUNCTION:

    li    t1,   30
    li    t2,   -7
    la    t0,   addr

    mul  x10,   t1,    t2
    sw   x10,  0(t0)
    
    div  x10,   t1,    t2
    sw   x10,  4(t0)
    
    divu x10,   t1,    t2
    sw   x10,  8(t0)
    
    rem  x10,   t1,    t2
    sw   x10, 12(t0)

    remu x10,   t1,    t2
    sw   x10, 16(t0)

    ret


# Do not modify this part!!! #
__start:                     #
    jal  x1,FUNCTION         #
    addi a0,x0,10            #
    ecall                    #
##############################
