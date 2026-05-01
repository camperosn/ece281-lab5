--| FILENAME      : full_adder.vhd
--| AUTHOR(S)     : Nicholas Camperos
--| CREATED       : 2/7/26
--| DESCRIPTION   :  Full adder
--|
--| DOCUMENTATION : None


----------------------------------------------------------------------------------
-- Full Adder
-- See Digital Design and Computer Architecture, RISC-V Figure 5.3 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           Cin : in  STD_LOGIC;
           S : out  STD_LOGIC;
           Cout : out  STD_LOGIC);
end full_adder;

architecture Behavioral of full_adder is
begin

        S <= A XOR B XOR Cin;
        Cout <= (A AND B) OR (B AND Cin) OR (A AND Cin);
        
end Behavioral;