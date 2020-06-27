module CONTROL_UNIT #(
   parameter BITS = 32,
   parameter word_depth = 32
) (
   Opcode,
   Funct7,
   Funct3,
   rst_n,
   Branch,
   MemRead,
   MemtoReg,
   ALUCtrl,
   MemWrite,
   ALUSrc,
   RegWrite
);

input         rst_n;
input         [6:0] Opcode, [6:0] Funct7, [2:0] Funct3;
output reg    [3:0] ALUCtrl;
output        Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;

// currently supported instructions:
//
//  add      011 0011
//  sub      011 0011
//  xor      011 0011
//  or       011 0011
//  and      011 0011
//  addi     001 0011
//  slti     001 0011
//  sltiu    001 0011
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

assign    Branch       = (rst_n && (Opcode[6]   == 1'b1  ) );
assign    MemRead      = (rst_n && (Opcode[6:4] == 3'b000) );
assign    MemtoReg     = (rst_n && (Opcode[6:4] == 3'b000) );
assign    MemWrite     = (rst_n && (Opcode[6:4] == 3'b010) );
assign    ALUSrc       = (rst_n && ALUSrcHelper);
assign    RegWrite     = (rst_n && ({Opcode[6:4],Opcode[2]} != 4'b1100));
assign    ALUSrcHelper = ((Opcode[3:2] != 2'b00) || (ALUOp[1:0] == 2'b00));

parameter   R_Type       = 7'b011_0011
parameter   I_TypeCalc   = 7'b001_0011  // addi, xori, slti, ...
parameter   U_Type_0     = 7'b001_0111  // auipc
parameter   I_TypeLoad   = 7'b000_0011  // load related
parameter   S_Type       = 7'b010_0011  // store related
parameter   SB_Type      = 7'b110_0011  // branch related
parameter   UJ_Type_0    = 7'b110_1111  // jal
parameter   UJ_Type_1    = 7'b110_0111  // jalr

parameter ALUCTRL_AND           = 0;
parameter ALUCTRL_OR            = 1;
parameter ALUCTRL_ADD           = 2;
parameter ALUCTRL_MUL           = 3;
parameter ALUCTRL_MULU          = 4;
parameter ALUCTRL_DIV           = 5;
parameter ALUCTRL_DIVU          = 6;
parameter ALUCTRL_REM           = 7;
parameter ALUCTRL_REMU          = 8;
parameter ALUCTRL_SUB           = 9;
parameter ALUCTRL_SLT           = 10;
parameter ALUCTRL_SLTU          = 11;
parameter ALUCTRL_XOR           = 12;
parameter ALUCTRL_SLL           = 13;
parameter ALUCTRL_SRA           = 14;
parameter ALUCTRL_SRL           = 15;
parameter ALUCTRL_BEQ           = 16;
parameter ALUCTRL_BNE           = 17;
parameter ALUCTRL_BLT           = 18;
parameter ALUCTRL_BLTU          = 19;
parameter ALUCTRL_BGE           = 20;
parameter ALUCTRL_BGEU          = 21;
parameter ALUCTRL_JALR          = 22;
parameter ALUCTRL_JAL           = 23;
parameter ALUCTRL_AUIPC         = 24;
parameter ALUCTRL_LUI           = 25;
parameter ALUCTRL_NOP           = 26;

always @*
   case(Opcode)
      RType, ITypeCalc: begin
      end
      UType0, ITypeLoad, SType: begin
      end
end

endmodule
