
//File Name: fifo_arbiter.sv
//Description: The fifo_arbiter module.
`include "macros.sv"

module fifo_arb
 import router_pkg::*;
 #(parameter DATA_WIDTH = 32,
				parameter NUM_CLIENTS = 4)
(
input  logic clk,
input  logic rst,
//==============================
//  New alloc from neighber Tiles
//==============================
// Input
input  logic             valid_alloc_req0, // can rewrite more generic with logic [NUM_CLIENTS-1:0] valid_alloc_req;
input  logic             valid_alloc_req1, // 
input  logic             valid_alloc_req2,
input  logic             valid_alloc_req3,
input var t_tile_trans      alloc_req0,
input var t_tile_trans      alloc_req1,
input var t_tile_trans      alloc_req2,
input var t_tile_trans      alloc_req3,
// Output
output logic             out_ready_fifo0,
output logic             out_ready_fifo1,
output logic             out_ready_fifo2,
output logic             out_ready_fifo3,
//==============================
//  Output to next north tile
//==============================
// Output
output var t_tile_trans     winner_req,
// Input
input  logic             in_ready_arb_fifo0, // used by arb to choose winner
input  logic             in_ready_arb_fifo1,
input  logic             in_ready_arb_fifo2,
input  logic             in_ready_arb_fifo3
);
t_tile_trans din[3:0];
t_tile_trans dout_fifo[3:0];

logic [3:0] push;
logic [3:0] full;
logic [3:0] empty;
logic [1:0] src_num;;
always_comb begin
din[0] = alloc_req0;
din[1] = alloc_req1;
din[2] = alloc_req2;
din[3] = alloc_req3;
push[0] = valid_alloc_req0;
push[1] = valid_alloc_req1;
push[2] = valid_alloc_req2;
push[3] = valid_alloc_req3;
out_ready_fifo0 = !full[0];
out_ready_fifo1 = !full[1];
out_ready_fifo2 = !full[2];
out_ready_fifo3 = !full[3];
end
//*************************** NOT GOOD SIGNALS - CORRECT IT*************************** 
	genvar i;
	generate
		for (i=0; i<NUM_CLIENTS; i=i+1)begin
			fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
				inside_fifo (.clk(clk),
					     .rst(rst),
					     .push(push[i]), // valid_alloc_req#
					     .push_data(din[i]),// alloc_req#
					     .pop(fifo_pop[i]),//arbiter chose this fifo to pop.
					     .pop_data(dout_fifo[i]), // arbiter input
					     .full(full[i]),//out_ready_fifo#
					     .empty(empty[i]));// indication to arbiter that the fifo is empty
		end
	endgenerate

arbiter #(.NUM_CLIENTS(4),
.DATA_WIDTH(32))
arb 
	(
	.clk(clk),
	.rst(rst),
	.req(empty[3:0]), // input from each fifo - not empty indication, valid candidate.
	.din(dout_fifo[3:0]), // input from each fifo, pop_data_arb candidate.
	.src_num(src_num[1:0]), // the arbiter winner use to fifo pop.        
	.valid(valid_arb_winner),
	.dout(winner_req)
	);
`DECODER(full,src_num,valid_arb_winner) //- the arbiter should do that - no?

endmodule
