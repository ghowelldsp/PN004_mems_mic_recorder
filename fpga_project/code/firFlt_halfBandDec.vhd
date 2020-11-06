----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2020 19:09:26
-- Design Name: 
-- Module Name: firFlt_halfBandDec - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity firFlt_halfBandDec is
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_CE              : in    std_logic;                      -- clock enable
            DIN                 : in    std_logic_vector (15 downto 0); -- input data
            DOUT                : out   std_logic_vector (15 downto 0)  -- output data
            );
end firFlt_halfBandDec;

architecture Behavioral of firFlt_halfBandDec is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ signal DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

---- Constants
constant coeffphase2_1                  : signed(15 downto 0) := to_signed(-3, 16); -- sfix16_En15
constant coeffphase2_2                  : signed(15 downto 0) := to_signed(13, 16); -- sfix16_En15
constant coeffphase2_3                  : signed(15 downto 0) := to_signed(-33, 16); -- sfix16_En15
constant coeffphase2_4                  : signed(15 downto 0) := to_signed(73, 16); -- sfix16_En15
constant coeffphase2_5                  : signed(15 downto 0) := to_signed(-141, 16); -- sfix16_En15
constant coeffphase2_6                  : signed(15 downto 0) := to_signed(251, 16); -- sfix16_En15
constant coeffphase2_7                  : signed(15 downto 0) := to_signed(-421, 16); -- sfix16_En15
constant coeffphase2_8                  : signed(15 downto 0) := to_signed(679, 16); -- sfix16_En15
constant coeffphase2_9                  : signed(15 downto 0) := to_signed(-1084, 16); -- sfix16_En15
constant coeffphase2_10                 : signed(15 downto 0) := to_signed(1776, 16); -- sfix16_En15
constant coeffphase2_11                 : signed(15 downto 0) := to_signed(-3282, 16); -- sfix16_En15
constant coeffphase2_12                 : signed(15 downto 0) := to_signed(10364, 16); -- sfix16_En15
constant coeffphase2_13                 : signed(15 downto 0) := to_signed(10364, 16); -- sfix16_En15
constant coeffphase2_14                 : signed(15 downto 0) := to_signed(-3282, 16); -- sfix16_En15
constant coeffphase2_15                 : signed(15 downto 0) := to_signed(1776, 16); -- sfix16_En15
constant coeffphase2_16                 : signed(15 downto 0) := to_signed(-1084, 16); -- sfix16_En15
constant coeffphase2_17                 : signed(15 downto 0) := to_signed(679, 16); -- sfix16_En15
constant coeffphase2_18                 : signed(15 downto 0) := to_signed(-421, 16); -- sfix16_En15
constant coeffphase2_19                 : signed(15 downto 0) := to_signed(251, 16); -- sfix16_En15
constant coeffphase2_20                 : signed(15 downto 0) := to_signed(-141, 16); -- sfix16_En15
constant coeffphase2_21                 : signed(15 downto 0) := to_signed(73, 16); -- sfix16_En15
constant coeffphase2_22                 : signed(15 downto 0) := to_signed(-33, 16); -- sfix16_En15
constant coeffphase2_23                 : signed(15 downto 0) := to_signed(13, 16); -- sfix16_En15
constant coeffphase2_24                 : signed(15 downto 0) := to_signed(-3, 16); -- sfix16_En15

-- Signals
TYPE data16_pipeline_type IS ARRAY (NATURAL range <>) OF signed(15 downto 0); -- sfix16_En14
TYPE data32_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 downto 0); -- sfix16_En14
signal coeffArray                       : data16_pipeline_type(0 TO 23);
signal prodArray                        : data32_pipeline_type(0 TO 23) := (others => (others => '0'));
signal ring_count                       : unsigned(1 downto 0); -- ufix2
signal phase_0                          : std_logic; -- boolean
signal phase_1                          : std_logic; -- boolean
signal input_typeconvert                : signed(15 downto 0); -- sfix16_En14
signal input_pipeline_phase0            : data16_pipeline_type(0 TO 11); -- sfix16_En14
signal input_pipeline_phase1            : data16_pipeline_type(0 TO 23); -- sfix16_En14
signal product_phase0_13                : signed(31 downto 0); -- sfix32_En29
signal prodCnt                          : integer range 0 to 23;
signal multiPhaseCeCnt                  : unsigned(0 downto 0);
signal multiPhaseCe                     : std_logic;

