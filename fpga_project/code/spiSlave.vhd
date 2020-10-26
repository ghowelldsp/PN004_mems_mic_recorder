----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2020 12:46:40
-- Design Name: 
-- Module Name: spiSlave - Behavioral
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

entity spiSlave is
    port      ( CLK                 : in  std_logic; -- system clock
                RST                 : in  std_logic; -- high active synchronous reset
                -- SPI SLAVE INTERFACE
                SCLK                : in  std_logic; -- SPI clock
                CS_N                : in  std_logic; -- SPI chip select, active in low
                MOSI                : in  std_logic; -- SPI serial data from master to slave
                MISO                : out std_logic; -- SPI serial data from slave to master
                -- USER INTERFACE
                DIN                 : in  std_logic_vector(7 downto 0); -- input data for SPI master
                DOUT                : out std_logic_vector(7 downto 0); -- output data from SPI master
                CS_START_FLG        : out std_logic;                    -- signals that the cs line has gone low
                CS_END_FLG          : out std_logic;                    -- signals that the cs line has gone high
                LST_RISE_BIT        : out std_logic;                    -- signal indicating the last bit rising edge
                LST_FALL_BIT        : out std_logic                     -- signal indicating the last bit falling edge
                );
end spiSlave;

architecture Behavioral of spiSlave is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- cs signals
signal csLatch              : std_logic;
signal csOffset             : std_logic;

-- sclk signals
signal sclk_latch           : std_logic;
signal sclk_offset          : std_logic;
signal sclkRiseFlg          : std_logic;
signal sclkFallFlg          : std_logic;

-- bit counter signals
signal riseBitCnt           : unsigned(2 downto 0);
signal fallBitCnt           : unsigned(2 downto 0);
signal lastRiseBitFlg       : std_logic;
signal lastFallBitFlg       : std_logic;

-- mosi signals
signal mosiShftReg          : std_logic_vector (7 downto 0);
signal mosiData             : std_logic_vector (7 downto 0);

-- miso signals
signal misoBuff             : std_logic;

begin

-----------------------------------------------------------------------------------
------------------------ COMPONENT INSTANTIATIONS ---------------------------------
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------------------- MAIN PROCESSES -----------------------------------
-----------------------------------------------------------------------------------

    -------------------------------- CS LATCH -----------------------------------
    -- latches the cs to the system clock and creates start and end flags
    
    -- latch the incoming cs line from the master spi device, then latch the same
    -- line but offset by 1 sys clock cycle to an offset signal
    process (RST, CLK)
    begin
        if (RST = '1') then
            csLatch <= '1';
            csOffset <= '1';    
        elsif (rising_edge(CLK)) then
            csLatch <= CS_N;
            csOffset <= csLatch;           
        end if;
    end process;
    
    -- create master clock rise and fall flags from latched clock signal and offset
    -- clock signal
    CS_START_FLG <= '1' when (csLatch = '0' and csOffset = '1') else '0';
    CS_END_FLG <= '1' when (csLatch = '1' and csOffset = '0') else '0';

    -------------------------------- SCLK LATCH -----------------------------------
    -- latches the sclk clock to the system clock and creates rise and fall flags
    
    -- latch the incoming clock from the master spi device, then latch the same
    -- clock but offset by 1 sys clock cycle to an offset signal
    process (RST, CLK)
    begin
        if (RST = '1') then
            sclk_latch <= '0';
            sclk_offset <= '0';    
        elsif (rising_edge(CLK)) then
            sclk_latch <= SCLK;
            sclk_offset <= sclk_latch;           
        end if;
    end process;
    
    -- create master clock rise and fall flags from latched clock signal and offset
    -- clock signal
    sclkRiseFlg <= '1' when (sclk_latch = '1' and sclk_offset = '0') else '0';
    sclkFallFlg <= '1' when (sclk_latch = '0' and sclk_offset = '1') else '0';
    
    
    ------------------- RISING / FALLING EDGE BIT COUNTERS ------------------------
    -- counts the number of clock cycles of the sclk clock
    
    -- counts up to 8 bits on the rising edge of the master clock, then resets
    process (RST, CLK)
    begin
        if (RST = '1') then
            riseBitCnt <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (sclkRiseFlg = '1') then
                if (riseBitCnt = "111") then
                    riseBitCnt <= (others => '0');
                else
                    riseBitCnt <= riseBitCnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- raises a flag on the falling edge of the 8th bit
    lastRiseBitFlg <= '1' when (riseBitCnt = "111" and sclkRiseFlg = '1') else '0';
    LST_RISE_BIT <= lastRiseBitFlg;
    
    -- counts up to 8 bits on the falling edge of the master clock, then resets
    process (RST, CLK)
    begin
        if (RST = '1') then
            fallBitCnt <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (sclkFallFlg = '1') then
                if (fallBitCnt = "111") then
                    fallBitCnt <= (others => '0');
                else
                    fallBitCnt <= fallBitCnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- raises a flag on the falling edge of the 8th bit
    lastFallBitFlg <= '1' when (fallBitCnt = "111" and sclkFallFlg = '1') else '0';
    LST_FALL_BIT <= lastFallBitFlg;
    
    
    -------------------------------- MOSI -------------------------------------
    
    -- captures the current mosi bit on the rising edge off the master
    -- clock, shifts register and stores in LSB
    process (RST, CLK)
    begin
        if (RST = '1') then
            mosiShftReg <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (sclkRiseFlg = '1') then
                mosiShftReg <= mosiShftReg(6 downto 0) & MOSI;
            end if;
        end if;
    end process;
    
    -- saves the final 8 bit value recieved from MOSI on the falling 
    -- edge of the last bit    
    process (RST, CLK)
    begin
        if (RST = '1') then
            mosiData <= (others => '0');
        elsif (rising_edge(CLK)) then
            if (lastFallBitFlg = '1') then
                mosiData <= mosiShftReg;
            end if;
        end if;
    end process;
    
    -- send data out of module 
    DOUT <= mosiData;
    
    -------------------------------- MISO -------------------------------------
    
    -- selects the output bit to stream to MISO
    misoBuff <= DIN(0) when (riseBitCnt = "111") else
                DIN(1) when (riseBitCnt = "110") else
                DIN(2) when (riseBitCnt = "101") else
                DIN(3) when (riseBitCnt = "100") else
                DIN(4) when (riseBitCnt = "011") else
                DIN(5) when (riseBitCnt = "010") else
                DIN(6) when (riseBitCnt = "001") else
                DIN(7);
    
    -- buffers the miso line to the output when chip select line is low           
    MISO <= misoBuff when (CS_N = '0') else '0';
    
end Behavioral;
