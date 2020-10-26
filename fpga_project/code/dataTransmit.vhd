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

entity dataTransmit is
    generic   ( BIT_DEPTH           : integer   := 8;       -- no. of bits data
                FIFO_BIT_DEPTH      : integer   := 12       -- fifo bit depth, defined by the fifo state
                );
    port      ( RST                 : in    std_logic;  -- active high synchronous reset 
                CLK                 : in    std_logic;  -- system clock
                CLK_MMCM            : in    std_logic;  -- mmcm clock
                -- SPI
                SPI_DIN             : out   std_logic_vector(7 downto 0);   -- input data for SPI master
                SPI_DOUT            : in    std_logic_vector(7 downto 0);   -- output data from SPI master
                CS_START_FLG        : in    std_logic;    -- signals that the cs line has gone low
                CS_END_FLG          : in    std_logic;    -- signals that the cs line has gone high
                LST_RISE_BIT        : in    std_logic;    -- signal indicating the last bit rising edge
                -- PCM
                CLK_PCM_CE          : in    std_logic;      -- pcm clock
                PCM_MIC1_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 1 data
                PCM_MIC2_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 2 data
                PCM_MIC3_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 3 data
                PCM_MIC4_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 4 data
                PCM_MIC5_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 5 data
                PCM_MIC6_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 6 data
                PCM_MIC7_DATA       : in    std_logic_vector (15 downto 0); -- pcm mic 7 data
                PCM_MIC8_DATA       : in    std_logic_vector (15 downto 0)  -- pcm mic 8 data
                );             
end dataTransmit;

architecture Behavioral of dataTransmit is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component fifoWrite
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
end component;

component fifoRead
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
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- fifo block generic signals
signal  fifoReset            : std_logic;
signal  fifoWrClk            : std_logic;
signal  fifoRdClk            : std_logic;

-- fifo 1 block signal
signal  fifoAEmpty_1         : std_logic;
signal  fifoAFull_1          : std_logic;
signal  fifoDout_1           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoEmpty_1          : std_logic;
signal  fifoFull_1           : std_logic;
signal  fifoRdCnt_1          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoRdErr_1          : std_logic;
signal  fifoWrCnt_1          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoWrErr_1          : std_logic;
signal  fifoDin_1            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoRdEn_1           : std_logic;
signal  fifoWrEn_1           : std_logic;

-- fifo 2 block signal
signal  fifoAEmpty_2         : std_logic;
signal  fifoAFull_2          : std_logic;
signal  fifoDout_2           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoEmpty_2          : std_logic;
signal  fifoFull_2           : std_logic;
signal  fifoRdCnt_2          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoRdErr_2          : std_logic;
signal  fifoWrCnt_2          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoWrErr_2          : std_logic;
signal  fifoDin_2            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoRdEn_2           : std_logic;
signal  fifoWrEn_2           : std_logic;

-- fifo 3 block signal
signal  fifoAEmpty_3         : std_logic;
signal  fifoAFull_3          : std_logic;
signal  fifoDout_3           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoEmpty_3          : std_logic;
signal  fifoFull_3           : std_logic;
signal  fifoRdCnt_3          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoRdErr_3          : std_logic;
signal  fifoWrCnt_3          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoWrErr_3          : std_logic;
signal  fifoDin_3            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoRdEn_3           : std_logic;
signal  fifoWrEn_3           : std_logic;

-- fifo 4 block signal
signal  fifoAEmpty_4         : std_logic;
signal  fifoAFull_4          : std_logic;
signal  fifoDout_4           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoEmpty_4          : std_logic;
signal  fifoFull_4           : std_logic;
signal  fifoRdCnt_4          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoRdErr_4          : std_logic;
signal  fifoWrCnt_4          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal  fifoWrErr_4          : std_logic;
signal  fifoDin_4            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal  fifoRdEn_4           : std_logic;
signal  fifoWrEn_4           : std_logic;

-- data transmission flags
signal  startFlg            : std_logic;
signal  stopFlg             : std_logic;

-- data transmission state
signal  fifoRstBuff         : std_logic;

