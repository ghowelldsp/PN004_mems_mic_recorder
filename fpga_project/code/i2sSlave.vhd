----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2020 12:46:40
-- Design Name: 
-- Module Name: i2sSlave - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity i2sSlave is
    port      ( CLK                 : in  std_logic; -- system clock
                RST                 : in  std_logic; -- high active synchronous reset
                -- I2S SIGNALS
                B_CLK               : in  std_logic; -- bit clock
                LR_CLK              : in  std_logic; -- left right clock
                -- DATA SIGNALS
                DIN1                : in  std_logic_vector(15 downto 0); -- input data 1
                DIN2                : in  std_logic_vector(15 downto 0); -- input data 2
                DOUT                : out std_logic
                );
end i2sSlave;

architecture Behavioral of i2sSlave is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- bclk signals
signal  bClkLatch               : std_logic;
signal  bClkOffset              : std_logic;
signal  bClkRiseFlg             : std_logic;
signal  bClkFallFlg             : std_logic;

-- lrclk signals
signal  lrClkLatch              : std_logic;
signal  lrClkOffset             : std_logic;
signal  lrClkRiseFlg            : std_logic;
signal  lrClkFallFlg            : std_logic;

-- input data sync
signal  dinSync1                : std_logic_vector(15 downto 0);
signal  dinSync2                : std_logic_vector(15 downto 0);
signal  doutBuff                : std_logic_vector(15 downto 0);

-- output data transfer
type    doutCntStateType        is (doutCntState_start, doutCntState_firstRise, doutCntState_count);
signal  doutCntState            : doutCntStateType;
signal  bitCnt                  : integer range 0 to 24;

begin

-----------------------------------------------------------------------------------
------------------------ COMPONENT INSTANTIATIONS ---------------------------------
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------------------- MAIN PROCESSES -----------------------------------
-----------------------------------------------------------------------------------


    -------------------------------- BCLK LATCH -----------------------------------
    -- latches the bclk to the system clock and creates creates rise and fall flags
    
    -- latch the incoming bclk line from the master i2s device, then latch the same
    -- line but offset by 1 clock cycle to an offset signal
    process (RST, CLK)
    begin
        if (RST = '1') then
            bClkLatch <= '0';
            bClkOffset <= '0';    
        elsif (rising_edge(CLK)) then
            bClkLatch <= B_CLK;
            bClkOffset <= bClkLatch;           
        end if;
    end process;
    
    -- create master clock rise and fall flags from latched clock signal and offset
    -- clock signal
    bClkRiseFlg <= '1' when (bClkLatch = '1' and bClkOffset = '0') else '0';
    bClkFallFlg <= '1' when (bClkLatch = '0' and bClkOffset = '1') else '0';
    
    
    -------------------------------- LRCLK LATCH ----------------------------------
    -- latches the lrclk clock to the system clock and creates rise and fall flags
    
    -- latch the incoming lrclk from the master i2s device, then latch the same
    -- clock but offset by 1 sys clock cycle to an offset signal
    process (RST, CLK)
    begin
        if (RST = '1') then
            lrClkLatch <= '0';
            lrClkOffset <= '0';    
        elsif (rising_edge(CLK)) then
            lrClkLatch <= LR_CLK;
            lrClkOffset <= lrClkLatch;           
        end if;
    end process;
    
    -- create master clock rise and fall flags from latched clock signal and offset
    -- clock signal
    lrClkRiseFlg <= '1' when (lrClkLatch = '1' and lrClkOffset = '0') else '0';
    lrClkFallFlg <= '1' when (lrClkLatch = '0' and lrClkOffset = '1') else '0';
    
    
    ------------------------------ INPUT DATA SYNC --------------------------------
    -- creates an input data signal that is synced to the falling edge of the left
    -- right clock
    
    -- sync process
    process (RST, CLK)
    begin
        if (RST = '1') then
            dinSync1 <= (others => '0');
            dinSync2 <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (lrClkFallFlg = '1') then
                dinSync1 <= DIN1;
                dinSync2 <= DIN2;
            end if;
        end if;
    end process;
    
    ---------------------------- OUTPUT DATA TRANSFER -----------------------------
    -- handles the i2s data out processes
    
    -- bit counter state machine
    process (RST, CLK)
    begin
        if (RST = '1') then
            bitCnt <= 0;
            doutCntState <= doutCntState_start;
        elsif (rising_edge(CLK)) then
            case doutCntState is
            
            when doutCntState_start =>
                if (lrClkRiseFlg = '1' or lrClkFallFlg = '1') then
                    doutCntState <= doutCntState_firstRise;
                end if;
            
            -- delays the output data by 1 bit    
            when doutCntState_firstRise =>
                if (bClkRiseFlg = '1') then
                    doutCntState <= doutCntState_count;
                end if;
            
            -- creates the bit counter to enable incrimenting the data being
            -- writtern over the spi bus
            when doutCntState_count =>              
                if (bClkFallFlg = '1') then
                    if (bitCnt = 24) then
                        bitCnt <= 0;
                        doutCntState <= doutCntState_start;
                    else
                        bitCnt <= bitCnt + 1;
                    end if;
                end if;
            
            end case;
        end if;
    end process;
    
    -- output data selection buffer
    doutBuff <= dinSync1 when (LR_CLK = '0') else dinSync2;
    
    -- output data buffer
    DOUT <= doutBuff(15) when (bitCnt = 1) else
            doutBuff(14) when (bitCnt = 2) else
            doutBuff(13) when (bitCnt = 3) else
            doutBuff(12) when (bitCnt = 4) else
            doutBuff(11) when (bitCnt = 5) else
            doutBuff(10) when (bitCnt = 6) else
            doutBuff(9) when (bitCnt = 7) else
            doutBuff(8) when (bitCnt = 8) else
            doutBuff(7) when (bitCnt = 9) else
            doutBuff(6) when (bitCnt = 10) else
            doutBuff(5) when (bitCnt = 11) else
            doutBuff(4) when (bitCnt = 12) else
            doutBuff(3) when (bitCnt = 13) else
            doutBuff(2) when (bitCnt = 14) else
            doutBuff(1) when (bitCnt = 15) else
            doutBuff(0) when (bitCnt = 16) else
            '0';   
    
end Behavioral;
