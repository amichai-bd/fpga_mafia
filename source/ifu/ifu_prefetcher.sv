`include "macros.vh"

module ifu_prefetcher
import ifu_pkg::*;
(

    // debug 
    output [1:0] current_stateOut,

    // Chip Signals
    input logic Clock,
    input logic Rst,

    // Cache Interface
    input logic cache_rspTagValidIn, 
    input logic cache_rspTagStatusIn, 
    input logic [TAG_WIDTH - 1 : 0] cache_rspTagIn,
    output logic cache_reqTagValidOut, // 
    output logic [TAG_WIDTH - 1 : 0] cache_reqTagOut, // check if cache has the line we want to get 

    // IFU signals
    input logic ifu_prefReqSent,

    // CPU Interface
    input logic [ADDR_WIDTH-1:0] cpu_reqAddrIn, // requested addr by cpu

    // Memory Interface
    input logic [TAG_WIDTH-1:0] mem_rspTagIn, // tag of the line provided by response of the memory
    input logic mem_rspInsLineValidIn, // the line is ready in the response and can be read by the cache
    output logic [TAG_WIDTH - 1:0] mem_reqTagOut, // Predicted address sent to memory
    output logic mem_reqTagValidOut             // Indicates if the prefetch request is valid
    
);


///////////////////
// State Encoding //
///////////////////
typedef enum logic [1:0] { 
    s_check = 2'b00,
    s_request = 2'b01,
    s_sleep = 2'b10,
    s_count = 2'b11
} pref_state_t;



    
///////////////////
// Logic Defines //
///////////////////

// state machine
pref_state_t current_state, next_state;

logic [TAG_WIDTH - 1 : 0] cpu_reqTagIn;
logic [TAG_WIDTH - 1 : 0] cpu_reqTagIn_buffer;
logic sleep;
logic [1:0] cycleCounter; 

/////////////
// Assigns //
/////////////
assign current_stateOut = current_state;
assign cpu_reqTagIn = cpu_reqAddrIn[ADDR_WIDTH - 1 : OFFSET_WIDTH];
assign mem_reqTagOut = cpu_reqTagIn + 1;
assign cache_reqTagOut = cpu_reqTagIn + 1;
assign sleep = (((cache_rspTagIn == cache_reqTagOut) && cache_rspTagValidIn && cache_rspTagStatusIn) || // if cache has the next line sleep
               ((mem_rspTagIn == mem_reqTagOut)  &&  mem_rspInsLineValidIn) || // if line is brought from memory sleep
                ifu_prefReqSent);                                              // if the request was already sent then we don't need to send again


///////////////////////////
// Always Comb Statement //
///////////////////////////
always_comb begin
    
    case (current_state)

        s_check: begin
            cache_reqTagValidOut = VALID;
            if ((cache_rspTagIn == cache_reqTagOut) && cache_rspTagValidIn) begin
                cache_reqTagValidOut = !VALID;
                if (cache_rspTagStatusIn) begin
                    mem_reqTagValidOut = !VALID;
                    next_state = s_sleep;
                end else begin
                    mem_reqTagValidOut = VALID;
                    next_state = s_request;
                end
            end
        end

        s_request: begin
            mem_reqTagValidOut = VALID;
            if(sleep) begin
                mem_reqTagValidOut = !VALID;
                next_state = s_sleep;
            end
        end

        s_sleep: begin
            mem_reqTagValidOut = !VALID;
            cache_reqTagValidOut = !VALID;
            if ((cpu_reqTagIn_buffer != cpu_reqTagIn) || (cycleCounter == 2'b11)) begin // if PC-Tag changes or 4 cycles have passed since last request
                next_state = s_check;
            end
        end

        default: begin
            next_state = s_check;
            mem_reqTagValidOut = !VALID;
            cache_reqTagValidOut = !VALID;
        end
    
    endcase

end


///////////////////////////
// Always_ff Statement ////
///////////////////////////
always_ff @(posedge Clock or posedge Rst) begin
    
    cpu_reqTagIn_buffer <= cpu_reqTagIn;
    
    if (Rst) begin
        cycleCounter <= 2'b0;
        current_state <= s_check;
    end else begin
        
        current_state <= next_state;

        if (next_state == s_sleep) begin
            cycleCounter <= 2'b0;
        end else begin 
            cycleCounter <= cycleCounter + 1;
        end


    end

end

endmodule


