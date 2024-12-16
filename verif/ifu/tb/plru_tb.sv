// PLRU test bench
// ./build.py -dut ifu -hw -sim -top plru_tb -clean

`include "macros.vh"

module plru_tb;
import ifu_pkg::*;

logic                         clk;
logic                         rst;
var t_cache_ctrl2_plru        cache_ctrl2_plru;    
logic                         cache_miss;  
logic  [$clog2(WAYS_NUM)-1:0] hit_cl;      // in case of last hit we have to update as most recently used (MRU) 
logic [$clog2(WAYS_NUM)-1:0]  evicted_cl;   // the evicted cache line in case of miss

initial begin: clock_generator
    forever begin
        #5 clk = 0;
        #5 clk = 1;    
    end
end

plru  plru
(

    .clk(clk),
    .rst(rst),
    .cache_ctrl2_plru(cache_ctrl2_plru),    
    .cache_miss(cache_miss),  
    .hit_cl(hit_cl),      
    .evicted_cl(evicted_cl)  
);

initial begin: main_tb
    rst = 1;
    #20
    @(posedge clk);

    // check tree when cache is not full and we have miss
    rst = 0;
    cache_ctrl2_plru.update_tree    = 1;
    cache_ctrl2_plru.update_counter = 1;
    cache_miss                      = 1;
    hit_cl                          = 0;

    #200
    @(posedge clk)

    // cache is full and we have hit
    cache_miss = 0;
    hit_cl     = 9;
    #60    // cache hit of the same line
    @(posedge clk)

    hit_cl     = 2;
    #20   
    @(posedge clk)

    hit_cl     = 6;
    #20    
    @(posedge clk)

    hit_cl     = 7;
    #20    
    @(posedge clk)

    // cache is full and we have hit
    cache_miss = 1;
    #10
    @(posedge clk)

    #10

    $finish;

end


parameter V_TIMEOUT = 10000;
initial begin: time_out_detection
    #V_TIMEOUT
    $finish;
end

initial begin: monitor
    $monitor("time = %t | cache miss = %h\t | evicted cache line is = %h\t",$time, cache_miss, evicted_cl);
end

endmodule