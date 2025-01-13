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
    output logic [LINE_WIDTH * NUM_LINES - 1:0] debug_dataArray, // Flattened dataArray
    output logic [(TAG_WIDTH + 1) * NUM_TAGS - 1:0] debug_tagArray, // Flattened tagArray with valid bit
    output logic [NUM_LINES - 2:0] debug_plruTree, // Current PLRU tree
    output logic [P_BITS - 1:0] debug_plruIndex // PLRU index selected for eviction
);

///////////////////
// Logic Defines //
///////////////////

// cpu
logic [TAG_WIDTH - 1 : 0] cpu_reqTagIn;

// arrays
tag_arr_t tagArray [NUM_TAGS];
data_arr_t dataArray [NUM_LINES];
logic [P_BITS - 1:0] replacementLine;

// Hit 
logic [P_BITS - 1:0] hitPosition;
logic [NUM_TAGS - 1:0] hitArray;
logic hitStatus;


// PLRU
logic [NUM_LINES - 2:0] plruTree;
logic [NUM_LINES - 2:0] updatedPlruTree;
logic [P_BITS - 1:0] updatedPlruIdx; // this is used to calculate the plru after access, or when finding when finding replacementLine (which is the line that we can overwrite)
logic plruAccessLineValid;
logic [P_BITS - 1:0] plruAccessLine;

/////////////
// Assigns //
/////////////

// Requested Tag
assign cpu_reqTagIn = cpu_reqAddrIn[ADDR_WIDTH - 1:OFFSET_WIDTH];

// Hit
assign hitStatus = |hitArray;
assign mem_reqTagValidOut = !hitStatus;

// Insertion
assign dataInsertion = mem_rspInsLineValidIn && mem_reqTagValidOut;

// Debug
assign hitStatusOut = hitStatus;
assign debug_plruTree = plruTree;
assign debug_plruIndex = replacementLine;

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

    // Initialize Variables
    plruAccessLineValid = 0;
    replacementLine = 0;
    updatedPlruTree = plruTree;

    // Hit Status
    for (int i = 0; i < NUM_TAGS; i++) begin
        if (cpu_reqTagIn == tagArray[i].tag && tagArray[i].valid == VALID) begin
            hitArray[i] = 1;
            hitPosition = i;
        end else begin
            hitArray[i] = 0;
        end
    end

    // Cache Action
    if (hitStatus == HIT) begin
        cpu_rspAddrOut = cpu_reqAddrIn;
        cpu_rspInsLineOut = dataArray[hitPosition];
        cpu_rspInsLineValidOut = VALID;
        plruAccessLine = hitPosition; 
        plruAccessLineValid = VALID;
    end else begin
        cpu_rspInsLineValidOut = !VALID;
        mem_reqTagOut = cpu_reqTagIn;   
    end

    // Line Insertion
    if (dataInsertion) begin 
        
        // first we update PLRU update on Insertion
        updatedPlruIdx = 0;
        for (int level = 0; level < P_BITS ; level++ ) begin
            if (plruTree[updatedPlruIdx] == 0) begin
                replacementLine[P_BITS - level - 1] = 0;
                updatedPlruIdx = (updatedPlruIdx << 1) + 1;    
            end else begin
                replacementLine[P_BITS - level - 1] = 1;
                updatedPlruIdx = (updatedPlruIdx << 1) + 1;
            end
        end
        
        // if this line is requested by the cpu then we can output it
        if (cpu_reqTagIn == mem_rspTagIn)  begin
            cpu_rspAddrOut = cpu_reqAddrIn;
            cpu_rspInsLineOut = mem_rspInsLineValidIn; 
            cpu_rspInsLineValidOut = VALID;
            plruAccessLine = replacementLine;
            plruAccessLineValid = VALID;   // the line is considered accessed
        end
    end

    // PLRU update on access
    if (plruAccessLineValid) begin
        updatedPlruIdx = 0;
        for (int level = 0; level < P_BITS ; level++ ) begin
            if (plruAccessLine[P_BITS - level - 1] == 0) begin
                updatedPlruTree[updatedPlruIdx] = 1;
                updatedPlruIdx = (updatedPlruIdx << 1) + 2;
            end else begin
                updatedPlruTree[updatedPlruIdx] = 0;
                updatedPlruIdx = (updatedPlruIdx << 1) + 1;
            end
        end
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
        plruTree <= 15'b0;
    end else begin
        if (hitStatus == HIT) begin
            plruTree <= updatedPlruTree; 
        end

        if (mem_rspInsLineValidIn) begin
            dataArray[replacementLine] <= mem_rspInsLineIn;
            tagArray[replacementLine].valid <= VALID;
            tagArray[replacementLine].tag[TAG_WIDTH-1:0] <= mem_rspTagIn[TAG_WIDTH-1:0];
            plruTree <= updatedPlruTree; 
        end
    end
end

endmodule