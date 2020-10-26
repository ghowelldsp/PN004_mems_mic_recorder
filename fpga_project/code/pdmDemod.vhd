----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2020 19:09:26
-- Design Name: 
-- Module Name: pdmDemod - Behavioral
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

entity pdmDemod is
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
end pdmDemod;

architecture Behavioral of pdmDemod is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component cicFilter
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_PDM_CE          : in    std_logic;                      -- pdm clock
            PDM_DIN             : in    std_logic_vector(1 downto 0);   -- 2-bit pdm data in
            PCM_DOUT            : out   std_logic_vector (15 downto 0); -- pcm data out
            PDM_BIT_FLG         : in    std_logic                       -- signal that indicates the CIC filter to write data, then delay
            );
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    cicFilter1_comp : cicFilter
        port map  ( RST             => RST,     
                    CLK             => CLK,      
                    CLK_PDM_CE      => CLK_PDM_CE,
                    PDM_DIN         => PDM_MIC1_DIN,   
                    PCM_DOUT        => PCM_MIC1_DOUT, 
                    PDM_BIT_FLG     => PDM_BIT1_FLG
                    );
                    
    cicFilter2_comp : cicFilter
        port map  ( RST             => RST,     
                    CLK             => CLK,      
                    CLK_PDM_CE      => CLK_PDM_CE,
                    PDM_DIN         => PDM_MIC2_DIN,   
                    PCM_DOUT        => PCM_MIC2_DOUT, 
                    PDM_BIT_FLG     => PDM_BIT2_FLG
                    );
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    -------------------------------- SYSTEM RESET -------------------------------------
    

end Behavioral;
