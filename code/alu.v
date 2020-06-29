`include "alu_control_def.v"
`define ALU_BITS      32
`define ALU_CTRL_BITS 5

module ALU(rdata1, rdata2, imm, alu_src, alu_ctrl, result, is_zero);
    input [`ALU_BITS-1:0] rdata1;
    input [`ALU_BITS-1:0] rdata2;
    input [`ALU_CTRL_BITS-1:0] alu_ctrl;
    input                      alu_src;
    input [`ALU_BITS-1:0]      imm;

    output [`ALU_BITS-1:0]     result;
    output                     is_zero;

    wire [`ALU_BITS-1:0]       main_in2;
    wire [`ALU_BITS-1:0]       tmp_in2;
    wire [`ALU_BITS:0]         tmp_out;
    wire                       sign;

    reg [`ALU_BITS:0]          tmp_result;
    reg                        last_zero;

    assign result = tmp_result[`ALU_BITS-1:0];
    assign is_zero = last_zero;
    assign sign =
                 alu_ctrl == `ALUCTRL_SUB
                 || (
                     alu_ctrl >= `ALUCTRL_BEQ
                     && alu_ctrl <= `ALUCTRL_BGEU
                     );
    // alu_src
    // 0 => reg
    // 1 => imm
    ALUmux amu0(
                .r2(rdata2),
                .imm(imm),
                .src(alu_src),
                .out(tmp_in2)
                );
    ALUneg an0(
               .in(tmp_in2),
               .sign(sign),
               .out(main_in2)
               );
    ALUmain am0(
                .in1(rdata1),
                .in2(main_in2),
                .ctrl(alu_ctrl),
                .result(tmp_out)
                );
    always @(*) tmp_result = tmp_out;

    always @(*) begin
        // some cases
        // branch -> "bit is_zero" eq/ne when a xor b == 0/not 0
        //                      lt/ge when a slt b == true/false
        //                      ltu/geu when a sltu b == true/false
        // arith -> "bits result", set is_zero to 0
        // load/save -> "bits result", set is_zero to 0
        case(alu_ctrl)
            `ALUCTRL_BLT, `ALUCTRL_BLTU:
                last_zero = tmp_result[0];
            `ALUCTRL_BEQ:
                last_zero = tmp_result[`ALU_BITS];
            `ALUCTRL_BNE:
                last_zero = ~tmp_result[`ALU_BITS];
            `ALUCTRL_BGE, `ALUCTRL_BGEU:
                last_zero = ~tmp_result[0];
            default:
                last_zero = 0;
        endcase
    end
endmodule // ALU

module ALUmain(in1, in2, ctrl, result);
    input [`ALU_BITS-1:0]  in1;
    input [`ALU_BITS-1:0]  in2;
    input [`ALU_CTRL_BITS-1:0] ctrl;
    output [`ALU_BITS:0]       result;

    reg [`ALU_BITS:0]          arith_in1;
    reg [`ALU_BITS:0]          arith_in2;
    reg [`ALU_BITS:0]          arith_carry;
    reg                        extend;

    assign result = arith_carry;

    always @(*) begin
        case(ctrl)
            `ALUCTRL_SLTU, `ALUCTRL_SRA, `ALUCTRL_BLTU, `ALUCTRL_BGEU:
                extend = 1;
            default:
                extend = 0;
        endcase
    end

    always @(*) begin
        arith_in1[`ALU_BITS-1:0] = in1;
        arith_in1[`ALU_BITS] = extend ? in1[`ALU_BITS-1] : 0;
    end

    always @(*) begin
        arith_in2[`ALU_BITS-1:0] = in2;
        arith_in2[`ALU_BITS] = extend ? in2[`ALU_BITS-1] : 0;
    end

    always @(*) begin
        case(ctrl)
            // both add and sub are add, in2 already being negative
            `ALUCTRL_ADD, `ALUCTRL_SUB:
                arith_carry = arith_in1 + arith_in2;
            // slt => ignore last bit, sltu => all, compare to is_zero
            // fu 硬尻, 只留最後一個bit
            `ALUCTRL_SLT, `ALUCTRL_SLTU, `ALUCTRL_BLT, `ALUCTRL_BLTU, `ALUCTRL_BGE, `ALUCTRL_BGEU:
                arith_carry = ((arith_in1 << (~extend) + arith_in2 << (~extend)) & `ALU_BITS'b0) >> `ALU_BITS;
            `ALUCTRL_AND:
                arith_carry = arith_in1 & arith_in2;
            `ALUCTRL_OR:
                arith_carry = arith_in1 | arith_in2 ;
            `ALUCTRL_XOR, `ALUCTRL_BEQ, `ALUCTRL_BNE:
                arith_carry = {
                               (arith_in1[`ALU_BITS-1:0] ^ arith_in2[`ALU_BITS-1:0]) ? 0 : 1,
                               arith_in1[`ALU_BITS-1:0] ^ arith_in2[`ALU_BITS-1:0]
                               };
            // only lower 5 bits
            `ALUCTRL_SLL:
                arith_carry = arith_in1 << arith_in2[4:0];
            `ALUCTRL_SRA:
                arith_carry = $signed(arith_in1) >>> arith_in2[4:0];
            `ALUCTRL_SRL:
                arith_carry = arith_in1 >> arith_in2[4:0];
            default:
                arith_carry = 0;
        endcase
    end

endmodule // ALUmain

module ALUneg(in, sign, out);
    input [`ALU_BITS-1:0]  in;
    input                  sign;
    output [`ALU_BITS-1:0] out;

    assign out = sign ? (~in+1) : in;
endmodule // ALUneg

module ALUmux(r2, imm, src, out);
    input [`ALU_BITS-1:0] r2;
    input [`ALU_BITS-1:0] imm;
    input                 src;
    output [`ALU_BITS-1:0] out;

    assign out = src ? imm : r2;
endmodule // ALUmux
