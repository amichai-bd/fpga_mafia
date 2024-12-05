`include "macros.vh"
module i_cache_tb;
import ifu_pkg::*;

// ./build.py -dut ifu -hw -sim -top i_cache_tb

i_cache i_cache
(   
    .clk(),
    .rst(),
    .pcQ100H(),
    .i_mem2cache_rsp(),
    .cache2i_mem_req(),
    .cache2core_rsp()
);

initial begin
    $finish;
end

endmodule