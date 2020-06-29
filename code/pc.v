// PC control unit
module PC (Pc, Pc_nxt, Imm_In, Branch);

    input           Branch;
    input [31:0]    Pc, Imm_In;
    output [31:0]   Pc_nxt;

    wire [31:0]     imm;

    assign imm = Imm_In << 1;
    assign Pc_nxt = Branch?(Pc+imm):(Pc+4);

endmodule

module PC_AND(Branch, Zero, Is_Branch);
    input Branch;
    input Zero;
    output Is_Branch;

    assign Is_Branch = Branch & Zero;

endmodule // pc_and
