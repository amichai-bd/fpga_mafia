module alu_oz_tb;
import sc_core_oz_pkg::*;
logic clk;
logic rst;
var m_alu_ctrl alu_ctrl;
logic [4:0] reg_dest;
logic [DATA_WIDTH-1:0] result;

sc_core_oz_alu sc_core_oz_alu_tb
(
    .clk,
    .rst,
    .alu_ctrl(alu_ctrl),
    .reg_dest(reg_dest),
    .result(result)
);

initial begin 
    alu_ctrl.reg_src1 = 32'd3;
    alu_ctrl.reg_src2 = 32'd5;
    alu_ctrl.op = ADD;

    #20 

    alu_ctrl.op = SUB;

    #20

    alu_ctrl.reg_src1 = 32'hf0000000;
    alu_ctrl.reg_src2 = 32'd2;
    alu_ctrl.op = SLL;

    #20

    alu_ctrl.op = SLT;

    #20

    alu_ctrl.op = SLTU;

    #20

    alu_ctrl.op = XOR;

    #20

    alu_ctrl.op = SRL;

    #20

    alu_ctrl.op = SRA;

    #20

    alu_ctrl.op = OR;

    #20

    alu_ctrl.op = AND;

    #20

    $finish;
end

parameter TIME_OUT = 10000;

initial begin 
    #TIME_OUT
    $display ("timeout reached");
    $finish;
end


endmodule