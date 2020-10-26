----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2020 20:53:59
-- Design Name: 
-- Module Name: memsMicRec_tb - Behavioral
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

-- libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;  --include package textio.vhd

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity memsMicRec_tb is
--  Port ( );
end memsMicRec_tb;

architecture Behavioral of memsMicRec_tb is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component memsMicRec_top
    generic   ( SYS_RST_VAL         : integer   := 20;  -- no. of sysClk cycles before reset
                MMCM_RST_VAL        : integer   := 20   -- no. of mmcmClk cycles before reset
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
--                LR_CLK              : in    std_logic
                );    
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- clock signals
constant    clkHalfPeriod       : time                              := 5ns;         -- half the sample period for 100MHz system board clock
constant    clkPdmHP            : time                              := 162.7604ns;  -- half period of pdm clock signal [162.7604@3.072MHz]
signal      simClk              : std_logic                         := '0';
signal      clkPdmHD            : std_logic;  

-- i2s signals
constant    bclkHalfPeriod      : time                              := 162.7604ns;
signal      bclk                : std_logic;   
constant    lrclkHalfPeriod     : time                              := 10417ns;
signal      lrclk               : std_logic;  

-- pdm signals
signal      pdmData             : std_logic;
signal      pdmDataTmp          : std_logic_vector (0 downto 0);
signal      dataStartCue        : std_logic                         := '0';         -- signal that only allows pdm data start once
constant    pdmDataStart        : time                              := 7881.068ns;  -- time before pdm data starts
signal      endoffile           : bit                               := '0';         -- bit for indicating end of file.

-- SPI SIGNALS
signal      sclk                : std_logic;
signal      cs_n                : std_logic;
signal      mosi                : std_logic;
signal      miso                : std_logic;
signal      sclkHalfPeriod      : time                              := 50ns;
signal      mosiStartByte       : std_logic_vector(7 downto 0)      := "10101010";
signal      mosiPoleByte        : std_logic_vector(7 downto 0)      := "00110011";
signal      mosiReadByte        : std_logic_vector(7 downto 0)      := "00000000";
signal      mosiEndByte         : std_logic_vector(7 downto 0)      := "00001111";

signal      spiStartTime        : time                              := 62.7us;  -- time before spi transmission starts
signal      spiClockStart       : time                              := sclkHalfPeriod * 20;  -- time before spi clock starts
signal      spiPoleTime         : time                              := 3ms;
signal      spiReadTime         : time                              := 1ms;
signal      spiFinTime          : time                              := 1ms;
signal      spiDataEnd          : time                              := 500ms;

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    TOP : memsMicRec_top
    port map  ( CLK             => simClk,     
                CLK_PDM_HD      => clkPdmHD,
                PDM_DATA_IN     => pdmData,
                -- SPI SIGNALS
                SCLK            => sclk,
                CS_N            => cs_n,
                MOSI            => mosi,
                MISO            => miso
                -- I2S SIGNALS
--                B_CLK           => bclk,
--                LR_CLK          => lrclk
                );    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    ------------------------------------ CLOCKS ---------------------------------------
    
    -- sys clock Process
    process
        begin
            simClk <= '0';
        wait for clkHalfPeriod;  --for 0.5 ns signal is '0'.
            simClk <= '1';          
        wait for clkHalfPeriod;  --for next 0.5 ns signal is '1'.     
    end process;
    
    ---------------------------------- I2S SIGNALS ------------------------------------
    
    -- bclk - 3.072MHz half duty clock
    process
        begin
            bclk <= '0';
        wait for bclkHalfPeriod;
            bclk <= '1';          
        wait for bclkHalfPeriod;     
    end process;
    
    -- lrclk - 48kHz half duty clock
    process
        begin
            lrclk <= '0';
        wait for lrclkHalfPeriod;
            lrclk <= '1';          
        wait for lrclkHalfPeriod;    
    end process;
    
    ---------------------------------- PDM SIGNAL -------------------------------------
    
    --- read pdm data from text file
    process
        -- mic 1
        file        infile1         : text is in  "Z:\Documents\DOCS\projects\projects_uploaded\PN004_mems_mic_recorder\pdm_simulink_model\simPdm.txt";  -- declare input file
        variable    inline1         : line;                     -- line number declaration
        variable    dataread1       : real;
        -- mic 2
        file        infile2         : text is in   "Z:\Documents\DOCS\projects\projects_uploaded\PN004_mems_mic_recorder\pdm_simulink_model\simPdm.txt";  -- declare input file
        variable    inline2         : line;                     -- line number declaration
        variable    dataread2       : real;
    begin
        if (dataStartCue = '0') then
            dataStartCue <= '1';
            wait for pdmDataStart;
