//-----------------------------------------------------------------------------
// Title            : simple core  design
// Project          : simple_core
//-----------------------------------------------------------------------------
// File             : core
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 9/2022
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------


+incdir+../../../source/common/
+incdir+../../../source/mini_core/
+incdir+../../../source/accel_core/
+incdir+../../../source/big_core/
+incdir+../../../source/fabric/

// param packages
../../../source/mini_core/mini_core_pkg.sv
../../../source/accel_core/accel_core_cr_pkg.sv


// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/mini_core/mini_core_if.sv
../../../source/mini_core/mini_core_ctrl.sv
../../../source/mini_core/mini_core_rf.sv
../../../source/mini_core/mini_core_exe.sv
../../../source/mini_core/mini_core_mem_acs.sv
../../../source/mini_core/mini_core_wb.sv
../../../source/mini_core/mini_core.sv
../../../source/accel_core/accel_core_cr_mem.sv
../../../source/accel_core/accel_core_mem_wrap.sv
../../../source/accel_core/accel_core_xor.sv

// additional files
../../../source/accel_core/accel_core_top.sv


