`include "alu_control_def.v"
`timescale 1 ns/10 ps

module CONTROL_UNIT #(
                      parameter BITS = 32
                      ) (
                         Opcode,
                         Funct7,
                         Funct3,
                         rst_n,
                         Branch,
                         MemtoReg,
                         ALUCtrl,
                         MemWrite,
                         ALUSrc,
                         RegWrite
                         );

    parameter   R_Type         = 7'b011_0011;  // RV32I such as add; RV32M such as MUL
    parameter   I_Type_Calc    = 7'b001_0011;  // addi, xori, slti, ...
    parameter   U_Type_AUIPC   = 7'b001_0111;  // auipc
    parameter   I_Type_Load    = 7'b000_0011;  // load related
    parameter   S_Type         = 7'b010_0011;  // store related
    parameter   SB_Type        = 7'b110_0011;  // branch related
    parameter   UJ_Type_JAL    = 7'b110_1111;  // jal
    parameter   UJ_Type_JALR   = 7'b110_0111;  // jalr

    input         rst_n;
    input [6:0]   Opcode, Funct7;
    input [2:0]   Funct3;
    output reg [4:0] ALUCtrl;
    output reg       Branch, MemtoReg, MemWrite, ALUSrc, RegWrite;

    always @* begin  // ALUCtrl
        case(Opcode)
            R_Type, I_Type_Calc: begin
                case(Funct3)
                    3'b000: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_ADD;
                                    7'b010_0000: ALUCtrl = `ALUCTRL_SUB;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_MUL;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_ADD;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b000
                    3'b001: begin
                        case(Funct7)
                            7'b000_0000: ALUCtrl = `ALUCTRL_SLL;
                            7'b000_0001: ALUCtrl = `ALUCTRL_MULH;
                            default    : ALUCtrl = `ALUCTRL_NOP;
                        endcase
                    end  // case(Funct3) == 3'b001
                    3'b010: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_SLT;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_MULHSU;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_SLT;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b010
                    3'b011: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_SLTU;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_MULHU;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_SLTU;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b011
                    3'b100: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_XOR;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_DIV;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_XOR;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b100
                    3'b101: begin
                        case(Funct7)
                            7'b000_0000: ALUCtrl = `ALUCTRL_SRL;
                            7'b010_0000: ALUCtrl = `ALUCTRL_SRA;
                            7'b000_0001: ALUCtrl = `ALUCTRL_DIVU;
                            default:     ALUCtrl = `ALUCTRL_NOP;
                        endcase
                    end  // case(Funct3) == 3'b101
                    3'b110: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_OR;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_REM;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_OR;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b110
                    3'b111: begin
                        case(Opcode)
                            R_Type: begin
                                case(Funct7)
                                    7'b000_0000: ALUCtrl = `ALUCTRL_AND;
                                    7'b000_0001: ALUCtrl = `ALUCTRL_REMU;
                                    default:     ALUCtrl = `ALUCTRL_NOP;
                                endcase
                            end
                            I_Type_Calc: begin
                                ALUCtrl = `ALUCTRL_AND;
                            end
                            default:           ALUCtrl = `ALUCTRL_NOP;
                        endcase  // Opcode
                    end  // case(Funct3) == 3'b111
                endcase  // Funct3
            end  // R_Type, I_Type_Calc
            U_Type_AUIPC: begin
                ALUCtrl = `ALUCTRL_AUIPC;
            end
            I_Type_Load, S_Type: begin
                ALUCtrl = `ALUCTRL_ADD;
            end
            SB_Type: begin
                case(Funct3)
                    3'b000:  ALUCtrl = `ALUCTRL_BEQ;
                    3'b001:  ALUCtrl = `ALUCTRL_BNE;
                    3'b100:  ALUCtrl = `ALUCTRL_BLT;
                    3'b101:  ALUCtrl = `ALUCTRL_BGE;
                    3'b110:  ALUCtrl = `ALUCTRL_BLTU;
                    3'b111:  ALUCtrl = `ALUCTRL_BGEU;
                    default: ALUCtrl = `ALUCTRL_NOP;
                endcase
            end
            UJ_Type_JAL: begin
                ALUCtrl = `ALUCTRL_JAL;
            end
            UJ_Type_JALR: begin
                ALUCtrl = `ALUCTRL_JALR;
            end
            default: begin
                ALUCtrl = `ALUCTRL_NOP;
            end
        endcase  // Opcode
    end  // ALUCtrl


    always @* begin  // Branch
        case(Opcode)
            UJ_Type_JAL, UJ_Type_JALR, SB_Type: begin
                Branch = 1'b1;
            end
            default: begin
                Branch = 1'b0;
            end
        endcase
    end  // Branch

    always @* begin // MemtoReg
      case (Opcode) 
         I_Type_Load: MemtoReg = 1'b1;
         default: MemtoReg = 1'b0;
      endcase
    end //Branch 

    always @* begin  // MemWrite
        case(Opcode)
            S_Type: begin
                MemWrite = 1'b1;
            end
            default: begin
                MemWrite = 1'b0;
            end
        endcase
    end  // MemWrite

    always @* begin  // ALUSrc
        case(Opcode)
            I_Type_Calc, U_Type_AUIPC, UJ_Type_JAL, UJ_Type_JALR: begin
                ALUSrc   = 1'b1;
            end
            default: begin
                ALUSrc   = 1'b0;
            end
        endcase
    end  // ALUSrc


    always @* begin  // RegWrite
        case(Opcode)
            S_Type, SB_Type, UJ_Type_JAL: begin
                RegWrite = 1'b0;
            end
            default: begin
                RegWrite = 1'b1;
            end
        endcase
    end  // RegWrite


endmodule  // CONTROL_UNIT
