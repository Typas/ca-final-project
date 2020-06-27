module ALU(rdata1, rdata2, regs, imm, alu_src, alu_ctrl, result, is_zero);
   input [ALU_BITS-1:0] rdata1;
   input [ALU_BITS-1:0] rdata2;
   input [ALU_CTRL_BITS-1:0] alu_ctrl;
   input                     alu_src;
   input [ALU_BITS-1:0]      imm;

   output [ALU_BITS-1:0]     result;
   output                    is_zero;

   wire [ALU_BITS-1:0]       main_in2;
   wire [ALU_BITS-1:0]       tmp_in2;
   wire                      sign;

   reg [ALU_BITS:0]          tmp_result;

   assign result = tmp_result[ALU_BITS-1:0];
   assign is_zero = tmp_result[ALU_BITS];
   ALUmux amu0(
               .r2(rdata2),
               .imm(imm),
               .src(alu_src),
               .out(tmp_in2),
               )
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

   always @(*) begin
      // some cases
      // branch -> "bit is_zero" eq/ne when a xor b == 0/not 0
      //                      lt/ge when a slt b == true/false
      //                      ltu/geu when a sltu b == true/false
      // arith -> "bits result", set is_zero to 0
      // load/save -> "bits result", set is_zero to 0
   end
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
        // slt => ignore last bit, sltu => all, compare to is_zero
        ALUCTRL_SLT, ALUCTRL_SLTU:
          arith_carry = arith_in1 << (~extend) + arith_in2 << (~extend);
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

module ALUneg(in, sign, out);
   input [ALU_BITS-1:0]  in;
   input                 sign;
   output [ALU_BITS-1:0] out;

   assign out = sign ? (~in+1) : in;
endmodule // ALUneg

module ALUmux(r2, imm, src, out);
   input [ALU_BITS-1:0] r2;
   input [ALU_BITS-1:0] imm;
   input                src;
   output [ALU_BITS-1:0] out;

   assign out = src ? imm : r2;
endmodule // ALUmux
