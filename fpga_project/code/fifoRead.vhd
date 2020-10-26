----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2020 13:21:50
-- Design Name: 
-- Module Name: dataTrans - Behavioral
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

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity fifoRead is
    generic   ( FIFO_SIZE           : integer   := 4096;    -- total no. of bytes per fifo
                NUM_FIFOS           : integer   := 4
                );
    port      ( CLK                 : in    std_logic;  -- system clock
                -- SPI
                SPI_DIN             : out   std_logic_vector(7 downto 0);   -- input data for SPI master
                CS_START_FLG        : in    std_logic;    -- signals that the cs line has gone low
                CS_END_FLG          : in    std_logic;    -- signals that the cs line has gone high
                LST_RISE_BIT        : in    std_logic;    -- signal indicating the last bit rising edge
                -- FIFO
                FIFO_RST            : in    std_logic;
                FIFO_RD_EN_1        : out   std_logic;
                FIFO_RD_EN_2        : out   std_logic;
                FIFO_RD_EN_3        : out   std_logic;
                FIFO_RD_EN_4        : out   std_logic;
                FIFO_FULL_1         : in    std_logic;
                FIFO_FULL_2         : in    std_logic;
                FIFO_FULL_3         : in    std_logic;
                FIFO_FULL_4         : in    std_logic;
                FIFO_DOUT_1         : in    std_logic_vector (7 downto 0);
                FIFO_DOUT_2         : in    std_logic_vector (7 downto 0);
                FIFO_DOUT_3         : in    std_logic_vector (7 downto 0);
                FIFO_DOUT_4         : in    std_logic_vector (7 downto 0)
                );             
end fifoRead;

architecture Behavioral of fifoRead is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- data transmission
signal  fifoFullFlg         : std_logic; 

-- read enable     
signal  firstRdEnFlg        : std_logic;
signal  rdState             : std_logic_vector (1 downto 0);
signal  rdEnTmp             : std_logic;
signal  rdEnTmp1            : std_logic;
signal  rdEnOffset          : std_logic;

-- fifo select
signal  rdFifoSelFlg        : std_logic;
signal  rdFifoSelCnt        : integer range 0 to (NUM_FIFOS-1);

-- data output
signal  doutFlg             : std_logic;
signal  spiDinBuff          : std_logic_vector (7 downto 0);
signal  fifoDoutTmp         : std_logic_vector (7 downto 0);
signal  rdEnCnt             : integer range 0 to FIFO_SIZE;

begin
    
    -----------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------
    -----------------------------------------------------------------------------
    
    -------------------------- DATA TRANSMISSION PROCESS ------------------------
    
    -- fifo full flag
    fifoFullFlg <= '1' when (FIFO_FULL_1 = '1' or FIFO_FULL_2 = '1' or FIFO_FULL_3 = '1' or FIFO_FULL_4 = '1') else '0';
    
    -- transmission state process
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (FIFO_RST = '1') then
                rdState <= "00";
                firstRdEnFlg <= '0';
            else
                case rdState is
                
                -- idle, waits till fifo full
                when "00" =>
                    if (fifoFullFlg = '1') then
                        rdState <= "01";
                    end if;
                
                -- fifo full, wait for next pole byte - this ensures that the next pole
                -- byte is caught on the chance that the fifo full flag is raised on a
                -- cs_start_flg
                when "01" =>
                    if (CS_START_FLG = '1') then
                        rdState <= "10";
                    end if;
                    
                -- wait for end of pole byte
                when "10" =>
                    if (CS_END_FLG = '1') then
                        rdState <= "11";
                        firstRdEnFlg <= '1';     
                    end if;
                    
                -- stay in fifo output mode untill end of fifo data
                when "11" =>
                firstRdEnFlg <= '0';
                    if (CS_END_FLG = '1') then
                        rdState <= "00";  
                    end if;
                    
                when others =>
                    rdState <= "00";
                    
                end case; 
            end if;
        end if;
    end process;
    
    -------------------------------- READ ENABLE --------------------------------
    -- handles the read enable signals
    
    -- temp read enable signals
    rdEnTmp <= '1' when (firstRdEnFlg = '1' or CS_START_FLG = '1' or LST_RISE_BIT = '1') else '0';
    rdEnTmp1 <= rdEnTmp when (rdState = "11" and rdEnCnt < FIFO_SIZE) else '0';
    
    -- offsets read enable flag so that it oorresponds to the falling edges of 
    -- the clock
    process (CLK)
    begin
        if (falling_edge(CLK)) then
            if (FIFO_RST = '1') then
                rdEnOffset <= '0';
            else
                rdEnOffset <= rdEnTmp1;
            end if;
        end if;
    end process;
    
    -- read enable signals
    FIFO_RD_EN_1  <= rdEnOffset when (rdFifoSelCnt = 0) else '0';
    FIFO_RD_EN_2  <= rdEnOffset when (rdFifoSelCnt = 1) else '0';
    FIFO_RD_EN_3  <= rdEnOffset when (rdFifoSelCnt = 2) else '0';
    FIFO_RD_EN_4  <= rdEnOffset when (rdFifoSelCnt = 3) else '0';
            
    -- read enable counter
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            if (FIFO_RST = '1') then
                rdEnCnt <= 0;
            else
                if (rdEnOffset = '1') then
                    rdEnCnt <= rdEnCnt + 1;
                elsif (CS_END_FLG = '1') then
                    rdEnCnt <= 0;  
                end if;
            end if;
        end if;
    end process;
    
    ------------------------------- FIFO SELECTOR -------------------------------
    -- selects the fifo to read data from
    
    -- fifo selector flag
    rdFifoSelFlg <= '1' when (rdEnCnt = FIFO_SIZE and CS_END_FLG = '1') else '0';
    
    -- fifo selector counter
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            if (FIFO_RST = '1') then
                rdFifoSelCnt <= 0;
            else
                if (rdFifoSelFlg = '1') then
                    if (rdFifoSelCnt < (NUM_FIFOS-1)) then
                        rdFifoSelCnt <= rdFifoSelCnt + 1;
                    else
                        rdFifoSelCnt <= 0;
                    end if;
                end if;
            end if;
        end if;    
    end process;
    
    -------------------------------- DATA OUTPUT --------------------------------
    -- handles the data output from the fifo the to the spi driver
    
    -- fifo data output
    fifoDoutTmp <= FIFO_DOUT_1 when (rdFifoSelCnt = 0) else 
                   FIFO_DOUT_2 when (rdFifoSelCnt = 1) else
                   FIFO_DOUT_3 when (rdFifoSelCnt = 2) else
                   FIFO_DOUT_4 when (rdFifoSelCnt = 3) else
                   (others => '0');
    
    -- spi data input mux
    spiDinBuff <= "10000000" when (rdState = "00") else -- fifo not full
                  "01000000" when (rdState = "01" or rdState = "10") else -- fifo full
                  fifoDoutTmp when (rdState = "11") else -- fifo data output
                  (others => '0');
    
    -- data output flag, signals when to send data out to the spi driver
    doutFlg <= '1' when (CS_START_FLG = '1' or LST_RISE_BIT = '1') else '0';
    
    -- data output to spi driver
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (FIFO_RST = '1') then
                SPI_DIN <= (others => '0');
            else
                if (doutFlg = '1') then
                     SPI_DIN <= spiDinBuff;
                end if;  
            end if;
        end if;
    end process;

end Behavioral;
