module CONTROL_UNIT #(
   parameter BITS = 32,
   parameter word_depth = 32
) (
   Opcode[6:0],
   rst_n,
   Branch,
   MemRead,
   MemtoReg,
   ALUOp,
   MemWrite,
   ALUSrc,
   RegWrite
);

input         rst_n;
input         [6:0] Opcode;
output        [1:0] ALUOp;
output        Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;

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
//
//  ALUOp[1:0]:
//  00 --> alu shall take one input from reg file, one from imm gen, perform ADDITION
//  01 --> branch related, alu take both input from reg file, perform SUBTRACTION
//  10 --> we couldn't decide what to do merely on opcode; leave for alu to decide.
//  11 --> dummy don't care, shall not be in this case however.

assign    Branch    = ((!rst_n) && (Opcode[6]   == 1'b1  ))? 1'b1 : 1'b0;
assign    MemRead   = ((!rst_n) && (Opcode[5:3] == 3'b0  ))? 1'b1 : 1'b0;
assign    MemtoReg  = ((!rst_n) && (Opcode[6:4] == 3'b000))? 1'b1 : 1'b0;
assign    ALUOp[1]  = ((!rst_n) && (Opcode[6:4] == 3'b011))? 1'b1 : 1'b0;
assign    ALUOp[0]  = ((!rst_n) && (Opcode[6:4] == 3'b110))? 1'b1 : 1'b0;
assign    MemWrite  = ((!rst_n) && (Opcode[6:4] == 3'b010))? 1'b1 : 1'b0;
assign    ALUSrc    = ((!rst_n) && (Opcode[6:4] == 3'b010))? 1'b1 : 1'b0;
assign    RegWrite  = ((!rst_n) && ({Opcode[6:4],Opcode[2]} != 4'b1100))? 1'b1 : 1'b0;

endmodule
