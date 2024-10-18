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
../../../source/accel_core/accel_core_pkg.sv


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


// accel core files
../../../source/accel_core/accel_core_top.sv
../../../source/accel_core/accel_core_cr_mem.sv
../../../source/accel_core/accel_core_mem_wrap.sv


//accel core farm files
../../../source/accel_core/accel_core_xor.sv
../../../source/accel_core/accel_core_booth_pipeline.sv
../../../source/accel_core/accel_core_mul_wrapper.sv
../../../source/accel_core/shift_multiplier.sv
../../../source/accel_core/accel_core_farm.sv
../../../source/accel_core/accel_core_mul_controller.sv
//../../../source/accel_core/accel_core_mul_top.sv
