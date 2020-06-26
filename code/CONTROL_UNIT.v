module CONTROL_UNIT #(
   parameter BITS = 32,
   parameter word_depth = 32
) (
   Opcode,
   rst_n,
   Branch,
   MemRead,
   MemtoReg,
   ALUOp,
   MemWrite,
   ALUSrc,
   RegWrite
);

input         Opcode[6:0], rst_n;
output        Branch, MemRead, MemtoReg, ALUOp[1:0], MemWrite, ALUSrc, RegWrite;
output        Branch, MemRead, MemtoReg, ALUOp[1:0], MemWrite, ALUSrc, RegWrite;

// currently supported instructions:
//
//  add      011 0011
//  sub      011 0011
//  xor      011 0011
//  or       011 0011
//  and      011 0011
//  addi     001 0011
//  auipc    001 0111
//  lw       000 0011
//  lh       000 0011
//  lb       000 0011
//  sw       010 0011
//  sh       010 0011
//  sb       010 0011
//  jal      110 1111
//  jalr     110 0111
//  beq      110 0011
//  bne      110 0011
//  blt      110 0011
//  bge      110 0011
//  bltu     110 0011
//  bgeu     110 0011

assign    Branch    = ((!rst_n) && (Opcode[6]   == 1'b1  ))? 1'b1 : 1'b0;
assign    MemRead   = ((!rst_n) && (Opcode[5:3] == 3'b0  ))? 1'b1 : 1'b0;
assign    MemtoReg  = ((!rst_n) && (Opcode[6:4] == 3'b000))? 1'b1 : 1'b0;
assign    ALUOp[1]  = ((!rst_n) && (Opcode[6:4] == 3'b011))? 1'b1 : 1'b0;
assign    ALUOp[0]  = ((!rst_n) && (Opcode[6:4] == 3'b110))? 1'b1 : 1'b0;
assign    MemWrite  = ((!rst_n) && (Opcode[6:4] == 3'b010))? 1'b1 : 1'b0;
assign    ALUSrc    = 
