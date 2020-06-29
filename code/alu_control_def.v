`ifndef _ALU_CONTROL_DEF_V
`define _ALU_CONTROL_DEF_V

`timescale 1 ns/10 ps
`define ALUCTRL_AND            0
`define ALUCTRL_OR             1
`define ALUCTRL_ADD            2
`define ALUCTRL_SUB            3
`define ALUCTRL_SLT            4
`define ALUCTRL_SLTU           5
`define ALUCTRL_XOR            6
`define ALUCTRL_SLL            7
`define ALUCTRL_SRA            8
`define ALUCTRL_SRL            9
`define ALUCTRL_BEQ            10
`define ALUCTRL_BNE            11
`define ALUCTRL_BLT            12
`define ALUCTRL_BLTU           13
`define ALUCTRL_BGE            14
`define ALUCTRL_BGEU           15
`define ALUCTRL_JALR           16
`define ALUCTRL_JAL            17
`define ALUCTRL_AUIPC          18
`define ALUCTRL_LUI            19
`define ALUCTRL_MUL            20
`define ALUCTRL_MULH           21
`define ALUCTRL_MULHSU         22
`define ALUCTRL_MULHU          23
`define ALUCTRL_DIV            24
`define ALUCTRL_DIVU           25
`define ALUCTRL_REM            26
`define ALUCTRL_REMU           27
`define ALUCTRL_NOP            31

`endif // _ALU_CONTROL_DEF_V
