`include "alu_control_def.v"
`define ALU_BITS      32
`define ALU_CTRL_BITS 5

module ALU(clk, rst_n, rdata1, pc_in, rdata2, imm, alu_pcsrc ,alu_immsrc, alu_ctrl, result, is_zero, ready);
    input [`ALU_BITS-1:0] rdata1;
    input [`ALU_BITS-1:0] rdata2;
    input [`ALU_CTRL_BITS-1:0] alu_ctrl;
    input [`ALU_BITS-1:0]      pc_in;
    input                      alu_pcsrc;
    input                      alu_immsrc;
    input [`ALU_BITS-1:0]      imm;
    input                      clk;
    input                      rst_n;

    output [`ALU_BITS-1:0]     result;
    output                     is_zero;
    output                     ready;

    wire [`ALU_BITS-1:0]       main_in1;
    wire [`ALU_BITS-1:0]       main_in2;
    wire [`ALU_BITS-1:0]       tmp_in2;
    wire [`ALU_BITS:0]         tmp_out;
    wire [2*`ALU_BITS-1:0]     multdiv_out;
    wire [`ALU_BITS:0]         alumain_out;
    wire                       sign;
    wire                       multdiv_mode;
    wire                       multdiv_valid;
    wire                       multdiv_ready;

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

    // alu_immsrc
    // 0 => reg
    // 1 => imm
    ALUmux amu0(
                .rdata(rdata2),
                .other(imm),
                .src(alu_immsrc),
                .out(tmp_in2)
                );
    ALUmux amu1(
                .rdata(rdata1),
                .other(pc_in),
                .src(alu_pcsrc),
                .out(main_in1)
                );
    ALUneg an0(
               .in(tmp_in2),
               .sign(sign),
               .out(main_in2)
               );
    ALUmain am0(
                .in1(main_in1),
                .in2(main_in2),
                .ctrl(alu_ctrl),
                .result(alumain_out)
                );
    multDivCtrl mc0(
                    .ctrl(alu_ctrl),
                    .mode(multdiv_mode),
                    .valid(multdiv_valid)
                    );
    multDiv md0(
                .clk(clk),
                .rst_n(rst_n),
                .valid(multdiv_valid),
                .ready(multdiv_ready),
                .mode(multdiv_mode),
                .in_A(main_in1),
                .in_B(main_in2),
                .out(multdiv_out)
                );
    selectALU sa0(
                  .ctrl(alu_ctrl),
                  .md_out(multdiv_out),
                  .am_out(alumain_out),
                  .out(tmp_out),
                  .MSB1(main_in1[`ALU_BITS-1]),
                  .MSB2(main_in2[`ALU_BITS-1])
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
            `ALUCTRL_JAL, `ALUCTRL_JALR:
                last_zero = 1;
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
            `ALUCTRL_ADD, `ALUCTRL_SUB, `ALUCTRL_AUIPC:
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
                               !(arith_in1[`ALU_BITS-1:0] ^ arith_in2[`ALU_BITS-1:0]),
                               arith_in1[`ALU_BITS-1:0] ^ arith_in2[`ALU_BITS-1:0]
                               };
            // only lower 5 bits
            `ALUCTRL_SLL:
                arith_carry = arith_in1 << arith_in2[4:0];
            `ALUCTRL_SRA:
                arith_carry = $signed(arith_in1) >>> arith_in2[4:0];
            `ALUCTRL_SRL:
                arith_carry = arith_in1 >> arith_in2[4:0];
            `ALUCTRL_JAL, `ALUCTRL_JALR:
                arith_carry = arith_in1 + 4;
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

module ALUmux(rdata, other, src, out);
    input [`ALU_BITS-1:0] rdata;
    input [`ALU_BITS-1:0] other;
    input                 src;
    output [`ALU_BITS-1:0] out;

    assign out = src ? other : rdata;
endmodule // ALUmux

