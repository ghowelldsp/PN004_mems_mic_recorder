----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2020 19:41:42
-- Design Name: 
-- Module Name: memsMicRec_top - Behavioral
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

entity memsMicRec_top is
    generic   ( SYS_RST_VAL         : integer   := 10000000; -- no. of sysClk cycles before reset (10000000=0.1ms@100Mhz)
                MMCM_RST_VAL        : integer   := 6144000   -- no. of mmcmClk cycles before reset (6144000=0.1ms@61.44Mhz)
                );   
    port      ( CLK                 : in    std_logic;  -- board clock (100Mhz)
                CLK_PDM_HD          : out   std_logic;  -- pdm mic clock
                PDM_DATA_IN         : in    std_logic;  -- mic pdm data
                -- SPI SIGNALS
                SCLK                : in    std_logic; -- SPI clock
                CS_N                : in    std_logic; -- SPI chip select, active in low
                MOSI                : in    std_logic; -- SPI serial data from master to slave
                MISO                : out   std_logic  -- SPI serial data from slave to master
                -- I2S SIGNALS
--                B_CLK               : in    std_logic;
--                LR_CLK              : in    std_logic;
--                I2S_DOUT_1          : out   std_logic;
--                I2S_DOUT_2          : out   std_logic;
--                I2S_DOUT_3          : out   std_logic;
--                I2S_DOUT_4          : out   std_logic
                ); 
end memsMicRec_top;

architecture Behavioral of memsMicRec_top is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component clocks
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
end component;

component pdm2bitDecode
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
end component;

component cicDemod
    port      ( RST                 : in    std_logic;                      -- system reset
                CLK                 : in    std_logic;                      -- sys clock
                CLK_PDM_CE          : in    std_logic;                      -- pdm clock
                PDM_MIC1_DIN        : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
                PDM_MIC2_DIN        : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
                PCM_MIC1_DOUT       : out   std_logic_vector (15 downto 0); -- pcm data out
                PCM_MIC2_DOUT       : out   std_logic_vector (15 downto 0); -- pcm data out
                PDM_BIT1_FLG        : in    std_logic;                      -- signal that indicates bit 1 of the pdm signal has been read
                PDM_BIT2_FLG        : in    std_logic                       -- signal that indicates bit 2 of the pdm signal has been read                       
                );
end component;

component cicFirDemod
    port      ( RST                 : in    std_logic;                      -- system reset
                CLK                 : in    std_logic;                      -- sys clock
                CLK_PDM_CE          : in    std_logic;                      -- pdm clock
                CLK_FLT8_CE         : in    std_logic;                      -- clock for filter rate (8 times slower than pdm clk)
                CLK_FLT16_CE        : in    std_logic;                      -- clock for filter rate (16 times slower than pdm clk)
                CLK_FLT32_CE        : in    std_logic;                      -- clock for filter rate (32 times slower than pdm clk)
                PDM_MIC1_DIN        : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
                PDM_MIC2_DIN        : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
                PCM_MIC1_DOUT       : out   std_logic_vector (15 downto 0); -- pcm data out
                PCM_MIC2_DOUT       : out   std_logic_vector (15 downto 0)  -- pcm data out                      
                );
end component;

component dcFiltering
    port      ( RST                 : in    std_logic;                      -- system reset
                CLK                 : in    std_logic;                      -- sys clock
                CLK_CE              : in    std_logic;                      -- clock enable
                DIN_1_1             : in    std_logic_vector(15 downto 0);  -- data in
                DIN_2_1             : in    std_logic_vector(15 downto 0);  -- data in
                DIN_1_2             : in    std_logic_vector(15 downto 0);  -- data in
                DIN_2_2             : in    std_logic_vector(15 downto 0);  -- data in
                DOUT_1_1            : out   std_logic_vector (15 downto 0); -- data out
                DOUT_2_1            : out   std_logic_vector (15 downto 0); -- data out
                DOUT_1_2            : out   std_logic_vector (15 downto 0); -- data out
                DOUT_2_2            : out   std_logic_vector (15 downto 0)  -- data out                    
                );
end component;

---- i2s slave
--component i2sTransfer
--    port      ( CLK                 : in  std_logic; -- system clock
--                RST                 : in  std_logic; -- high active synchronous reset
--                -- I2S SIGNALS
--                B_CLK               : in  std_logic; -- bit clock
--                LR_CLK              : in  std_logic; -- left right clock
--                -- DATA SIGNALS
--                DIN1_1              : in  std_logic_vector(15 downto 0); -- input data 1 pair 1
--                DIN2_1              : in  std_logic_vector(15 downto 0); -- input data 2 pair 1
--                DIN1_2              : in  std_logic_vector(15 downto 0); -- input data 1 pair 2
--                DIN2_2              : in  std_logic_vector(15 downto 0); -- input data 2 pair 2
--                DIN1_3              : in  std_logic_vector(15 downto 0); -- input data 1 pair 3
--                DIN2_3              : in  std_logic_vector(15 downto 0); -- input data 2 pair 3
--                DIN1_4              : in  std_logic_vector(15 downto 0); -- input data 1 pair 4
--                DIN2_4              : in  std_logic_vector(15 downto 0); -- input data 2 pair 4
--                DOUT1               : out std_logic; -- output data 1
--                DOUT2               : out std_logic; -- output data 2
--                DOUT3               : out std_logic; -- output data 3
--                DOUT4               : out std_logic  -- output data 4
--                );
--end component;

