
integer trk_alu;
initial begin: trk_alu_gen
    $timeformat(-12, 0, " ", 6);
    #1
    trk_alu = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_alu.log"},"w");
    $fwrite(trk_alu,"---------------------------------------------------------\n");
    $fwrite(trk_alu,"Time\t|\tPC \t | AluIn1Q102H\t| AluIn2Q102H\t| AluOutQ102H\t|\n");
    $fwrite(trk_alu,"---------------------------------------------------------\n");  

end
//tracker on ALU operations
always @(posedge Clk) begin : alu_print
    $fwrite(trk_alu,"%t\t| %8h |%8h \t|%8h \t|%8h \t| \n", $realtime,PcQ102H, big_core_top.big_core.big_core_exe.AluIn1Q102H , big_core_top.big_core.big_core_exe.AluIn2Q102H, big_core_top.big_core.big_core_exe.AluOutQ102H);
end

integer trk_inst;
initial begin: trk_inst_gen
    #1
    trk_inst = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_inst.log"},"w");
    $fwrite(trk_inst,"---------------------------------------------------------\n");
    $fwrite(trk_inst,"PC \t | Instruction\t|\n");
    $fwrite(trk_inst,"---------------------------------------------------------\n");  

end
always @(posedge Clk) begin : inst_print
    if(big_core_top.big_core.big_core_ctrl.ValidInstQ105H)
        $fwrite(trk_inst,"%8h \t |%8h | \n", 
        big_core_top.big_core.big_core_ctrl.CtrlQ105H.Pc, 
        big_core_top.big_core.big_core_ctrl.CtrlQ105H.Instruction);
end

integer trk_inst_ref;
initial begin: trk_inst_ref_gen
    #1
    trk_inst_ref = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_inst_ref.log"},"w");
    $fwrite(trk_inst_ref,"---------------------------------------------------------\n");
    $fwrite(trk_inst_ref,"PC \t | Instruction\t|\n");
    $fwrite(trk_inst_ref,"---------------------------------------------------------\n");  

end


//=============================
// Memory Access tracking
//=============================
// delay writes to mem by two cycles
// Region - can be from any region. Data/VGA/CR memory

logic RegionMemWrEnQ104H, RegionMemWrEnQ105H;
`MAFIA_DFF(RegionMemWrEnQ104H, big_core_top.big_core.big_core_mem_access1.Ctrl.DMemWrEnQ103H , Clk)
`MAFIA_DFF(RegionMemWrEnQ105H, RegionMemWrEnQ104H , Clk)

logic [31:0] RegionMemWrDataQ104H, RegionMemWrDataQ105H;
`MAFIA_DFF(RegionMemWrDataQ104H, big_core_top.big_core.big_core_mem_access1.DMemWrDataQ103H , Clk)
`MAFIA_DFF(RegionMemWrDataQ105H, RegionMemWrDataQ104H , Clk)

logic [31:0] RegionMemAddrQ104H, RegionMemAddrQ105H;
`MAFIA_DFF(RegionMemAddrQ104H, big_core_top.big_core.big_core_mem_access1.AluOutQ103H , Clk)
`MAFIA_DFF(RegionMemAddrQ105H, RegionMemAddrQ104H , Clk)

logic VGAHitQ104H, VGAHitQ105H;
logic CRHitQ104H, CRHitQ105H;
`MAFIA_DFF(VGAHitQ104H, big_core_top.big_core_mem_wrap.MatchVGAMemRegionQ103H , Clk)
`MAFIA_DFF(VGAHitQ105H, VGAHitQ104H , Clk)
`MAFIA_DFF(CRHitQ104H, big_core_top.big_core_mem_wrap.MatchCRMemRegionQ103H , Clk)
`MAFIA_DFF(CRHitQ105H, CRHitQ104H , Clk)

// read signals
logic [31:0] RegionMemRdDataQ105H;
logic [31:0] RegionMemRdEnQ104H, RegionMemRdEnQ105H;
assign RegionMemRdDataQ105H  = big_core_top.big_core.big_core_wb.PostSxDMemRdDataQ105H;  // data read from memorry in case of MemRdEn
`MAFIA_DFF(RegionMemRdEnQ104H, big_core_top.big_core.big_core_mem_access1.Ctrl.DMemRdEnQ103H , Clk)
`MAFIA_DFF(RegionMemRdEnQ105H, RegionMemRdEnQ104H , Clk)


integer trk_data_memory_access;
initial begin: trk_data_memory_access_gen
    #1
    trk_data_memory_access = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_data_memory_access.log"},"w");
    $fwrite(trk_data_memory_access,"----------------------------------------------------\n");
    $fwrite(trk_data_memory_access,"Time  |  PC   | Address  | Data  |\n");
    $fwrite(trk_data_memory_access,"----------------------------------------------------\n");  
end

