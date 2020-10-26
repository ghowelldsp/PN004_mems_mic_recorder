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

entity dataTrans is
    generic   ( BIT_DEPTH           : integer   := 8;       -- no. of bits data
                FIFO_BIT_DEPTH      : integer   := 12       -- fifo bit depth, defined by the fifo state
                );
    port      ( RST                 : in    std_logic;  -- active high synchronous reset 
                CLK                 : in    std_logic;  -- system clock
                CLK_MMCM            : in    std_logic;  -- mmcm clock
                RST_MMCM            : in    std_logic;  -- active high synchronous mmcm reset
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
end dataTrans;

architecture Behavioral of dataTrans is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- fifo block generic signals
signal fifoReset            : std_logic;
signal fifoWrClk            : std_logic;
signal fifoRdClk            : std_logic;

-- fifo 1 block signal
signal fifoAEmpty_1         : std_logic;
signal fifoAFull_1          : std_logic;
signal fifoDout_1           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal fifoEmpty_1          : std_logic;
signal fifoFull_1           : std_logic;
signal fifoRdCnt_1          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal fifoRdErr_1          : std_logic;
signal fifoWrCnt_1          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal fifoWrErr_1          : std_logic;
signal fifoDin_1            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal fifoRdEn_1           : std_logic;
signal fifoWrEn_1           : std_logic;

-- fifo 2 block signal
signal fifoAEmpty_2         : std_logic;
signal fifoAFull_2          : std_logic;
signal fifoDout_2           : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal fifoEmpty_2          : std_logic;
signal fifoFull_2           : std_logic;
signal fifoRdCnt_2          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal fifoRdErr_2          : std_logic;
signal fifoWrCnt_2          : std_logic_vector ((FIFO_BIT_DEPTH - 1) downto 0);
signal fifoWrErr_2          : std_logic;
signal fifoDin_2            : std_logic_vector ((BIT_DEPTH - 1) downto 0);
signal fifoRdEn_2           : std_logic;
signal fifoWrEn_2           : std_logic;

-- transmission code values
signal  START_VAL           : signed (7 downto 0) := "10101010";
signal  POLE_VAL            : signed (7 downto 0) := "00110011";
signal  END_VAL             : signed (7 downto 0) := "00001111";

-- transmission state
type    transState_type     is (transState_idle, transState_checkFifo, transState_checkStatus, transState_readFifo);
signal  transState          : transState_type;
signal  fifoSel             : std_logic;
signal  recData             : std_logic;
signal  readFifo            : std_logic;
signal  transEndFlg         : std_logic;
signal  spiDinSelect        : std_logic_vector (1 downto 0);

-- transmission reset
type    fifoRstState_type   is (fifoRstState_idle, fifoRstState_rst);
signal  fifoRstState        : fifoRstState_type;
signal  fifoRstBuff         : std_logic;
signal  fifoRstCnt          : integer range 0 to 20;

-- write to fifo
signal  pcmClkCnt           : integer range 0 to 1279;
signal  fifoDinBuff         : std_logic_vector (7 downto 0);
signal  fifoWrEnBuff        : std_logic; 

-- fifo selector process
type    fifoSelectState_type is (fifoSelectState_fifo1, fifoSelectState_fifo2);
signal  fifoSelectState     : fifoSelectState_type;
signal  fifoSelect          : std_logic;

-- fifo read signals
signal  spiDinBuff          : std_logic_vector (7 downto 0);
signal  fifoDataBuff        : std_logic_vector(7 downto 0);
signal  fifoRdEnBuff        : std_logic;
signal  fifoRdEnTmp         : std_logic;
signal  rdEnCnt             : integer range 0 to 4098;

-- fifo read DEBUG
signal  fifoDataTmpCnt      : integer range 0 to 15;
signal  fifoDataTmp         : std_logic_vector(7 downto 0);
signal  fifoDataTmp1         : std_logic_vector(7 downto 0);

-- spi din shifter
signal  csStartOffsetFlg    : std_logic;
signal  csStartOffset1Flg   : std_logic;
signal  lstRiseBitOffsetFlg : std_logic;
signal  spiDinFlg           : std_logic;

begin

    -----------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------
    -----------------------------------------------------------------------------
    
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
                        FIRST_WORD_FALL_THROUGH => FALSE)               -- Sets the FIFO FWFT to TRUE or FALSE
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
                        FIRST_WORD_FALL_THROUGH => FALSE)               -- Sets the FIFO FWFT to TRUE or FALSE
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
    
    process(RST, CLK)
    begin
        if (RST = '1') then
            fifoSel <= '1';
            recData <= '0';
            readFifo <= '0';
            transEndFlg <= '0';
            spiDinSelect <= "00";
            transState <= transState_idle;
        elsif (rising_edge(CLK)) then
            case transState is
            
            -- stays in idle until end of a spi transmisson, then checks to
            -- see if data recieved indicates to start transmission
            when transState_idle =>
                recData <= '0';
                transEndFlg <= '0';
                readFifo <= '0';
                fifoSel <= '1';
                spiDinSelect <= "00";
                if (CS_END_FLG = '1') then
                    if (SPI_DOUT = std_logic_vector(START_VAL)) then
                        recData <= '1';
                        transState <= transState_checkFifo;
                    end if;
                end if;
            
            -- checks the fifos to see if either is full at the start of each 
            -- spi pole
            when transState_checkFifo =>
                readFifo <= '0';
                if (CS_START_FLG = '1') then
                    transState <= transState_checkStatus;
                    if (fifoFull_1 = '1' or fifoFull_2 = '1') then
                        fifoSel <= not fifoSel;
                        spiDinSelect <= "01";
                    else
                        spiDinSelect <= "10";
                    end if;
                end if;
            
            -- checks the data received from the spi is an end signal, stopping
            -- the process, or if a fifo is full where it goes to read the data, 
            -- else goes back to check fifo     
            when  transState_checkStatus =>
                if (CS_END_FLG = '1') then
                    if (SPI_DOUT = std_logic_vector(END_VAL)) then
                        transEndFlg <= '1';
                        transState <= transState_idle;
                    elsif (spiDinSelect = "01") then
                        transState <= transState_readFifo;
                    else
                        transState <= transState_checkFifo;
                    end if;
                end if;
            
            -- read a full fifo's worth of data
            when transState_readFifo =>
                if (CS_START_FLG = '1') then
                    readFifo <= '1';
                    spiDinSelect <= "11";
                elsif (CS_END_FLG = '1') then
                    spiDinSelect <= "00";
                    readFifo <= '0';
                    transState <= transState_checkFifo;
                end if;                 
             
            end case;
        end if;
    end process;
    
    
    ----------------------------- TRANSMISSION RESET ----------------------------
    -- handles the reset process or the data transmission process
    
    -- RESET FIFO
    -- resets the fifo's after a transmission has completed
    process (RST, CLK)
    begin
        if (RST = '1') then
            fifoRstBuff <= '0';
            fifoRstCnt <= 0;
            fifoRstState <= fifoRstState_idle;
        elsif (rising_edge(CLK)) then
            case fifoRstState is
            
            -- stays in idle until transmission end flag
            when fifoRstState_idle =>
                fifoRstBuff <= '0';
                if (transEndFlg = '1') then
                    fifoRstState <= fifoRstState_rst;
                end if;
            
            -- hold the reset line high for set number of clock periods, before
            -- returning back to idle
            when fifoRstState_rst =>
                fifoRstBuff <= '1';
                if (fifoRstCnt = 20) then
                    fifoRstCnt <= 0;
                    fifoRstState <= fifoRstState_idle;
                else
                    fifoRstCnt <= fifoRstCnt + 1;
                end if;
                
            end case;
        end if;
    end process;
    
    -- assigns to the fifo reset line   
    fifoReset <= fifoRstBuff when (RST_MMCM = '0') else '1'; 
    
    
    
    --------------------------------- FIFO WRITE --------------------------------
    -- writes the pdm data to the FIFO in 8-bit words using a counter that resets
    -- every pcm clock flag 
    
    -- counter
    process(RST_MMCM, CLK_MMCM)
    begin
        if (RST_MMCM = '1') then
            pcmClkCnt <= 0;
        elsif (rising_edge(CLK_MMCM)) then
            if (CLK_PCM_CE = '1') then
                pcmClkCnt <= 0;
            else
                pcmClkCnt <= pcmClkCnt + 1;
            end if;
        end if;    
    end process;
    
    -- assigns the pdm data to the fifo data input buffer
