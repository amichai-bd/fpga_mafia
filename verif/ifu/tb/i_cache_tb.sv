`include "macros.vh"
module i_cache_tb;
import ifu_pkg::*;

// ./build.py -dut ifu -hw -sim -top i_cache_tb

logic                  clk;
logic                  rst;
logic [31:0]           pcQ100H;
var t_i_mem2cache_rsp  i_mem2cache_rsp;
var t_cache2i_mem_req  cache2i_mem_req;
var t_cache2core_rsp   cache2core_rsp;


// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
     rst = 1'b1;
#100 rst = 1'b0;
end: reset_gen

i_cache i_cache
(   
    .clk(clk),
    .rst(rst),
    .pcQ100H(pcQ100H),
    .i_mem2cache_rsp(i_mem2cache_rsp),
    .cache2i_mem_req(cache2i_mem_req),
    .cache2core_rsp(cache2core_rsp)
);

initial begin : load_data_to_cache
    i_cache.data_arr[0] = 128'h01000000_02000000_03000000_04000000; 
    i_cache.data_arr[1] = 128'h11000000_12000000_13000000_14000000; 
    i_cache.data_arr[2] = 128'h21000000_22000000_23000000_24000000; 
    i_cache.data_arr[3] = 128'h31000000_32000000_33000000_34000000; 
    i_cache.data_arr[4] = 128'h41000000_42000000_43000000_44000000; 
    i_cache.data_arr[5] = 128'h51000000_52000000_53000000_54000000; 
    i_cache.data_arr[6] = 128'h61000000_62000000_63000000_64000000; 
    i_cache.data_arr[7] = 128'h71000000_72000000_73000000_74000000; 
end



initial begin: add_tag
    i_cache.tag_address_arr[0] = 'h33;
    i_cache.tag_address_arr[1] = 'h44;
    i_cache.tag_address_arr[2] = 'h55;
    i_cache.tag_address_arr[3] = 'h66;
    i_cache.tag_address_arr[4] = 'h77;

end

integer i;
initial begin: valid_bit_enable
    for(i=0; i < 5; i++) begin
        i_cache.tag_valid_arr[i] = 1'b1;
    end
end
initial begin
    #100
    
    pcQ100H[31:4] = 'h33;
    pcQ100H[3:2]  = 2'b00;
    #10;
    @(posedge clk);

    pcQ100H[31:4] = 'h33;
    pcQ100H[3:2]  = 2'b01;
    #10;
    @(posedge clk);

    pcQ100H[31:4] = 'h33;
    pcQ100H[3:2]  = 2'b10;
    #10;
    @(posedge clk);

    pcQ100H[31:4] = 'h33;
    pcQ100H[3:2]  = 2'b11;
    #10;
    @(posedge clk);

    pcQ100H[31:4] = 'h66;
    pcQ100H[3:2]  = 2'b10;
    #10;
    @(posedge clk);

    pcQ100H[31:4] = 'h90;
    pcQ100H[3:2]  = 2'b10;
    #20;
    @(posedge clk);

    $finish;
end

parameter V_TIMEOUT = 10000;
initial begin: timeout_check
    #V_TIMEOUT
    $finish;
end

endmodule