// Core -> Cache request
typedef struct packed {
    logic [31:0]  Address;  
    logic [31:0]  Data;    
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
} t_mem_store_history ;

typedef struct packed {
    logic [31:0]  Address;  
    logic [31:0]  Data;    
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
} t_mem_load_history ;

t_mem_store_history mem_store_history[$];
t_mem_store_history cur_mem_store;
t_mem_store_history ref_mem_store_history[$];
t_mem_store_history ref_cur_mem_store;

t_mem_load_history mem_load_history[$];
t_mem_load_history cur_mem_load;
t_mem_load_history ref_mem_load_history[$];
t_mem_load_history ref_cur_mem_load;


// signals for store
logic DMemWrEnQ103H;
logic [31:0] DMemWrDataQ103H;
logic [31:0] AluOutQ103H;
assign DMemWrEnQ103H   = big_core_top.big_core.big_core_mem_access1.Ctrl.DMemWrEnQ103H;
assign DMemWrDataQ103H = big_core_top.big_core.big_core_mem_access1.DMemWrDataQ103H;
assign AluOutQ103H     = big_core_top.big_core.big_core_mem_access1.AluOutQ103H;   // store address

// signals for load
logic DMemRdEnQ105H;
logic [31:0] PostSxDMemRdDataQ105H;
logic [31:0] AluOutQ105H;
logic [31:0] l_data;
assign DMemRdEnQ105H         = big_core_top.big_core.big_core_ctrl.CtrlQ105H.DMemRdEn;
assign PostSxDMemRdDataQ105H = big_core_top.big_core.big_core_wb.PostSxDMemRdDataQ105H;
assign AluOutQ105H           = big_core_top.big_core.big_core_wb.AluOutQ105H;   // load address
assign l_data = (rv32i_ref.instr_type == LB)  ?  rv32i_ref.lb_data :
                (rv32i_ref.instr_type == LH)  ?  rv32i_ref.lh_data :
                (rv32i_ref.instr_type == LW)  ?  rv32i_ref.lw_data :
                (rv32i_ref.instr_type == LBU) ? rv32i_ref.lbu_data :
                (rv32i_ref.instr_type == LHU) ? rv32i_ref.lhu_data : 0;

task get_mem_store();
$display("get_mem_store start");
fork forever begin 
    @(posedge Clk) begin
        if (DMemWrEnQ103H) begin
            cur_mem_store.Address  = AluOutQ103H;
            cur_mem_store.Data     = DMemWrDataQ103H;
            cur_mem_store.Pc       = PcQ103H;
            cur_mem_store.cur_time = $time;
            mem_store_history.push_back(cur_mem_store);
            // $display("cur_mem_store = %p", cur_mem_store);
         end
    end
end
join_none
endtask

task get_mem_load();
$display("get_mem_load start");
fork forever begin 
    @(posedge Clk) begin
        if (DMemRdEnQ105H) begin
            cur_mem_load.Address  = AluOutQ105H;
            cur_mem_load.Data     = PostSxDMemRdDataQ105H;
            cur_mem_load.Pc       = PcQ105H;
            cur_mem_load.cur_time = $time;
            mem_load_history.push_back(cur_mem_load);
            // $display("cur_mem_load = %p", cur_mem_load);

        end
    end
end
join_none
endtask

task get_ref_mem_store();
fork forever begin 
    @(posedge Clk) begin
        if (rv32i_ref.DMemWrEn) begin
            ref_cur_mem_store.Address  = rv32i_ref.mem_wr_addr;
            ref_cur_mem_store.Data     = rv32i_ref.data_rd2;
            ref_cur_mem_store.Pc       = rv32i_ref.pc;
            ref_cur_mem_store.cur_time = $time;
            ref_mem_store_history.push_back(ref_cur_mem_store);
            // $display("ref_cur_mem_store = %p", ref_cur_mem_store);
            end 
        end
    end
join_none
endtask

task get_ref_mem_load();
fork forever begin 
    @(posedge Clk) begin
        if (rv32i_ref.DMemRdEn) begin
            ref_cur_mem_load.Address  = rv32i_ref.mem_rd_addr;
            ref_cur_mem_load.Data     = l_data;  
            ref_cur_mem_load.Pc       = rv32i_ref.pc;
            ref_cur_mem_load.cur_time = $time;
            ref_mem_load_history.push_back(ref_cur_mem_load);
            // $display("ref_cur_mem_load = %p", ref_cur_mem_load);
            end 
        end
    end
