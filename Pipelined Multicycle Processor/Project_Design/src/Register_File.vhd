-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Register File
--
-------------------------------------------------------------------------------
--
-- Description : Contains 32 128-bit registers
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Register_File is
	port(
		 clk : in std_logic;
	
		 -- From IF
		 instruct_in : in std_logic_vector(24 downto 0);
		 
		 -- From WB
		 rd_index : in std_logic_vector(4 downto 0);
		 wr_en : in std_logic;
		 data : in std_logic_vector(127 downto 0);
		 
		 -- To EX
		 rs1 : out std_logic_vector(127 downto 0);
		 rs2 : out std_logic_vector(127 downto 0);
		 rs3 : out std_logic_vector(127 downto 0);
		 instruct_out : out std_logic_vector(24 downto 0)
	     );
end Register_File;


architecture Behavioral of Register_File is
	type vector_32_array is array (0 to 31) of std_logic_vector(127 downto 0);
	signal reg_array : vector_32_array := (others => (others => '0')); -- all 32 regs initialize to 0
begin
	
	-- Write to register rd when wr_en = '1' (1st half of cycle)
	Write: process (clk)
	begin
		if (rising_edge(clk) and wr_en = '1') then
			reg_array(to_integer(unsigned(rd_index))) <= data;
		end if;
	end process;
	
	-- Send registers to ALU (2nd half of cycle)
	Read: process (clk)
	begin
		if (falling_edge(clk) and instruct_in(24) = '0') then	-- LI
			rs1 <= reg_array(to_integer(unsigned(instruct_in(4 downto 0))));
		else												-- R3 and R4
			rs1 <= reg_array(to_integer(unsigned(instruct_in(9 downto 5))));
			rs2 <= reg_array(to_integer(unsigned(instruct_in(14 downto 10))));
			rs3 <= reg_array(to_integer(unsigned(instruct_in(19 downto 15))));
		end if;
	end process;

	-- Pass the instruction to ALU
	instruct_out <= instruct_in;

end Behavioral;
