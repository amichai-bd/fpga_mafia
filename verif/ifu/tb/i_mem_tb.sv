// instruction memory tb

// ./build.py -dut ifu -hw -sim -top i_mem_tb

module i_mem_tb;

parameter DATA_WIDTH = 128;
parameter ADRS_WIDTH = 32;



logic                  clock;
logic [ADRS_WIDTH-1:0] address;
logic                  wren;
logic [DATA_WIDTH-1:0] data;
logic [DATA_WIDTH-1:0] q;  

initial begin
    forever begin
        #5 clock = 0;
        #5 clock = 1;
    end
end

i_mem
#(.DATA_WIDTH(DATA_WIDTH), .ADRS_WIDTH(ADRS_WIDTH))
i_mem
(
    .clock(clock),
    .address(address[ADRS_WIDTH-1:4]), 
    .wren(wren),
    .data(data),
    .q(q)        
);    

initial begin
    wren = 0;
    address = 32'h0000001_0; //tag_offset
    data    = 128'h1;
    #30    
    @(posedge clock)

    wren = 1;
    address = 32'h0000001_0;
    data    = 128'h00000001;
    #30    
    @(posedge clock)

    address = 32'h0000002_0;
    data    = 128'h00000002;
    #30    
    @(posedge clock)


    $finish;
end

parameter V_TIMEOUT = 10000;
initial begin : timeout_check 
    #V_TIMEOUT
    $finish;
end


endmodule