signal quantized_sum                    : signed(63 downto 0); -- sfix64_En29
signal sum1                             : signed(63 downto 0); -- sfix64_En29
signal add_cast                         : signed(63 downto 0); -- sfix64_En29
signal add_cast_1                       : signed(63 downto 0); -- sfix64_En29
signal add_temp                         : signed(64 downto 0); -- sfix65_En29
signal sum2                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_2                       : signed(63 downto 0); -- sfix64_En29
signal add_cast_3                       : signed(63 downto 0); -- sfix64_En29
signal add_temp_1                       : signed(64 downto 0); -- sfix65_En29
signal sum3                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_4                       : signed(63 downto 0); -- sfix64_En29
signal add_cast_5                       : signed(63 downto 0); -- sfix64_En29
signal add_temp_2                       : signed(64 downto 0); -- sfix65_En29
signal sum4                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_6                       : signed(63 downto 0); -- sfix64_En29
signal add_cast_7                       : signed(63 downto 0); -- sfix64_En29
signal add_temp_3                       : signed(64 downto 0); -- sfix65_En29
signal sum5                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_8                       : signed(63 downto 0); -- sfix64_En29
signal add_cast_9                       : signed(63 downto 0); -- sfix64_En29
signal add_temp_4                       : signed(64 downto 0); -- sfix65_En29
signal sum6                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_10                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_11                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_5                       : signed(64 downto 0); -- sfix65_En29
signal sum7                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_12                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_13                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_6                       : signed(64 downto 0); -- sfix65_En29
signal sum8                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_14                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_15                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_7                       : signed(64 downto 0); -- sfix65_En29
signal sum9                             : signed(63 downto 0); -- sfix64_En29
signal add_cast_16                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_17                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_8                       : signed(64 downto 0); -- sfix65_En29
signal sum10                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_18                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_19                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_9                       : signed(64 downto 0); -- sfix65_En29
signal sum11                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_20                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_21                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_10                      : signed(64 downto 0); -- sfix65_En29
signal sum12                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_22                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_23                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_11                      : signed(64 downto 0); -- sfix65_En29
signal sum13                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_24                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_25                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_12                      : signed(64 downto 0); -- sfix65_En29
signal sum14                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_26                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_27                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_13                      : signed(64 downto 0); -- sfix65_En29
signal sum15                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_28                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_29                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_14                      : signed(64 downto 0); -- sfix65_En29
signal sum16                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_30                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_31                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_15                      : signed(64 downto 0); -- sfix65_En29
signal sum17                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_32                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_33                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_16                      : signed(64 downto 0); -- sfix65_En29
signal sum18                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_34                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_35                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_17                      : signed(64 downto 0); -- sfix65_En29
signal sum19                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_36                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_37                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_18                      : signed(64 downto 0); -- sfix65_En29
signal sum20                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_38                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_39                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_19                      : signed(64 downto 0); -- sfix65_En29
signal sum21                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_40                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_41                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_20                      : signed(64 downto 0); -- sfix65_En29
signal sum22                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_42                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_43                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_21                      : signed(64 downto 0); -- sfix65_En29
signal sum23                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_44                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_45                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_22                      : signed(64 downto 0); -- sfix65_En29
signal sum24                            : signed(63 downto 0); -- sfix64_En29
signal add_cast_46                      : signed(63 downto 0); -- sfix64_En29
signal add_cast_47                      : signed(63 downto 0); -- sfix64_En29
signal add_temp_23                      : signed(64 downto 0); -- sfix65_En29
signal output_typeconvert               : signed(15 downto 0); -- sfix16_En14
signal regoutTmp                        : signed(15 downto 0); -- sfix16_En14
signal regout                           : signed(15 downto 0); -- sfix16_En14
signal muxout                           : signed(15 downto 0); -- sfix16_En14

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------
    
    ---------------------------- ASSIGN COEFFICIENT VALUES ----------------------------
    
    coeffArray(0) <= coeffphase2_1;
    coeffArray(1) <= coeffphase2_2;
    coeffArray(2) <= coeffphase2_3;
    coeffArray(3) <= coeffphase2_4;
    coeffArray(4) <= coeffphase2_5;
    coeffArray(5) <= coeffphase2_6;
    coeffArray(6) <= coeffphase2_7;
    coeffArray(7) <= coeffphase2_8;
    coeffArray(8) <= coeffphase2_9;
    coeffArray(9) <= coeffphase2_10;
    coeffArray(10) <= coeffphase2_11;
    coeffArray(11) <= coeffphase2_12;
    coeffArray(12) <= coeffphase2_13;
    coeffArray(13) <= coeffphase2_14;
    coeffArray(14) <= coeffphase2_15;
    coeffArray(15) <= coeffphase2_16;
    coeffArray(16) <= coeffphase2_17;
    coeffArray(17) <= coeffphase2_18;
    coeffArray(18) <= coeffphase2_19;
    coeffArray(19) <= coeffphase2_20;
    coeffArray(20) <= coeffphase2_21;
    coeffArray(21) <= coeffphase2_22;
    coeffArray(22) <= coeffphase2_23;
    coeffArray(23) <= coeffphase2_24;
    
    ----------------------------------- PHASE CE --------------------------------------

    ce_output : process (CLK, RST)
    begin
        if (RST = '1') then
            ring_count <= to_unsigned(1, 2);
        elsif (rising_edge(CLK)) then
            if CLK_CE = '1' then
                ring_count <= ring_count(0) & ring_count(1);
            end if;
        end if; 
    end process ce_output;
    
    phase_0 <= ring_count(0) and CLK_CE;
    
    phase_1 <= ring_count(1) and CLK_CE;
    
    input_typeconvert <= signed(DIN);
    
    Delay_Pipeline_Phase0_process : process (CLK, RST)
    begin
        if RST = '1' then
            input_pipeline_phase0(0 TO 11) <= (others => (others => '0'));
        elsif (rising_edge(CLK)) then
            if phase_0 = '1' then
                input_pipeline_phase0(0) <= input_typeconvert;
                input_pipeline_phase0(1 TO 11) <= input_pipeline_phase0(0 TO 10);
            end if;
        end if; 
    end process Delay_Pipeline_Phase0_process;
    
    Delay_Pipeline_Phase1_process : process (CLK, RST)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                input_pipeline_phase1(0 TO 23) <= (others => (others => '0'));
            elsif (phase_1 = '1') then
                input_pipeline_phase1(0) <= input_typeconvert;
                input_pipeline_phase1(1 TO 23) <= input_pipeline_phase1(0 TO 22);
            end if;
        end if;
    end process Delay_Pipeline_Phase1_process;

    product_phase0_13 <= resize(input_pipeline_phase0(11)(15 downto 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32);
    
    multi_phase_ce_process : process (CLK, RST)
    begin
        if (RST = '1') then
            multiPhaseCeCnt <= to_unsigned(1,1);
        elsif (rising_edge(CLK)) then
            multiPhaseCeCnt <= multiPhaseCeCnt + to_unsigned(1,1);
        end if;
    end process multi_phase_ce_process;
    
    multiPhaseCe <= '1' when (multiPhaseCeCnt = to_unsigned(0,1)) else '0';
    
    pipeline_counter : process (CLK, RST)
    begin
        if (RST = '1') then
            prodCnt <= 0;
        elsif (rising_edge(CLK)) then
            if (multiPhaseCe = '1') then
                if (prodCnt = 23) then
                    prodCnt <= 0;
                else
                    prodCnt <= prodCnt + 1;
                end if;
            end if;
        end if;
    end process pipeline_counter;
    
    product_process : process (CLK, RST)
    begin
        if (rising_edge(CLK)) then
            if (multiPhaseCe = '1') then
                prodArray(prodCnt) <= input_pipeline_phase1(prodCnt) * coeffArray(prodCnt);
            end if;
        end if;
    end process product_process;

    quantized_sum <= resize(prodArray(0), 64);
    
    add_cast <= quantized_sum;
    add_cast_1 <= resize(prodArray(1), 64);
    add_temp <= resize(add_cast, 65) + resize(add_cast_1, 65);
    sum1 <= add_temp(63 downto 0);
    
    add_cast_2 <= sum1;
    add_cast_3 <= resize(prodArray(2), 64);
    add_temp_1 <= resize(add_cast_2, 65) + resize(add_cast_3, 65);
    sum2 <= add_temp_1(63 downto 0);
    
    add_cast_4 <= sum2;
    add_cast_5 <= resize(prodArray(3), 64);
    add_temp_2 <= resize(add_cast_4, 65) + resize(add_cast_5, 65);
    sum3 <= add_temp_2(63 downto 0);
    
    add_cast_6 <= sum3;
    add_cast_7 <= resize(prodArray(4), 64);
    add_temp_3 <= resize(add_cast_6, 65) + resize(add_cast_7, 65);
    sum4 <= add_temp_3(63 downto 0);
    
    add_cast_8 <= sum4;
    add_cast_9 <= resize(prodArray(5), 64);
    add_temp_4 <= resize(add_cast_8, 65) + resize(add_cast_9, 65);
    sum5 <= add_temp_4(63 downto 0);
    
    add_cast_10 <= sum5;
    add_cast_11 <= resize(prodArray(6), 64);
    add_temp_5 <= resize(add_cast_10, 65) + resize(add_cast_11, 65);
    sum6 <= add_temp_5(63 downto 0);
    
    add_cast_12 <= sum6;
    add_cast_13 <= resize(prodArray(7), 64);
    add_temp_6 <= resize(add_cast_12, 65) + resize(add_cast_13, 65);
    sum7 <= add_temp_6(63 downto 0);
    
    add_cast_14 <= sum7;
    add_cast_15 <= resize(prodArray(8), 64);
    add_temp_7 <= resize(add_cast_14, 65) + resize(add_cast_15, 65);
    sum8 <= add_temp_7(63 downto 0);
    
    add_cast_16 <= sum8;
    add_cast_17 <= resize(prodArray(9), 64);
    add_temp_8 <= resize(add_cast_16, 65) + resize(add_cast_17, 65);
    sum9 <= add_temp_8(63 downto 0);
    
    add_cast_18 <= sum9;
    add_cast_19 <= resize(prodArray(10), 64);
    add_temp_9 <= resize(add_cast_18, 65) + resize(add_cast_19, 65);
    sum10 <= add_temp_9(63 downto 0);
    
    add_cast_20 <= sum10;
    add_cast_21 <= resize(prodArray(11), 64);
    add_temp_10 <= resize(add_cast_20, 65) + resize(add_cast_21, 65);
    sum11 <= add_temp_10(63 downto 0);
    
    add_cast_22 <= sum11;
    add_cast_23 <= resize(prodArray(12), 64);
    add_temp_11 <= resize(add_cast_22, 65) + resize(add_cast_23, 65);
    sum12 <= add_temp_11(63 downto 0);
    
    add_cast_24 <= sum12;
    add_cast_25 <= resize(prodArray(13), 64);
    add_temp_12 <= resize(add_cast_24, 65) + resize(add_cast_25, 65);
    sum13 <= add_temp_12(63 downto 0);
    
    add_cast_26 <= sum13;
    add_cast_27 <= resize(prodArray(14), 64);
    add_temp_13 <= resize(add_cast_26, 65) + resize(add_cast_27, 65);
    sum14 <= add_temp_13(63 downto 0);
    
    add_cast_28 <= sum14;
    add_cast_29 <= resize(prodArray(15), 64);
    add_temp_14 <= resize(add_cast_28, 65) + resize(add_cast_29, 65);
    sum15 <= add_temp_14(63 downto 0);
    
    add_cast_30 <= sum15;
    add_cast_31 <= resize(prodArray(16), 64);
    add_temp_15 <= resize(add_cast_30, 65) + resize(add_cast_31, 65);
    sum16 <= add_temp_15(63 downto 0);
    
    add_cast_32 <= sum16;
    add_cast_33 <= resize(prodArray(17), 64);
    add_temp_16 <= resize(add_cast_32, 65) + resize(add_cast_33, 65);
    sum17 <= add_temp_16(63 downto 0);
    
    add_cast_34 <= sum17;
    add_cast_35 <= resize(prodArray(18), 64);
    add_temp_17 <= resize(add_cast_34, 65) + resize(add_cast_35, 65);
    sum18 <= add_temp_17(63 downto 0);
    
    add_cast_36 <= sum18;
    add_cast_37 <= resize(prodArray(19), 64);
    add_temp_18 <= resize(add_cast_36, 65) + resize(add_cast_37, 65);
    sum19 <= add_temp_18(63 downto 0);
    
    add_cast_38 <= sum19;
    add_cast_39 <= resize(prodArray(20), 64);
    add_temp_19 <= resize(add_cast_38, 65) + resize(add_cast_39, 65);
    sum20 <= add_temp_19(63 downto 0);
    
    add_cast_40 <= sum20;
    add_cast_41 <= resize(prodArray(21), 64);
    add_temp_20 <= resize(add_cast_40, 65) + resize(add_cast_41, 65);
    sum21 <= add_temp_20(63 downto 0);
    
    add_cast_42 <= sum21;
    add_cast_43 <= resize(prodArray(22), 64);
    add_temp_21 <= resize(add_cast_42, 65) + resize(add_cast_43, 65);
    sum22 <= add_temp_21(63 downto 0);
    
    add_cast_44 <= sum22;
    add_cast_45 <= resize(prodArray(23), 64);
    add_temp_22 <= resize(add_cast_44, 65) + resize(add_cast_45, 65);
    sum23 <= add_temp_22(63 downto 0);
    
    add_cast_46 <= sum23;
    add_cast_47 <= resize(product_phase0_13, 64);
    add_temp_23 <= resize(add_cast_46, 65) + resize(add_cast_47, 65);
    sum24 <= add_temp_23(63 downto 0);
    
    output_typeconvert <= sum24(30 downto 15);
    
    -- clocks data outputs to reduced timing errors from the above logic
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                regoutTmp <= (others => '0');
            else
                regoutTmp <= output_typeconvert;
            end if;
        end if;
    end process;
    
    DataHoldRegister_process : process (CLK, RST)
    begin
        if (RST = '1') then
            regout <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (phase_0 = '1') then
                regout <= regoutTmp;
            end if;
        end if; 
    end process DataHoldRegister_process;
    
    muxout <= regoutTmp when ( phase_0 = '1' ) else regout;
    
    -- Assignment Statements
    DOUT <= std_logic_vector(muxout);

end Behavioral;
