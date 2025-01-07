`include "cpuc_macros.vh"

module cpuc_tb;
import cpuc_package::*;

logic             clk;
logic             rst;
var t_reg_outputs reg_outputs;

initial begin :clock_generation
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end
end

cpuc cpuc
(
    .clk(clk),
    .rst(rst),
    .reg_outputs(reg_outputs)
);


initial begin
    #10
    $finish;
end

parameter V_TIMEOUT = 10000;
initial begin
    #V_TIMEOUT
    $display("timeout reached");
    $finish;
end

endmodule


