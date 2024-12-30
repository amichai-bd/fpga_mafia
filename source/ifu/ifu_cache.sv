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

    // Debug
    output logic dataInsertion,
    output logic hitStatusOut,
    output logic debug_freeline,
    output logic [LINE_WIDTH * NUM_LINES - 1:0] debug_dataArray, // Flattened dataArray
    output logic [(TAG_WIDTH + 1) * NUM_TAGS - 1:0] debug_tagArray, // Flattened tagArray with valid bit
    output logic [NUM_LINES - 2:0] debug_plruTree, // Current PLRU tree
    output logic [P_BITS - 1:0] debug_plruIndex // PLRU index selected for eviction
);

///////////////////
// Logic Defines //
///////////////////
tag_arr_t tagArray [NUM_TAGS];
logic [ADDR_WIDTH - 1 : OFFSET_WIDTH] cpu_reqTagIn;
data_arr_t dataArray [NUM_LINES];

// Hit status
logic [P_BITS - 1:0] hitPosition;
logic [NUM_TAGS - 1:0] hitArray;
logic hitStatus;

// PLRU
logic [P_BITS - 1:0] lineForPLRU;
logic [P_BITS - 1:0] freeLine;
logic freeLineValid;
logic [NUM_LINES - 2:0] plruTree;
logic [NUM_LINES - 2:0] currentTree;
logic [NUM_LINES - 2:0] tempUpdatedTree;
logic [P_BITS - 1:0] plruIndex;

/////////////
// Assigns //
/////////////
assign cpu_reqTagIn = cpu_reqAddrIn[ADDR_WIDTH - 1:OFFSET_WIDTH];
assign hitStatus = |hitArray;
assign mem_reqTagValidOut = !hitStatus;
assign dataInsertion = (mem_reqTagValidOut == VALID) && (mem_rspInsLineValidIn == VALID) && (mem_reqTagOut == mem_rspTagIn);
assign debug_freeline = freeLine;
assign hitStatusOut = hitStatus;
assign debug_plruTree = plruTree;
assign debug_plruIndex = plruIndex;

// Flattened debug arrays for monitoring
generate
    genvar i;
    for (i = 0; i < NUM_LINES; i++) begin
        assign debug_dataArray[i * LINE_WIDTH +: LINE_WIDTH] = dataArray[i].line;
    end
    for (i = 0; i < NUM_TAGS; i++) begin
        assign debug_tagArray[i * (TAG_WIDTH + 1) +: TAG_WIDTH + 1] = {tagArray[i].valid, tagArray[i].tag};
    end
endgenerate

///////////////////////////
// Always Comb Statement //
///////////////////////////
always_comb begin
    // Local Variables
    automatic int loopCount;           // Safeguard for infinite loop
    automatic logic [P_BITS - 1:0] index;

    // Initialize Local Variables
    index = 0;
    loopCount = 0;
    plruIndex = 0;
    freeLine = 0;
    freeLineValid = 0;

    // Hit Status
    for (int i = 0; i < NUM_TAGS; i++) begin
        if (cpu_reqTagIn == tagArray[i].tag && tagArray[i].valid == VALID) begin
            hitArray[i] = 1;
            hitPosition = i;
            cpu_rspAddrOut = cpu_reqAddrIn;
        end else begin
            hitArray[i] = 0;
        end
    end

    // Cache Action
    if (hitStatus == HIT) begin
        cpu_rspInsLineOut = dataArray[hitPosition];
        cpu_rspInsLineValidOut = VALID;
        lineForPLRU = hitPosition;
    end else begin
        cpu_rspInsLineValidOut = !VALID;
        mem_reqTagOut = cpu_reqTagIn;
        lineForPLRU = freeLine;
    end

    // Line Insertion
    if (dataInsertion) begin
        freeLineValid = 0;
        for (int i = 0; i < NUM_TAGS; i++) begin
            if (!tagArray[i].valid) begin
                freeLine = i;
                freeLineValid = 1;
                break;
            end
        end
        if (freeLineValid == 0) begin
            freeLine = plruIndex;
        end
    end

    // PLRU Tree Update
    tempUpdatedTree = currentTree;
    for (int level = P_BITS - 1; level >= 0; level--) begin
        tempUpdatedTree[index] = !(lineForPLRU[level]);
        index = (index << 1) | lineForPLRU[level];
    end

    // Debug the updated tree
    $display("Updated PLRU Tree: %b", tempUpdatedTree);

    // PLRU Index Calculation
    plruIndex = 0;
    while (plruIndex < NUM_LINES - 1 && loopCount < NUM_LINES) begin
        if (plruTree[plruIndex] === 1'bx) begin
            $display("Error: Invalid value in PLRU Tree at index %0d", plruIndex);
            plruIndex = 0;
            break;
        end
        plruIndex = (plruIndex << 1) | plruTree[plruIndex];
        loopCount++;
    end
    if (loopCount == NUM_LINES) begin
        $display("Error: Infinite loop detected in PLRU index calculation!");
    end
end

///////////////////////////
// Always_ff Statement ////
///////////////////////////
always_ff @(posedge Clock or posedge Rst) begin
    if (Rst) begin
        for (int i = 0; i < NUM_TAGS; i++) begin
            tagArray[i] <= 0;
            dataArray[i] <= 0;
        end
        plruTree <= 0;
        currentTree <= 0;
    end else begin
        if (hitStatus == HIT) begin
            plruTree <= tempUpdatedTree; 
            currentTree <= tempUpdatedTree; // Sync currentTree
        end

        if (dataInsertion) begin
            dataArray[freeLine] <= mem_rspInsLineIn;
            tagArray[freeLine].valid <= VALID;
            tagArray[freeLine].tag[TAG_WIDTH-1:0] <= mem_rspTagIn[TAG_WIDTH-1:0];
            plruTree <= tempUpdatedTree; 
            currentTree <= tempUpdatedTree; // Sync currentTree
        end
    end
end

endmodule