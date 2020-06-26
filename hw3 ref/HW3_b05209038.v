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
