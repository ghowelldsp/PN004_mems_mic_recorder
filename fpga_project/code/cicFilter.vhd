----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2020 19:09:26
-- Design Name: 
-- Module Name: cicFilter - Behavioral
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

entity cicFilter is
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_PDM_CE          : in    std_logic;                      -- pdm clock
            PDM_DIN             : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
            PCM_DOUT            : out   std_logic_vector (15 downto 0); -- pcm data out
            PDM_BIT_FLG         : in    std_logic                       -- signal that indicates the CIC filter to write data, then delay
            );
end cicFilter;

architecture Behavioral of cicFilter is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

type CIC_state_type is (CIC_idle_state, CIC_read_input_state, CIC_integrator_delay_state);     -- defining pdm conversion states
signal CIC_state            : CIC_state_type;          -- selecting start     

signal dataInSigned                     : signed(1 downto 0);       -- data in in signed form
signal count64                          : unsigned(5 downto 0);     -- counts to 64
signal phase64                          : std_logic;                -- a 64 clock divisor
--  --   -- Section 1 Signals 
signal section_in1                      : signed(1 downto 0); -- sfix2
signal section_cast1                    : signed(25 downto 0); -- sfix26
signal sum1                             : signed(25 downto 0); -- sfix26
signal section_out1                     : signed(25 downto 0); -- sfix26
signal add_cast                         : signed(25 downto 0); -- sfix26
signal add_cast_1                       : signed(25 downto 0); -- sfix26
signal add_temp                         : signed(26 downto 0); -- sfix27
--   -- Section 2 signals 
signal section_in2                      : signed(25 downto 0); -- sfix26
signal sum2                             : signed(25 downto 0); -- sfix26
signal section_out2                     : signed(25 downto 0); -- sfix26
signal add_cast_2                       : signed(25 downto 0); -- sfix26
signal add_cast_3                       : signed(25 downto 0); -- sfix26
signal add_temp_1                       : signed(26 downto 0); -- sfix27
--   -- Section 3 signals 
signal section_in3                      : signed(25 downto 0); -- sfix26
signal sum3                             : signed(25 downto 0); -- sfix26
signal section_out3                     : signed(25 downto 0); -- sfix26
signal add_cast_4                       : signed(25 downto 0); -- sfix26
signal add_cast_5                       : signed(25 downto 0); -- sfix26
signal add_temp_2                       : signed(26 downto 0); -- sfix27
--   -- Section 4 signals 
signal section_in4                      : signed(25 downto 0); -- sfix26
signal sum4                             : signed(25 downto 0); -- sfix26
signal section_out4                     : signed(25 downto 0); -- sfix26
signal add_cast_6                       : signed(25 downto 0); -- sfix26
signal add_cast_7                       : signed(25 downto 0); -- sfix26
signal add_temp_3                       : signed(26 downto 0); -- sfix27
--   -- Section 5 signals 
signal section_in5                      : signed(25 downto 0); -- sfix26
signal diff1                            : signed(25 downto 0); -- sfix26
signal section_out5                     : signed(25 downto 0); -- sfix26
signal sub_cast                         : signed(25 downto 0); -- sfix26
signal sub_cast_1                       : signed(25 downto 0); -- sfix26
signal sub_temp                         : signed(26 downto 0); -- sfix27
--   -- Section 6 signals 
signal section_in6                      : signed(25 downto 0); -- sfix26
signal diff2                            : signed(25 downto 0); -- sfix26
signal section_out6                     : signed(25 downto 0); -- sfix26
signal sub_cast_2                       : signed(25 downto 0); -- sfix26
signal sub_cast_3                       : signed(25 downto 0); -- sfix26
signal sub_temp_1                       : signed(26 downto 0); -- sfix27
--   -- Section 7 signals 
signal section_in7                      : signed(25 downto 0); -- sfix26
signal diff3                            : signed(25 downto 0); -- sfix26
signal section_out7                     : signed(25 downto 0); -- sfix26
signal sub_cast_4                       : signed(25 downto 0); -- sfix26
signal sub_cast_5                       : signed(25 downto 0); -- sfix26
signal sub_temp_2                       : signed(26 downto 0); -- sfix27
--   -- Section 8 signals 
signal section_in8                      : signed(25 downto 0); -- sfix26
signal diff4                            : signed(25 downto 0); -- sfix26
signal section_out8                     : signed(25 downto 0); -- sfix26
signal sub_cast_6                       : signed(25 downto 0); -- sfix26
signal sub_cast_7                       : signed(25 downto 0); -- sfix26
signal sub_temp_3                       : signed(26 downto 0); -- sfix27
-- Data Hold and Output Signals
signal regout                           : signed(25 downto 0); -- sfix26
signal CICDataOutTemp                   : signed(25 downto 0); -- sfix26
signal CICDataOutSigned                 : signed(25 downto 0);              -- sfix26
signal CICDataOut                       : std_logic_vector (25 downto 0);
signal normaliseCast                    : signed(51 downto 0);              -- sfix52_En48
signal normaliseOut                     : signed(15 downto 0);              -- sfix16_En14

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    -------------------------------- SYSTEM RESET -------------------------------------
    
    -- counts up to 64  
    process (CLK, RST)
    begin
        if RST = '1' then
        count64 <= to_unsigned(0, 6);
        elsif (rising_edge(clk)) then
            if CLK_PDM_CE = '1' then
                if count64 = to_unsigned(63, 6) then
                    count64 <= to_unsigned(0, 6);
                else
                    count64 <= count64 + to_unsigned(1, 6);
                end if;
            end if;
        end if; 
    end process counter_64;
    
    -- this essentially provides an internal clock at 1/64th of 1MHz
    phase64 <= '1' when count64 = to_unsigned(0, 6) and CLK_PDM_CE = '1' else '0';
    
    --------------- Integrator Delays -----------------------------
    process (RST, CLK)
    begin
        if (RST = '1') then
            dataInSigned <= (others => '0');
            section_out1 <= (others => '0');
            section_out2 <= (OTHERS => '0');
            section_out3 <= (OTHERS => '0');
            section_out4 <= (OTHERS => '0');
            CIC_state <= CIC_idle_state;
        
        elsif (rising_edge(clk)) then
            case CIC_state is
            
            when CIC_idle_state =>
                if (PDM_BIT_FLG = '1') then
                    CIC_state <= CIC_read_input_state;
                end if;
                           
            when CIC_read_input_state =>
                dataInSigned <= signed(PDM_DIN);    -- converts the input data from std_logic_vector to signed form
                CIC_state <= CIC_integrator_delay_state;
            
            -- delays each integrators sum    
            when CIC_integrator_delay_state =>
                section_out1 <= sum1;                   -- integrator 1 sum delay
                section_out2 <= sum2;                   -- integrator 2 sum delay
                section_out3 <= sum3;                   -- integrator 3 sum delay
                section_out4 <= sum4;                   -- integrator 3 sum delay
                CIC_state <= CIC_idle_state;
            
            end case;
        end if;
    end process;

    -------------- Section # 1 : Integrator ------------------
    section_in1 <= dataInSigned;

    section_cast1 <= resize(section_in1, 26);

    add_cast <= section_cast1;
    add_cast_1 <= section_out1;
    add_temp <= resize(add_cast, 27) + resize(add_cast_1, 27);
    sum1 <= add_temp(25 downto 0);
  
    ------------------ Section # 2 : Integrator ------------------
    section_in2 <= section_out1;
    
    add_cast_2 <= section_in2;
    add_cast_3 <= section_out2;
    add_temp_1 <= resize(add_cast_2, 27) + resize(add_cast_3, 27);
    sum2 <= add_temp_1(25 downto 0);

    ------------------ Section # 3 : Integrator ------------------    
    section_in3 <= section_out2;
    
    add_cast_4 <= section_in3;
    add_cast_5 <= section_out3;
    add_temp_2 <= resize(add_cast_4, 27) + resize(add_cast_5, 27);
    sum3 <= add_temp_2(25 downto 0);

    ------------------ Section # 4 : Integrator ------------------   
    section_in4 <= section_out3;
    
    add_cast_6 <= section_in4;
    add_cast_7 <= section_out4;
    add_temp_3 <= resize(add_cast_6, 27) + resize(add_cast_7, 27);
    sum4 <= add_temp_3(25 downto 0);

    ------------------ COMB FILTER DELAYS -------------------------
    process (RST, CLK)
    begin
        if (RST = '1') then
            diff1 <= (OTHERS => '0');
            diff2 <= (OTHERS => '0');
            diff3 <= (OTHERS => '0');
            diff4 <= (OTHERS => '0');
            regout <= (OTHERS => '0');
        
        elsif (rising_edge(clk)) then
            if (phase64 = '1') then
                diff1 <= section_in5;
                diff2 <= section_in6;
                diff3 <= section_in7;
                diff4 <= section_in8;
                regout <= section_out8;           
            end if;            
        end if;
    end process;

    ------------------ Section # 5 : Comb ------------------  
    section_in5 <= section_out4;
    
    sub_cast <= section_in5;
    sub_cast_1 <= diff1;
    sub_temp <= resize(sub_cast, 27) - resize(sub_cast_1, 27);
    section_out5 <= sub_temp(25 downto 0);

    ------------------ Section # 6 : Comb ------------------   
    section_in6 <= section_out5;
    
    sub_cast_2 <= section_in6;
    sub_cast_3 <= diff2;
    sub_temp_1 <= resize(sub_cast_2, 27) - resize(sub_cast_3, 27);
    section_out6 <= sub_temp_1(25 downto 0);

    ------------------ Section # 7 : Comb ------------------
    section_in7 <= section_out6;
    
    sub_cast_4 <= section_in7;
    sub_cast_5 <= diff3;
    sub_temp_2 <= resize(sub_cast_4, 27) - resize(sub_cast_5, 27);
    section_out7 <= sub_temp_2(25 downto 0);

    ------------------ Section # 8 : Comb ------------------
    section_in8 <= section_out7;
    
    sub_cast_6 <= section_in8;
    sub_cast_7 <= diff4;
    sub_temp_3 <= resize(sub_cast_6, 27) - resize(sub_cast_7, 27);
    section_out8 <= sub_temp_3(25 downto 0);

    ----------------- Data Hold and Output Signals ---------------
    CICDataOutTemp <= section_out8 when ( phase64 = '1' ) else regout;
    -- Assignment Statements
    CICDataOut <= std_logic_vector(CICDataOutTemp);
    
    -- converts the CIC output to a signed integer
    CICDataOutSigned <= signed(CICDataOut);
    
    -- normalises the CIC output signal
    normaliseCast <= resize(CICDataOutSigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 52);
    normaliseOut <= normaliseCast(49 downto 34);
    
    -- converts back to std_logic_vector
    PCM_DOUT <= std_logic_vector(normaliseOut);

end Behavioral;
