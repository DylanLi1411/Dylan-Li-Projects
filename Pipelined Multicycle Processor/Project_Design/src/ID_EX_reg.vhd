-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: ID/EX reg
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register between ID and EX stages
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX_reg is
	 port(
		 clk : in STD_LOGIC;
		 rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs3_in : in STD_LOGIC_VECTOR(127 downto 0);
		 instruction_in : in STD_LOGIC_VECTOR(24 downto 0);
		 
		 instruction_out : out STD_LOGIC_VECTOR(24 downto 0);
		 rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs3_out : out STD_LOGIC_VECTOR(127 downto 0)
	     );
end ID_EX_reg;


architecture Behavioral of ID_EX_reg is
begin
	
	-- Send signals on rising edge (1st half of cycle)
	Send: process(clk)
    begin
        if rising_edge(clk) then
			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			rs3_out <= rs3_in;
			
            instruction_out <= instruction_in;
        end if;
    end process;

end Behavioral;
