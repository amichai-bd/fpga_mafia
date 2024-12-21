
`include "macros.vh"

module ifu_cache
import ifu_pkg::*;

#( 
    parameter NUM_TAGS,      // Number of tags
    parameter NUM_LINES,     // Number of lines: should be equal to number of tags
    parameter TAG_WIDTH,     // Width of each tag
    parameter LINE_WIDTH,    // Width of each cache line
    parameter ADDR_WIDTH,    // Width of each address
    parameter OFFSET_WIDTH   // Width of offset bits in address
)
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
output logic dataInsertion

);



///////////////////
// Logic Defines //
///////////////////
// tag array
tag_arr_t tagArray [NUM_TAGS];
logic [TAG_WIDTH - OFFSET_WIDTH - 1 : 0 ] cpu_reqTagIn;

// data array
data_arr_t dataArray [NUM_LINES];
// logic dataInsertion;

// hit status
logic [$clog2(NUM_TAGS)-1:0] hitPosition; // synthesizable calculated in compilation time 
logic [NUM_TAGS-1:0] hitArray;
logic hitStatus;

// plru
logic [NUM_LINES - 2 : 0 ] plruTree;

/////////////
// Assigns //
/////////////
assign cpu_reqTagIn = cpu_reqAddrIn[TAG_WIDTH-1:OFFSET_WIDTH];
assign hitStatus = |hitArray;
assign mem_reqTagValidOut = !hitStatus;
assign dataInsertion = (mem_reqTagValidOut == VALID) && (mem_rspInsLineValidIn == VALID) && (mem_reqTagOut == mem_rspTagIn);

///////////////////////////
// Always Comb Statement //
///////////////////////////

always_comb begin 
/////////////////
// Cache Reset //
/////////////////
    if (Rst) begin
        for (int i = 0 ; i < NUM_TAGS ; i++) begin
            tagArray[i] = 0;
            dataArray[i] = 0; // maybe we need to reset also the data array to zero
            hitArray[i] = 0;
        end
        cpu_rspAddrOut = 0;
        plruTree = 0;
    end

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
        //updates the plru tree when there is a hit
        updatePLruTree(plruTree,hitPosition);
    end else begin // miss handling
        cpu_rspInsLineValidOut = !VALID; // we do not have the line in cache
        mem_reqTagOut = cpu_reqAddrIn; 
    end

////////////////////
// Line Insertion //
////////////////////
    if (dataInsertion) begin
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
        dataArray[freeLine] = mem_rspInsLineIn;
        tagArray[freeLine].valid = VALID;
        tagArray[freeLine].tag = mem_rspTagIn;

        updatePLruTree(plruTree , freeLine);    
    end
end // always_comb end

///////////////
// Utilities //
///////////////
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