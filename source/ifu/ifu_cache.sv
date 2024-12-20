
`include "macros.vh"



module ifu_cache
import ifu_pkg::*;
#( 
    parameter NUM_TAGS,      // Number of tags
    parameter NUM_LINES,     // Number of lines: should be equal to number of tags
    parameter TAG_WIDTH,     // Width of each tag: evacuation_bit + valid_bit + tag_bits = 1 + 1 + 28
    parameter LINE_WIDTH,    // Width of each cache line
    parameter OFFSET_WIDTH
)
(
// Inputs
input logic Clock,
input logic Rst,
input logic [31:0] pc,
input logic [127:0] insLineIn,
input logic insLineValidIn,

// Outputs
output logic [127:0] insLineOut,
output logic insLineValidOut

);

tag_arr_t tagArray [NUM_TAGS];
data_arr_t dataArray [NUM_LINES];
logic [TAG_WIDTH - OFFSET_WIDTH - 1 : 0 ] pcTag;
logic [NUM_LINES - 2 : 0 ] plruTree;


assign pcTag = pc[TAG_WIDTH-1:OFFSET_WIDTH];

always_ff@(posedge Rst) begin
    if (Rst) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            tagArray[i] <= 0;
            dataArray[i] <= 0; // maybe we need to reset also the data array to zero
        end
        plruTree <= 0;
    end
end

always_ff@(posedge Clock) begin

    insLineValidOut <= 0;  // Default to invalid unless explicitly set
    //handle cache miss
    if (!insLineValidOut && insLineValidIn) begin
        static int freeLine = -1;
        //checks if there any empty cache lines before using the PLRU 
        for (int i = 0 ; i < NUM_TAGS ; i++)begin
            if (!tagArray[i].valid)begin
                freeLine = i;
                break;
            end
        end
        //in case all the lines in the cache are full
        if (freeLine == -1)begin
            freeLine = getPLRUIndex(plruTree);
        end

        dataArray[freeLine] <= insLineIn;
        tagArray[freeLine].valid <= 1'b1;
        tagArray[freeLine].tag <= pcTag;

        updatePLruTree(plruTree , freeLine);    

        insLineValidOut <= 1'b1;
        insLineOut <= insLineIn;
        
        
    end 
end

always_ff@(posedge Clock) begin
    
    insLineValidOut <= 0;
    for (int i = 0 ; i < NUM_TAGS ; i++) begin
        if(tagArray[i].tag == pcTag) begin
            insLineValidOut <= tagArray[i].valid;
            insLineOut <= dataArray[i];

            //updates the plru tree when there is a hit
            updatePLruTree(plruTree,i);
        end
        
    end
end 


task updatePLruTree(inout logic [NUM_LINES - 2 : 0 ] tree , input int line );
    static int index = 0;
    static int Tree_Depth = $clog2(NUM_LINES) - 1;
    for(int layer = Tree_Depth ; layer >= 0 ; layer--)begin
        tree[index] <= (line >> layer) & 1;
        index = (index << 1) | ((line >> layer) & 1);
    end
endtask


function int getPLRUIndex(logic [NUM_LINES - 2 : 0 ] tree);
    static int index = 0;
    while(index < NUM_LINES - 1 ) begin
        //updates the index to search in the next layer in the tree, tree[index] chooses the left or the left node
        index = (index << 1) | tree[index]; 
    end
    return index; 
endfunction


endmodule