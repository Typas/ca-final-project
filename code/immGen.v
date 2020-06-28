// Immediate Generator unit

module immGen(inst, imm);
	input	[31:0] 	inst;
	output 	[31:0] 	imm;

	wire 	[6:0] 	opcode;
	reg 	[31:0]	imm;

	assign opcode = inst[6:0];

	always @(*) begin
		case (opcode)
			7'b0010111, 7'b0110111: imm = {inst[31:12], 12'bz}; // auipc, lui
			7'b0100011: imm = {20'bz, inst[31:25], inst[11:7]}; // save functions
			7'b1100111, 7'b0000011, 7'b0010011: imm = {20'bz, inst[31:20]}; // jalr, load functions, immediate funtions 
			7'b1101111: imm = {12'bz, inst[31], inst[19:12],inst[20], inst[30:21], 1'bz}; // jal
			default: imm = 32'bz;
		endcase
	end
endmodule

	
