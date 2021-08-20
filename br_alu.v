/* BRANCH FUNCTIONS
/  beq     3'b000
/  bne     3'b001
/  blt     3'b010
/  bge     3'b011
/  bltu    3'b100
/  bgeu    3'b101
/  invalid 3'b111
*/
module br_alu(	input [31:0] a,
		input [31:0] b,
		input [2:0] func,
		output out);
		
	function calcOut(input [31:0] a,
			 input [31:0] b,
			 input [31:0] func);
		case(func)
			3'b000:  calcOut = a == b;
			3'b001:  calcOut = a != b;
			3'b010:  calcOut = $signed(a) < $signed(b);
			3'b011:  calcOut = $signed(a) >= $signed(b);
			3'b100:  calcOut = a < b;
			3'b101:  calcOut = a >= b;
			default: calcOut = 1'bx;
		endcase
	endfunction
	
	assign out = calcOut(a, b, func); 
endmodule
