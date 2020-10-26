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

entity fifoWrite is
    generic   ( BYTE_PER_WR         : integer   := 16;      -- no. of bytes to write to fifo each sample
                FIFO_SIZE           : integer   := 4096;    -- total no. of bytes per fifo
                NUM_FIFOS           : integer   := 4
                );
    port      ( CLK_MMCM            : in    std_logic;  -- mmcm clock
                -- PCM
                CLK_PCM_CE          : in    std_logic;      -- pcm clock
                PCM_MIC1_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 1 data
                PCM_MIC2_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 2 data
                PCM_MIC3_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 3 data
                PCM_MIC4_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 4 data
                PCM_MIC5_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 5 data
                PCM_MIC6_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 6 data
                PCM_MIC7_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 7 data
                PCM_MIC8_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 8 data
                -- FIFO
                FIFO_RST            : in    std_logic;
                FIFO_WR_EN_1        : out   std_logic;
                FIFO_WR_EN_2        : out   std_logic;
                FIFO_WR_EN_3        : out   std_logic;
                FIFO_WR_EN_4        : out   std_logic;
                FIFO_DIN_1          : out   std_logic_vector (7 downto 0);
                FIFO_DIN_2          : out   std_logic_vector (7 downto 0);
                FIFO_DIN_3          : out   std_logic_vector (7 downto 0);
                FIFO_DIN_4          : out   std_logic_vector (7 downto 0)
                );             
end fifoWrite;

architecture Behavioral of fifoWrite is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- write enable signals
signal  wrEnState           : std_logic_vector (1 downto 0);
signal  wrEnCnt             : integer range 0 to BYTE_PER_WR;
signal  wrEnBuff            : std_logic;

-- data input signals
signal  fifoDinBuff         : std_logic_vector(7 downto 0);

-- fifo selector
signal  wrDinCnt            : integer range 0 to FIFO_SIZE;
signal  wrFifoSelFlg        : std_logic;
signal  wrFifoSelCnt        : integer range 0 to (NUM_FIFOS-1);

begin
    
    -----------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------
    -----------------------------------------------------------------------------
    
    ------------------------------ FIFO WRITE ENABLE ----------------------------
    -- writes the pdm data to the FIFO in 8-bit words using a counter that resets
    -- every pcm clock flag 
    
    -- state process for the write enable signal
    process(CLK_MMCM)
    begin
        if (falling_edge(CLK_MMCM)) then
            if (FIFO_RST = '1') then
                wrEnState <= "00";
                wrEnCnt <= 0;
            else
                case wrEnState is
                
                -- idle  
                when "00" =>
                    if (CLK_PCM_CE = '1') then
                        wrEnState <= "01";
                    end if;
                
                -- count
                when "01" =>
                    if (wrEnCnt < BYTE_PER_WR) then
                        wrEnCnt <= wrEnCnt + 1;
                    else
                        wrEnState <= "00";
                        wrEnCnt <= 0;
                    end if;
                    
                when others =>
                    wrEnState <= "00";  
                    
                end case;
            end if;
        end if;
    end process;
    
    -- write enable buffer
    wrEnBuff <= '0' when (wrEnCnt = 0) else '1';
    
    -- assign write enable lines to fifos
    FIFO_WR_EN_1 <= wrEnBuff when (wrFifoSelCnt = 0) else '0';
    FIFO_WR_EN_2 <= wrEnBuff when (wrFifoSelCnt = 1) else '0';
    FIFO_WR_EN_3 <= wrEnBuff when (wrFifoSelCnt = 2) else '0';
    FIFO_WR_EN_4 <= wrEnBuff when (wrFifoSelCnt = 3) else '0';
    
    ------------------------------ FIFO DATA INPUT ------------------------------
    
    -- FIFO DATA INPUT
    -- assign the pdm data to the fifo data input buffer
    fifoDinBuff <=  PCM_MIC1_DATA(7 downto 0)   when (wrEnCnt = 1) else
                    PCM_MIC1_DATA(15 downto 8)  when (wrEnCnt = 2) else
                    PCM_MIC2_DATA(7 downto 0)   when (wrEnCnt = 3) else
                    PCM_MIC2_DATA(15 downto 8)  when (wrEnCnt = 4) else
                    PCM_MIC3_DATA(7 downto 0)   when (wrEnCnt = 5) else
                    PCM_MIC3_DATA(15 downto 8)  when (wrEnCnt = 6) else
                    PCM_MIC4_DATA(7 downto 0)   when (wrEnCnt = 7) else
                    PCM_MIC4_DATA(15 downto 8)  when (wrEnCnt = 8) else
                    PCM_MIC5_DATA(7 downto 0)   when (wrEnCnt = 9) else
                    PCM_MIC5_DATA(15 downto 8)  when (wrEnCnt = 10) else
                    PCM_MIC6_DATA(7 downto 0)   when (wrEnCnt = 11) else
                    PCM_MIC6_DATA(15 downto 8)  when (wrEnCnt = 12) else
                    PCM_MIC7_DATA(7 downto 0)   when (wrEnCnt = 13) else
                    PCM_MIC7_DATA(15 downto 8)  when (wrEnCnt = 14) else
                    PCM_MIC8_DATA(7 downto 0)   when (wrEnCnt = 15) else
                    PCM_MIC8_DATA(15 downto 8)  when (wrEnCnt = 16) else
                    (others => '0');
                    
    -- DEBUG
    -- allows debugging of the data transmission process by impersonating the
    -- data that is being put into the fifo. uncomment below code, the comment
    -- out fifoDinBuff above                  
