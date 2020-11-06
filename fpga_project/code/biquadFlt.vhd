----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:
-- Design Name: 
-- Module Name: biquadFlt - Behavioral
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

entity biquadFlt is
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_CE              : in    std_logic;                      -- clock enable
            DIN                 : in    std_logic_vector (15 downto 0); -- input data
            DOUT                : out   std_logic_vector (15 downto 0); -- output data
            B0                  : in    std_logic_vector (31 downto 0); -- b0 coefficient - sfix32_En30 
            B1                  : in    std_logic_vector (31 downto 0); -- b1 coefficient - sfix32_En30 
            B2                  : in    std_logic_vector (31 downto 0); -- b2 coefficient - sfix32_En30 
            A1                  : in    std_logic_vector (31 downto 0); -- a1 coefficient - sfix32_En30 
            A2                  : in    std_logic_vector (31 downto 0)  -- a2 coefficient - sfix32_En30 
            );
end biquadFlt;

architecture Behavioral of biquadFlt is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

TYPE vector_of_signed96 IS ARRAY (NATURAL RANGE <>) OF signed(95 downto 0);
TYPE vector_of_signed64 IS ARRAY (NATURAL RANGE <>) OF signed(63 downto 0);
TYPE vector_of_signed32 IS ARRAY (NATURAL RANGE <>) OF signed(31 downto 0);

-- signals
signal delayReg                         : vector_of_signed64(0 TO 1);  -- sfix64_En48 [5]

signal dinSigned                        : signed(15 downto 0);  -- sfix16_En14
signal dinSignedConv                    : signed(63 downto 0);  -- sfix64_En48

signal coeffVec                         : vector_of_signed32(0 TO 4);  -- sfix32_En30 [5]
signal delayVec                         : vector_of_signed64(0 TO 4);  -- sfix64_En48 [2]
signal multiPhaseCeCnt                  : unsigned(1 downto 0);
signal multiPhaseCe                     : std_logic;
signal multiVec                         : vector_of_signed96(0 TO 4);  -- sfix96_En78 [5]
signal multiInx                         : integer range 0 to 4;
signal a2mul1                           : signed(63 downto 0);  -- sfix64_En48
signal a1mul1                           : signed(63 downto 0);  -- sfix64_En48
signal b0mul1                           : signed(63 downto 0);  -- sfix64_En48
signal b1mul1                           : signed(63 downto 0);  -- sfix64_En48
signal b2mul1                           : signed(63 downto 0);  -- sfix64_En48

signal dinCast                          : signed(64 downto 0);  -- sfix65_En48
signal a1mul1Cast                       : signed(64 downto 0);  -- sfix65_En48
signal a2mul1Cast                       : signed(64 downto 0);  -- sfix65_En48
signal sub1Tmp                          : signed(64 downto 0);  -- sfix65_En48
signal sub1                             : signed(63 downto 0);  -- sfix64_En48
signal sub1Cast                         : signed(64 downto 0);  -- sfix65_En48
signal sub2Tmp                          : signed(64 downto 0);  -- sfix65_En48
signal sub2                             : signed(63 downto 0);  -- sfix65_En48

signal sum1                             : signed(63 downto 0);  -- sfix64_En48
signal sum2                             : signed(63 downto 0);  -- sfix64_En48

