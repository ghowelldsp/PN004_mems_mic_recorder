// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sun May 24 15:24:08 2020
// Host        : DESKTOP-H4I3KC3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top mmcm_clock -prefix
//               mmcm_clock_ mmcm_clock_stub.v
// Design      : mmcm_clock
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mmcm_clock(CLK_OUT1, reset, LOCKED, SYSCLK)
/* synthesis syn_black_box black_box_pad_pin="CLK_OUT1,reset,LOCKED,SYSCLK" */;
  output CLK_OUT1;
  input reset;
  output LOCKED;
  input SYSCLK;
endmodule
