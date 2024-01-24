-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: IF/ID reg
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register between IF and ID stages
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID_reg is
    Port ( clk : in STD_LOGIC;
           instruction_in : in STD_LOGIC_VECTOR(24 downto 0);
           instruction_out : out STD_LOGIC_VECTOR(24 downto 0));
end IF_ID_reg;


architecture Behavioral of IF_ID_reg is
begin
	
	-- Send instruction on rising clock edge (1st half of cycle)
	Send: process(clk)
    begin
        if rising_edge(clk) then
            instruction_out <= instruction_in;
        end if;
    end process;

end Behavioral;
