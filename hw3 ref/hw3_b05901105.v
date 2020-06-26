module multDiv(
   clk,
   rst_n,
   valid,
   ready,
   mode,
   in_A,       /* TODO !!! */
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
assign   out   = shreg;
assign   ready = (state==OUT)? 1'b1 : 1'b0;

// Combinational always block
// Todo 1: State machine
always @(*) begin
   case(state)
      IDLE: begin
         if ( valid == 1'b1 ) begin
            if ( mode == 1'b1 )
            begin
               state_nxt = DIV;
            end
            else if ( mode == 1'b0 )
            begin
               state_nxt = MULT; 
            end
         end
         else begin
            state_nxt = IDLE;
         end
      end // IDLE
      MULT: begin
         if ( counter == 31 ) begin
            state_nxt = OUT;
         end
         else begin
            state_nxt = MULT;
         end
      end // MULT
      DIV : begin
         if ( counter == 31 ) begin
            state_nxt = OUT;
         end
         else begin
            state_nxt = DIV;
         end
      end // DIV
      OUT : begin
         state_nxt = IDLE;
      end // OUT
   endcase // case(state)
end

// Todo 2: Counter
always @(*) begin
   if ( state == IDLE || state == OUT ) begin
      counter_nxt = 0;
   end
   else if ( state == MULT || state == DIV ) begin
      counter_nxt = counter + 1;
   end
   else begin // dummy
      counter_nxt = 0;
   end
end

// ALU input
always @(*) begin
   case(state)
      IDLE: begin
         if (valid) alu_in_nxt = in_B;
         else       alu_in_nxt = 0;
      end
   OUT: alu_in_nxt = 0;
   default: alu_in_nxt = alu_in;
endcase
  end

  // Todo 3: ALU output
  always @(*) begin
     case ( state )
        MULT: begin
           if ( shreg[0] == 1'b1 ) begin
              alu_out = alu_in + shreg[63:32];
           end
           else begin
              alu_out = { 1'b0, shreg[63:32] };
           end
        end
        DIV: begin
           if ( shreg[63:32] >= alu_in ) begin
              alu_out = shreg[63:32] - alu_in;
           end
           else begin
              alu_out = shreg[63:32];
           end
        end
        default: begin
           alu_out = 0;
        end
     endcase
  end

  // Todo 4: Shift register
  always @(*) begin
     case(state)
        MULT: begin
           shreg_nxt = { alu_out, shreg[31:1] };
        end // case MULT
        DIV: begin
           /*===========================================================
           // Modified from that provided in midterm...
           // consider 19 div 5, shreg is 8-bit, ALU is 4-bit
           //
           //  iteration                      divisor          shreg
           // #0 init                          0101         0010_0110
           // #1 not enough, shift, write 0    0101         0100_1100
           // #2 not enough, shift, write 0    0101         1001_1000
           // #3 sub, shift, write 1           0101         1001_0001
           // #4 sub, shift, write 1           0101         1000_0011
           // #5 shift-right the left half     0101         0100_0011
           //
           //
           //
           // We'll shift left-half when it's not the last iteration,
           // and move just the right-half when it's the last.
           //
           // This modification stems from the fact that the provided
           // solution in midterm seem not work with when
           // considering \( \frac{m}{n} \) where (n>m)...
           ===========================================================*/

          shreg_nxt = { alu_out[31:0], shreg[31:0] };

          if ( counter < 31 ) begin
             shreg_nxt = shreg_nxt << 1;
          end
          else begin
             shreg_nxt[31:0] = shreg_nxt[31:0] << 1;
          end

          shreg_nxt = shreg_nxt | (
             (shreg[63:32] >= alu_in) ? 32'b1 : 32'b0
          );

       end // case DIV
       IDLE: begin
          if ( valid == 1'b1 ) begin
             if ( mode == 1'b1 ) begin // division
                shreg_nxt = in_A << 1;
             end
             else begin// multiplication/dummy
                shreg_nxt = in_A;
             end
          end
          else begin // dummy
             shreg_nxt = 0;
          end
       end // case IDLE
       default: begin // dummy
       shreg_nxt = 0;
    end
 endcase
end

// Todo: Sequential always block
always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      state     <= IDLE;
      shreg     <= 63'b0;
      alu_in    <= 32'b0;
      counter   <= 5'b0;
   end
   else begin
      state        <= state_nxt;
      alu_in       <= alu_in_nxt;
      counter      <= counter_nxt;
      shreg        <= shreg_nxt;
   end
end

endmodule

