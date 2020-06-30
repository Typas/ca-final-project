// Your code
`include "alu_control_def.v"
`include "CONTROL_UNIT.v"
`include "alu.v"
`include "pc.v"
`include "immGen.v"

module CHIP(clk,
            rst_n,
            // For mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // For mem_I
            mem_addr_I,
            mem_rdata_I);

    input         clk, rst_n ;
    // For mem_D
    output        mem_wen_D  ;
    output [31:0] mem_addr_D ;
    output [31:0] mem_wdata_D;
    input  [31:0] mem_rdata_D;
    // For mem_I
    output [31:0] mem_addr_I ;
    input  [31:0] mem_rdata_I;

    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg  [31:0]   PC          ;              //
    wire [31:0]   PC_nxt      ;              //
    wire          regWrite    ;              //
    wire [ 4:0]   rs1, rs2, rd;              //
    wire [31:0]   rs1_data    ;              //
    wire [31:0]   rs2_data    ;              //
    wire [31:0]   rd_data     ;              //
    //---------------------------------------//

    // Todo: other wire/reg
    wire [31:0]               imm;
    wire                      branch;
    wire                      is_branch;
    wire                      MemtoReg;
    wire [`ALU_CTRL_BITS-1:0] ALUCtrl;
    wire                      ALUPCSrc;
    wire                      ALUSrc;
    wire                      Jalr;
    wire [`ALU_BITS-1:0]      ALUout;
    wire                      zero;
    wire                      ready;
    wire                      Stall;


    //---------------------------------------//
    // Do not modify this part!!!            //
    //---------------------------------------//                                 
    reg_file reg0(
                  .clk(clk),                           //
                  .rst_n(rst_n),                       //
                  .wen(regWrite),                      //
                  .a1(rs1),                            //
                  .a2(rs2),                            //
                  .aw(rd),                             //
                  .d(rd_data),                         //
                  .q1(rs1_data),                       //
                  .q2(rs2_data));                      //
    //---------------------------------------//
    // Todo: any combinational/sequential circuit
    //---------------------------------------//
    PC_AND pc_and0(
                   .Branch(branch),
                   .Zero(zero),
                   .Is_Branch(is_branch));
    PC pc0(
           .Pc(PC),
           .Pc_nxt(PC_nxt),
           .Imm_In(imm),
           .Rs_data1(rs1_data),
           .Branch(is_branch),
           .Jalr(Jalr));

    immGen imm0(
                .instruction(mem_rdata_I),
                .immediate(imm));

    CONTROL_UNIT ctrl0(
                       .Opcode(mem_rdata_I[6:0]),
                       .Funct7(mem_rdata_I[31:25]),
                       .Funct3(mem_rdata_I[14:12]),
                       .MulDivAluReady(ready),
                       .rst_n(rst_n),
                       .Branch(branch),
                       .MemtoReg(MemtoReg),
                       .ALUCtrl(ALUCtrl),
                       .MemWrite(mem_wen_D),
                       .ALUSrc(ALUSrc),
                       .ALUPCSrc(ALUPCSrc),
                       .RegWrite(regWrite),
                       .PCJalr(Jalr),
                       .Stall(Stall));

    ALU alu0(
             .clk(clk),
             .rst_n(rst_n),
             .rdata1(rs1_data),
             .pc_in(PC),
             .rdata2(rs2_data),
             .imm(imm),
             .alu_pcsrc(ALUPCSrc),
             .alu_immsrc(ALUSrc),
             .alu_ctrl(ALUCtrl),
             .result(ALUout),
             .is_zero(zero),
             .ready(ready));
   
   assign rd = mem_rdata_I[11:7];
   assign rs1 = mem_rdata_I[19:15];
   assign rs2 = mem_rdata_I[24:20];
   assign rd_data = MemtoReg ? mem_rdata_D : ALUout;
   assign mem_addr_D = ALUout;
   assign mem_wdata_D = rs2_data;
   assign mem_addr_I = PC;

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                PC <= 32'h00010000; // Do not modify this value!!!

            end
            else begin
                if (!Stall) PC <= PC_nxt;
                else PC <= PC;
            end
        end
endmodule

module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);

    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth

    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0]      q1, q2;

    reg [BITS-1:0]         mem [0:word_depth-1];
    reg [BITS-1:0]         mem_nxt [0:word_depth-1];

    integer                i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;
                    32'd3: mem[i] <= 32'h10008000;
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end
    end
endmodule

