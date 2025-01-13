module fibonacci_st_tb;
import fibonacci_pkg::*;


    logic        clk;
    logic        rst;
    logic        start;
    logic [2:0]  term;
    var t_output_interface output_interface;

    // used for better debug
    logic       valid;
    logic [7:0] result;

    // clock generation
    initial begin
        forever begin
            #5 clk = 0;
            #5 clk = 1;
        end
    end


    fibonacci_st fibonacci_st
    (
        .clk(clk),
        .rst(rst),
        .start(start),
        .term(term),
        .output_interface(output_interface)
    );

    initial begin: main_tb
        #1
        rst   = 1;
        start = 0;
        term = 3'h7; 
        #10
        @(posedge clk)

        rst   = 0;
        #20
        @(posedge clk)
        
        start = 1;
        #100
        @(posedge clk)

        $finish;

    end
    
    parameter V_TIMEOUT = 1000;
    initial begin:timeout_detection
        #V_TIMEOUT
        $display("timeout reached");
        $finish;        
    end

    assign valid  = output_interface.valid;
    assign result = output_interface.result;

endmodule