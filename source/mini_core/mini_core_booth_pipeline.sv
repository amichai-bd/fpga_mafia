//parameter WIDTH = 8;
//typedef struct packed {
   // logic [2*WIDTH:0] AQQ_0;
   // logic [WIDTH-1:0] Mu;
//} stage_mul_inp_t;



// FIXME - IMPLEMENT A SYSTEM FOR X BIT * Y BIT. PREMATURE ALGORITHM BREAK TO DECREASE PIPE STAGES 
`include "macros.vh"
module mini_core_booth_pipeline
import mini_core_pkg::*;
(
    input logic                  clk,
    input logic                  rst,
    input logic                  [WIDTH-1:0] Mu,  
    input logic                  [WIDTH-1:0] Qu,  
    output logic                 [2*WIDTH-1:0] out 
);

    logic                       start_mul;
    stage_mul_inp_t stage_inputs[0:WIDTH];


    // Initial stage setup
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            stage_inputs[0].AQQ_0 <= 0;
            stage_inputs[0].Mu     <= 0;
        end else begin
            stage_inputs[0].AQQ_0 <= {{(WIDTH){1'b0}}, Qu, 1'b0};
            stage_inputs[0].Mu     <= Mu ;
        end
    end
    
    // Booth algorithm pipeline
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < WIDTH; i++) begin
                stage_inputs[i+1].AQQ_0 <=  0;
                stage_inputs[i+1].Mu     <= 0;
            end
        end else begin
            for (int i = 0; i < WIDTH; i++) begin // Booth algorithm implementation
                stage_inputs[i+1].Mu <= stage_inputs[i].Mu;
                case (stage_inputs[i].AQQ_0[1:0])
                    2'b01: begin
                        stage_inputs[i+1].AQQ_0[2*WIDTH:WIDTH+1] <= (stage_inputs[i].AQQ_0[2*WIDTH:WIDTH+1] + stage_inputs[i].Mu) >>> 1;
                    end
                    2'b10: begin
                        stage_inputs[i+1].AQQ_0[2*WIDTH:WIDTH+1] <= (stage_inputs[i].AQQ_0[2*WIDTH:WIDTH+1] - stage_inputs[i].Mu) >>> 1;
                    end 
                    default:
                        stage_inputs[i+1].AQQ_0[2*WIDTH:WIDTH+1] <= (stage_inputs[i].AQQ_0[2*WIDTH:WIDTH+1]) >>> 1;
                endcase
            end
        end
    end
    
    assign out = stage_inputs[WIDTH].AQQ_0[2*WIDTH:1];
endmodule
