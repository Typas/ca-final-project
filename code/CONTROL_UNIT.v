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

`include "alu_control_def.v"

parameter   R_Type         = 7'b011_0011;
parameter   I_Type_Calc    = 7'b001_0011;  // addi, xori, slti, ...
parameter   U_Type_AUIPC   = 7'b001_0111;  // auipc
parameter   I_Type_Load    = 7'b000_0011;  // load related
parameter   S_Type         = 7'b010_0011;  // store related
parameter   SB_Type        = 7'b110_0011;  // branch related
parameter   UJ_Type_JAL    = 7'b110_1111;  // jal
parameter   UJ_Type_JALR   = 7'b110_0111;  // jalr

input         rst_n;
input         [6:0] Opcode, Funct7;
input         [2:0] Funct3;
output reg    [4:0] ALUCtrl;
output        Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;

assign    Branch       = (rst_n && (Opcode[6]   == 1'b1  ) );
assign    MemRead      = (rst_n && (Opcode[6:4] == 3'b000) );
assign    MemtoReg     = (rst_n && (Opcode[6:4] == 3'b000) );
assign    MemWrite     = (rst_n && (Opcode[6:4] == 3'b010) );
assign    ALUSrcHelper =
   (  (Opcode[2:0] == 3'b111) || (Opcode[5:3] == 3'b010) );
assign    ALUSrc       = (rst_n && ALUSrcHelper );
assign    RegWrite     = (rst_n && ({Opcode[6:4],Opcode[2]} != 4'b1100));

always @* begin
   case(Opcode)
      R_Type, I_Type_Calc: begin
         case(Funct3)
            3'b000: begin
               case(Opcode)
                  R_Type: begin
                     case(Funct7)
                        7'b000_0000: ALUCtrl = ALUCTRL_ADD;
                        7'b001_0000: ALUCtrl = ALUCTRL_SUB;
                        default:     ALUCtrl = ALUCTRL_NOP;
                     endcase
                  end
                  I_Type_Calc: begin
                     ALUCtrl = ALUCTRL_ADD;
                  end
                  default: ALUCtrl = ALUCTRL_NOP;
               endcase
            end
            3'b001: ALUCtrl = ALUCTRL_SLL;
            3'b010: ALUCtrl = ALUCTRL_SLT;
            3'b011: ALUCtrl = ALUCTRL_SLTU;
            3'b100: ALUCtrl = ALUCTRL_XOR;
            3'b101: begin
               case(Funct7)
                  7'b000_0000: ALUCtrl = ALUCTRL_SRL;
                  7'b010_0000: ALUCtrl = ALUCTRL_SRA;
                  default:     ALUCtrl = ALUCTRL_NOP;
               endcase
            end
            3'b110: ALUCtrl = ALUCTRL_OR;
            3'b111: ALUCtrl = ALUCTRL_AND;
         endcase  // Funct3
      end  // R_Type, I_Type_Calc
      U_Type_AUIPC: begin
         ALUCtrl = ALUCTRL_AUIPC;
      end
      I_Type_Load, S_Type: begin
         ALUCtrl = ALUCTRL_ADD;
      end
      SB_Type: begin
         case( Funct3 )
            3'b000:  ALUCtrl = ALUCTRL_BEQ;
            3'b001:  ALUCtrl = ALUCTRL_BNE;
            3'b100:  ALUCtrl = ALUCTRL_BLT;
            3'b101:  ALUCtrl = ALUCTRL_BGE;
            3'b110:  ALUCtrl = ALUCTRL_BLTU;
            3'b111:  ALUCtrl = ALUCTRL_BGEU;
            default: ALUCtrl = ALUCTRL_NOP;
         endcase
      end
      UJ_Type_JAL: begin
         ALUCtrl = ALUCTRL_JAL;
      end
      UJ_Type_JALR: begin
         ALUCtrl = ALUCTRL_JALR;
      end
      /* TODO: add remaining cases */
      default: begin
         ALUCtrl = ALUCTRL_NOP;
      end
   endcase  // Opcode
end

endmodule
