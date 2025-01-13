package fibonacci_pkg;

parameter DATA_WIDTH = 8;

typedef struct packed {
    logic       valid;
    logic [DATA_WIDTH-1:0] result;     
}t_output_interface;

// states for fibonacci_st.sv
typedef enum {
    IDLE,
    CALC
}t_states;

endpackage


