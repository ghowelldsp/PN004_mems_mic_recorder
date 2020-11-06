----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.08.2020 19:09:26
-- Design Name: 
-- Module Name: cicFirDemod - Behavioral
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

entity cicFirDemod is
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
end cicFirDemod;

architecture Behavioral of cicFirDemod is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component cicFlt_4thOrd_8DecFact
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_CE              : in    std_logic;                      -- clock enable
            DIN                 : in    std_logic_vector(1 downto 0);   -- input data
            DOUT                : out   std_logic_vector (13 downto 0)  -- output data
            );
end component;

component firFlt_halfBandDec
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_CE              : in    std_logic;                      -- clock enable
            DIN                 : in    std_logic_vector (15 downto 0); -- input data
            DOUT                : out   std_logic_vector (15 downto 0)  -- output data
            );
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- cic signals
signal cic11Dout                : std_logic_vector (13 downto 0);
signal cic21Dout                : std_logic_vector (13 downto 0);

-- normalisation signals
signal cicDoutSigned1           : signed(13 downto 0);  -- sfix14
signal normCast1                : signed(27 downto 0);  -- sfix28_En24
signal normOutTmp1              : signed(15 downto 0);  -- sfix16_En14
signal normOut1                 : std_logic_vector(15 downto 0);  -- ufix16
signal cicDoutSigned2           : signed(13 downto 0);  -- sfix14
signal normCast2                : signed(27 downto 0);  -- sfix28_En24
signal normOutTmp2              : signed(15 downto 0);  -- sfix16_En14
signal normOut2                 : std_logic_vector(15 downto 0);  -- ufix16

-- fir signals
signal fir11Dout                : std_logic_vector(15 downto 0);
signal fir12Dout                : std_logic_vector(15 downto 0);
signal fir21Dout                : std_logic_vector(15 downto 0);
signal fir22Dout                : std_logic_vector(15 downto 0);

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -------------------------------- MIC 1 FILTERS ------------------------------------
    
    cicFlt_4thOrd_8DecFact_1_comp : cicFlt_4thOrd_8DecFact
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_PDM_CE,
                    DIN             => PDM_MIC1_DIN,
                    DOUT            => cic11Dout
                    );
    
    firFlt_halfBandDec_11_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT8_CE,
                    DIN             => normOut1,
                    DOUT            => fir11Dout
                    );
                    
    firFlt_halfBandDec_12_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT16_CE,
                    DIN             => fir11Dout,
                    DOUT            => fir12Dout
                    );
   
    firFlt_halfBandDec_13_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT32_CE,
                    DIN             => fir12Dout,
                    DOUT            => PCM_MIC1_DOUT
                    );
    
    -------------------------------- MIC 2 FILTERS ------------------------------------
                  
    cicFlt_4thOrd_8DecFact_2_comp : cicFlt_4thOrd_8DecFact
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_PDM_CE,
                    DIN             => PDM_MIC2_DIN,
                    DOUT            => cic21Dout
                    );
                    
    firFlt_halfBandDec_21_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT8_CE,
                    DIN             => normOut2,
                    DOUT            => fir21Dout
                    );
                    
    firFlt_halfBandDec_22_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT16_CE,
                    DIN             => fir21Dout,
                    DOUT            => fir22Dout
                    );
   
    firFlt_halfBandDec_23_comp : firFlt_halfBandDec
        port map  ( RST             => RST,
                    CLK             => CLK,
                    CLK_CE          => CLK_FLT32_CE,
                    DIN             => fir22Dout,
                    DOUT            => PCM_MIC2_DOUT
                    );
                       
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    --------------------------- NORMALISE CIC OUTPUT DATA 1 ----------------------------
    
    cicDoutSigned1 <= signed(cic11Dout);

    normCast1 <= resize(cicDoutSigned1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 28);
    normOutTmp1 <= normCast1(25 downto 10);
    
    normOut1 <= std_logic_vector(normOutTmp1);
    
    --------------------------- NORMALISE CIC OUTPUT DATA 1 ----------------------------
    
    cicDoutSigned2 <= signed(cic21Dout);

    normCast2 <= resize(cicDoutSigned2 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 28);
    normOutTmp2 <= normCast2(25 downto 10);
    
    normOut2 <= std_logic_vector(normOutTmp2);
    
end Behavioral;
