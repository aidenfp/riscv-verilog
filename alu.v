/* ALU FUNCTIONS */
// Add  = 4'h0
// Sub  = 4'h1
// And  = 4'h2
// Or   = 4'h3
// Xor  = 4'h4
// Slt  = 4'h5
// Sltu = 4'h6
// Sll  = 4'h7
// Srl  = 4'h8
// Sra  = 4'h9
module alu(	input [31:0] a,
		input [31:0] b,
		input [3:0] func,
		output [31:0] out);

	function [31:0] aluOut(	input [31:0] a,
				input [31:0] b,
				input [3:0] func);
		case(func)
			4'b0000: aluOut = $signed(a) + $signed(b);
			4'b0001: aluOut = $signed(a) - $signed(b);
			4'b0010: aluOut = a & b;
			4'b0011: aluOut = a | b;
			4'b0100: aluOut = a ^ b;
			4'b0101: aluOut = $signed(a) < $signed(b);
			4'b0110: aluOut = a < b;
			4'b0111: aluOut = a << b[4:0];
			4'b1000: aluOut = a >> b[4:0];
			4'b1001: aluOut = a >>> b[4:0];
			default: aluOut = 32'hxxxxxxxx;
		endcase
	endfunction

	assign out = aluOut(a, b, func);
endmodule
