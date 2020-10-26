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

entity hpFlt is
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
end hpFlt;

architecture Behavioral of hpFlt is

-----------------------------------------------------------------------------
---------------------- COMPONENT DECLERATIONS -------------------------------
-----------------------------------------------------------------------------

component biquad
    port  ( RST                 : in    std_logic;                      -- system reset
            CLK                 : in    std_logic;                      -- sys clock
            CLK_CE              : in    std_logic;                      -- clock enable
            DIN                 : in    std_logic_vector (15 downto 0); -- input data
            DOUT                : out   std_logic_vector (15 downto 0); -- output data
            B0                  : in    std_logic_vector (31 downto 0); -- b0 coefficient - sfix32_En30 
            B1                  : in    std_logic_vector (31 downto 0); -- b1 coefficient - sfix32_En30 
            B2                  : in    std_logic_vector (31 downto 0); -- b2 coefficient - sfix32_En30 
            A1                  : in    std_logic_vector (31 downto 0); -- a1 coefficient - sfix32_En30 
            A2                  : in    std_logic_vector (31 downto 0)  -- a2 coefficient - sfix32_En30 
            );
end component;

-----------------------------------------------------------------------------
------------------------ SIGNAL DECLERATIONS --------------------------------
-----------------------------------------------------------------------------

-- coefficents constants
constant coeff_b0_1             : signed(31 downto 0) := to_signed(1072748428, 32); -- sfix32_En30
constant coeff_b1_1             : signed(31 downto 0) := to_signed(-2145496855, 32); -- sfix32_En30
constant coeff_b2_1             : signed(31 downto 0) := to_signed(1072748428, 32); -- sfix32_En30
constant coeff_a1_1             : signed(31 downto 0) := to_signed(-2145495936, 32); -- sfix32_En30
constant coeff_a2_1             : signed(31 downto 0) := to_signed(1071755951, 32);  -- sfix32_En30

-- coefficents signals
signal coeff_b0_std_1           : std_logic_vector (31 downto 0);
signal coeff_b1_std_1           : std_logic_vector (31 downto 0);
signal coeff_b2_std_1           : std_logic_vector (31 downto 0);
signal coeff_a1_std_1           : std_logic_vector (31 downto 0);
signal coeff_a2_std_1           : std_logic_vector (31 downto 0);

begin

    -----------------------------------------------------------------------------------
    ------------------------ COMPONENT INSTANTIATIONS ---------------------------------
    -----------------------------------------------------------------------------------
    
    -------------------------------- DATA 1 FILTERS -----------------------------------
    
    bq1_1 : biquad
        port map  ( RST                 => RST,
                    CLK                 => CLK,
                    CLK_CE              => CLK_CE,
                    DIN                 => DIN_1_1,
                    DOUT                => DOUT_1_1,
                    B0                  => coeff_b0_std_1,
                    B1                  => coeff_b1_std_1,
                    B2                  => coeff_b2_std_1,
                    A1                  => coeff_a1_std_1,
                    A2                  => coeff_a2_std_1 
                    );
                    
    -------------------------------- DATA 2 FILTERS -----------------------------------
    
    bq1_2 : biquad
        port map  ( RST                 => RST,
                    CLK                 => CLK,
                    CLK_CE              => CLK_CE,
                    DIN                 => DIN_2_1,
                    DOUT                => DOUT_2_1,
                    B0                  => coeff_b0_std_1,
                    B1                  => coeff_b1_std_1,
                    B2                  => coeff_b2_std_1,
                    A1                  => coeff_a1_std_1,
                    A2                  => coeff_a2_std_1 
                    );
                    
    -------------------------------- DATA 3 FILTERS -----------------------------------
    
    bq1_3 : biquad
        port map  ( RST                 => RST,
                    CLK                 => CLK,
                    CLK_CE              => CLK_CE,
                    DIN                 => DIN_1_2,
                    DOUT                => DOUT_1_2,
                    B0                  => coeff_b0_std_1,
                    B1                  => coeff_b1_std_1,
                    B2                  => coeff_b2_std_1,
                    A1                  => coeff_a1_std_1,
                    A2                  => coeff_a2_std_1 
                    );
    
    -------------------------------- DATA 4 FILTERS -----------------------------------
    
    bq1_4 : biquad
        port map  ( RST                 => RST,
                    CLK                 => CLK,
                    CLK_CE              => CLK_CE,
                    DIN                 => DIN_2_2,
                    DOUT                => DOUT_2_2,
                    B0                  => coeff_b0_std_1,
                    B1                  => coeff_b1_std_1,
                    B2                  => coeff_b2_std_1,
                    A1                  => coeff_a1_std_1,
                    A2                  => coeff_a2_std_1 
                    );
    
    -----------------------------------------------------------------------------------
    -------------------------------- MAIN PROCESSES -----------------------------------
    -----------------------------------------------------------------------------------

    ------------------------------ CONVERT COEFFICCIENTS ------------------------------
    
    coeff_b0_std_1 <= std_logic_vector(coeff_b0_1);
    coeff_b1_std_1 <= std_logic_vector(coeff_b1_1);
    coeff_b2_std_1 <= std_logic_vector(coeff_b2_1);
    coeff_a1_std_1 <= std_logic_vector(coeff_a1_1);
    coeff_a2_std_1 <= std_logic_vector(coeff_a2_1);
    
end Behavioral;
