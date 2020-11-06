----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2020 23:26:35
-- Design Name: 
-- Module Name: pdm2bitDecode - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity pdm2bitDecode is
    generic   ( PDM_BIT1_OFFSET_VAL : integer       := 4;      -- this is the number of sys clk cycles before mic1 pdm data is captured
                PDM_BIT2_OFFSET_VAL : integer       := 14      -- this is the number of sys clk cycles before mic1 pdm data is captured
                );
    port      ( RST                 : in    std_logic;          -- system reset
                CLK                 : in    std_logic;          -- system clk
                CLK_PDM_CE          : in    std_logic;          -- pdm oversampling clk enable
                -- PDM DATA
                PDM_DATA            : in    std_logic;          -- pdm data from mics
                PDM_2BIT_MIC1_DATA  : out   std_logic_vector (1 downto 0);  -- pdm data output in 2 bit format
                PDM_2BIT_MIC2_DATA  : out   std_logic_vector (1 downto 0);  -- pdm data output in 2 bit format
                -- PDM FLAGS
                PDM_BIT1_FLG        : out   std_logic;
                PDM_BIT2_FLG        : out   std_logic
                );
end pdm2bitDecode;

architecture Behavioral of pdm2bitDecode is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- pdm offset count
signal pdmOffsetCnt                 : integer range 0 to 20;
signal pdmBit1Flg                   : std_logic;
signal pdmBit2Flg                   : std_logic;

-- pdm latch signals
signal pdmLatch1                    : std_logic;
signal pdmLatch2                    : std_logic;

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    --------------------------------- PDM OFFSET --------------------------------------
    
    -- pdm offset state process
    process (RST, CLK)
    begin
        if (RST = '1') then
            pdmOffsetCnt <= 0; 
        elsif (rising_edge(CLK)) then
            if (CLK_PDM_CE = '1') then
                pdmOffsetCnt <= 0;
            else
                pdmOffsetCnt <= pdmOffsetCnt + 1;
            end if; 
        end if;
    end process;
    
    -- PDM OFFSET FLAG
    pdmBit1Flg <= '1' when (pdmOffsetCnt = PDM_BIT1_OFFSET_VAL) else '0';
    pdmBit2Flg <= '1' when (pdmOffsetCnt = PDM_BIT2_OFFSET_VAL) else '0';
    
    PDM_BIT1_FLG <= pdmBit1Flg;
    PDM_BIT2_FLG <= pdmBit2Flg;
    
    --------------------------------- PDM LATCH ---------------------------------------
    
    -- PDM DATA LATCH PROCESS
    -- latches the PDM input data on the offset
    process (RST, CLK)
    begin
        if (RST = '1') then
            pdmLatch1 <= 'U'; 
            pdmLatch2 <= 'U';        
        elsif (rising_edge(CLK)) then -- latches pdm data from the mics at the offset flag
            if (pdmBit1Flg = '1') then
                pdmLatch1 <= PDM_DATA;
            elsif (pdmBit2Flg = '1') then
                pdmLatch2 <= PDM_DATA;                
            end if;
        end if;
    end process;
    
    
    -- CONVERTS DATA TO 2 BITS
    PDM_2BIT_MIC1_DATA <=   "01" when (pdmLatch1 = '1') else
                            "11" when (pdmLatch1 = '0') else
                            "00"; 
    
    PDM_2BIT_MIC2_DATA <=   "01" when (pdmLatch2 = '1') else
                            "11" when (pdmLatch2 = '0') else
                            "00";                                        

end Behavioral;
