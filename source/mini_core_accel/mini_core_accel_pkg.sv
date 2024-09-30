//-------------------------------------
// accelerators farm package
//-------------------------------------

package mini_core_accel_pkg;

parameter  INT8_MULTIPLIER_NUM = 16;
parameter  NEURON_MAC_NUM      = 2;
parameter  NUM_WIDTH_INT8      = 8;
typedef  logic [7:0]       int8;
typedef  logic [15:0]      int16;


//-------------------------
// int8 multiplier structs
//-------------------------
typedef enum {
    PRE_START,
    COMPUTE,
    DONE          
} t_mul_int8_states;

typedef struct packed {
    int8   multiplicand;
    int8   multiplier;
}t_mul_int8_input;

typedef struct packed {
    logic done;
    int16 result;
}t_mul_int8_output;

//-------------------------
// neuron mac structs
//-------------------------
typedef struct packed {
    logic [7:0][15:0] mul_result;  // result fron int8_multiplier
    logic [7:0]       bias; 
}t_neuron_mac_input;

typedef struct packed {
    logic [7:0] int8_result;
}t_neuron_mac_output;

//-------------------------
// systolic array structs
//-------------------------
parameter DIMENTION = 4;  // 4x4 grid. Do not change the grid size without updating structs

typedef struct packed{
    int8  weight;
    int8  activation;
    logic start;
    logic done;   
} t_pe_unit_input;

typedef struct packed {
    int8  activation;
    int8  weight;
    logic done;
} t_pe_unit_output;
//-------------------------
// cr structs
//-------------------------
typedef struct packed {
    logic [7:0]  cr_core2mul_multiplicant_int8;  
    logic [7:0]  cr_core2mul_multiplier_int8; 
    logic [15:0] cr_mul2core_result;  // 16 bit result
    logic        cr_mul2core_done;    // result is ready
}t_cr_int8_multiplier;

typedef struct packed {
    t_cr_int8_multiplier [INT8_MULTIPLIER_NUM-1:0] cr_int8_multiplier;
}t_accel_cr_int8_multipliers;

typedef struct packed{
    logic [7:0] neuron_mac_bias0;
    logic [7:0] neuron_mac_bias1;
    logic [7:0] neuron_mac_result0;
    logic [7:0] neuron_mac_result1;
}t_accel_cr_neuron_mac;

//-------------------------
// Debug structs
//-------------------------
// FIXME  used for degub purposes untill we will have dedicated ref model
typedef struct packed {
    logic [31:0] cr_debug_0;
    logic [31:0] cr_debug_1;
    logic [31:0] cr_debug_2;
    logic [31:0] cr_debug_3;
} t_cr_debug;

//----------------------------
// acceleration farm structs
//----------------------------
// data connecting CR to dedicated unit
typedef struct packed { 
    t_mul_int8_input   [INT8_MULTIPLIER_NUM-1:0] core2mul_int8;      // {multiplicand, multiplier}
    t_neuron_mac_input [NEURON_MAC_NUM-1:0]      int8_mul2neuron_mac;  // {mul_result[7:0][15:0], bias}
}t_accel_farm_input;

// response from multiplier 
typedef struct packed {
    t_mul_int8_output   [INT8_MULTIPLIER_NUM-1:0] mul2core_int8;
    t_neuron_mac_output [NEURON_MAC_NUM-1:0]      neuron_mac_result;
}t_accel_farm_output;



// define CR's
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR =  CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;


//FIXME refactor to be more compact
//=====================================
//   define CR's for INT8 multiplier
//=====================================
parameter CR_CORE2MUL_INT8_MULTIPLICANT_0     = CR_MEM_OFFSET + 'hf000;
parameter CR_CORE2MUL_INT8_MULTIPLIER_0       = CR_MEM_OFFSET + 'hf001;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_1     = CR_MEM_OFFSET + 'hf002;
parameter CR_CORE2MUL_INT8_MULTIPLIER_1       = CR_MEM_OFFSET + 'hf003;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_2     = CR_MEM_OFFSET + 'hf004;
parameter CR_CORE2MUL_INT8_MULTIPLIER_2       = CR_MEM_OFFSET + 'hf005;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_3     = CR_MEM_OFFSET + 'hf006;
parameter CR_CORE2MUL_INT8_MULTIPLIER_3       = CR_MEM_OFFSET + 'hf007;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_4     = CR_MEM_OFFSET + 'hf008;
parameter CR_CORE2MUL_INT8_MULTIPLIER_4       = CR_MEM_OFFSET + 'hf009;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_5     = CR_MEM_OFFSET + 'hf00a;
parameter CR_CORE2MUL_INT8_MULTIPLIER_5       = CR_MEM_OFFSET + 'hf00b;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_6     = CR_MEM_OFFSET + 'hf00c;
parameter CR_CORE2MUL_INT8_MULTIPLIER_6       = CR_MEM_OFFSET + 'hf00d;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_7     = CR_MEM_OFFSET + 'hf00e;
parameter CR_CORE2MUL_INT8_MULTIPLIER_7       = CR_MEM_OFFSET + 'hf00f;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_8     = CR_MEM_OFFSET + 'hf010;
parameter CR_CORE2MUL_INT8_MULTIPLIER_8       = CR_MEM_OFFSET + 'hf011;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_9     = CR_MEM_OFFSET + 'hf012;
parameter CR_CORE2MUL_INT8_MULTIPLIER_9       = CR_MEM_OFFSET + 'hf013;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_10    = CR_MEM_OFFSET + 'hf014;
parameter CR_CORE2MUL_INT8_MULTIPLIER_10      = CR_MEM_OFFSET + 'hf015;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_11    = CR_MEM_OFFSET + 'hf016;
parameter CR_CORE2MUL_INT8_MULTIPLIER_11      = CR_MEM_OFFSET + 'hf017;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_12    = CR_MEM_OFFSET + 'hf018;
parameter CR_CORE2MUL_INT8_MULTIPLIER_12      = CR_MEM_OFFSET + 'hf019;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_13    = CR_MEM_OFFSET + 'hf01a;
parameter CR_CORE2MUL_INT8_MULTIPLIER_13      = CR_MEM_OFFSET + 'hf01b;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_14    = CR_MEM_OFFSET + 'hf01c;
parameter CR_CORE2MUL_INT8_MULTIPLIER_14      = CR_MEM_OFFSET + 'hf01d;
parameter CR_CORE2MUL_INT8_MULTIPLICANT_15    = CR_MEM_OFFSET + 'hf01e;
parameter CR_CORE2MUL_INT8_MULTIPLIER_15      = CR_MEM_OFFSET + 'hf01f;


