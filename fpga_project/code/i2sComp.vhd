----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2020 12:46:40
-- Design Name: 
-- Module Name: i2sComp - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-----------------------------------------------------------------------------
-------------------------- IO DECLERATIONS ----------------------------------
-----------------------------------------------------------------------------

entity i2sComp is
    port      ( CLK                 : in  std_logic; -- system clock
                RST                 : in  std_logic; -- high active synchronous reset
                -- I2S SIGNALS
                B_CLK               : in  std_logic; -- bit clock
                LR_CLK              : in  std_logic; -- left right clock
                -- DATA SIGNALS
                DIN1_1              : in  std_logic_vector(15 downto 0); -- input data 1 pair 1
                DIN2_1              : in  std_logic_vector(15 downto 0); -- input data 2 pair 1
                DIN1_2              : in  std_logic_vector(15 downto 0); -- input data 1 pair 2
                DIN2_2              : in  std_logic_vector(15 downto 0); -- input data 2 pair 2
                DIN1_3              : in  std_logic_vector(15 downto 0); -- input data 1 pair 3
                DIN2_3              : in  std_logic_vector(15 downto 0); -- input data 2 pair 3
                DIN1_4              : in  std_logic_vector(15 downto 0); -- input data 1 pair 4
                DIN2_4              : in  std_logic_vector(15 downto 0); -- input data 2 pair 4
                DOUT1               : out std_logic; -- output data 1
                DOUT2               : out std_logic; -- output data 2
                DOUT3               : out std_logic; -- output data 3
                DOUT4               : out std_logic  -- output data 4
                );
end i2sComp;

architecture Behavioral of i2sComp is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

-- i2s slave
component i2sSlave
    port      ( CLK                 : in  std_logic; -- system clock
                RST                 : in  std_logic; -- high active synchronous reset
                -- I2S SIGNALS
                B_CLK               : in  std_logic; -- bit clock
                LR_CLK              : in  std_logic; -- left right clock
                -- DATA SIGNALS
                DIN1                : in  std_logic_vector(15 downto 0); -- input data 1
                DIN2                : in  std_logic_vector(15 downto 0); -- input data 2
                DOUT                : out std_logic
                );
end component;


-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------


begin

-----------------------------------------------------------------------------------
------------------------ COMPONENT INSTANTIATIONS ---------------------------------
-----------------------------------------------------------------------------------

    i2sSlave_1_comp : i2sSlave
        port map  ( CLK                 => CLK,
                    RST                 => RST,
                    -- I2S SIGNALS
                    B_CLK               => B_CLK,
                    LR_CLK              => LR_CLK,
                    DIN1                => DIN1_1,
                    DIN2                => DIN2_1,
                    DOUT                => DOUT1
                    );
                    
    i2sSlave_2_comp : i2sSlave
        port map  ( CLK                 => CLK,
                    RST                 => RST,
                    -- I2S SIGNALS
                    B_CLK               => B_CLK,
                    LR_CLK              => LR_CLK,
                    DIN1                => DIN1_2,
                    DIN2                => DIN2_2,
                    DOUT                => DOUT2
                    );
    
    i2sSlave_3_comp : i2sSlave
        port map  ( CLK                 => CLK,
                    RST                 => RST,
                    -- I2S SIGNALS
                    B_CLK               => B_CLK,
                    LR_CLK              => LR_CLK,
                    DIN1                => DIN1_3,
                    DIN2                => DIN2_3,
                    DOUT                => DOUT3
                    );
    
    i2sSlave_4_comp : i2sSlave
        port map  ( CLK                 => CLK,
                    RST                 => RST,
                    -- I2S SIGNALS
                    B_CLK               => B_CLK,
                    LR_CLK              => LR_CLK,
                    DIN1                => DIN1_4,
                    DIN2                => DIN2_4,
                    DOUT                => DOUT4
                    );

-----------------------------------------------------------------------------------
-------------------------------- MAIN PROCESSES -----------------------------------
-----------------------------------------------------------------------------------


    -------------------------------- BCLK LATCH -----------------------------------

    
end Behavioral;
