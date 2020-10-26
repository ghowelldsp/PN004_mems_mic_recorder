----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2020 19:41:42
-- Design Name: 
-- Module Name: clocks - Behavioral
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

entity clocks is
    -- sysClk   => 100MHz
    -- mmcmClk  => 61.44MHZ
    generic   ( CLK_SPI_MAX_VAL     : integer  := 9;        -- no. of cycles of sysClk for spi period ((sysClk/spi)-1) [9@10MHz]
                CLK_SPI_HD_VAL      : integer  := 5;        -- no. of cycles of sysClk for spi half duty ((sysClk/spi)/2) [5@10MHz]
                CLK_PDM_MAX_VAL     : integer  := 19;       -- no. of cycles of mmdc for pdm period ((mmcm/pdm)-1) [19@3.072MHz] 
                CLK_PDM_HD_VAL      : integer  := 10;       -- no. of cycles of mmdc for pdm half duty (mmcm/pdm)/2)) [10@3.072MHz] 
                CLK_PCM_MAX_VAL     : integer  := 1279;     -- no. of cycles of mmdc for pcm period ((mmcm/pcm)-1) [1279@48kHz] 
                CLK_PCM_HD_VAL      : integer  := 640       -- no. of cycles of mmdc for pcm half duty (mmcm/pcm)/2)) [640@48kHz]
                );
    port      ( RST_SYS             : in    std_logic;
                RST_MMCM            : in    std_logic;
                CLK_SYS             : in    std_logic;
                -- MMCM CLOCK AND DIVIDED SIGNALS
                CLK_MMCM            : out   std_logic;      -- mmcm clk signal running at 61.44 MHz
                CLK_MMCM_LOCK       : out   std_logic;      -- mmcm clk lock signal
                CLK_PDM_CE          : out   std_logic;      -- oversampling clock for the pdm signal
                CLK_PDM_CE_PHASE    : out   std_logic;      -- oversampling clock for the pdm signal, 180 deg out of phase
                CLK_PDM_HD          : out   std_logic;      -- oversampling clock with 50% duty cycle, for the fifo's
                CLK_FLT8_CE         : out   std_logic;      -- clock for filter rate (8 times slower than pdm clk)
                CLK_FLT16_CE        : out   std_logic;      -- clock for filter rate (16 times slower than pdm clk)
                CLK_FLT32_CE        : out   std_logic;      -- clock for filter rate (32 times slower than pdm clk)
                CLK_PCM_CE          : out   std_logic;      -- pcm audio sample clock
                CLK_PCM_CE_PHASE    : out   std_logic;      -- pcm audio sample clock, 180 deg out of phase
                -- SYS CLOCK DIVIDED SIGNALS
                CLK_SPI_CE          : out   std_logic
                );            
end clocks;

architecture Behavioral of clocks is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component mmcm_clock
    port  ( CLK_OUT1    : out   std_logic;
            RESET       : in    std_logic;
            LOCKED      : out   std_logic;
            SYSCLK      : in    std_logic
            );
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- mmcm signals
signal clkMmcm                  : std_logic;

-- pdm clocks
signal clkPdmCeCnt              : integer range 0 to CLK_PDM_MAX_VAL;
signal clkPdmHdCnt              : integer range 0 to CLK_PDM_MAX_VAL;
signal clkPdmHD                 : std_logic;
signal clkPdmCe                 : std_logic;

-- filter clocks
signal fltClkCnt8               : unsigned(2 downto 0);
signal fltClkPhase8             : std_logic;
signal fltClkPhase8Tmp          : std_logic;
signal fltClkCnt16              : unsigned(3 downto 0);
signal fltClkPhase16            : std_logic;
signal fltClkPhase16Tmp         : std_logic;
signal fltClkCnt32              : unsigned(4 downto 0);
signal fltClkPhase32            : std_logic;
signal fltClkPhase32Tmp         : std_logic;

-- pcm clocks
signal clkPcmCeCnt              : integer range 0 to 3839;

