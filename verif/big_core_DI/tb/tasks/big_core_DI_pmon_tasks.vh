integer pmon_file;
real instret_high_low_real;
real cycle_high_low_real;
real result_ipc, result_cpi;

 task track_performance();
 pmon_file = $fopen({"../../../target/big_core_DI/tests/",test_name,"/trk_cpi_ipc.log"},"w");
       $fdisplay(pmon_file,"===========================================");
       $fdisplay(pmon_file,"PMON tracker for ", test_name, " test");
       $fdisplay(pmon_file,"Monitoring IPC and CPI");
       $fdisplay(pmon_file,"==========================================");
       $fdisplay(pmon_file,"\nSummary report");
       $fdisplay(pmon_file,"---------------------");
       $fdisplay(pmon_file, "Number of cycles: %1d\nNumber of valid instructions: %1d",big_core_top.big_core.big_core_csr.csr_mcycle_high_low, big_core_top.big_core.big_core_csr.csr_minstret_high_low);
       
       // calculatin IPC and CPI
       instret_high_low_real = big_core_top.big_core.big_core_csr.csr_minstret_high_low;
       cycle_high_low_real = big_core_top.big_core.big_core_csr.csr_mcycle_high_low;
       result_ipc = instret_high_low_real / cycle_high_low_real;
       result_cpi = cycle_high_low_real / instret_high_low_real;
       $fdisplay(pmon_file, "IPC(instruction per cycles) =  %f", $sformatf("%.3f", result_ipc));
       $fdisplay(pmon_file, "IPC[%%] =  %f", $sformatf("%.3f", result_ipc*100));
       $fdisplay(pmon_file, "CPI(cycles per instruction) =  %f", $sformatf("%.3f", result_cpi));
       $fclose(pmon_file);
 endtask;     
 