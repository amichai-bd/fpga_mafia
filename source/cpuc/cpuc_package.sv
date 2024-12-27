//---------------------------------------------
// Project:   CPUC
// File name: cpuc_registers 
// Date:      26.12.24
// Author:     
//---------------------------------------------
// Description: cpuc_package
//---------------------------------------------


package cpuc_package;

parameter SIGNED_CMP = 1;    // by default allow negative numbers 
parameter DATA_WIDTH = 32;   // width of data in the cpu

parameter MEM_SIZE   = 8096; // mem size of 8096*32 = 32kbyte
parameter ADDR_WIDTH = $clog2(MEM_SIZE);   // width of adress in the memory

// number of instantiated units
parameter NUM_OF_REGS     = 32;  // number of registers
parameter NUM_OF_MUL      = 16;  // number of multipliers
parameter NUM_OF_ADDERS   = 16;  // number of adders
parameter NUM_OF_CMP      = 16;  // number of comperators
parameter NUM_OF_MUX      = 1;   // number of muxes
parameter NUM_OF_EQUAL    = 16;  // number of is equal
parameter NUM_OF_SING_MEM = 2;   // number of is single prot ram
parameter NUM_OF_DUAL_MEM = 2;   // number of is dual port ram
parameter NUM_OF_QUAD_MEM = 2;   // number of is quad port ram

parameter NUM_OF_CONSTS = 32;  // number of constants is the cpuc
parameter PROGRAM_SIZE  = 32;  // number of instructions

typedef struct packed {

    logic [NUM_OF_REGS-1:0][DATA_WIDTH-1:0] reg_outputs;

} t_reg_outputs;

endpackage