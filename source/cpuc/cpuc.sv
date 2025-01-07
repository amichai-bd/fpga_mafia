//------------------------------------
// Project:   CPUC
// File name: cpuc.sv
// Date:      26.12.24
// Author:     
//--------------------------------------
// Description: cpuc grid
//--------------------------------------

// TODO - add multiplication on integers
// TODO - add FO operations
// TODO - add types of RAM's
// TODO - add mux


`include "cpuc_macros.vh"

module cpuc 
import cpuc_package::*;
(
    input logic clk,
    input logic rst,
    output var t_reg_outputs reg_outputs
);

//follow the pattern when adding new components
logic [NUM_OF_REGS+NUM_OF_PC-1:0][DATA_WIDTH-1:0]  regs_array_output;
logic [NUM_OF_ADDERS-1:0][DATA_WIDTH-1:0]          adders_array_output;
logic [NUM_OF_CMP-1:0][DATA_WIDTH-1:0]             greaters_array_output;
logic [NUM_OF_EQUAL-1:0][DATA_WIDTH-1:0]           compares_array_output;
logic [NUM_OF_CONSTS-1:0][DATA_WIDTH-1:0]          constants_array_output;

logic [NUM_OF_REGS+NUM_OF_PC-1:0][DATA_WIDTH-1:0]      regs_array_inputs;
logic [NUM_OF_REGS+NUM_OF_PC-1:0][1:0][DATA_WIDTH-1:0] adders_array_input;
logic [INST_LENGTH-1:0] buff_en;

//**************************************
//  Tri state connections to registers
//**************************************
logic [NUM_OF_COMPONENTS-1:0][DATA_WIDTH-1:0] component_outputs ;
//assign component_outputs = {regs_array_output, adders_array_output, greaters_array_output, compares_array_output};
assign component_outputs = {constants_array_output, compares_array_output, greaters_array_output, adders_array_output, regs_array_output};

genvar c_tri_state_reg, l_tri_state_reg; 
generate
      for(c_tri_state_reg=0; c_tri_state_reg < NUM_OF_REGS+NUM_OF_PC; c_tri_state_reg++) begin :inputs_over_all_registers_inputs
          for(l_tri_state_reg=0; l_tri_state_reg < NUM_OF_COMPONENTS; l_tri_state_reg++) begin :index_over_all_component_outputs
                cpuc_tristate cpuc_tristate_comp_to_reg
                (
                    .en(buff_en[c_tri_state_reg * NUM_OF_COMPONENTS + l_tri_state_reg]),
                    .data_in(component_outputs[l_tri_state_reg]),
                    .data_out(regs_array_inputs[c_tri_state_reg])  //connect each components to the same point
                );

          end
      end
endgenerate

//****************************************
//  Tri state connections to components
//****************************************

// adder
genvar tri_state_adder_in1, tri_state_adder_in2;
logic [DATA_WIDTH-1:0] adder_in1, adder_in2; 
generate
      for(tri_state_adder_in1=0; tri_state_adder_in1 < NUM_OF_REGS+NUM_OF_PC; tri_state_adder_in1++) begin 
                cpuc_tristate cpuc_tristate_reg_to_adder_in1
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+tri_state_adder_in1),
                    .data_in(regs_array_output[tri_state_adder_in1]),
                    .data_out(adder_in1) 
                );
          end
          for(tri_state_adder_in2=0; tri_state_adder_in2 < NUM_OF_REGS+NUM_OF_PC; tri_state_adder_in2++) begin 
                cpuc_tristate cpuc_tristate_reg_to_adder_in2
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+NUM_OF_ADDERS+tri_state_adder_in2), 
                    .data_in(regs_array_output[tri_state_adder_in2]),
                    .data_out(adder_in2) 
                );
          end
endgenerate

// greater operator '>'
genvar tri_state_greater_in1, tri_state_greater_in2;
logic [DATA_WIDTH-1:0] greater_in1, greater_in2; 
generate
      for(tri_state_greater_in1=0; tri_state_greater_in1 < NUM_OF_REGS+NUM_OF_PC; tri_state_greater_in1++) begin 
                cpuc_tristate cpuc_tristate_reg_to_greater_in1
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+2*NUM_OF_ADDERS + tri_state_greater_in1),
                    .data_in(regs_array_output[tri_state_greater_in1]),
                    .data_out(greater_in1) 
                );
          end
          for(tri_state_greater_in2=0; tri_state_greater_in2 < NUM_OF_REGS+NUM_OF_PC; tri_state_greater_in2++) begin 
                cpuc_tristate cpuc_tristate_reg_to_greater_in2
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+2*NUM_OF_ADDERS + NUM_OF_CMP+tri_state_greater_in2),
                    .data_in(regs_array_output[tri_state_greater_in2]),
                    .data_out(greater_in2) 
                );
          end
endgenerate

// equal operator '>'
genvar tri_state_equal_in1, tri_state_equal_in2;
logic [DATA_WIDTH-1:0] equal_in1, equal_in2; 
generate
      for(tri_state_equal_in1=0; tri_state_equal_in1 < NUM_OF_REGS+NUM_OF_PC; tri_state_equal_in1++) begin 
                cpuc_tristate cpuc_tristate_reg_to_equal_in1
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+2*NUM_OF_ADDERS + 2*NUM_OF_CMP+tri_state_equal_in1),
                    .data_in(regs_array_output[tri_state_equal_in1]),
                    .data_out(equal_in1) 
                );
          end
          for(tri_state_equal_in2=0; tri_state_equal_in2 < NUM_OF_REGS+NUM_OF_PC; tri_state_equal_in2++) begin 
                cpuc_tristate cpuc_tristate_reg_to_equal_in2
                (
                    .en(NUM_OF_COMPONENTS*(NUM_OF_REGS + NUM_OF_PC)+2*NUM_OF_ADDERS + 2*NUM_OF_CMP+ NUM_OF_EQUAL+tri_state_equal_in2),
                    .data_in(regs_array_output[tri_state_equal_in2]),
                    .data_out(equal_in2) 
                );
          end
endgenerate

//*********************************
//    CPUC components instances
//*********************************
genvar i_regs;
generate
    for(i_regs=0;i_regs<NUM_OF_REGS+NUM_OF_PC;i_regs++) begin: registers // including pc
       cpuc_register cpuc_registers
       (
         .clk(clk),
         .rst(rst),
         .data_in(regs_array_inputs[i_regs]),
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
         .data_in1(adder_in1),
         .data_in2(adder_in2),
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
         .data_in1(greater_in1),
         .data_in2(greater_in2),
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
         .data_in1(equal_in1),
         .data_in2(equal_in2),
         .data_out(compares_array_output[i_compare])
       ); 
    end  
endgenerate

genvar i_constants;  // TODO - allow connection of constants to arithmetic operations
generate
     for(i_constants=0;i_constants<1;i_constants++) begin: constants
       cpuc_constants cpuc_constants
       (
         .const0(constants_array_output[0]),
         .const1(constants_array_output[1]),
         .const2(constants_array_output[2]),
         .const3(constants_array_output[3])
       ); 
    end  
endgenerate


//*****************************
//        CPUC outputs
//*****************************
integer i;
always_comb begin
    reg_outputs = '0;
    for (i=0;i<NUM_OF_REGS+NUM_OF_PC;i++) begin
        reg_outputs[i] = regs_array_output[i];
    end
end

//*****************************
//     instruction memory
//*****************************
logic [$clog2(PROGRAM_SIZE)-1:0] pc, next_pc;

assign next_pc = (buff_en[NUM_OF_REGS+NUM_OF_PC-1] == 1'b1) ? regs_array_output[NUM_OF_REGS+NUM_OF_PC-1] : pc+1; // FIXME - pc can except any component data not only from regs
`CPUC_RST_DFF(pc, next_pc, clk, rst)

cpuc_single_ram 
#(.ADDR_WIDTH($clog2(PROGRAM_SIZE)), .DATA_WIDTH(INST_LENGTH))
instruction_memory
(
    .clk(clk),
    .address(pc), // degined as A
    .wren(1'b0),
    .data('0),    // defined as V
    .q(buff_en)        // defined as M

);

endmodule
