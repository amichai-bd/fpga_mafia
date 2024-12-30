//------------------------------------
// Project:   CPUC
// File name: cpuc.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: cpuc grid
//--------------------------------------

`include "cpuc_macros.vh"

module cpuc 
import cpuc_package::*;
(
    input logic clk,
    input logic rst,
    output var t_reg_outputs reg_outputs
);

// TODO - add multiplication on integers
// TODO - add FO operations
// TODO - add types of RAM's
// TODO - add constants
// TODO - add mux

//*************************************
//            GRID DESIGN
//*************************************

/*  example of the grid for registers. Number of columns are the number of registers
    and the number of rows are the number of components that can be connected to any register.

      R0 R1 R2 R3
      __ __ __ __
 R0  |__|__|__|__|
 R1  |__|__|__|__|
 R2  |__|__|__|__|
 R3  |__|__|__|__|
  +  |__|__|__|__|
 ==  |__|__|__|__|
  >  |__|__|__|__|
  *  |__|__|__|__|

*/


//*************************************
//        COMPONENTS OUTPUT
//*************************************
// TODO - follow the pattern when adding new components
logic [0:NUM_OF_REGS+NUM_OF_PC-1][DATA_WIDTH-1:0]  regs_array_output;
logic [0:NUM_OF_ADDERS-1][DATA_WIDTH-1:0]          adders_array_output;
logic [0:NUM_OF_CMP-1][DATA_WIDTH-1:0]             greaters_array_output;
logic [0:NUM_OF_EQUAL-1][DATA_WIDTH-1:0]           compares_array_output;

genvar i_regs;
generate;
    for(i_regs=0;i_regs<=NUM_OF_REGS+NUM_OF_PC;i_regs++) begin: registers // including pc
       cpuc_register cpuc_registers
       (
         .clk(clk),
         .rst(rst),
         .data_in(),
         .data_out(regs_array_output[i_regs])
       ); 
    end 
endgenerate


// cpuc adders
genvar i_adders;
generate
     for(i_adders=0;i_adders<NUM_OF_ADDERS;i_adders++) begin: adders
       cpuc_adder cpuc_adders
       (
         .data_in1(),
         .data_in2(),
         .data_out(adders_array_output[i_adders])
       ); 
    end  
endgenerate

// cpuc operator`>`
genvar i_greater;
generate
     for(i_greater=0;i_greater<NUM_OF_CMP;i_greater++) begin: is_greater_operator
       cpuc_cmp cpuc_greater
       (
         .data_in1(),
         .data_in2(),
         .data_out(greaters_array_output[i_greater])
       ); 
    end  
endgenerate

// cpuc operator `==`
genvar i_compare;
generate
     for(i_compare=0;i_compare<NUM_OF_EQUAL;i_compare++) begin: comparison_operator
       cpuc_equal cpuc_compare
       (
         .data_in1(),
         .data_in2(),
         .data_out(compares_array_output[i_compare])
       ); 
    end  
endgenerate

logic [0:NUM_OF_COMPONENTS-1][DATA_WIDTH-1:0] component_outputs ;
assign component_outputs = {regs_array_output, adders_array_output, greaters_array_output, compares_array_output};

logic [0:NUM_OF_COMPONENTS-1][0:NUM_OF_REGS+NUM_OF_PC-1][DATA_WIDTH-1:0] register_inputs_2d_grid ; // vertical (column) belongs to specific register
                                                                                                   // and contains outputs of all the components
                                                                                                   // all the columns are duplications cause the represent the registers
                                                                                                   // and all the registers gets the same data

genvar c_tri_state, i_tri_state; // each column 'c' has 'i' tri-states coming from other component outputs
generate
      for(c_tri_state=0; c_tri_state < NUM_OF_REGS+NUM_OF_PC; c_tri_state++) begin :inputs_over_all_registers
          for(i_tri_state=0; i_tri_state < NUM_OF_COMPONENTS; i_tri_state++) begin :index_over_individual_register
                cpuc_tristate
                (
                    .en(),
                    .data_in(component_outputs[NUM_OF_COMPONENTS]),
                    .data_out(register_inputs_2d_grid[i_tri_state][c_tri_state]) 
                );

          end
      end
endgenerate
// outputs of the cpu are the register values
integer i;
always_comb begin
    for (i=0;i<NUM_OF_REGS+NUM_OF_PC;i++) begin
        reg_outputs[i] = regs_array_output[i];
    end
end
endmodule
