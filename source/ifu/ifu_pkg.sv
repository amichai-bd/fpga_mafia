 
 
 package ifu_pkg;



///////////////////////
// Parameter Defines //
///////////////////////
parameter logic HIT   = 1'b1;  // Indicates a hit
parameter logic MISS  = 1'b0;  // Indicates a miss
parameter logic VALID = 1'b1;  // Indicates validity
parameter NUM_TAGS = 16;      // Number of tags
parameter NUM_LINES = 16;     // Number of lines: should be equal to number of tags
parameter OFFSET_WIDTH = 4;   // Width of each offset
parameter ADDR_WIDTH = 32;    // Width of address
parameter TAG_WIDTH = 28;     // Width of each Tag 
parameter LINE_WIDTH = 128;   // Width of each cache line
parameter P_BITS = $clog2(NUM_TAGS);   // Bits needed for position of line

/////////////////////
// Package Defines //
///////////////////// 

 typedef struct packed {
        bit valid;                  // Valid bit
        logic [TAG_WIDTH-1:0] tag;  // Tag value
 } tag_arr_t;

typedef struct packed {
        logic [LINE_WIDTH-1:0] line;  // Tag value
} data_arr_t;

 endpackage