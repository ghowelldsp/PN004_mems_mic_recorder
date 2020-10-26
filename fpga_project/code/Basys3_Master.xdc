                                                                                                                                                                                                                                                                      ## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK]

## Switches
#set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
#set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
#set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
#set_property PACKAGE_PIN R2 [get_ports {sw[15]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]


# LEDs
#set_property PACKAGE_PIN U16 [get_ports {LEDS[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[0]}]
#set_property PACKAGE_PIN E19 [get_ports {LEDS[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[1]}]
#set_property PACKAGE_PIN U19 [get_ports {LEDS[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[2]}]
#set_property PACKAGE_PIN V19 [get_ports {LEDS[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[3]}]
#set_property PACKAGE_PIN W18 [get_ports {LEDS[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[4]}]
#set_property PACKAGE_PIN U15 [get_ports {LEDS[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[5]}]
#set_property PACKAGE_PIN U14 [get_ports {LEDS[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[6]}]
#set_property PACKAGE_PIN V14 [get_ports {LEDS[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[7]}]
#set_property PACKAGE_PIN V13 [get_ports {LEDS[8]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[8]}]
#set_property PACKAGE_PIN V3 [get_ports {LEDS[9]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[9]}]
#set_property PACKAGE_PIN W3 [get_ports {LEDS[10]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[10]}]
#set_property PACKAGE_PIN U3 [get_ports {LEDS[11]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[11]}]
#set_property PACKAGE_PIN P3 [get_ports {LEDS[12]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[12]}]
#set_property PACKAGE_PIN N3 [get_ports {LEDS[13]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[13]}]
#set_property PACKAGE_PIN P1 [get_ports {LEDS[14]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[14]}]
#set_property PACKAGE_PIN L1 [get_ports {LEDS[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[8]}]


#7 segment display
#set_property PACKAGE_PIN W7 [get_ports {SSD_SEG_VALUE[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[6]}]
#set_property PACKAGE_PIN W6 [get_ports {SSD_SEG_VALUE[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[5]}]
#set_property PACKAGE_PIN U8 [get_ports {SSD_SEG_VALUE[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[4]}]
#set_property PACKAGE_PIN V8 [get_ports {SSD_SEG_VALUE[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[3]}]
#set_property PACKAGE_PIN U5 [get_ports {SSD_SEG_VALUE[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[2]}]
#set_property PACKAGE_PIN V5 [get_ports {SSD_SEG_VALUE[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[1]}]
#set_property PACKAGE_PIN U7 [get_ports {SSD_SEG_VALUE[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_VALUE[0]}]

#set_property PACKAGE_PIN V7 [get_ports dp]
#    set_property IOSTANDARD LVCMOS33 [get_ports dp]

#set_property PACKAGE_PIN U2 [get_ports {SSD_SEG_NUM[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_NUM[0]}]
#set_property PACKAGE_PIN U4 [get_ports {SSD_SEG_NUM[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_NUM[1]}]
#set_property PACKAGE_PIN V4 [get_ports {SSD_SEG_NUM[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_NUM[2]}]
#set_property PACKAGE_PIN W4 [get_ports {SSD_SEG_NUM[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SSD_SEG_NUM[3]}]



##Buttons
#set_property PACKAGE_PIN U18 [get_ports btnC]
#	set_property IOSTANDARD LVCMOS33 [get_ports btnC]
#set_property PACKAGE_PIN T18 [get_ports btnU]
#	set_property IOSTANDARD LVCMOS33 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]
#	set_property IOSTANDARD LVCMOS33 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]
#	set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]
#	set_property IOSTANDARD LVCMOS33 [get_ports btnD]



#Pmod Header JA
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {SCLK}]
	set_property IOSTANDARD LVCMOS33 [get_ports {SCLK}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {CS_N}]
	set_property IOSTANDARD LVCMOS33 [get_ports {CS_N}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {MOSI}]
	set_property IOSTANDARD LVCMOS33 [get_ports {MOSI}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {MISO}]
	set_property IOSTANDARD LVCMOS33 [get_ports {MISO}]
#Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {CLK_PDM_HD}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {CLK_PDM_HD}]
#Sch name = JA8
#set_property PACKAGE_PIN K2 [get_ports {PDM_DATA_IN}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {PDM_DATA_IN}]
##Sch name = JA9
#set_property PACKAGE_PIN H2 [get_ports {pdm_data_in_7}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {pdm_data_in_7}]
##Sch name = JA10
#set_property PACKAGE_PIN G3 [get_ports {pdm_data_in_8}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {pdm_data_in_8}]


