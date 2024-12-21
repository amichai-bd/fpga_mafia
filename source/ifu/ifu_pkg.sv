 
 
 package ifu_pkg;



///////////////////////
// Parameter Defines //
///////////////////////
parameter logic HIT   = 1'b1;  // Indicates a hit
parameter logic MISS  = 1'b0;  // Indicates a miss
parameter logic VALID = 1'b1;  // Indicates validity
parameter NUM_TAGS = 16;      // Number of tags
parameter NUM_LINES = 16;     // Number of lines: should be equal to number of tags
parameter TAG_WIDTH = 27;     // Width of each tag: evacuation_bit + valid_bit + tag_bits = 1 + 1 + 28
parameter LINE_WIDTH = 128;    // Width of each cache line
parameter OFFSET_WIDTH = 4;   // Width of each offset
parameter ADDR_WIDTH = 32;


 typedef struct packed {
        bit valid;                  // Valid bit
        logic [TAG_WIDTH-1:0] tag;  // Tag value
 } tag_arr_t;

typedef struct packed {
        logic [LINE_WIDTH-1:0] line;  // Tag value
} data_arr_t;

 endpackage