begin

    -----------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------
    -----------------------------------------------------------------------------
    
    fifoWrComp: fifoWrite
        port map  ( CLK_MMCM            => CLK_MMCM,
                    -- PCM
                    CLK_PCM_CE          => CLK_PCM_CE,
                    PCM_MIC1_DATA       => PCM_MIC1_DATA, 
                    PCM_MIC2_DATA       => PCM_MIC2_DATA,  
                    PCM_MIC3_DATA       => PCM_MIC3_DATA,  
                    PCM_MIC4_DATA       => PCM_MIC4_DATA,   
                    PCM_MIC5_DATA       => PCM_MIC5_DATA,  
                    PCM_MIC6_DATA       => PCM_MIC6_DATA,   
                    PCM_MIC7_DATA       => PCM_MIC7_DATA, 
                    PCM_MIC8_DATA       => PCM_MIC8_DATA,
                    -- FIFO
                    FIFO_RST            => fifoReset,
                    FIFO_WR_EN_1        => fifoWrEn_1,
                    FIFO_WR_EN_2        => fifoWrEn_2,
                    FIFO_WR_EN_3        => fifoWrEn_3,
                    FIFO_WR_EN_4        => fifoWrEn_4,
                    FIFO_DIN_1          => fifoDin_1,
                    FIFO_DIN_2          => fifoDin_2,
                    FIFO_DIN_3          => fifoDin_3,
                    FIFO_DIN_4          => fifoDin_4
                    );
    
    fifoRdComp: fifoRead
        port map  ( CLK                 => CLK,
                    -- SPI
                    SPI_DIN             => SPI_DIN,
                    CS_START_FLG        => CS_START_FLG,
                    CS_END_FLG          => CS_END_FLG,
                    LST_RISE_BIT        => LST_RISE_BIT,
                    -- FIFO
                    FIFO_RST            => fifoReset,
                    FIFO_RD_EN_1        => fifoRdEn_1,
                    FIFO_RD_EN_2        => fifoRdEn_2,
                    FIFO_RD_EN_3        => fifoRdEn_3,
                    FIFO_RD_EN_4        => fifoRdEn_4,
                    FIFO_FULL_1         => fifoFull_1,
                    FIFO_FULL_2         => fifoFull_2,
                    FIFO_FULL_3         => fifoFull_3,
                    FIFO_FULL_4         => fifoFull_4,
                    FIFO_DOUT_1         => fifoDout_1,
                    FIFO_DOUT_2         => fifoDout_2,
                    FIFO_DOUT_3         => fifoDout_3,
                    FIFO_DOUT_4         => fifoDout_4
                    );
    
    -- FIFO_DUALCLOCK_MACRO: Dual-Clock First-In, First-Out (FIFO) RAM Buffer
    --                       Artix-7
    -- Xilinx HDL Language Template, version 2017.4
    
    -- Note -  This Unimacro model assumes the port directions to be "downto". 
    --         Simulation of this model with "to" in the port directions could lead to erroneous results.
    
    -----------------------------------------------------------------
    -- DATA_WIDTH | FIFO_SIZE | FIFO Depth | rdCount1/wrCount1 Width --
    -- ===========|===========|============|=======================--
    --   37-72    |  "36Kb"   |     512    |         9-bit         --
    --   19-36    |  "36Kb"   |    1024    |        10-bit         --
    --   19-36    |  "18Kb"   |     512    |         9-bit         --
    --   10-18    |  "36Kb"   |    2048    |        11-bit         --
    --   10-18    |  "18Kb"   |    1024    |        10-bit         --
    --    5-9     |  "36Kb"   |    4096    |        12-bit         --
    --    5-9     |  "18Kb"   |    2048    |        11-bit         --
    --    1-4     |  "36Kb"   |    8192    |        13-bit         --
    --    1-4     |  "18Kb"   |    4096    |        12-bit         --
    -----------------------------------------------------------------
    
    FIFO_DUALCLOCK_MACRO_inst_1 : FIFO_DUALCLOCK_MACRO
        generic map   ( DEVICE                  => "7SERIES",           -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
                        ALMOST_full_OFFSET      => X"0080",             -- Sets almost full1 threshold
                        ALMOST_empty_OFFSET     => X"0080",             -- Sets the almost empty1 threshold
                        DATA_WIDTH              => 8,                   -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
                        FIFO_SIZE               => "36Kb",              -- Target BRAM, "18Kb" or "36Kb" 
                        FIRST_WORD_FALL_THROUGH => FALSE)                -- Sets the FIFO FWFT to TRUE or FALSE
        port map      ( almostempty             => fifoAEmpty_1,        -- 1-bit output almost empty1
                        almostfull              => fifoAFull_1,         -- 1-bit output almost full1
                        DO                      => fifoDout_1,          -- Output data, width defined by DATA_WIDTH parameter
                        empty                   => fifoEmpty_1,         -- 1-bit output empty1
                        full                    => fifoFull_1,          -- 1-bit output full1
                        rdCount                 => fifoRdCnt_1,         -- Output read count, width determined by FIFO depth
                        rdErr                   => fifoRdErr_1,         -- 1-bit output read error
                        wrCount                 => fifoWrCnt_1,         -- Output write count, width determined by FIFO depth
                        wrErr                   => fifoWrErr_1,         -- 1-bit output write error
                        DI                      => fifoDin_1,           -- Input data, width defined by DATA_WIDTH parameter
                        rdClk                   => fifoRdClk,           -- 1-bit input read clock
                        rdEn                    => fifoRdEn_1,          -- 1-bit input read enable
                        RST                     => fifoReset,           -- 1-bit input reset
                        wrClk                   => fifoWrClk,           -- 1-bit input write clock
                        wrEn                    => fifoWrEn_1           -- 1-bit input write enable
                        );
                    
    FIFO_DUALCLOCK_MACRO_inst_2 : FIFO_DUALCLOCK_MACRO
        generic map   ( DEVICE                  => "7SERIES",           -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
                        ALMOST_full_OFFSET      => X"0080",             -- Sets almost full1 threshold
                        ALMOST_empty_OFFSET     => X"0080",             -- Sets the almost empty1 threshold
                        DATA_WIDTH              => 8,                   -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
                        FIFO_SIZE               => "36Kb",              -- Target BRAM, "18Kb" or "36Kb" 
                        FIRST_WORD_FALL_THROUGH => FALSE)                -- Sets the FIFO FWFT to TRUE or FALSE
        port map      ( almostempty             => fifoAEmpty_2,        -- 1-bit output almost empty1
                        almostfull              => fifoAFull_2,         -- 1-bit output almost full1
                        DO                      => fifoDout_2,          -- Output data, width defined by DATA_WIDTH parameter
                        empty                   => fifoEmpty_2,         -- 1-bit output empty1
                        full                    => fifoFull_2,          -- 1-bit output full1
                        rdCount                 => fifoRdCnt_2,         -- Output read count, width determined by FIFO depth
                        rdErr                   => fifoRdErr_2,         -- 1-bit output read error
                        wrCount                 => fifoWrCnt_2,         -- Output write count, width determined by FIFO depth
                        wrErr                   => fifoWrErr_2,         -- 1-bit output write error
                        DI                      => fifoDin_2,           -- Input data, width defined by DATA_WIDTH parameter
                        rdClk                   => fifoRdClk,           -- 1-bit input read clock
                        rdEn                    => fifoRdEn_2,          -- 1-bit input read enable
                        RST                     => fifoReset,           -- 1-bit input reset
                        wrClk                   => fifoWrClk,           -- 1-bit input write clock
                        wrEn                    => fifoWrEn_2           -- 1-bit input write enable
                        );
                        
    FIFO_DUALCLOCK_MACRO_inst_3 : FIFO_DUALCLOCK_MACRO
        generic map   ( DEVICE                  => "7SERIES",           -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
                        ALMOST_full_OFFSET      => X"0080",             -- Sets almost full1 threshold
                        ALMOST_empty_OFFSET     => X"0080",             -- Sets the almost empty1 threshold
                        DATA_WIDTH              => 8,                   -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
                        FIFO_SIZE               => "36Kb",              -- Target BRAM, "18Kb" or "36Kb" 
                        FIRST_WORD_FALL_THROUGH => FALSE)                -- Sets the FIFO FWFT to TRUE or FALSE
        port map      ( almostempty             => fifoAEmpty_3,        -- 1-bit output almost empty1
                        almostfull              => fifoAFull_3,         -- 1-bit output almost full1
                        DO                      => fifoDout_3,          -- Output data, width defined by DATA_WIDTH parameter
                        empty                   => fifoEmpty_3,         -- 1-bit output empty1
                        full                    => fifoFull_3,          -- 1-bit output full1
                        rdCount                 => fifoRdCnt_3,         -- Output read count, width determined by FIFO depth
                        rdErr                   => fifoRdErr_3,         -- 1-bit output read error
                        wrCount                 => fifoWrCnt_3,         -- Output write count, width determined by FIFO depth
                        wrErr                   => fifoWrErr_3,         -- 1-bit output write error
                        DI                      => fifoDin_3,           -- Input data, width defined by DATA_WIDTH parameter
                        rdClk                   => fifoRdClk,           -- 1-bit input read clock
                        rdEn                    => fifoRdEn_3,          -- 1-bit input read enable
                        RST                     => fifoReset,           -- 1-bit input reset
                        wrClk                   => fifoWrClk,           -- 1-bit input write clock
                        wrEn                    => fifoWrEn_3           -- 1-bit input write enable
                        );
          
          
    FIFO_DUALCLOCK_MACRO_inst_4 : FIFO_DUALCLOCK_MACRO
        generic map   ( DEVICE                  => "7SERIES",           -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
                        ALMOST_full_OFFSET      => X"0080",             -- Sets almost full1 threshold
                        ALMOST_empty_OFFSET     => X"0080",             -- Sets the almost empty1 threshold
                        DATA_WIDTH              => 8,                   -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
                        FIFO_SIZE               => "36Kb",              -- Target BRAM, "18Kb" or "36Kb" 
                        FIRST_WORD_FALL_THROUGH => FALSE)                -- Sets the FIFO FWFT to TRUE or FALSE
        port map      ( almostempty             => fifoAEmpty_4,        -- 1-bit output almost empty1
                        almostfull              => fifoAFull_4,         -- 1-bit output almost full1
                        DO                      => fifoDout_4,          -- Output data, width defined by DATA_WIDTH parameter
                        empty                   => fifoEmpty_4,         -- 1-bit output empty1
                        full                    => fifoFull_4,          -- 1-bit output full1
                        rdCount                 => fifoRdCnt_4,         -- Output read count, width determined by FIFO depth
                        rdErr                   => fifoRdErr_4,         -- 1-bit output read error
                        wrCount                 => fifoWrCnt_4,         -- Output write count, width determined by FIFO depth
                        wrErr                   => fifoWrErr_4,         -- 1-bit output write error
                        DI                      => fifoDin_4,           -- Input data, width defined by DATA_WIDTH parameter
                        rdClk                   => fifoRdClk,           -- 1-bit input read clock
                        rdEn                    => fifoRdEn_4,          -- 1-bit input read enable
                        RST                     => fifoReset,           -- 1-bit input reset
                        wrClk                   => fifoWrClk,           -- 1-bit input write clock
                        wrEn                    => fifoWrEn_4           -- 1-bit input write enable
                        );
    
    -----------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------
    -----------------------------------------------------------------------------
    
    -- fifo write clock
    fifoWrClk <= CLK_MMCM;
    
    -- fifo read clock
    fifoRdClk <= CLK;  

    -------------------------- DATA TRANSMISSION PROCESS ------------------------
    -- handles the sycronisation of the fifo read, write and reset processes. 
    -- this is partly dictated by how the spi master handles the process.
    
    -- data transfer flags
    process(RST, CLK)
    begin 
        if (rising_edge(CLK)) then
            if (RST = '1') then
                startFlg <= '0';
                stopFlg <= '0';
            else
                if (CS_END_FLG = '1') then
                    case SPI_DOUT is
                    
                    -- start transmission
                    when "10101010" =>
                        startFlg <= '1';
                    
                    -- stop transmission      
                    when "00001111" =>
                        stopFlg <= '1';
                        
                    when others =>
                        startFlg <= '0';
                        stopFlg <= '0';
                    
                    end case;
                else
                    startFlg <= '0';
                    stopFlg <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- fifo reset
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                fifoRstBuff <= '1';
            else
                if (startFlg =  '1') then
                    fifoRstBuff <= '0';
                elsif (stopFlg = '1') then
                    fifoRstBuff <= '1';   
                end if;
            end if;
        end if;
    end process;
    
    -- assign fifo reset
    fifoReset <= fifoRstBuff;
  
end Behavioral;