parameter CR_MUL2CORE_INT8_0        = CR_MEM_OFFSET + 'hf050;
parameter CR_MUL2CORE_INT8_DONE_0   = CR_MEM_OFFSET + 'hf051;
parameter CR_MUL2CORE_INT8_1        = CR_MEM_OFFSET + 'hf052;
parameter CR_MUL2CORE_INT8_DONE_1   = CR_MEM_OFFSET + 'hf053;
parameter CR_MUL2CORE_INT8_2        = CR_MEM_OFFSET + 'hf054;
parameter CR_MUL2CORE_INT8_DONE_2   = CR_MEM_OFFSET + 'hf055;
parameter CR_MUL2CORE_INT8_3        = CR_MEM_OFFSET + 'hf056;
parameter CR_MUL2CORE_INT8_DONE_3   = CR_MEM_OFFSET + 'hf057;
parameter CR_MUL2CORE_INT8_4        = CR_MEM_OFFSET + 'hf058;
parameter CR_MUL2CORE_INT8_DONE_4   = CR_MEM_OFFSET + 'hf059;
parameter CR_MUL2CORE_INT8_5        = CR_MEM_OFFSET + 'hf05a;
parameter CR_MUL2CORE_INT8_DONE_5   = CR_MEM_OFFSET + 'hf05b;
parameter CR_MUL2CORE_INT8_6        = CR_MEM_OFFSET + 'hf05c;
parameter CR_MUL2CORE_INT8_DONE_6   = CR_MEM_OFFSET + 'hf05d;
parameter CR_MUL2CORE_INT8_7        = CR_MEM_OFFSET + 'hf05e;
parameter CR_MUL2CORE_INT8_DONE_7   = CR_MEM_OFFSET + 'hf05f;
parameter CR_MUL2CORE_INT8_8        = CR_MEM_OFFSET + 'hf060;
parameter CR_MUL2CORE_INT8_DONE_8   = CR_MEM_OFFSET + 'hf061;
parameter CR_MUL2CORE_INT8_9        = CR_MEM_OFFSET + 'hf062;
parameter CR_MUL2CORE_INT8_DONE_9   = CR_MEM_OFFSET + 'hf063;
parameter CR_MUL2CORE_INT8_10       = CR_MEM_OFFSET + 'hf064;
parameter CR_MUL2CORE_INT8_DONE_10  = CR_MEM_OFFSET + 'hf065;
parameter CR_MUL2CORE_INT8_11       = CR_MEM_OFFSET + 'hf066;
parameter CR_MUL2CORE_INT8_DONE_11  = CR_MEM_OFFSET + 'hf067;
parameter CR_MUL2CORE_INT8_12       = CR_MEM_OFFSET + 'hf068;
parameter CR_MUL2CORE_INT8_DONE_12  = CR_MEM_OFFSET + 'hf069;
parameter CR_MUL2CORE_INT8_13       = CR_MEM_OFFSET + 'hf06a;
parameter CR_MUL2CORE_INT8_DONE_13  = CR_MEM_OFFSET + 'hf06b;
parameter CR_MUL2CORE_INT8_14       = CR_MEM_OFFSET + 'hf06c;
parameter CR_MUL2CORE_INT8_DONE_14  = CR_MEM_OFFSET + 'hf06d;
parameter CR_MUL2CORE_INT8_15       = CR_MEM_OFFSET + 'hf06e;
parameter CR_MUL2CORE_INT8_DONE_15  = CR_MEM_OFFSET + 'hf06f; 


//==================================
//   define CR's for neuron_mac
//==================================
parameter NEURON_MAC_BIAS0         = CR_MEM_OFFSET + 'hf100;
parameter NEURON_MAC_BIAS1         = CR_MEM_OFFSET + 'hf101; 
parameter NEURON_MAC_RESULT0       = CR_MEM_OFFSET + 'hf102; 
parameter NEURON_MAC_RESULT1       = CR_MEM_OFFSET + 'hf103;  

// used for debug purposes
parameter CR_DEBUG_0                = CR_MEM_OFFSET + 'hff00;
parameter CR_DEBUG_1                = CR_MEM_OFFSET + 'hff01;
parameter CR_DEBUG_2                = CR_MEM_OFFSET + 'hff02;
parameter CR_DEBUG_3                = CR_MEM_OFFSET + 'hff03;

endpackage