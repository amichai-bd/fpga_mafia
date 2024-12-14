/****************************************
* IFU - Instruction Fetch Unit Package
*****************************************/

package ifu_pkg;

parameter CL_WIDTH            = 128;
parameter WAYS_NUM            = 16;
parameter TAG_ADDRESS_WIDTH   = 28;  // pc[31:4]
parameter PLRU_NODES_NUM      = WAYS_NUM - 1;    


typedef struct packed {
    logic [CL_WIDTH-1:0] filled_instruction; // instruction from i_mem in case of fill/miss
    logic                valid;
    logic [31:0]         address;
} t_i_mem2cache_rsp;

typedef struct packed {
    logic [31:0] fill_requested_address;    
    logic        fill_requested_address_valid;
} t_cache2i_mem_req;

typedef struct packed {
    logic [31:0] requested_instruction;   
    logic        requested_instruction_valid;
} t_cache2core_rsp;

typedef struct packed {
    logic next_node_is_right;
    logic next_node_is_left;
}t_plru_node;

typedef struct packed{
    t_plru_node [PLRU_NODES_NUM] plru_tree_nodes; 
} t_plru_tree_nodes;

endpackage