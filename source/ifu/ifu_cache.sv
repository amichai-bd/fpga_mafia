
`include "macros.vh"

module ifu_cache
import ifu_pkg::*;
(
// Chip Signals
input logic Clock,
input logic Rst,

// CPU Interface
input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn, // requested addr by cpu
output logic [ADDR_WIDTH-1:0] cpu_rspAddrOut, // address of the line in the response to cpu
output logic [LINE_WIDTH-1:0] cpu_rspInsLineOut, // the line in the response to cpu
output logic cpu_rspInsLineValidOut, // valid, meaning the cpu can read the line

// Memory Interface
input logic [TAG_WIDTH-1:0] mem_rspTagIn, // tag of the line provide by response of the memory
input logic [LINE_WIDTH-1:0] mem_rspInsLineIn, // the line provided in the response of the memory
input logic mem_rspInsLineValidIn, // the line is ready in the response and can be read by the cache
output logic [TAG_WIDTH-1:0] mem_reqTagOut, // tag requested by the cache from the memory
output logic mem_reqTagValidOut, // there is a request for the tag to be brought from the memory

// Prefetcher Interface
// to be added
//
// debug 
output logic dataInsertion,
output logic hitStatusOut,
output logic [NUM_LINES - 2 :0] plruTreeOut

);


///////////////////
// Logic Defines //
///////////////////
// tag array
tag_arr_t tagArray [NUM_TAGS];
logic [ADDR_WIDTH - 1  : OFFSET_WIDTH-1 ] cpu_reqTagIn;

// data array
data_arr_t dataArray [NUM_LINES];
// logic dataInsertion;

// hit status
logic [P_BITS - 1:0] hitPosition; // synthesizable calculated in compilation time 
logic [NUM_TAGS-1:0] hitArray;
logic hitStatus;

// plru
logic [P_BITS - 1 : 0] lineForPLRU;
logic [P_BITS - 1 : 0] freeLine;
logic freeLineValid;
logic [NUM_LINES - 2 : 0 ] plruTree;
logic [NUM_LINES - 2 : 0] updatedTree; // Holds the updated PLRU tree
logic [P_BITS - 1 : 0] plruIndex; // Holds the LRU index
logic updateTreeValid;

/////////////
// Assigns //
/////////////
assign cpu_reqTagIn = cpu_reqAddrIn[ADDR_WIDTH-1:OFFSET_WIDTH-1];
assign hitStatus = |hitArray;
assign mem_reqTagValidOut = !hitStatus;
assign dataInsertion = (mem_reqTagValidOut == VALID) && (mem_rspInsLineValidIn == VALID) && (mem_reqTagOut == mem_rspTagIn);
assign plruTreeOut = plruTree;
assign hitStatusOut = hitStatus;


///////////////////////////
// Always Comb Statement //
///////////////////////////

always_comb begin 
////////////////
// Hit Status //
////////////////
    for (int i = 0 ; i < NUM_TAGS; i++) begin
        if (cpu_reqTagIn == tagArray[i].tag && tagArray[i].valid == VALID) begin
            hitArray[i] = 1;
            hitPosition = i;
            cpu_rspAddrOut = cpu_reqAddrIn;
        end else begin
            hitArray[i] = 0;
        end
    end

//////////////////
// Cache Action //
//////////////////
    if(hitStatus == HIT) begin // hit handling 
        cpu_rspInsLineOut = dataArray[hitPosition];
        cpu_rspInsLineValidOut = VALID; // we have the line in cache
        lineForPLRU = hitPosition;
    end else begin // miss handling      
        cpu_rspInsLineValidOut = !VALID; // we do not have the line in cache
        mem_reqTagOut = cpu_reqTagIn;
        lineForPLRU = freeLine; 
    end

////////////////////
// Line Insertion //
////////////////////
    if (dataInsertion) begin
        freeLineValid = 0;
        freeLine = 0;
        //checks if there any empty cache lines before using the PLRU 
        for (int i = 0 ; i < NUM_TAGS ; i++)begin
            if (!tagArray[i].valid)begin
                freeLine = i;
                freeLineValid = 1;
                break;
            end
        end
        //in case all the lines in the cache are full
        if (freeLineValid == 0)begin
            freeLine = plruIndex;
        end        
    end
end // always_comb end


///////////////////////////
// Always ff Statement //
///////////////////////////
always_ff @(posedge Clock or posedge Rst) begin

/////////////////
// Cache Reset //
/////////////////
    if (Rst) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            tagArray[i] <= 0;
            dataArray[i] <= 0; 
        end
        plruTree <= 0;         // Reset PLRU tree
    end 

    if (hitStatus == HIT) begin
        plruTree <= updatedTree; //updates the plru tree when there is a hit
    end
    
    if(dataInsertion) begin
        dataArray[freeLine] <= mem_rspInsLineIn;
        tagArray[freeLine].valid <= VALID;
        tagArray[freeLine].tag <= mem_rspTagIn;
        plruTree <= updatedTree;    
    end   
end


///////////////
// Utilities //
///////////////
//Updates the PLRU tree after a hit or replacement.
module updatePLruTree (
    input logic [NUM_LINES - 2 : 0] currentTree,
    input logic [P_BITS - 1 : 0] line,
    output logic [NUM_LINES - 2 : 0] updatedTree
);

logic [P_BITS - 1 : 0] index;

always_comb begin
    index = 0;
    updatedTree = currentTree;
    for (int level = P_BITS - 1 ; level >= 0; level--) begin
        updatedTree[index] = (line >> level) & 1;
        index = (index << 1) | ((line >> level) & 1);
    end
end
endmodule

//Computes the least recently used (LRU) index.
module getPLRUIndex (
    input logic [NUM_LINES - 2 : 0] tree,
    output logic [P_BITS - 1 : 0] index
);

always_comb begin 
    index = 0;
    while(index < NUM_LINES - 1) begin
        // Updates the index to search in the next layer in the tree, tree[index] chooses the left or right node
        index = (index << 1 ) | tree[index];
        index = index & 4'b1111; // mod 16 to insure the index is always smaller than 16
    end
end

endmodule


// Module Instantiations
getPLRUIndex plru_index_inst (
    .tree(plruTree),
    .index(plruIndex)
);

updatePLruTree update_plru_inst (
    .currentTree(plruTree),
    .line(lineForPLRU), 
    .updatedTree(updatedTree)
);

endmodule
