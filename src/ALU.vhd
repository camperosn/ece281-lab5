----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    component ripple_adder is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               B : in STD_LOGIC_VECTOR (7 downto 0);
               Cin : in STD_LOGIC;
               S : out STD_LOGIC_VECTOR (7 downto 0);
               Cout : out STD_LOGIC);
    end component;
    
    signal w_sum : std_logic_vector(7 downto 0);
    signal w_c_out : std_logic := '0';
    signal w_c_in : std_logic := '0';

begin

	ripple_adder_0 : ripple_adder 
	port map (
	   A => i_A,
	   B => i_B,
	   Cin => w_c_in,
	   S => w_sum,
	   Cout => w_c_out
	);
    
    -- this is missing flags, it is also only able to add right now
    -- but it needs to be able to subtract to..
    o_result <= w_sum when i_op = "000" else
                w_sum when i_op = "001" else
                (i_A OR i_B) when i_op = "010" else
                (i_A AND i_B) when i_op = "011" else
                "00000000";
    


-- 000 ADD
-- 001 SUB
-- 010 AND
-- 011 OR


end Behavioral;
