//---------------------------------------------
// Project:   CPUC
// File name: cpuc_registers 
// Date:      26.12.24
// Author:     
//---------------------------------------------
// Description: cpuc_package
//---------------------------------------------


package cpuc_package;

parameter SIGNED_CMP = 1;    // by default allow signed operations 
parameter DATA_WIDTH = 32;   // width of data in the cpu

parameter MEM_SIZE   = 8096; // mem size of 8096*32 = 32kbyte
parameter ADDR_WIDTH = $clog2(MEM_SIZE);   // width of address in the memory

// number of instantiated units
parameter NUM_OF_REGS     = 8;  // number of registers
parameter NUM_OF_MUL      = 0;   // number of multipliers
parameter NUM_OF_ADDERS   = 2;   // number of adders
parameter NUM_OF_CMP      = 2;   // number of comperators
parameter NUM_OF_MUX      = 0;   // number of muxes
parameter NUM_OF_EQUAL    = 2;   // number of is equal
parameter NUM_OF_SING_MEM = 0;   // number of is single prot ram
parameter NUM_OF_DUAL_MEM = 0;   // number of is dual port ram
parameter NUM_OF_QUAD_MEM = 0;   // number of is quad port ram
parameter NUM_OF_PC       = 1;   // number of program counters
parameter NUM_OF_INST_MEM = 1;   // number of instruction memory

parameter NUM_OF_CONSTS   = 4;  // number of constants is the cpuc

//number of components that can be connected to amy register
parameter NUM_OF_COMPONENTS  = NUM_OF_REGS + NUM_OF_MUL + NUM_OF_ADDERS + NUM_OF_CMP + NUM_OF_MUX + NUM_OF_EQUAL + 
                               NUM_OF_SING_MEM + NUM_OF_DUAL_MEM + NUM_OF_QUAD_MEM + NUM_OF_PC + NUM_OF_CONSTS;  

parameter PROGRAM_SIZE  = 8;  // number of instructions
// instruction length = buffer number
parameter INST_LENGTH   = NUM_OF_COMPONENTS*NUM_OF_REGS + NUM_OF_REGS*(NUM_OF_MUL + NUM_OF_ADDERS + NUM_OF_CMP + NUM_OF_MUX
                                                                     + NUM_OF_EQUAL)*2;

typedef struct packed {

    logic [NUM_OF_REGS+NUM_OF_PC-1:0][DATA_WIDTH-1:0] reg_outputs;

} t_reg_outputs;

endpackage


