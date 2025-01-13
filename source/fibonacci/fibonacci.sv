`include "macros.vh"

module fibonacci
import fibonacci_pkg::*;
(
    input logic        clk,
    input logic        rst,
    input logic [2:0]  term,
    output var t_output_interface output_interface
);

  logic [DATA_WIDTH-1:0] fib_series [0:7];
  logic [3:0] counter;

  integer i;
  always_ff @(posedge clk) begin
        if(rst) begin
            for(i=2; i<8;i++) begin
                fib_series[0] <= 8'h1;
                fib_series[1] <= 8'h1;
                fib_series[i] <= 8'h0;
            end
            counter <= 4'h2;
            output_interface.valid  <= 0;
            output_interface.result <= 0;    
        end
        else begin
            if(term == 8'h0 || term == 8'h1) begin
                output_interface.valid  <= 1;
                output_interface.result <= fib_series[term]; 
            end
            else if(counter <= term) begin
                fib_series[counter] <= fib_series[counter-1] + fib_series[counter-3'h2];
                counter <= counter + 1;
            end
            else begin
                output_interface.valid  <= 1;
                output_interface.result <= fib_series[term]; 
            end       
        end
  end  

    

endmodule