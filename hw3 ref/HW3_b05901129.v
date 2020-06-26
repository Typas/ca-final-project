// Latch somewhere
module multDiv(
    clk,
    rst_n,
    valid,
    ready,
    mode,
    in_A,
    in_B,
    out
);

    // Definition of ports
    input         clk, rst_n;
    input         valid, mode; // mode: 0: multu, 1: divu
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE = 2'b00;
    parameter MULT = 2'b01;
    parameter DIV  = 2'b10;
    parameter OUT  = 2'b11;

    // Todo: Wire and reg
    reg  [ 1:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;
    wire        is_ready;

    // Todo 5: wire assignments
    assign out = shreg; 
    assign is_ready = (state == OUT);
    assign ready = is_ready;
    
    // Combinational always block
    // Todo 1: State machine
    always @(*) begin
        case(state)
            IDLE: begin
                if (!valid) state_nxt = IDLE;
                else begin
                    if (!mode) state_nxt = MULT;
                    if (mode) state_nxt = DIV;
                end 
            end
            MULT: state_nxt = (counter==31)?OUT:MULT;
            DIV : state_nxt = (counter==31)?OUT:DIV;
            OUT : state_nxt = IDLE;
        endcase
    end

    // Todo 2: Counter, only adds up if in multu & divu
    always @(*) begin
        if ((state == MULT) || (state == DIV)) counter_nxt = counter + 1;
        else counter_nxt = 0;
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
    // multu: add in_B to first 32bits if last bit of shreg is 1, else nothing;
            MULT: begin 
                if (!shreg[0]) alu_out = shreg[63:32];
                else alu_out = shreg[63:32] + alu_in;
            end
    // divu: just substract by in_B, then leave shift register to decide
            DIV:  alu_out = shreg[63:32] - alu_in; 
            default: alu_out = 0;
        endcase
    end

    // Todo 4: Shift register
    always @(*) begin
        case(state)
    // multu: normally is put result in shreg_nxt first then srli, but
    // there is overflow issue handled by alu_out(33bits)
            MULT: begin 
                shreg_nxt = shreg >> 1;
                shreg_nxt[63:31] = alu_out;
            end    
            DIV: begin
    // divu: check if alu_out < 0, yes then just slli, else swap out first
    // 32bits then slli, and add to the end 1        
                if (!alu_out[32]) shreg_nxt = ({alu_out[31:0],shreg[31:0]} << 1) + 1 ;
                else shreg_nxt = shreg << 1;
                if (counter == 31) shreg_nxt[63:32] = shreg_nxt[63:32] >> 1;
            end
            OUT: shreg_nxt = 0; 
     // idle: get in_A into shreg_nxt if valid, should slli if state_nxt=DIV
            IDLE: begin
                if (valid) begin
                    if (!mode) shreg_nxt = in_A;
                    else shreg_nxt = in_A << 1;
                end
                else shreg_nxt = 0;
            end
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
            shreg <= shreg_nxt;     
            state <= state_nxt;
            counter <= counter_nxt;
            alu_in <= alu_in_nxt;
        end
    end

endmodule