join_none
endtask


string s_msg = "Store data integrity test passed"; // default
task di_mem_store();
$display("ref_mem_store_history size = %0d", ref_mem_store_history.size());
$display("mem_store_history size     = %0d", mem_store_history.size());
foreach(ref_mem_store_history[i])begin
    if ((ref_mem_store_history[i].Address == mem_store_history[i].Address ) && 
        (ref_mem_store_history[i].Data    == mem_store_history[i].Data ) )
    begin
        $display(" >> mem_store_history[%0d] Match: time: %0d, PC: %8h, Address: %h, Data: %h", i, mem_store_history[i].cur_time,
                                                                                                 mem_store_history[i].Pc,
                                                                                                 mem_store_history[i].Address,
                                                                                                 mem_store_history[i].Data);
        //ref_mem_store_history.delete(i);
        //mem_store_history.delete(i);
    end else begin
        $display(" >> mem_store_history[%0d] Mismatch!!", i);
        $error("ERROR: mem_store_history mismatch");
        $display("      ref_mem_store_history[%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, ref_mem_store_history[i].cur_time, ref_mem_store_history[i].Pc, ref_mem_store_history[i].Address, ref_mem_store_history[i].Data);
        $display("      mem_store_history    [%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, mem_store_history[i].cur_time    , mem_store_history[i].Pc    , mem_store_history[i].Address    , mem_store_history[i].Data    );
        s_msg = "Store data integrity test failed - mem_store_history mismatch";
    end
end

if(ref_mem_store_history.size() != mem_store_history.size()) begin
    $error("ERROR: mem_store_history size mismatch");
    s_msg = "Store data integrity test failed - mem_store_history size mismatch";
end else begin
    $display("mem_store_history size match");
end
$display("Store data Integrity final status: %s", s_msg);
$display("====================================\n");
//TODO - review why the below code is not working (history not empty)
//if(ref_mem_store_history.size() != 0) begin
//    $error("ERROR: mem_store_history not empty");
//end else begin
//    $display("mem_store_history size match");
//end
endtask

string l_msg = "Load data integrity test passed"; // default
task di_mem_load();
$display("ref_mem_load_history size = %0d", ref_mem_load_history.size());
$display("mem_load_history size     = %0d", mem_load_history.size());
foreach(ref_mem_load_history[i])begin
    if ((ref_mem_load_history[i].Address == mem_load_history[i].Address ) && 
        (ref_mem_load_history[i].Data    == mem_load_history[i].Data ) )
    begin
        $display(" >> mem_load_history[%0d] Match: time: %0d, PC: %8h, Address: %h, Data: %h", i, mem_load_history[i].cur_time,
                                                                                                 mem_load_history[i].Pc,
                                                                                                 mem_load_history[i].Address,
                                                                                                 mem_load_history[i].Data);
        //ref_mem_load_history.delete(i);
        //mem_load_history.delete(i);
    end else begin
        $display(" >> mem_load_history[%0d] Mismatch!!", i);
        $error("ERROR: mem_load_history mismatch");
        $display("      ref_mem_load_history[%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, ref_mem_load_history[i].cur_time, ref_mem_load_history[i].Pc, ref_mem_load_history[i].Address, ref_mem_load_history[i].Data);
        $display("      mem_load_history    [%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, mem_load_history[i].cur_time    , mem_load_history[i].Pc    , mem_load_history[i].Address    , mem_load_history[i].Data    );
        l_msg = "Load data integrity test failed - mem_load_history mismatch";
    end
end

if(ref_mem_load_history.size() != mem_load_history.size()) begin
    $error("ERROR: mem_load_history size mismatch");
    l_msg = "Load data integrity test failed - mem_load_history size mismatch";
end else begin
    $display("mem_load_history size match");
end
$display("Load data Integrity final status: %s", l_msg);
$display("===============================\n");

endtask

task sl_eot (string s_msg, string l_msg);
    #10;
    $display("======================================");
    $display("End of simulation: %s", s_msg);
    $display("======================================\n");
    
    $display("======================================");
    $display("Starting store data integrity test");
    $display("======================================\n");
    di_mem_store();

    #10;
    $display("====================================");
    $display("Starting load data integrity test");
    $display("====================================\n");
    di_mem_load();
    $finish;
endtask