--    fifoDinBuff <=  PCM_MIC1_DATA(7 downto 0)   when (pcmClkCnt = 1) else
--                    PCM_MIC1_DATA(15 downto 8)  when (pcmClkCnt = 2) else
--                    PCM_MIC2_DATA(7 downto 0)   when (pcmClkCnt = 3) else
--                    PCM_MIC2_DATA(15 downto 8)  when (pcmClkCnt = 4) else
--                    PCM_MIC3_DATA(7 downto 0)   when (pcmClkCnt = 5) else
--                    PCM_MIC3_DATA(15 downto 8)  when (pcmClkCnt = 6) else
--                    PCM_MIC4_DATA(7 downto 0)   when (pcmClkCnt = 7) else
--                    PCM_MIC4_DATA(15 downto 8)  when (pcmClkCnt = 8) else
--                    PCM_MIC5_DATA(7 downto 0)   when (pcmClkCnt = 9) else
--                    PCM_MIC5_DATA(15 downto 8)  when (pcmClkCnt = 10) else
--                    PCM_MIC6_DATA(7 downto 0)   when (pcmClkCnt = 11) else
--                    PCM_MIC6_DATA(15 downto 8)  when (pcmClkCnt = 12) else
--                    PCM_MIC7_DATA(7 downto 0)   when (pcmClkCnt = 13) else
--                    PCM_MIC7_DATA(15 downto 8)  when (pcmClkCnt = 14) else
--                    PCM_MIC8_DATA(7 downto 0)   when (pcmClkCnt = 15) else
--                    PCM_MIC8_DATA(15 downto 8)  when (pcmClkCnt = 16) else
--                    (others => '0'); 
                    
    -- assigns the data to the respective fifo    
    fifoDin_1 <= fifoDinBuff when (fifoSelect = '0') else (others => '0');
    fifoDin_2 <= fifoDinBuff when (fifoSelect = '1') else (others => '0');
    
    -- raises the write enable line               
    fifoWrEnBuff <= '1' when (pcmClkCnt > 0 and pcmClkCnt < 17 and recData = '1') else '0'; 
    fifoWrEn_1 <= fifoWrEnBuff when (fifoSelect = '0') else '0';
    fifoWrEn_2 <= fifoWrEnBuff when (fifoSelect = '1') else '0';   
    
    -- DEBUG
    -- allows debugging of the data transmission process by impersonating the
    -- data that is being put into the fifo. uncomment below code, the comment
    -- out fifoDinBuff above
                   
    fifoDinBuff <=  "00000001" when (pcmClkCnt = 1) else
                    "00000000" when (pcmClkCnt = 2) else
                    "00000010" when (pcmClkCnt = 3) else
                    "00000000" when (pcmClkCnt = 4) else
                    "00000011" when (pcmClkCnt = 5) else
                    "00000000" when (pcmClkCnt = 6) else
                    "00000100" when (pcmClkCnt = 7) else
                    "00000000" when (pcmClkCnt = 8) else
                    "00000101" when (pcmClkCnt = 9) else
                    "00000000" when (pcmClkCnt = 10) else
                    "00000110" when (pcmClkCnt = 11) else
                    "00000000" when (pcmClkCnt = 12) else
                    "00000111" when (pcmClkCnt = 13) else
                    "00000000" when (pcmClkCnt = 14) else
                    "00001000" when (pcmClkCnt = 15) else
                    "00000000" when (pcmClkCnt = 16) else
                    (others => '0');      
    
 
    
    ---------------------------- FIFO SELECTOR PROCESS --------------------------
    -- this selects which fifo to write data to, when fifoSelect is '0', data is written
    -- to fifo 1, when '1' the data is then written to fifo 2
    
    process(RST_MMCM, CLK_MMCM)
    begin
        if (RST_MMCM = '1') then
            fifoSelect <= '0';
            fifoSelectState <= fifoSelectState_fifo1;
        elsif (rising_edge(CLK_MMCM)) then
            case fifoSelectState is
            
            -- wait 
            when fifoSelectState_fifo1 =>
                fifoSelect <= '0';
                if (fifoFull_1 = '1') then                                                                   
                    fifoSelectState <= fifoSelectState_fifo2;
                end if;                   
            
            when fifoSelectState_fifo2 =>
                fifoSelect <= '1';
                if (fifoFull_2 = '1' or fifoReset = '1') then                                                              
                    fifoSelectState <= fifoSelectState_fifo1;
                end if;
            
            end case;
        end if;
    end process;       
    
    
    --------------------------------- FIFO READ ---------------------------------
    -- sets the read enable line to read from the fifo and send to the SPI slave
    
    -- selects which fifo to read from depending which is full
    fifoDataBuff <= fifoDout_1 when (fifoSel = '0') else fifoDout_2;
    
    -- spi data in multiplexor
    spiDinBuff <=   "01000000" when (spiDinSelect = "01") else -- fifo full
                    "10000000" when (spiDinSelect = "10") else -- fifo not full
                    fifoDataBuff when (spiDinSelect = "11") else
                    (others => '0');
                    
    -- read enable buffer
    fifoRdEnBuff <= '1' when (LST_RISE_BIT = '1' or csStartOffsetFlg = '1') else '0'; 
    fifoRdEnTmp <= fifoRdEnBuff when (rdEnCnt < 4096 and readFifo = '1') else '0';
    
    -- read enable counter
    process(RST, CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                rdEnCnt <= 0;
            elsif (fifoRdEn_1 = '1' or fifoRdEn_2 = '1') then
                rdEnCnt <= rdEnCnt + 1;
            elsif (readFifo = '0') then
                rdEnCnt <= 0; 
            end if;
        end if;
    end process;
    
    -- switches for read enable
    fifoRdEn_1 <= fifoRdEnTmp when (fifoSel = '0') else '0';
    fifoRdEn_2 <= fifoRdEnTmp when (fifoSel = '1') else '0';
    
    -- DEBUG
    -- allows debugging of the data transmission by impersonating the data
    -- read from the fifo. Uncomment all code, then comment out fifoDataBuff 
    -- from above
    
--    fifoDataBuff <= fifoDataTmp when (fifoSel = '0') else fifoDataTmp;
    
--    process (fifoReset, CLK)
--    begin
--        if (fifoReset = '1') then
--            fifoDataTmpCnt <= 0;
--        elsif (rising_edge(CLK)) then
--            if (fifoRdEn_1 = '1' or fifoRdEn_2 = '1') then
--                if (fifoDataTmpCnt = 15) then
--                    fifoDataTmpCnt <= 0;
--                else
--                    fifoDataTmpCnt <= fifoDataTmpCnt + 1;
--                end if;
--            end if;
--        end if;
--    end process;
    
--    fifoDataTmp <=  "00000001" when (fifoDataTmpCnt = 1) else
--                    "00000000" when (fifoDataTmpCnt = 2) else
--                    "00000010" when (fifoDataTmpCnt = 3) else
--                    "00000000" when (fifoDataTmpCnt = 4) else
--                    "00000011" when (fifoDataTmpCnt = 5) else
--                    "00000000" when (fifoDataTmpCnt = 6) else
--                    "00000100" when (fifoDataTmpCnt = 7) else
--                    "00000000" when (fifoDataTmpCnt = 8) else
--                    "00000101" when (fifoDataTmpCnt = 9) else
--                    "00000000" when (fifoDataTmpCnt = 10) else
--                    "00000110" when (fifoDataTmpCnt = 11) else
--                    "00000000" when (fifoDataTmpCnt = 12) else
--                    "00000111" when (fifoDataTmpCnt = 13) else
--                    "00000000" when (fifoDataTmpCnt = 14) else
--                    "00001010" when (fifoDataTmpCnt = 15) else
--                    "00000000" when (fifoDataTmpCnt = 0) else
--                    "00000000";
                    
--    fifoDataTmp1 <= "00100000" when (fifoDataTmpCnt = 1) else
--                    "00100010" when (fifoDataTmpCnt = 2) else
--                    "00000010" when (fifoDataTmpCnt = 3) else
--                    "00000000" when (fifoDataTmpCnt = 4) else
--                    "00000011" when (fifoDataTmpCnt = 5) else
--                    "00000000" when (fifoDataTmpCnt = 6) else
--                    "00000100" when (fifoDataTmpCnt = 7) else
--                    "00000000" when (fifoDataTmpCnt = 8) else
--                    "00000101" when (fifoDataTmpCnt = 9) else
--                    "00000000" when (fifoDataTmpCnt = 10) else
--                    "00000110" when (fifoDataTmpCnt = 11) else
--                    "00000000" when (fifoDataTmpCnt = 12) else
--                    "00000111" when (fifoDataTmpCnt = 13) else
--                    "00000000" when (fifoDataTmpCnt = 14) else
--                    "00001010" when (fifoDataTmpCnt = 15) else
--                    "00000000" when (fifoDataTmpCnt = 0) else
--                    "00000000";
    
    
    ------------------------------ SPI DIN SHIFTER ------------------------------
    -- controls the data that goes to the SPI data in line
    
    -- offsets the spi start flag which is used to shift the spi data ready for
    -- the first byte of the transmission message
    process (RST, CLK)
    begin
        if (RST = '1') then
            csStartOffsetFlg <= '0';
            lstRiseBitOffsetFlg <= '0';
        elsif (rising_edge(CLK)) then
            csStartOffsetFlg <= CS_START_FLG;
            csStartOffset1Flg <= csStartOffsetFlg;
            lstRiseBitOffsetFlg <= LST_RISE_BIT;
        end if;
    end process;
    
    -- spi data input flag
    spiDinFlg <= '1' when (csStartOffset1Flg = '1' or lstRiseBitOffsetFlg = '1') else '0';
    
    -- updates the data to the spi line each time the spi data input flag is high
    process (RST, CLK)
    begin
        if (RST = '1') then
            SPI_DIN <= (others => '0');   
        elsif (rising_edge(CLK)) then
            if (spiDinFlg = '1') then
                SPI_DIN <= spiDinBuff;
            end if;
        end if;
    end process;

end Behavioral;
