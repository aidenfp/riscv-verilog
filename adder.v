module add(input [31:0] a, input [31:0] b, output [32:0] out);
	assign out = a + b;
endmodule

module cla8(input [7:0] a,
		input [7:0] b,
		input cin,
		output [8:0] out);
	
	wire [7:0] g, p;
	assign g = a & b;
	assign p = a | b;
	
	wire [3:0] g1, p1;
	genvar i;
	generate
	for (i = 0; i < 4; i = i + 1) begin
		assign g1[i] = g[2*i + 1] | (p[2*i + 1] & g[2*i]); 
		assign p1[i] = p[2*i + 1] & p[2*i];
	end
	endgenerate
	
	wire [1:0] g2, p2;
	genvar j;
	generate
	for (j = 0; j < 2; j = j + 1) begin
		assign g2[j] = g1[2*j + 1] | (p1[2*j + 1] & g1[2*j]);
		assign p2[j] = p1[2*j + 1] & p1[2*j];
	end
	endgenerate

	wire g3, p3;
	assign g3 = g2[1] | (p2[1] & g2[0]);
	assign p3 = p2[1] & p2[0];
	
	wire [8:0] c;
	assign c[0] = cin;
	assign c[1] = g[0] | (p[0] & cin);
	assign c[2] = g1[0] | (p1[0] & cin);
	assign c[3]= g[2] | (p[2] & c[2]);
	assign c[4] = g2[0] | (p2[0] & cin);
	assign c[5] = g[4] | (p[4] & c[4]);
	assign c[6] = g1[2] | (p1[2] & c[4]);
	assign c[7] = g[6] | (p[6] & c[6]);
	assign c[8] = g3 | (p3 & cin);
	
	genvar k;
	generate
	for (k = 0; k < 8; k = k + 1)
		assign out[k] = a[k] ^ b[k] ^ c[k];
	endgenerate

	assign out[8] = c[8];

endmodule

module cla32(input [31:0] a,
		input[31:0] b,
		input cin,
		output [32:0] out);
	
	cla8 cla1(.a(a[7:0]), .b(b[7:0]), .cin(cin));
	cla8 cla2(.a(a[15:8]), .b(b[15:8]), .cin(cla1.out[8]));
	cla8 cla3(.a(a[23:16]), .b(b[23:16]), .cin(cla2.out[8]));
	cla8 cla4(.a(a[31:24]), .b(b[31:24]), .cin(cla3.out[8]));

	assign out = {cla4.out, cla3.out[7:0], cla2.out[7:0], cla1.out[7:0]};
endmodule

/*module tb;
	reg [31:0] a, b;
	wire cin = 0;
	reg clk;
	wire check;
	reg passed;

	assign check = sum.out == add.out;
	always @ (posedge clk) begin
		$display("a=%h, b=%h, cla=%h, check=%b", a, b, sum.out, check);
		a <= $random;
		b <= $random;
		passed <= check == 0 ? 0 : passed;
	end	
	
	always #1 clk <= ~clk;

	cla32 sum(.a(a), .b(b), .cin(cin));
	add add(.a(a), .b(b));

	initial begin
		clk <= 0;
		passed <= 1;
		a <= $random;
		b <= $random;
		#200
		$display("passed=%b", passed);
		$finish;
	end	
endmodule*/
