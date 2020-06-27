module ALU(rdata1, rdata2, regs, imm, alu_src, alu_op, imm_ins, result, zero);
   parameter ALU_BITS    = 32;
   parameter ALU_CTRL_BITS = 4;
   parameter ALUCTRL_AND = 0;
   parameter ALUCTRL_OR  = 1;
   parameter ALUCTRL_ADD = 2;
   parameter ALUCTRL_MUL = 3;
   parameter ALUCTRL_DIV = 4;
   parameter ALUCTRL_REM = 5;
   parameter ALUCTRL_SUB = 6;
   parameter ALUCTRL_SLT = 7;
   parameter ALUCTRL_XOR = 9;
   parameter ALUCTRL_SLL = 10;
   parameter ALUCTRL_SRA = 11;
   parameter ALUCTRL_SRL = 12;
   parameter ALUCTRL_SLTU = 14;

   input [ALU_BITS-1:0] rdata1;
   input [ALU_BITS-1:0] rdata2;
   input [1:0]          alu_op;
   input [3:0]          imm_ins;
   input                alu_src;
   input [ALU_BITS-1:0] imm;

   output [ALU_BITS-1:0] result;
   output                zero;

   wire [ALU_BITS-1:0]   main_in2;
   wire [ALU_BITS-1:0]   tmp_in2;
   wire                  sign;
   wire [ALU_CTRL_BITS-1:0] alu_ctrl;

   reg [ALU_BITS-1:0]       tmp_result;

   assign tmp_in2 = alu_src ? imm : rdata2;
   ALUcontrol ac0(
                  .alu_op(alu_op),
                  .ins(imm_ins),
                  .ctrl(alu_ctrl)
                  );
   assign sign = alu_ctrl == ALUCTRL_SUB;
   ALUneg an0(
              .in(tmp_in2),
              .sign(sign), .out(main_in2)
              );

   ALUmain am0(
               .in1(rdata1),
               .in2(rdata2),
               .ctrl(alu_ctrl),
               .result(tmp_result)
               );


   // alu_src
   // 0 => reg
   // 1 => imm
   // alu_op
   // 11 => undefined
   // 10 => R-format
   // 01 => branch
   // 00 => lw/sw

   // alu control: input from imm_ins and alu_op

endmodule // ALU

module ALUmain(in1, in2, ctrl, result);
   input [ALU_BITS-1:0]  in1;
   input [ALU_BITS-1:0]  in2;
   input [ALU_CTRL_BITS-1:0] alu_ctrl;
   output [ALU_BITS:0]       result;

   reg [ALU_BITS:0]          arith_in1;
   reg [ALU_BITS:0]          arith_in2;
   reg [ALU_BITS:0]          arith_carry;
   wire                      extend;

   assign result = arith_carry;
   assign extend = ctrl == ALUCTRL_SLTU || ctrl == ALUCTRL_SRA;

   always @(*) begin
      arith_in1[ALU_BITS-1:0] = in1;
      arith_in1[ALU_BITS] = extend ? in1[ALU_BITS-1] : 0;
   end

   always @(*) begin
      arith_in2[ALU_BITS-1:0] = in2;
      arith_in2[ALU_BITS] = extend ? in2[ALU_BITS-1] : 0;
   end

   always @(*) begin
      case(ctrl)
        // both add and sub are add, in2 already being negative
        ALUCTRL_ADD, ALUCTRL_SUB:
          arith_carry = arith_in1 + arith_in2;
        // slt => ignore top bit, sltu => all, compare to zero
        ALUCTRL_SLT, ALUCTRL_SLTU: begin
           arith_carry = arith_in1 + arith_in2;
           arith_carry = arith_carry[ALU_BITS-1+extend] ? 1 : 0;
        end
        ALUCTRL_AND:
          arith_carry = arith_in1 & arith_in2;
        ALUCTRL_OR:
          arith_carry = arith_in1 | arith_in2 ;
        ALUCTRL_XOR:
          arith_carry = arith_in1 ^ arith_in2;
        // only lower 5 bits
        ALUCTRL_SLL:
          arith_carry = arith_in1 << arith_in2[4:0];
        ALUCTRL_SRA:
          arith_carry = $signed(arith_in1) >>> arith_in2[4:0];
        ALUCTRL_SRL:
          arith_carry = arith_in1 >> arith_in2[4:0];
      endcase
   end

endmodule // ALUmain

module ALUcontrol(alu_op, ins, ctrl);
   input [1:0] alu_op;
   input [3:0] ins;
   output [ALU_CTRL_BITS-1:0] ctrl;
endmodule // ALUcontrol

module ALUneg(in, sign, out);
   input [ALU_BITS-1:0]  in;
   input                 sign;
   output [ALU_BITS-1:0] out;

   assign out = sign ? (~in+1) : in;
endmodule // ALUneg
