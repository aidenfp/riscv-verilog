`include "alu.v"
`include "br_alu.v"
`include "decode.v"
`include "reg_file.v"

module processor(
                 input          clk,
                 input          rst_n,
                 input  [4:0]   reg_addr,
                 output [31:0]  current_pc,
                 output [31:0]  reg_val
                );

    /* PROGRAM COUNTER */
    reg [31:0] pc;

    /* SIGNALS AND BUSES */ 
    wire [31:0] inst, rd1, rd2, imm, alu_b, br_target, alu_out, mem_out, rf_wd, next_pc;
    wire [4:0]  rs1, rs2, rf_wa; 
    wire [3:0]  alu_func;
    wire [2:0]  br_func;
    wire [1:0]  wd_sel, pc_sel, mem_rw;
    wire        rf_we, b_sel, br_out;

    function [31:0] writeData(input [1:0] wd_sel);
        case(wd_sel)
            2'b00: writeData = pc + 4;
            2'b01: writeData = alu_out;
            2'b10: writeData = mem_out;
        endcase
    endfunction
    assign rf_wd = writeData(wd_sel);

    function [31:0] aluB(input b_sel);
        case(b_sel)
            1'b0: aluB = rd2;
            1'b1: aluB = imm;
        endcase
    endfunction
    assign alu_b = aluB(b_sel);

    function [31:0] nextPC(input [1:0] pc_sel);
        case(pc_sel)
            2'b00: nextPC = pc + 4;
            2'b01: nextPC = pc + imm;
            2'b10: nextPC = (rd1 + imm) & ~32'b1;
            2'b11: nextPC = br_out == 1'b1 ? pc + imm : pc + 4;  
        endcase
    endfunction
    assign next_pc = nextPC(pc_sel);

    /* MODULES */
    alu alu1    (
                .a          (rd1),
                .b          (alu_b),
                .func       (alu_func),
                .out        (alu_out)
                );

    br_alu br_alu1(
                .a          (rd1),
                .b          (alu_b),
                .func       (br_func),
                .out        (br_out)
                );

    decode decode1(
                .inst       (inst),
                .imm        (imm),
                .rs1        (rs1),
                .rs2        (rs2),
                .rd         (rf_wa),
                .alu_func   (alu_func),
                .br_func    (br_func),
                .wd_sel     (wd_sel),
                .pc_sel     (pc_sel),
                .mem_rw     (mem_rw),
                .rf_we      (rf_we),
                .b_sel      (b_sel)
                );

    reg_file reg_file1(
                .clk        (clk),
                .rst_n      (rst_n),
                .ra1        (rs1),
                .ra2        (rs2),
                .wa         (rf_wa),
                .wd         (rf_wd),
                .w_en       (rf_we),
                .rd1        (rd1),
                .rd2        (rd2)
                );

    always @(posedge clk) begin
        if (!rst_n)
            pc <= 0;
        else
            pc <= next_pc;
    end
endmodule