module selectALU(ctrl, md_out, am_out, out, MSB1, MSB2);
    input [`ALU_CTRL_BITS-1:0] ctrl;
    input [2*`ALU_BITS-1:0] md_out;
    input [`ALU_BITS:0] am_out;
    input               MSB1;
    input               MSB2;
    output reg [`ALU_BITS:0] out;

    wire                     sign;
    wire                     md_neg_out_high;
    wire                     md_neg_out_low;

    assign sign = (ctrl == `ALUCTRLMULHSU
                   || ctrl == `ALUCTRLDIV
                   || ctrl == `ALUCTRLREM
                   ) ? MSB1 : (MSB1 ^ MSB2);
    ALUneg an0(
               .in(md_out[`ALU_CTRL_BITS-1:0]),
               .sign(sign),
               .out(md_neg_out_low)
               );
    ALUneg an1(
               .in(md_out[`ALU_CTRL_BITS-1:0]),
               .sign(sign),
               .out(md_neg_out_high)
               );


    always @(*) begin
        case(ctrl)
            `ALUCTRL_MUL, `ALUCTRLDIVU:
                out = {1'b0, md_out[`ALU_BITS-1:0]};
            `ALUCTRLMULHU, `ALUCTRLREMU:
                    out = {1'b0, md_out[2*`ALU_BITS-1:`ALU_BITS]};
            `ALUCTRLMULHSU, `ALUCTRLMULH, `ALUCTRLREM:
                out = {1'b0, md_neg_out_high};
            `ALUCTRLDIV:
                out = {1'b0, md_neg_out_low};
            default:
                out = am_out;
        endcase
    end

endmodule

module multDivCtrl(ctrl, mode, valid);
    input [`ALU_CTRL_BITS-1:0] ctrl;
    output                     mode, valid;

    assign mode = ctrl >= `ALUCTRL_DIV && ctrl <= `ALUCTRL_REMU;
    assign valid = ctrl >= `ALUCTRL_MUL && ctrl <= `ALUCTRL_REMU;
endmodule

module multDiv(clk, rst_n, valid, ready, mode, in_A, in_B, out);
    // Definition of ports
    input         clk, rst_n;
    input         valid, mode; // mode: 0: multu, 1: divu
    output        ready;
    input [31:0]  in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE = 2'b00;
    parameter MULT = 2'b01;
    parameter DIV  = 2'b10;
    parameter OUT  = 2'b11;

    // Todo: Wire and reg
    reg [ 1:0]    state, state_nxt;
    reg [ 4:0]    counter, counter_nxt;
    reg [63:0]    shreg, shreg_nxt;
    reg [31:0]    alu_in, alu_in_nxt;
    reg [32:0]    alu_out;

    // Todo 5: wire assignments
    assign out = shreg;
    assign ready = state == OUT;

    // Combinational always block
    // Todo 1: State machine
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) begin
                    if (mode) state_nxt = DIV;
                    else      state_nxt = MULT;
                end
                else begin
                    state_nxt = state;
                end
            end
            MULT: begin
                case(counter)
                    31: state_nxt = OUT;
                    default:   state_nxt = state;
                endcase
            end
            DIV : begin
                case (counter)
                    31: state_nxt = OUT;
                    default:   state_nxt = state;
                endcase
            end
            OUT : state_nxt = IDLE;
        endcase
    end
    // Todo 2: Counter
    always @(*) begin
        case(state)
            IDLE: counter_nxt = 0;
            MULT: counter_nxt = counter + 1;
            DIV : counter_nxt = counter + 1;
            OUT : counter_nxt = 0;
        endcase
    end

    // ALU input
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) alu_in_nxt = in_B;
                else       alu_in_nxt = 0;
            end
            OUT : alu_in_nxt = 0;
            default: alu_in_nxt = alu_in;
        endcase
    end

    // Todo 3: ALU output
    always @(*) begin
        case(state)
            IDLE: alu_out = 0;
            MULT: begin
                alu_out = shreg[63:32] + (shreg[0] ? alu_in : 0);
            end
            DIV : begin
                alu_out = shreg[63:32] - alu_in;
                if (alu_out[32]) begin
                    alu_out = shreg[63:32];
                    alu_out[32] = 0;
                end
                else begin
                    alu_out[32] = 1;
                end
            end
            OUT : alu_out = 0;
        endcase
    end

    // Todo 4: Shift register
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) shreg_nxt = in_A << mode; // need to shift 1 when div
                else       shreg_nxt = 0;
            end
            MULT: begin
                shreg_nxt[30:0]  = shreg[32:1];
                shreg_nxt[63:31] = alu_out; // shift without >> umm
            end
            DIV : begin
                shreg_nxt[0] = alu_out[32];
                if (counter == 31) begin
                    shreg_nxt[63:32] = alu_out[31:0];
                    shreg_nxt[31: 1] = shreg[30:0];
                end
                else begin
                    shreg_nxt[63:33] = alu_out[30:0];
                    shreg_nxt[32: 1] = shreg[31:0];
                end
            end
            OUT : shreg_nxt = 0;
        endcase
    end

    // Todo: Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            counter <= 0;
            shreg <= 0;
            alu_in <= 0;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            shreg <= shreg_nxt;
            alu_in <= alu_in_nxt;
        end
    end
endmodule
