-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Forwarding Unit
--
-------------------------------------------------------------------------------
--
-- Description : Takes the two instructions at EX and WB stage and decides to forward
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity Forwarding_Unit is
	 port(
	 	 instruction_EX : in STD_LOGIC_VECTOR(24 downto 0); -- From ID_EX_reg
	 
	 	 -- From EX_WB_reg
		 rd_index : in STD_LOGIC_VECTOR(4 downto 0);
		 rd_in : in STD_LOGIC_VECTOR(127 downto 0);
		 
		 -- To Forwarding Muxes
		 rd_out : out STD_LOGIC_VECTOR(127 downto 0);
		 mux_ctrl_1 : out STD_LOGIC;
		 mux_ctrl_2 : out STD_LOGIC;
		 mux_ctrl_3 : out STD_LOGIC
	     );
end Forwarding_Unit;


architecture Behavioral of Forwarding_Unit is
begin
	
	Forward: process(all)
    begin
        if (instruction_EX(24 downto 23) = "11" and instruction_EX(18 downto 15) = "0000") then	-- check for NOP
			mux_ctrl_1 <= '0';
			mux_ctrl_2 <= '0';
			mux_ctrl_3 <= '0';
			
		elsif (instruction_EX(24) = '0') then		-- check for LI
			if instruction_EX(4 downto 0) = rd_index then
				mux_ctrl_1 <= '1';
			else
				mux_ctrl_1 <= '0';
			end if;
			
			mux_ctrl_2 <= '0';
			mux_ctrl_3 <= '0';
			
		else									-- R-instructions
			if instruction_EX(9 downto 5) = rd_index then
				mux_ctrl_1 <= '1';
			else
				mux_ctrl_1 <= '0';
			end if;
			
			if instruction_EX(14 downto 10) = rd_index then
				mux_ctrl_2 <= '1';
			else
				mux_ctrl_2 <= '0';
			end if;
			
			if (instruction_EX(24 downto 23) = "10" and instruction_EX(19 downto 15) = rd_index) then --check R4
				mux_ctrl_3 <= '1';
			else
				mux_ctrl_3 <= '0';
			end if;
			
        end if;
		
		rd_out <= rd_in;
		
    end process;

end Behavioral;
