/*
##### OP CODES ##### 
aluOp    7'b0110011
aluOpImm 7'b0010011
luiOp    7'b0110111
jalOp    7'b1101111
jalrOp   7'b1100111
branchOp 7'b1100011
loadOp   7'b0000011
storeOp  7'b0100011
auipcOp  7'b0010111

##### R-Type funct3 #####
add  = 3'b000
sub  = 3'b000
sll  = 3'b001
slt  = 3'b010
sltu = 3'b011
xor  = 3'b100
srl  = 3'b101
sra  = 3'b101
or   = 3'b110
and  = 3'b111

##### I-Type funct3 ##### 
addi  = 3'b000
slti  = 3'b010
sltiu = 3'b011
xori  = 3'b100
ori   = 3'b110
andi  = 3'b111
slli  = 3'b001
srli  = 3'b101
srai  = 3'b101

##### B-Type funct3 ##### 
beq  = 3'b000
bne  = 3'b001
blt  = 3'b100
bge  = 3'b101
bltu = 3'b110
bgeu = 3'b111
*/

module decode(input [31:0] inst,
		output [31:0] imm,
		output [4:0] rs1,
		output [4:0] rs2,
		output [4:0] rd,
		output [3:0] alu_func,
		output [2:0] br_func,
		output [1:0] wrd_sel,
		output [1:0] pc_sel,
		output [1:0] mem_rw,
		output regfile_we,
		output b_sel);

	wire [6:0] opcode = inst[6:0];
	wire [2:0] funct3 = inst[14:12];
	wire [6:0] funct7 = inst[31:25];
	wire [31:0] immI  = $signed(inst[31:20]); 
	wire [31:0] immS  = $signed({inst[31:25], inst[11:7]}); 
	wire [31:0] immB  = $signed({inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});
	wire [31:0] immU  = {inst[31:12], 12'b0};
	wire [31:0] immJ  = $signed({inst[31], inst[19:12], inst[20], inst[30:21], 1'b0});
	assign rs1 = inst[19:15];
	assign rs2 = inst[24:20];
	assign rd  = inst[11:7];
	
	function [31:0] immVal(input[6:0] opcode);
		case(opcode)
			7'b0010011: immVal = $signed(inst[31:20]);
			7'b0110111: immVal = {inst[31:12], 12'b0};
			7'b1101111: immVal = $signed({inst[31], inst[19:12], inst[20], inst[30:21], 1'b0});
			7'b0100011: immVal = $signed({inst[31:25], inst[11:7]});
			7'b1100011: immVal = $signed({inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});
			default   : immVal = 32'b0;
		endcase
	endfunction
			 
	assign imm = immVal(opcode);

	/* ALU Functions
	/  add     4'b0000
	/  sub     4'b0001
	/  and     4'b0010
	/  or      4'b0011
	/  xor     4'b0100
	/  slt     4'b0101
	/  sltu    4'b0110
	/  sll     4'b0111
	/  srl     4'b1000
	/  sra     4'b1001
	/  invalid 4'b1111
	*/ 
	function [3:0] aluFunc(input[6:0] opcode, input[2:0] funct3, input[6:0] funct7);
		case(opcode)
			// R-Type Instructions
			7'b0110011: begin
				case(funct3)
					3'b000: begin
						case(funct7)
							7'b0000000: aluFunc = 4'b0000;
							7'b0100000: aluFunc = 4'b0001; 
							default:    aluFunc = 4'b1111;
						endcase
						end
					3'b001: aluFunc = 4'b0111; 
					3'b010: aluFunc = 4'b0101; 
					3'b011: aluFunc = 4'b0110; 
					3'b100: aluFunc = 4'b0100; 
					3'b101: begin
						case(funct7)
							7'b0000000: aluFunc = 4'b1000;
							7'b0100000: aluFunc = 4'b1001;
							default:    aluFunc = 4'b1111;
						endcase
						end
					3'b110: aluFunc = 4'b0011; 
					3'b111: aluFunc = 4'b0010; 
					default: aluFunc = 4'b1111;
				endcase
			end
			// I-Type Instructions
			7'b0010011: begin
				case(funct3)
					3'b000: aluFunc = 4'b0000;
					3'b010: aluFunc = 4'b0101;
					3'b011: aluFunc = 4'b0110;
					3'b100: aluFunc = 4'b0100;
					3'b110: aluFunc = 4'b0011;
					3'b111: aluFunc = 4'b0010;
					3'b001: aluFunc = 4'b0111;
					3'b101: begin
						case(funct7)
							7'b0000000: aluFunc = 4'b1000;
							7'b0100000: aluFunc = 4'b1001;
							default: aluFunc = 4'b1111;
						endcase
					end
					default: aluFunc = 4'b1111;
				endcase
			end
			//LW
			7'b0000011: aluFunc = 4'b0000;
			//SW
			7'b0100011: aluFunc = 4'b0000;
			//JALR
			7'b1100111: aluFunc = 4'b0000;
			default: aluFunc = 4'b1111;
		endcase
	endfunction
	
	assign alu_func = aluFunc(opcode, funct3, funct7);

	/* Branch Functions
	/  beq     3'b000
	/  bne     3'b001
	/  blt     3'b010
	/  bge     3'b011
	/  bltu    3'b100
	/  bgeu    3'b101
	/  invalid 3'b111
	*/
	function [2:0] brFunc(input[6:0] opcode, input[2:0] funct3);
		case(opcode)
			7'b1100011: begin
				case(funct3)
					3'b000: brFunc  = 3'b000;
					3'b001: brFunc  = 3'b001;
					3'b100: brFunc  = 3'b010;
					3'b101: brFunc  = 3'b011;
					3'b110: brFunc  = 3'b100;
					3'b111: brFunc  = 3'b101;
					default: brFunc = 3'b111; 
				endcase
			end
			default: brFunc = 3'b111;
		endcase
	endfunction

	assign br_func = brFunc(opcode, funct3);

	/* Word Select
	/  ra  2'b00
	/  alu 2'b01
	/  mem 2'b10
	*/
	function [1:0] wrdSelFunc(input [6:0] opcode); 
		case(opcode)
			7'b1101111: wrdSelFunc = 2'b00;
			7'b1100111: wrdSelFunc = 2'b00;
			7'b0000011: wrdSelFunc = 2'b10;
			default:    wrdSelFunc = 2'b01;
		endcase
	endfunction
	
	assign wrd_sel = wrdSelFunc(opcode);	

	/* PC Select
	/  next 2'b00
	/  br   2'b01
	/  jal  2'b10
	/  jalr 2'b11
	*/
	function [1:0] pcSelFunc(input [6:0] opcode);
		case(opcode)
			7'b1100011: pcSelFunc = 2'b01;
			7'b1101111: pcSelFunc = 2'b10;
			7'b1100111: pcSelFunc = 2'b11;
			default:    pcSelFunc = 2'b00;
		endcase
	endfunction

	assign pc_sel = pcSelFunc(opcode);

	function [1:0] memRWFunc(input [6:0] opcode);
		case(opcode)
			7'b0000011: memRWFunc = 2'b01;
			7'b0100011: memRWFunc = 2'b10;
			default :   memRWFunc = 2'b00;
		endcase
	endfunction

	assign mem_rw = memRWFunc(opcode);
	
	assign regfile_we = opcode == 7'b1100011 || opcode == 7'b0100011 ? 1'b0 : 1'b1;

	assign b_sel = opcode == 7'b0110011 || opcode == 7'b0100011 || opcode == 7'b1100011 ? 1'b0 : 1'b1;

endmodule