#Pmod Header JB
#Sch name = JB1
#set_property PACKAGE_PIN A14 [get_ports FIFO_RD_EN_1]
#    set_property IOSTANDARD LVCMOS33 [get_ports FIFO_RD_EN_1]
##Sch name = JB2
#set_property PACKAGE_PIN A16 [get_ports FIFO_RD_EN_2]
#    set_property IOSTANDARD LVCMOS33 [get_ports FIFO_RD_EN_2]
##Sch name = JB3
#set_property PACKAGE_PIN B15 [get_ports I2S_DOUT_1]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_1]
##Sch name = JB4
#set_property PACKAGE_PIN B16 [get_ports I2S_DOUT_2]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_2]
##Sch name = JB7
#set_property PACKAGE_PIN A15 [get_ports I2S_DOUT_3]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_3]
##Sch name = JB8
#set_property PACKAGE_PIN A17 [get_ports I2S_DOUT_4]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_4]
##Sch name = JB9
#set_property PACKAGE_PIN C15 [get_ports PDM_DATA_IN_7]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_DATA_IN_7]
##Sch name = JB10
#set_property PACKAGE_PIN C16 [get_ports PDM_DATA_IN_8]
#set_property IOSTANDARD LVCMOS33 [get_ports PDM_DATA_IN_8]



#Pmod Header JC
#Sch name = JC1
#set_property PACKAGE_PIN K17 [get_ports B_CLK]
#set_property IOSTANDARD LVCMOS33 [get_ports B_CLK]
##Sch name = JC2
#set_property PACKAGE_PIN M18 [get_ports LR_CLK]
#set_property IOSTANDARD LVCMOS33 [get_ports LR_CLK]
##Sch name = JC3
#set_property PACKAGE_PIN N17 [get_ports I2S_DOUT_1]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_1]
##Sch name = JC4
#set_property PACKAGE_PIN P18 [get_ports I2S_DOUT_2]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_2]
##Sch name = JC7
#set_property PACKAGE_PIN L17 [get_ports I2S_DOUT_3]
#set_property IOSTANDARD LVCMOS33 [get_ports I2S_DOUT_3]
##Sch name = JC8
#set_property PACKAGE_PIN M19 [get_ports {I2S_DOUT_4}]
#set_property IOSTANDARD LVCMOS33 [get_ports {I2S_DOUT_4}]
##Sch name = JC9
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
##Sch name = JC10
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]


#Pmod Header JXADC
#Sch name = XA1_P
set_property PACKAGE_PIN J3 [get_ports {CLK_PDM_HD}]
set_property IOSTANDARD LVCMOS33 [get_ports {CLK_PDM_HD}]
#Sch name = XA2_P
set_property PACKAGE_PIN L3 [get_ports {PDM_DATA_IN}]
set_property IOSTANDARD LVCMOS33 [get_ports {PDM_DATA_IN}]
#Sch name = XA3_P
#set_property PACKAGE_PIN M2 [get_ports {FIFO_FULL_1}]
#set_property IOSTANDARD LVCMOS33 [get_ports {FIFO_FULL_1}]
##Sch name = XA4_P
#set_property PACKAGE_PIN N2 [get_ports {FIFO_FULL_2}]
#set_property IOSTANDARD LVCMOS33 [get_ports {FIFO_FULL_2}]
##Sch name = XA1_N
#set_property PACKAGE_PIN K3 [get_ports {FIFO_SELECT}]
#set_property IOSTANDARD LVCMOS33 [get_ports {FIFO_SELECT}]
##Sch name = XA2_N
#set_property PACKAGE_PIN M3 [get_ports {fifoFullAtRd}]
#set_property IOSTANDARD LVCMOS33 [get_ports {fifoFullAtRd}]
##Sch name = XA3_N
#set_property PACKAGE_PIN M1 [get_ports {bothFifoFull}]
#set_property IOSTANDARD LVCMOS33 [get_ports {bothFifoFull}]
###Sch name = XA4_N
#set_property PACKAGE_PIN N1 [get_ports {bothFifoFull}]
#set_property IOSTANDARD LVCMOS33 [get_ports {bothFifoFull}]



##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports Hsync]
#set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
#set_property PACKAGE_PIN R19 [get_ports Vsync]
#set_property IOSTANDARD LVCMOS33 [get_ports Vsync]


##USB-RS232 Interface
#set_property PACKAGE_PIN A18 [get_ports uart_data_out]
#	set_property IOSTANDARD LVCMOS33 [get_ports uart_data_out]
#set_property PACKAGE_PIN B18 [get_ports uart_txd_in]
#	set_property IOSTANDARD LVCMOS33 [get_ports uart_txd_in]


##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]
#set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]
#set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]
#set_property PULLUP true [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property PACKAGE_PIN D18 [get_ports {QspiDB[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[0]}]
#set_property PACKAGE_PIN D19 [get_ports {QspiDB[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[1]}]
#set_property PACKAGE_PIN G18 [get_ports {QspiDB[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[2]}]
#set_property PACKAGE_PIN F18 [get_ports {QspiDB[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {QspiDB[3]}]
#set_property PACKAGE_PIN K19 [get_ports QspiCSn]
#set_property IOSTANDARD LVCMOS33 [get_ports QspiCSn]