-- spi
component spiSlave
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
end component;

component spiDataTransfer
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
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- reset function
signal  rstCnt              : integer range 0 to SYS_RST_VAL;
signal  rstSys              : std_logic                         := '1';

-- rst MMCM
signal  rstCntMMCM          : integer range 0 to MMCM_RST_VAL;
signal  rstMMCM             : std_logic                         := '1';

-- clocking signals
signal  clkMmcm             : std_logic; 
signal  clkMmcmLock         : std_logic; 
signal  clkPdmCE            : std_logic;    
signal  clkPdmCEphase       : std_logic;
signal  clkPcmCE            : std_logic;
signal  clkFlt8Ce           : std_logic;
signal  clkFlt16Ce          : std_logic;
signal  clkFlt32Ce          : std_logic;  
signal  clkPcmCEphase       : std_logic;
signal  clkSpiCE            : std_logic;

-- pdm signals
signal  pdm2bitMic1Data     : std_logic_vector (1 downto 0);
signal  pdm2bitMic2Data     : std_logic_vector (1 downto 0);
signal  pdmBit1Flg          : std_logic;
signal  pdmBit2Flg          : std_logic;

-- pcm signals
signal  pcmMic1Data         : std_logic_vector (15 downto 0);
signal  pcmMic2Data         : std_logic_vector (15 downto 0);
signal  pcmMic1Data2        : std_logic_vector (15 downto 0);
signal  pcmMic2Data2        : std_logic_vector (15 downto 0);

-- hp filter signals
signal  hpFltDout1_1        : std_logic_vector (15 downto 0);
signal  hpFltDout2_1        : std_logic_vector (15 downto 0);
signal  hpFltDout1_2        : std_logic_vector (15 downto 0);
signal  hpFltDout2_2        : std_logic_vector (15 downto 0);

-- spi signals
signal  spiDin              : std_logic_vector(7 downto 0);
signal  spiDout             : std_logic_vector(7 downto 0);
signal  spiDout1            : std_logic_vector(7 downto 0);
signal  csStartFlg          : std_logic;
signal  csEndFlg            : std_logic;
signal  spiLstRiseFlg       : std_logic;
signal  spiLstFallFlg       : std_logic;

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    clocking_comp : clocks                     
        port map  ( RST_SYS             => rstSys,
                    RST_MMCM            => rstMMCM,
                    CLK_SYS             => CLK,
                    -- MMCM CLOCK DIVIDED SIGNALS
                    CLK_MMCM            => clkMmcm, 
                    CLK_MMCM_LOCK       => clkMmcmLock,
                    CLK_PDM_CE          => clkPdmCE,
                    CLK_PDM_CE_PHASE    => clkPdmCEphase,
                    CLK_PDM_HD          => CLK_PDM_HD,
                    CLK_FLT8_CE         => clkFlt8Ce,
                    CLK_FLT16_CE        => clkFlt16Ce,
                    CLK_FLT32_CE        => clkFlt32Ce,    
                    CLK_PCM_CE          => clkPcmCE,
                    CLK_PCM_CE_PHASE    => clkPcmCEphase,
                    -- SYS CLOCK DIVIDED SIGNALS
                    CLK_SPI_CE          => clkSpiCE
                    );
                    
    pdm2bitDecode_comp : pdm2bitDecode
        port map  ( RST                 => rstMMCM,
                    CLK                 => clkMmcm,
                    CLK_PDM_CE          => clkPdmCE,
                    -- PDM DATA
                    PDM_DATA            => PDM_DATA_IN,
                    PDM_2BIT_MIC1_DATA  => pdm2bitMic1Data,
                    PDM_2BIT_MIC2_DATA  => pdm2bitMic2Data,
                    -- PDM FLAGS
                    PDM_BIT1_FLG        => pdmBit1Flg,
                    PDM_BIT2_FLG        => pdmBit2Flg
                    );
                   
    cicDemod_comp : cicDemod
        port map  ( RST                 => rstMMCM,
                    CLK                 => clkMmcm,
                    CLK_PDM_CE          => clkPdmCE,
                    PDM_MIC1_DIN        => pdm2bitMic1Data,
                    PDM_MIC2_DIN        => pdm2bitMic2Data,
                    PCM_MIC1_DOUT       => pcmMic1Data,
                    PCM_MIC2_DOUT       => pcmMic2Data,
                    PDM_BIT1_FLG        => pdmBit1Flg,
                    PDM_BIT2_FLG        => pdmBit2Flg             
                    );
                    
    cicFirDemod_comp : cicFirDemod
        port map  ( RST                 => rstMMCM,
                    CLK                 => clkMmcm,
                    CLK_PDM_CE          => clkPdmCE,
                    CLK_FLT8_CE         => clkFlt8Ce,
                    CLK_FLT16_CE        => clkFlt16Ce,
                    CLK_FLT32_CE        => clkFlt32Ce,
                    PDM_MIC1_DIN        => pdm2bitMic1Data,
                    PDM_MIC2_DIN        => pdm2bitMic2Data,
                    PCM_MIC1_DOUT       => pcmMic1Data2,
                    PCM_MIC2_DOUT       => pcmMic2Data2          
                    );
                    
    dcFiltering_comp : dcFiltering
        port map  ( RST                 => rstMMCM,
                    CLK                 => clkMmcm,
                    CLK_CE              => clkPcmCE,
                    DIN_1_1             => pcmMic1Data,
                    DIN_2_1             => pcmMic2Data,
                    DIN_1_2             => pcmMic1Data2,
                    DIN_2_2             => pcmMic2Data2,
                    DOUT_1_1            => hpFltDout1_1,
                    DOUT_2_1            => hpFltDout2_1,
                    DOUT_1_2            => hpFltDout1_2,
                    DOUT_2_2            => hpFltDout2_2
                    );
                    
                    
     -- i2s slave
