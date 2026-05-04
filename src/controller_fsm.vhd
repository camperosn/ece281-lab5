----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    type cycle is (cycle1, cycle2, cycle3, cycle4);
    signal current_cycle, next_cycle : cycle;

begin

    next_cycle <= cycle2 when current_cycle = cycle1 else
                  cycle3 when current_cycle = cycle2 else
                  cycle4 when current_cycle = cycle3 else
                  cycle1;
                  
    with current_cycle select
    o_cycle <=  "0001" when cycle1,
                "0010" when cycle2,
                "0100" when cycle3,
                "1000" when cycle4;
                
    state_register : process(i_adv, i_reset)
    begin
        if (i_reset = '1') then
            current_cycle <= cycle1;
        elsif rising_edge(i_adv) then
         current_cycle <= next_cycle;
       end if;
    end process state_register;

end FSM;