--            pdmDataTmp <= "U";
--            wait for clkPdmHP * 2;
        else
            -- mic 1 data
            if (not endfile(infile1)) then       -- checking the "END OF FILE" is not reached.
                readline(infile1, inline1);       -- reading a line from the file.         
                read(inline1, dataread1);         -- reading the data from the line and putting it in a real type variable.
                pdmDataTmp <= conv_std_logic_vector(integer(dataread1),1);   -- put the value available in variable in a signal.
            else
                endoffile <= '1';                   --set signal to tell end of file read file is reached.
            end if;          
            wait for clkPdmHP;
            
            -- mic 2 data
            if (not endfile(infile2)) then       -- checking the "END OF FILE" is not reached.
                readline(infile2, inline2);       -- reading a line from the file.         
                read(inline2, dataread2);         -- reading the data from the line and putting it in a real type variable.
                pdmDataTmp <= conv_std_logic_vector(integer(dataread2),1);   -- put the value available in variable in a signal.
            else
                endoffile <= '1';                   --set signal to tell end of file read file is reached.
            end if;          
            wait for clkPdmHP;
            
        end if;                 
    end process;
    
    pdmData <=  '1' when (pdmDataTmp = "1") else
                '0' when (pdmDataTmp = "0") else
                'U';
    
    ---------------------------------- SPI SIGNALS -----------------------------------
    
    -- CHIP SELECT
    process
    begin 
        cs_n <= '1';
        
        -- start byte
        wait for spiStartTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- 2nd pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- read data
        wait for spiReadTime;
        cs_n <= '0';
        wait for spiClockStart;
        for nv in 0 to 4095 loop     
            wait for sclkHalfPeriod*16;
        end loop;
        cs_n <= '1';
        
        -- pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- 2nd read data
        wait for spiReadTime;
        cs_n <= '0';
        wait for spiClockStart;
        for nv in 0 to 4095 loop     
            wait for sclkHalfPeriod*16;
        end loop;
        cs_n <= '1';
        
        -- pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- 3rd read data
        wait for spiReadTime;
        cs_n <= '0';
        wait for spiClockStart;
        for nv in 0 to 4095 loop     
            wait for sclkHalfPeriod*16;
        end loop;
        cs_n <= '1';
        
        -- pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- 4th read data
        wait for spiReadTime;
        cs_n <= '0';
        wait for spiClockStart;
        for nv in 0 to 4095 loop     
            wait for sclkHalfPeriod*16;
        end loop;
        cs_n <= '1';
        
        -- pole byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- 5th read data (part fifo)
        wait for spiReadTime;
        cs_n <= '0';
        wait for spiClockStart;
        for nv in 0 to 7 loop     
            wait for sclkHalfPeriod*16;
        end loop;
        cs_n <= '1';
        
        -- end byte
        wait for spiFinTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        -- start byte
        wait for spiPoleTime;
        cs_n <= '0';
        wait for spiClockStart;           
        wait for sclkHalfPeriod*16;
        cs_n <= '1';
        
        wait for spiDataEnd;
        
    end process;
    
    -- SCLK Process
    process
    begin
        sclk <= '0';
        
        -- start byte
        wait for spiStartTime;
        wait for spiClockStart;
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- 2nd pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niv in 0 to 4095 loop 
            for nii in 0 to 7 loop
                sclk <= '1';
                wait for sclkHalfPeriod;
                sclk <= '0';
                wait for sclkHalfPeriod;
            end loop;
        end loop;
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- 2nd read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niv in 0 to 4095 loop 
            for nii in 0 to 7 loop
                sclk <= '1';
                wait for sclkHalfPeriod;
                sclk <= '0';
                wait for sclkHalfPeriod;
            end loop;
        end loop;
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- 3rd read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niv in 0 to 4095 loop 
            for nii in 0 to 7 loop
                sclk <= '1';
                wait for sclkHalfPeriod;
                sclk <= '0';
                wait for sclkHalfPeriod;
            end loop;
        end loop;
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- 4th read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niv in 0 to 4095 loop 
            for nii in 0 to 7 loop
                sclk <= '1';
                wait for sclkHalfPeriod;
                sclk <= '0';
                wait for sclkHalfPeriod;
            end loop;
        end loop;
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- 5th read data (not full fifo)
        wait for spiReadTime;
        wait for spiClockStart;
        for niv in 0 to 7 loop 
            for nii in 0 to 7 loop
                sclk <= '1';
                wait for sclkHalfPeriod;
                sclk <= '0';
                wait for sclkHalfPeriod;
            end loop;
        end loop;
        
        -- end byte
        wait for spiFinTime;
        wait for spiClockStart; 
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        -- start byte
        wait for spiPoleTime;
        wait for spiClockStart;
        for nii in 0 to 7 loop
            sclk <= '1';
            wait for sclkHalfPeriod;
            sclk <= '0';
            wait for sclkHalfPeriod;
        end loop;
        
        wait for spiDataEnd;
            
    end process;
    
    -- MOSI 
    process
    begin
        -- pull low for when no transfer
        mosi <= '0';
        
        -- start byte
        wait for spiStartTime - sclkHalfPeriod;
        wait for spiClockStart; 
        for ni in 0 to 7 loop
            mosi <= mosiStartByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- 2nd pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niii in 0 to 4095 loop  
            for ni in 0 to 7 loop
                mosi <= mosiReadByte(-ni+7);
                wait for sclkHalfPeriod*2;
            end loop;
        end loop;      
        mosi <= '0';
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- 2nd read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niii in 0 to 4095 loop  
            for ni in 0 to 7 loop
                mosi <= mosiReadByte(-ni+7);
                wait for sclkHalfPeriod*2;
            end loop;
        end loop;      
        mosi <= '0';
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- 3rd read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niii in 0 to 4095 loop  
            for ni in 0 to 7 loop
                mosi <= mosiReadByte(-ni+7);
                wait for sclkHalfPeriod*2;
            end loop;
        end loop;      
        mosi <= '0';
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- 4th read data
        wait for spiReadTime;
        wait for spiClockStart;
        for niii in 0 to 4095 loop  
            for ni in 0 to 7 loop
                mosi <= mosiReadByte(-ni+7);
                wait for sclkHalfPeriod*2;
            end loop;
        end loop;      
        mosi <= '0';
        
        -- pole byte
        wait for spiPoleTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiPoleByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- 5th read data (part fifo)
        wait for spiReadTime;
        wait for spiClockStart;
        for niii in 0 to 7 loop  
            for ni in 0 to 7 loop
                mosi <= mosiReadByte(-ni+7);
                wait for sclkHalfPeriod*2;
            end loop;
        end loop;      
        mosi <= '0';
        
        -- end byte
        wait for spiFinTime;
        wait for spiClockStart;  
        for ni in 0 to 7 loop
            mosi <= mosiEndByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        -- start byte
        wait for spiPoleTime;
        wait for spiClockStart; 
        for ni in 0 to 7 loop
            mosi <= mosiStartByte(-ni+7);
            wait for sclkHalfPeriod*2;
        end loop;      
        mosi <= '0';
        
        wait for spiDataEnd; 
        
    end process;
    
end Behavioral;
