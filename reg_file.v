module reg_file(input [4:0] ra1, input [4:0] ra2,
		input [4:0] wa,
		input [31:0] wd,
		input w_en,
		output [31:0] rd1,
		output [31:0] rd2);
	
	reg [31:0] x_registers [31:0];
	
	function [31:0] getRegisterVal(input [4:0] regIndex);
		getRegisterVal = x_registers[regIndex];
	endfunction

	assign rd1 = getRegisterVal(ra1);
	assign rd2 = getRegisterVal(ra2);	
	
	always @ (posedge w_en)
		if (wa != 0)
			x_registers[wa] <= wd;
	
endmodule
