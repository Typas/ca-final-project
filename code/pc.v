// PC control unit


module pc_control(clk,
				  rst_n,
				  PC,
				  PC_nxt,
				  imm,
				  branch);
	
	input 		    clk, rst_n, branch	;
	input 	[31:0]	PC, imm				;
	output 	[31:0]	PC_nxt				;
	reg 	[31:0]	PC_nxt				;
	reg		[31:0]  IMM					;

	always @(*) begin
		IMM = imm << 1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			PC_nxt <= 32'h00010000;
		end
		else begin
			PC_nxt <= branch?(PC+IMM):(PC+4);
		end
	end
endmodule
