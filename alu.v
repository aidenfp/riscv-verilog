`include "adder.v"
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
 
module mux10(	input [31:0] p0,
		input [31:0] p1,
		input [31:0] p2,
		input [31:0] p3,
		input [31:0] p4,
		input [31:0] p5,	
		input [31:0] p6,
		input [31:0] p7,
		input [31:0] p8,	
		input [31:0] p9,
		input [3:0] select,
		output [31:0] out);
	wire [31:0] a, b, c, d, e, f, g, h;
	assign a = select == 0 ? p0 : p1;
	assign b = select == 2 ? p2 : p3;
	assign c = select == 4 ? p4 : p5;
	assign d = select == 6 ? p6 : p7;
	assign e = select == 8 ? p8 : p9;
	assign f = select == 0 || select == 1 ? a : b;
	assign g = select == 4 || select == 5 ? c : d;
	assign h = select == 0 || select == 1 || select == 2 || select == 3 ? f : g; 	
	
	assign out = select == 8 || select == 9 ? e : h;
endmodule
 
module cla_alu(	input [31:0] a,
		input [31:0] b,
		input [3:0] func,
		output [31:0] out);

	wire [31:0] add_sub;
	assign add_sub = func == 1 ? ~b + 1 : b;
	
	cla32 cla(.a(a), .b(add_sub), .cin(0));
		
	mux10 mux ( 	.p0(cla.out[31:0]),
			.p1(a - b),
			.p2(a & b),
			.p3(a | b),
			.p4(a ^ b),
			.p5($signed(a) < $signed(b)),
			.p6(a < b),
			.p7(a << b[4:0]),
			.p8(a >> b[4:0]),
			.p9(a >>> b[4:0]),
			.select(func));
	assign out = mux.out;

endmodule

module main;
	reg clk;
	reg [3:0] func;
	reg [31:0] a, b;
	integer i;

	alu alu(.a(a), .b(b), .func(func));

	always #5 clk <= ~clk;

	initial begin
		clk <= 0;
		func <= 4'h0;
		a <= 32'd3;
		b <= -32'h1;
		#5;
		for(i = 0; i < 10; i = i + 1) begin
			$display("func: %h, h: %h, d: %d", func, alu.out, alu.out);
			func <= func + 1;
			#5;
		end
		$finish;
	end
endmodule
