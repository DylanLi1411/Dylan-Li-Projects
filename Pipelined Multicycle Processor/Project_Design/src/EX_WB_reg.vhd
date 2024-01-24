-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: EX/WB reg
--
-------------------------------------------------------------------------------
--
-- Description : Pipeline register between EX and WB stages
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity EX_WB_reg is
	 port(
		 clk : in STD_LOGIC;
		 instruction : in STD_LOGIC_VECTOR(24 downto 0);
		 rd_in : in STD_LOGIC_VECTOR(127 downto 0);
		 
		 -- Send to RegFile
		 wr_en : out STD_LOGIC;
		 rd_out : out STD_LOGIC_VECTOR(127 downto 0);
		 
		 -- Send the index of rd to forwarding unit and RegFile
		 rd_index : out STD_LOGIC_VECTOR(4 downto 0)
	     );
end EX_WB_reg;


architecture Behavioral of EX_WB_reg is
begin
	
	-- Send signals
	Write_Back: process(clk)
    begin
		
        if falling_edge(clk) then
			
			-- Check nop instruction
			if (instruction(24 downto 23) = "11" and instruction(18 downto 15) = "0000") then
				wr_en <= '0';
			else
				wr_en <= '1';
			end if;
			
			rd_out <= rd_in;
			rd_index <= instruction(4 downto 0);
			
        end if;
    end process;

end Behavioral;