-- spi clocks
signal clkSpiCECnt              : integer range 0 to CLK_SPI_MAX_VAL;

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    mmcm_clocks : mmcm_clock   
        port map  ( CLK_OUT1    => clkMmcm,
                    RESET       => RST_SYS,
                    LOCKED      => CLK_MMCM_LOCK,
                    SYSCLK      => CLK_SYS 
                    );
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------
    
    -- send clk mmcm out of component
    CLK_MMCM <= clkMmcm;
    
    --------------------------------- PDM CLOCKS --------------------------------------
    
     -- pdm count
     process(RST_MMCM, clkMmcm)
     begin
         if (RST_MMCM = '1') then
             clkPdmCeCnt <= 0;
         elsif (rising_edge(clkMmcm)) then   
             if (clkPdmCeCnt = CLK_PDM_MAX_VAL) then
                 clkPdmCeCnt <= 0;
             else
                 clkPdmCeCnt <= clkPdmCeCnt + 1;
             end if;
         end if;    
     end process;
     
     -- creates pdm CE output clock signal
     clkPdmCe <= '1' when (clkPdmCeCnt = 1) else '0';
     CLK_PDM_CE <= '1' when (clkPdmCeCnt = 1) else '0';
     
     -- creates pdm phased clock
     CLK_PDM_CE_PHASE <= '1' when (clkPdmCeCnt = CLK_PDM_HD_VAL) else '0';
     
     -- pdm half duty clock
     process (RST_MMCM, clkMmcm)
     begin
         if (RST_MMCM = '1') then
             clkPdmHdCnt <= 0;
             clkPdmHD <= '0';
         elsif (rising_edge(clkMmcm)) then
             if clkPdmHdCnt < CLK_PDM_HD_VAL then
                 clkPdmHD <= '1';
                 clkPdmHdCnt <= clkPdmHdCnt + 1;
             elsif (clkPdmHdCnt = CLK_PDM_MAX_VAL) then
                 clkPdmHD <= '0';
                 clkPdmHdCnt <= 0;
             else
                 clkPdmHD <= '0';
                 clkPdmHdCnt <= clkPdmHdCnt + 1;
             end if;
         end if;
     end process;
     
     -- buffers half duty clock to output    
     CLK_PDM_HD <= clkPdmHD; --when (RESET = '0') else '0';
     
     ------------------------------ FILTER STAGES CLOCKS -------------------------------
     
     -- FILTER CLOCK (8x time slower that pdm clk)
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkCnt8 <= to_unsigned(1,3);
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                if (fltClkCnt8 >= to_unsigned(7,3)) then
                    fltClkCnt8 <= to_unsigned(0,3);
                else
                    fltClkCnt8 <= fltClkCnt8 + to_unsigned(1,3);
                end if;
            end if;
        end if;
     end process;
     
     fltClkPhase8Tmp <= '1' when (fltClkCnt8 = to_unsigned(0,3) and clkPdmCe = '1') else '0';
     
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkPhase8 <= '1';
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                fltClkPhase8 <= fltClkPhase8Tmp;
            end if;  
        end if;
     end process;
     
     CLK_FLT8_CE <= fltClkPhase8 and clkPdmCe;
     
     -- FILTER CLOCK (16x time slower that pdm clk)
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkCnt16 <= to_unsigned(1,4);
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                if (fltClkCnt16 >= to_unsigned(15,4)) then
                    fltClkCnt16 <= to_unsigned(0,4);
                else
                    fltClkCnt16 <= fltClkCnt16 + to_unsigned(1,4);
                end if;
            end if;
        end if;
     end process;
     
     fltClkPhase16Tmp <= '1' when (fltClkCnt16 = to_unsigned(0,4) and clkPdmCe = '1') else '0';
     
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkPhase16 <= '1';
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                fltClkPhase16 <= fltClkPhase16Tmp;
            end if;  
        end if;
     end process;
     
     CLK_FLT16_CE <= fltClkPhase16 and clkPdmCe;
     
     -- FILTER CLOCK (32x time slower that pdm clk)
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkCnt32 <= to_unsigned(1,5);
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                if (fltClkCnt32 >= to_unsigned(31,5)) then
                    fltClkCnt32 <= to_unsigned(0,5);
                else
                    fltClkCnt32 <= fltClkCnt32 + to_unsigned(1,5);
                end if;
            end if;
        end if;
     end process;
     
     fltClkPhase32Tmp <= '1' when (fltClkCnt32 = to_unsigned(0,5) and clkPdmCe = '1') else '0';
     
     process (RST_MMCM, clkMmcm)
     begin
        if (RST_MMCM = '1') then
            fltClkPhase32 <= '1';
        elsif (rising_edge(clkMmcm)) then
            if (clkPdmCe = '1') then
                fltClkPhase32 <= fltClkPhase32Tmp;
            end if;  
        end if;
     end process;
     
     CLK_FLT32_CE <= fltClkPhase32 and clkPdmCe;
     
     --------------------------------- PCM CLOCKS --------------------------------------
     
     -- PCM CLOCK COUNT PROCESS 
     process (RST_MMCM, clkMmcm)
     begin
         if (RST_MMCM = '1') then
             clkPcmCeCnt <= 0;
         elsif (rising_edge(clkMmcm)) then
             if clkPcmCeCnt = CLK_PCM_MAX_VAL then
                 clkPcmCeCnt <= 0;
             else
                 clkPcmCeCnt <= clkPcmCeCnt + 1;
             end if;
         end if; 
     end process;
     
     -- trigger a pulse when the sample count is 0 and 1MHz clock
     CLK_PCM_CE <= '1' when (clkPcmCeCnt = 1) else '0';
     CLK_PCM_CE_PHASE <= '1' when (clkPcmCeCnt = CLK_PCM_HD_VAL) else '0';

    --------------------------------- SPI CLOCKS --------------------------------------
    
    -- CLOCK SPI CE COUNT PROCESS
    process(RST_SYS, CLK_SYS)
    begin
        if (RST_SYS = '1') then
            clkSpiCECnt <= 0;
        elsif (rising_edge(CLK_SYS)) then   
            if (clkSpiCECnt = CLK_SPI_MAX_VAL) then
                clkSpiCECnt <= 0;
            else
                clkSpiCECnt <= clkSpiCECnt + 1;
            end if;
        end if;    
    end process;
    
    -- creates ce output signal
    CLK_SPI_CE <= '1' when (clkSpiCECnt = 1 and RST_SYS = '0') else '0';
    
end Behavioral;
