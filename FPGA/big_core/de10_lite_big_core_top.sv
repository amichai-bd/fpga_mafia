
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

`include "macros.sv"
module de10_lite_big_core_top(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input logic      [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// Accelerometer //////////
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

//=======================================================
//  Structural coding
//=======================================================

big_core big_core (
	.Clk                   (MAX10_CLK1_50), //    input  logic        Clk,
	.Rst                   (~KEY[0] ),      //    input  logic        Rst,
    // Instruction Memory
	.PcQ100H               (),              //    output logic [31:0] PcQ100H,             // To I_MEM
	.PreInstructionQ101H   ({SW[9:0],SW[9:0],SW[9:0],SW[1:0]} ), //    input  logic [31:0] PreInstructionQ101H, // From I_MEM
    // Data Memory
	.DMemWrDataQ103H       ( ),             //    output logic [31:0] DMemWrDataQ103H,     // To D_MEM
	.DMemAddressQ103H      ( ),             //    output logic [31:0] DMemAddressQ103H,    // To D_MEM
	.DMemByteEnQ103H       ( ),             //    output logic [3:0]  DMemByteEnQ103H,     // To D_MEM
	.DMemWrEnQ103H         ( ),             //    output logic        DMemWrEnQ103H,       // To D_MEM
	.DMemRdEnQ103H         ( ),             //    output logic        DMemRdEnQ103H,       // To D_MEM
	.DMemRdRspQ104H        ({SW[9:0],SW[9:0],SW[9:0],SW[1:0]})//    input  logic [31:0] DMemRdRspQ104H       // From D_MEM
);



// =======================================================	
//  This logic is just to clean all the warnings	
// =======================================================	
//outputs
`MAFIA_DFF(DRAM_ADDR[12:0] ,{SW[9:0], SW[2:0]} , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_BA[1:0]    , SW[1:0] , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_CAS_N      , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_CKE        , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_CLK        , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_CS_N       , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_LDQM       , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_RAS_N      , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_UDQM       , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(DRAM_WE_N       , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(HEX0[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(HEX1[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(HEX2[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(HEX3[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(HEX4[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(HEX5[7:0]       , SW[7:0] , MAX10_CLK1_50)
`MAFIA_DFF(LEDR[9:0]       , SW[9:0] , MAX10_CLK1_50)
`MAFIA_DFF(VGA_B[3:0]      , SW[3:0] , MAX10_CLK1_50)
`MAFIA_DFF(VGA_G[3:0]      , SW[3:0] , MAX10_CLK1_50)
`MAFIA_DFF(VGA_R[3:0]      , SW[3:0] , MAX10_CLK1_50)
`MAFIA_DFF(VGA_HS          , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(VGA_VS          , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(GSENSOR_CS_N    , SW[0]   , MAX10_CLK1_50)
`MAFIA_DFF(GSENSOR_SCLK    , SW[0]   , MAX10_CLK1_50)
// inputs:
logic temp;
logic next_temp;
assign next_temp = (|KEY) || (|GSENSOR_INT);
`MAFIA_DFF(temp    , next_temp   , ADC_CLK_10)
//inout
logic       	NEXT_GSENSOR_SDI;
logic       	NEXT_GSENSOR_SDO;
logic       	NEXT_ARDUINO_RESET_N;
logic [15:0]	NEXT_DRAM_DQ;
logic [15:0]	NEXT_ARDUINO_IO;
logic [35:0]	NEXT_GPIO;
`MAFIA_DFF( NEXT_GSENSOR_SDI      , SW[0] , MAX10_CLK2_50)
`MAFIA_DFF( NEXT_GSENSOR_SDO      , SW[0] , MAX10_CLK2_50)
`MAFIA_DFF( NEXT_ARDUINO_RESET_N  , SW[0] , MAX10_CLK2_50)
`MAFIA_DFF( NEXT_DRAM_DQ[15:0]    , {SW[9:0],SW[2:0]} 				 , MAX10_CLK2_50)
`MAFIA_DFF( NEXT_ARDUINO_IO[15:0] , {SW[9:0],SW[5:0]} 				 , MAX10_CLK2_50)
`MAFIA_DFF( NEXT_GPIO [35:0]      , {SW[9:0],SW[9:0],SW[9:0],SW[5:0]} , MAX10_CLK2_50)
assign GSENSOR_SDI 		= temp ? NEXT_GSENSOR_SDI 		: 'Z;
assign GSENSOR_SDO 		= temp ? NEXT_GSENSOR_SDO 		: 'Z;
assign ARDUINO_RESET_N 	= temp ? NEXT_ARDUINO_RESET_N 	: 'Z;
assign DRAM_DQ[15:0] 	= temp ? NEXT_DRAM_DQ[15:0] 	: 'Z;
assign ARDUINO_IO[15:0] = temp ? NEXT_ARDUINO_IO[15:0]  : 'Z;
assign GPIO[35:0] 		= temp ? NEXT_GPIO[35:0] 		: 'Z;

endmodule