--    fifoDinBuff <=  "00000001" when (wrEnCnt = 1) else
--                    "00000000" when (wrEnCnt = 2) else
--                    "00000010" when (wrEnCnt = 3) else
--                    "00000000" when (wrEnCnt = 4) else
--                    "00000011" when (wrEnCnt = 5) else
--                    "00000000" when (wrEnCnt = 6) else
--                    "00000100" when (wrEnCnt = 7) else
--                    "00000000" when (wrEnCnt = 8) else
--                    "00000101" when (wrEnCnt = 9) else
--                    "00000000" when (wrEnCnt = 10) else
--                    "00000110" when (wrEnCnt = 11) else
--                    "00000000" when (wrEnCnt = 12) else
--                    "00000111" when (wrEnCnt = 13) else
--                    "00000000" when (wrEnCnt = 14) else
--                    "00001000" when (wrEnCnt = 15) else
--                    "00000000" when (wrEnCnt = 16) else
--                    (others => '0'); 

    -- assign the data to the respective fifo    
    FIFO_DIN_1 <= fifoDinBuff when (wrFifoSelCnt = 0) else (others => '0');
    FIFO_DIN_2 <= fifoDinBuff when (wrFifoSelCnt = 1) else (others => '0');
    FIFO_DIN_3 <= fifoDinBuff when (wrFifoSelCnt = 2) else (others => '0');
    FIFO_DIN_4 <= fifoDinBuff when (wrFifoSelCnt = 3) else (others => '0');
    
        
    ------------------------------- FIFO SELECTOR -------------------------------
    -- selects which fifo to write to by counting the bits
    
    -- write enable counter
    process(CLK_MMCM)
    begin
        if (rising_edge(CLK_MMCM)) then
            if (FIFO_RST = '1') then
                wrDinCnt <= 0;
            else
                if (wrEnBuff = '1') then
                    wrDinCnt <= wrDinCnt + 1;
                elsif (wrDinCnt = FIFO_SIZE) then
                    wrDinCnt <= 0;
                end if;
            end if;
        end if;    
    end process;
    
    -- write fifo selector flag
    wrFifoSelFlg <= '1' when (wrDinCnt = FIFO_SIZE) else '0';
    
    -- fifo selector counter
    process(CLK_MMCM)
    begin
        if (rising_edge(CLK_MMCM)) then
            if (FIFO_RST = '1') then
                wrFifoSelCnt <= 0;
            else
                if (wrFifoSelFlg = '1') then
                    if (wrFifoSelCnt < (NUM_FIFOS-1)) then
                        wrFifoSelCnt <= wrFifoSelCnt + 1;
                    else
                        wrFifoSelCnt <= 0;
                    end if;
                end if;
            end if;
        end if;    
    end process;   

end Behavioral;