--    i2sTransfer_comp : i2sTransfer
--        port map  ( RST                 => rstMMCM,
--                    CLK                 => clkMmcm,
--                    B_CLK               => B_CLK,
--                    LR_CLK              => LR_CLK,
--                    DIN1_1              => pcmMic1Data,
--                    DIN2_1              => pcmMic2Data,
--                    DIN1_2              => pcmMic1Data2,
--                    DIN2_2              => pcmMic2Data2,
--                    DIN1_3              => hpFltDout1_1,
--                    DIN2_3              => hpFltDout2_1,
--                    DIN1_4              => hpFltDout1_2,
--                    DIN2_4              => hpFltDout2_2,
--                    DOUT1               => I2S_DOUT_1,
--                    DOUT2               => I2S_DOUT_2,
--                    DOUT3               => I2S_DOUT_3,
--                    DOUT4               => I2S_DOUT_4
--                    );
                    
    spiSlave_comp : spiSlave
        port map  ( CLK                 => CLK,
                    RST                 => rstSys,
                    -- SPI SLAVE INTERFACE
                    SCLK                => SCLK,
                    CS_N                => CS_N,
                    MOSI                => MOSI,
                    MISO                => MISO,
                    -- USER INTERFACE
                    DIN                 => spiDin,
                    DOUT                => spiDout,
                    CS_START_FLG        => csStartFlg,
                    CS_END_FLG          => csEndFlg,
                    LST_RISE_BIT        => spiLstRiseFlg,
                    LST_FALL_BIT        => spiLstFallFlg
                    );
                    
    spiDataTransfer_comp : spiDataTransfer
        port map  ( RST                 => rstSys,
                    CLK                 => CLK,
                    CLK_MMCM            => clkMmcm,
                    -- SPI
                    SPI_DOUT            => spiDout,
                    SPI_DIN             => spiDin,
                    CS_START_FLG        => csStartFlg,
                    CS_END_FLG          => csEndFlg,
                    LST_RISE_BIT        => spiLstRiseFlg,
                    -- PCM
                    CLK_PCM_CE          => clkPcmCE,
                    PCM_MIC1_DATA       => pcmMic1Data,     -- cic signals mic 1
                    PCM_MIC2_DATA       => pcmMic2Data,     -- cic signals mic 2
                    PCM_MIC3_DATA       => pcmMic1Data2,    -- cic / fir signals mic 1
                    PCM_MIC4_DATA       => pcmMic2Data2,    -- cic / fir signals mic 2
                    PCM_MIC5_DATA       => hpFltDout1_1,    -- cic hp signals mic 1
                    PCM_MIC6_DATA       => hpFltDout2_1,    -- cic hp signals mic 2
                    PCM_MIC7_DATA       => hpFltDout1_2,    -- cic / fir hp signals mic 1
                    PCM_MIC8_DATA       => hpFltDout2_2     -- cic / fir hp signals mic 2
                    );
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------
    
    -------------------------------- SYSTEM RESET -------------------------------------
    
    -- rst counting process
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            if (rstSys = '1') then
                if (rstCnt = SYS_RST_VAL) then 
                    rstCnt <= 0;
                else
                    rstCnt <= rstCnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- system reset line (high when active)
    rstSys <= '0' when (rstCnt = SYS_RST_VAL) else '1';       
       
    -- mmcm rst counting process
    process(clkMmcm)
    begin
        if (rising_edge(clkMmcm)) then
            if (rstMMCM = '1') then
                if (rstCntMMCM = MMCM_RST_VAL) then
                    rstCntMMCM <= 0;
                else
                    rstCntMMCM <= rstCntMMCM + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- system reset line (high when active)
    rstMMCM <= '0' when (rstCntMMCM = MMCM_RST_VAL and clkMmcmLock = '1') else '1'; 
    
end Behavioral;
