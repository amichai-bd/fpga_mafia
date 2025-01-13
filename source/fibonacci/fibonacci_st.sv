`include "macros.vh"
// fibonacci bases state machine design

module fibonacci_st
import fibonacci_pkg::*;
(
    input logic        clk,
    input logic        rst,
    input logic        start,
    input logic [2:0]  term,
    output var t_output_interface output_interface
);

  t_states state, next_state;

  logic [DATA_WIDTH-1:0] fib_series      [0:7];
  logic [DATA_WIDTH-1:0] next_fib_series [0:7];
  logic [2:0] counter, next_counter;

  //--------------------------------
  // ff's defines
  //--------------------------------
  always_ff @(posedge clk) begin: state_ff
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
  end 

  always_ff @(posedge clk) begin: counter_ff
        if(rst) begin
            counter <= 3'h2;
        end
        else begin
            counter <= next_counter;
        end
  end

  integer i;
  always_ff @(posedge clk) begin
        if(rst) begin
            fib_series[0] <= 8'h1;
            fib_series[1] <= 8'h1;
            for(i=2; i<8; i++) begin
                fib_series[i] <= '0;
            end
        end
        else begin
            fib_series <= next_fib_series;
        end
  end
  
  //--------------------------------
  // state machine
  //--------------------------------

  always_comb begin: state_transition
        next_state = state;
        case(state)
            IDLE: begin
                if(start) 
                    next_state = CALC;
                else     
                    next_state = IDLE;
            end
            CALC: begin
                if(counter < term) begin
                    next_state = CALC;
                end
                else begin
                    next_state = IDLE;
                end
            end
            default :next_state = IDLE;
        endcase
  end

  always_comb begin
        next_counter    = counter;
        next_fib_series = fib_series;
        case(state)
            CALC: begin
                next_counter = counter + 1;
                next_fib_series[counter] = fib_series[counter-1] + fib_series[counter-2];
            end
            default : ;
        endcase
  end

  assign output_interface.valid  = (counter == term) ? 1'b1: 1'b0;
  assign output_interface.result = (counter == term) ? fib_series[counter-1] + fib_series[counter-2] : 8'h0;

endmodule


