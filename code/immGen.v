// Immediate Generator unit

module immGen(instruction, immediate);
    input [31:0]  instruction;
    output [31:0] immediate;

    wire [6:0]    opcode;
    reg [31:0]    immediate;

    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0010111, 7'b0110111: immediate = {instruction[31:12], 12'b0}; // auipc, lui
            7'b0100011: immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]}; // save functions
            7'b1100111, 7'b0000011, 7'b0010011: immediate = {{21{instruction[31]}}, instruction[30:20]}; // jalr, load functions, immediate funtions 
            7'b1101111: immediate = {{12{instruction[31]}}, instruction[19:12],instruction[20], instruction[30:21], 1'b0}; // jal
            default: immediate = 32'b0;
        endcase
    end
endmodule
