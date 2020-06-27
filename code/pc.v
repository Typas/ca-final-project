// PC control unit


module pc_control(PC,
				  PC_nxt,
				  imm,
				  branch);
	
	input 		    branch	;
	input 	[31:0]	PC, imm				;
	output 	[31:0]	PC_nxt				;
   	wire	[31:0]  IMM					;

	assign IMM = imm << 1;
	assign PC_nxt = branch?(PC+IMM):(PC+4);

endmodule