integer trk_vga_memory_access;
initial begin: trk_vga_memory_access_gen
    #1
    trk_vga_memory_access = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_vga_memory_access.log"},"w");
    $fwrite(trk_vga_memory_access,"----------------------------------------------------\n");
    $fwrite(trk_vga_memory_access,"Time  |  PC   | Address  | Data  |\n");
    $fwrite(trk_vga_memory_access,"----------------------------------------------------\n");  
end

integer trk_cr_data_memory_access;
initial begin: trk_cr_memory_access_gen
    #1
    trk_cr_data_memory_access = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_cr_data_memory_access.log"},"w");
    $fwrite(trk_cr_data_memory_access,"----------------------------------------------------\n");
    $fwrite(trk_cr_data_memory_access,"Time  |  PC   |  Address  | Data  |\n");
    $fwrite(trk_cr_data_memory_access,"----------------------------------------------------\n");  
end

//tracker on memory_access operations
always @(posedge Clk) begin : memory_access_print
    if(RegionMemWrEnQ105H) begin
        if(VGAHitQ105H) begin
            $fwrite(trk_vga_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemWrDataQ105H);
        end
        else if(CRHitQ105H) begin
            $fwrite(trk_cr_data_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemWrDataQ105H);
        end
        else begin
            $fwrite(trk_data_memory_access,"%t | %8h | write |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemWrDataQ105H);
        end 
    end
    if(RegionMemRdEnQ105H) begin
        if(VGAHitQ105H) begin
            $fwrite(trk_vga_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemRdDataQ105H);
        end
        else if(CRHitQ105H) begin
            $fwrite(trk_cr_data_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemRdDataQ105H);
        end
        else begin
            $fwrite(trk_data_memory_access,"%t | %8h | read  |%8h |%8h \n", $realtime, PcQ105H, RegionMemAddrQ105H, RegionMemRdDataQ105H);
        end
    end
end


integer trk_reg_write;
initial begin: trk_reg_write_gen
    #1
    trk_reg_write = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_reg_write.log"},"w");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");
    $fwrite(trk_reg_write," Time | PC |reg_dst|  X0   ,  X1   ,  X2   ,  X3    ,  X4    ,  X5    ,  X6    ,  X7    ,  X8    ,  X9    ,  X10    , X11    , X12    , X13    , X14    , X15    , X16    , X17    , X18    , X19    , X20    , X21    , X22    , X23    , X24    , X25    , X26    , X27    , X28    , X29    , X30    , X31 \n");
    $fwrite(trk_reg_write,"---------------------------------------------------------\n");  
end

always_ff @(posedge Clk ) begin
        $fwrite(trk_reg_write,"%6d | %4h | %2d | %8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h,%8h \n"
        ,$time,            
                           PcQ105H,
                           big_core_top.big_core.big_core_rf.Ctrl.RegDstQ105H,
                           big_core_top.big_core.big_core_rf.Register[0],
                           big_core_top.big_core.big_core_rf.Register[1],
                           big_core_top.big_core.big_core_rf.Register[2],
                           big_core_top.big_core.big_core_rf.Register[3],
                           big_core_top.big_core.big_core_rf.Register[4],
                           big_core_top.big_core.big_core_rf.Register[5],
                           big_core_top.big_core.big_core_rf.Register[6],
                           big_core_top.big_core.big_core_rf.Register[7],
                           big_core_top.big_core.big_core_rf.Register[8],
                           big_core_top.big_core.big_core_rf.Register[9],
                           big_core_top.big_core.big_core_rf.Register[10],
                           big_core_top.big_core.big_core_rf.Register[11],
                           big_core_top.big_core.big_core_rf.Register[12],
                           big_core_top.big_core.big_core_rf.Register[13],
                           big_core_top.big_core.big_core_rf.Register[14],
                           big_core_top.big_core.big_core_rf.Register[15],
                           big_core_top.big_core.big_core_rf.Register[16],
                           big_core_top.big_core.big_core_rf.Register[17],
                           big_core_top.big_core.big_core_rf.Register[18],
                           big_core_top.big_core.big_core_rf.Register[19],
                           big_core_top.big_core.big_core_rf.Register[20],
                           big_core_top.big_core.big_core_rf.Register[21],
                           big_core_top.big_core.big_core_rf.Register[22],
                           big_core_top.big_core.big_core_rf.Register[23],
                           big_core_top.big_core.big_core_rf.Register[24],
                           big_core_top.big_core.big_core_rf.Register[25],
                           big_core_top.big_core.big_core_rf.Register[26],
                           big_core_top.big_core.big_core_rf.Register[27],
                           big_core_top.big_core.big_core_rf.Register[28],
                           big_core_top.big_core.big_core_rf.Register[29],
                           big_core_top.big_core.big_core_rf.Register[30],
                           big_core_top.big_core.big_core_rf.Register[31]
                           );
end
// FIXME

