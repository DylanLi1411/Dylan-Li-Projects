-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Forwarding Muxes
--
-------------------------------------------------------------------------------
--
-- Description : Muxes controlled by the forwarding unit for forwarding
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity Forwarding_Muxes is
	port(
		 -- From Register File
		 rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs3_in : in STD_LOGIC_VECTOR(127 downto 0);
		 
		 -- From Forwarding Unit
		 mux_1 : in	STD_LOGIC;
		 mux_2 : in	STD_LOGIC;
		 mux_3 : in	STD_LOGIC;
		 rd : in STD_LOGIC_VECTOR(127 downto 0);
		 
		 -- To ALU
		 rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs3_out : out STD_LOGIC_VECTOR(127 downto 0)
	     );
end Forwarding_Muxes;


architecture Behavioral of Forwarding_Muxes is
begin
	
	-- 3 muxes, one for each source register ('1' is rd, '0' is rs)
	Muxes: process(all)
    begin
        if mux_1 = '1' then
			rs1_out <= rd;
		else
			rs1_out <= rs1_in;
        end if;
		
		if mux_2 = '1' then
			rs2_out <= rd;
		else
			rs2_out <= rs2_in;
        end if;
		
		if mux_3 = '1' then
			rs3_out <= rd;
		else
			rs3_out <= rs3_in;
        end if;
    end process;

end Behavioral;
