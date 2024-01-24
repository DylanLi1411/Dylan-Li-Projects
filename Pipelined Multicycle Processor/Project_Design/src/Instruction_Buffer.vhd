-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Instruction Buffer
--
-------------------------------------------------------------------------------
--
-- Description : Stores 64 25-bit instructions and contains the program counter
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Instruction_Buffer is
	port(
		 clk : in std_logic;
		 instruct : out std_logic_vector(24 downto 0)
	     );
end Instruction_Buffer;


architecture Behavioral of Instruction_Buffer is
	type vector_64_array is array (0 to 63) of std_logic_vector(24 downto 0);
	signal instruct_array : vector_64_array; -- 64 instructions
	signal pc : natural range 0 to 63 := 0; -- program counter
begin
	
	-- Send new instruction at the start of every new clock cycle
	Read: process (clk)
	begin
		if rising_edge(clk) then
			instruct <= instruct_array(pc);
			
			-- Move to next instruction
			if pc < 63 then
				pc <= pc + 1;
			end if;
		end if;
			
	end process;
	
end Behavioral;