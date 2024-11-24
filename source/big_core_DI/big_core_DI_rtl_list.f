//-----------------------------------------------------------------------------
// Title            : big_core_dual_issue core
// Project          : dual issue core
//-----------------------------------------------------------------------------
// File             : rtl file list
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 11/2024
//-----------------------------------------------------------------------------
// Description : 6 stage dual issue core 
//-----------------------------------------------------------------------------

+incdir+../../../source/big_core/
+incdir+../../../source/fabric/
+incdir+../../../source/common/

// param packages
../../../source/big_core/packages/big_core_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/big_core/big_core_if.sv
../../../source/big_core/big_core_ctrl.sv
../../../source/big_core/big_core_rf.sv
../../../source/big_core/big_core_cr_mem.sv
../../../source/big_core/big_core_exe.sv
../../../source/big_core/big_core_csr.sv
../../../source/big_core/big_core_vga_ctrl.sv
../../../source/big_core/big_core_vga_sync_gen.sv
../../../source/big_core/vga_mem.sv
../../../source/big_core/big_core_mem_acs1.sv
../../../source/big_core/big_core_mem_acs2.sv
../../../source/big_core/big_core_wb.sv
../../../source/big_core/big_core.sv
../../../source/big_core/big_core_top.sv
../../../source/big_core/big_core_mem_wrap.sv
../../../source/big_core/big_core_d_mem_wrap.sv

// KBD FIles
../../../source/big_core/ps2_kbd/ps2_kbd_ctrl.sv




