// PC control unit
module PC (Pc, Pc_nxt, Imm_In, Rs_data1, Branch, Jalr);

    input           Branch, Jal;
    input [31:0]    Pc, Imm_In, Rs_data1;
    output [31:0]   Pc_nxt;

    wire [31:0]     imm;

    assign imm = Imm_In << 1;
    assign Pc_nxt = Branch?((Jalr?Rs_data1:Pc)+imm):(Pc+4);

endmodule

module PC_AND(Branch, Zero, Is_Branch);
    input Branch;
    input Zero;
    output Is_Branch;

    assign Is_Branch = Branch & Zero;

endmodule // pc_and