signal output_typeconvert               : signed(15 downto 0);  -- sfix16_En14
signal outputStd                        : std_logic_vector (15 downto 0);
signal doutTmp                          : std_logic_vector (15 downto 0);

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------
    
    --------------------------------- DELAY REG --------------------------------------
    -- delay register holding the delayed values of first section s1[n-1] and s1[n-2]
    
    delay_reg_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                delayReg <= (others => to_signed(0, 64));
            elsif (CLK_CE = '1') then
                delayReg(0) <= sub2;
                delayReg(1) <= delayReg(0);
            end if;
        end if;
    end process delay_reg_process;
    
    ---------------------------------- INPUT ------------------------------------------
    -- read input data
    
    input_data_process : process (CLK)
    begin 
        if (rising_edge(CLK)) then
            if (RST = '1') then
                dinSigned <= to_signed(0,16);
            elsif (CLK_CE = '1') then
                dinSigned <= signed(DIN);
            end if;
        end if;
    end process input_data_process;

    dinSignedConv <= resize(dinSigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 64);
    
    --------------------------------- MULIPLIER ---------------------------------------
    
    -- assign coefficient values to for multiplier
    coeffVec(0) <= signed(A1);
    coeffVec(1) <= signed(A2);
    coeffVec(2) <= signed(B1);
    coeffVec(3) <= signed(B2);
    coeffVec(4) <= signed(B0);
    
    -- assign coefficient values to for multiplier
    delayVec(0) <= delayReg(0);
    delayVec(1) <= delayReg(1);
    delayVec(2) <= delayReg(0);
    delayVec(3) <= delayReg(1);
    delayVec(4) <= sub2;
    
    multi_phase_ce_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                multiPhaseCeCnt <= to_unsigned(1,2);
            else
                multiPhaseCeCnt <= multiPhaseCeCnt + to_unsigned(1,2);
            end if;
        end if;
    end process multi_phase_ce_process;
    
    multiPhaseCe <= '1' when (multiPhaseCeCnt = to_unsigned(0,2)) else '0';
    
    multi_index_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then 
                multiInx <= 0;
            elsif (multiPhaseCe = '1') then
                if (multiInx >= 4) then
                    multiInx <= 0;
                else
                    multiInx <= multiInx + 1;
                end if;
            end if;
        end if;
    end process multi_index_process;
    
--    delayValTmp <= delayVec(multiInx);
    
    multiply_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                multiVec <= (others => (others => '0'));
            else
                if (multiPhaseCe = '1') then
                    multiVec(multiInx) <= delayVec(multiInx) *  coeffVec(multiInx);
                end if;
            end if;
        end if;
    end process multiply_process;
    
    a1mul1 <= multiVec(0)(93 downto 30);   
    a2mul1 <= multiVec(1)(93 downto 30);
    b1mul1 <= multiVec(2)(93 downto 30);
    b2mul1 <= multiVec(3)(93 downto 30);
    b0mul1 <= multiVec(4)(93 downto 30);
    
    --------------------------------- SUMMATION ---------------------------------------
    
    dinCast <= resize(dinSignedConv, 65);
    a1mul1Cast <= resize(a1mul1, 65);
    a2mul1Cast <= resize(a2mul1, 65);
    
    sub1 <= sub1Tmp(63 downto 0);    
    sub1Cast <= resize(sub1, 65);
    sub2 <= sub2Tmp(63 downto 0);
    
    sub_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                sub1Tmp <= (others => '0');
                sub2Tmp <= (others => '0');
                sum1 <= (others => '0');
                sum2 <= (others => '0');
            else
                -- s1[n] = x[n] - a1.s1[n-1] - a2.s1[n-2]
                sub1Tmp <= dinCast - a1mul1Cast;
                sub2Tmp <= sub1Cast - a2mul1Cast;
                -- y[n] = b0.s1[n] + b1.s1[n-1] + b2.s1[n-2]
                sum1 <= b0mul1 + b1mul1; 
                sum2 <= sum1 + b2mul1;
            end if;
        end if;
    end process sub_process;
    
    ---------------------------------- OUTPUT -----------------------------------------
    
    output_typeconvert <= sum2(49 downto 34);
    outputStd <= std_logic_vector(output_typeconvert);
    
    output_buff_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                doutTmp <= (others => '0');
            elsif (CLK_CE = '1') then
                doutTmp <= outputStd;
            end if;
        end if;
    end process output_buff_process;
    
    DOUT <= outputStd when (CLK_CE = '1') else doutTmp;

end Behavioral;
