`include "macros.vh"

module PS2_cntrl {
    input logic data;
    input logic clk;
    input logic rst;
    input logic output_enable;
    output logic [7:0] paral_data;
    output logic serial_output;
}

logic [10:0] curr_data;
logic [10:0] next_reg;
assign next_reg = {curr_data [9:0],data};

 MAFIA_ASYNC_RST_VAL_DFF(curr_data,next_reg,clk,output_enable,rst,0);

logic [3:0] clk_counter = 0;

always_ff @( Posedge clk or negedege rst ) begin 
    if(!rst)begin
        counter <=0;
    end
    else begin
        counter ++
        if(counter == 12)
          counter <= 1;
    end
end

    

if(counter == 11 && curr_data[0]) begin
    MAFIA_DFF(paral_data,curr_data[3:9],clk)
end

end