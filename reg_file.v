module reg_file(input clk,
		input rst_n,
		input [4:0] ra1,
	       	input [4:0] ra2,
		input [4:0] wa,
		input [31:0] wd,
		input w_en,
		output [31:0] rd1,
		output [31:0] rd2);
	
	reg [31:0] x_registers [31:0];

	function [31:0] getRegisterVal(input [4:0] reg_ind);
		getRegisterVal = x_registers[reg_ind];
	endfunction

	assign rd1 = getRegisterVal(ra1);
	assign rd2 = getRegisterVal(ra2);	
	
    integer i;
	always @ (posedge clk)
		if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                x_registers[i] <= 0;
        end 
        else if (wa != 0 && w_en == 1'b1)
			x_registers[wa] <= wd;
	
endmodule
