-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Pipelined Multimedia Unit Testbench
--
-------------------------------------------------------------------------------
--
-- Description : Testbench for the entire multimedia unit.
--				 Loads the instruction buffer upon start of simulation.
--				 Writes to the result file during simulation.
--				 Checks for expected file after simulation.
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use std.textio.all;

entity Final_tb is
end Final_tb;


architecture Behavioral of Final_tb is

	signal clk : std_logic := '0';	-- clock
	constant period : time := 10ns;

	type vector_64_array is array (0 to 63) of std_logic_vector(24 downto 0);
	
	-- external name for the instruct_array
	alias instruct_array is <<signal .Final_tb.UUT.In_Buffer.instruct_array : vector_64_array>>;
	
	-- Compare the reg array to expected values after simulation
	type vector_reg_array is array (0 to 31) of std_logic_vector(127 downto 0);
	alias reg_array is <<signal .Final_tb.UUT.RegFile.reg_array : vector_reg_array>>;
	
	------------------------ external names for results file ---------------------------------
	-- IF
	alias pc is <<signal .Final_tb.UUT.In_Buffer.pc : natural range 0 to 63>>;
	alias instruct_IF is <<signal .Final_tb.UUT.In_Buffer.instruct : std_logic_vector(24 downto 0)>>;
	
	-- ID
	alias instruct_ID is <<signal .Final_tb.UUT.RegFile.instruct_in : std_logic_vector(24 downto 0)>>;
	alias rs1 is <<signal .Final_tb.UUT.RegFile.rs1 : std_logic_vector(127 downto 0)>>;
	alias rs2 is <<signal .Final_tb.UUT.RegFile.rs2 : std_logic_vector(127 downto 0)>>;
	alias rs3 is <<signal .Final_tb.UUT.RegFile.rs3 : std_logic_vector(127 downto 0)>>;
	
	-- EX and forwarding
	alias instruct_EX is <<signal .Final_tb.UUT.ALU.Instruct : std_logic_vector(24 downto 0)>>;
	alias reg_ALU_1 is <<signal .Final_tb.UUT.ALU.InReg1 : std_logic_vector(127 downto 0)>>;
	alias reg_ALU_2 is <<signal .Final_tb.UUT.ALU.InReg2 : std_logic_vector(127 downto 0)>>;
	alias reg_ALU_3 is <<signal .Final_tb.UUT.ALU.InReg3 : std_logic_vector(127 downto 0)>>;
	alias reg_ALU_out is <<signal .Final_tb.UUT.ALU.OutReg : std_logic_vector(127 downto 0)>>;
	
	alias Mux_rd is <<signal .Final_tb.UUT.Muxes.rd : std_logic_vector(127 downto 0)>>;
	alias Mux1 is <<signal .Final_tb.UUT.Muxes.mux_1 : std_logic>>;
	alias Mux2 is <<signal .Final_tb.UUT.Muxes.mux_2 : std_logic>>;
	alias Mux3 is <<signal .Final_tb.UUT.Muxes.mux_3 : std_logic>>;
	
	-- WB
	alias wr_en is <<signal .Final_tb.UUT.EX_WB.wr_en : std_logic>>;
	alias rd_WB is <<signal .Final_tb.UUT.EX_WB.rd_out : std_logic_vector(127 downto 0)>>;
	alias rd_index is <<signal .Final_tb.UUT.EX_WB.rd_index : std_logic_vector(4 downto 0)>>;
	
	
	-- Resize a string for correct printing
	function padded(s: string) return string is
		variable return_value : string(1 to 200) := (others => ' ');
		variable index: positive := 1;
	begin
		while index < (s'length + 1) loop
		  return_value(index) := s(index);
		  index := index + 1;
		end loop;
		
	  return return_value;
	end function;
	
begin
	
    -- Unit Under Test
    UUT : entity Pipelined_Multimedia_Unit port map (
		clk => clk );
	
	-- Load instructions to buffer	
    read_file: process
		variable line_v : line;
    	file read_file : text;
    	variable instruction_v : std_logic_vector(24 downto 0);
		variable index : natural;
	begin
		file_open(read_file, "Binary_Instructions.txt", read_mode);
		index := 0;
		
		while not endfile(read_file) loop
	      readline(read_file, line_v);
	      read(line_v, instruction_v);
		  instruct_array(index) <= instruction_v;
		  
		  index := index + 1;
	    end loop;
		
	    file_close(read_file);
		
		wait;
	end process;
	
	
	-- Clock process
    clock: process
		variable line_v : line;
    	file read_file : text;
		file write_file : text;
    	variable reg_v : std_logic_vector(127 downto 0);
		variable string_v : string(1 to 200);
	begin
		file_open(read_file, "Expected_Results.txt", read_mode);
		file_open(write_file, "Log.txt", write_mode);
		
		for i in 0 to 140 loop
			if (i mod 2 = 0 and i > 0) then	-- Write to results file (log.txt) every clock cycle ****NOTE: log.txt is not in the src folder but in the Project_Design folder (one level up)
				string_v := padded("----------------------------- Clock cycle " & to_string(i/2) & " ------------------------------------");
				write(line_v, string_v);
				writeline(write_file, line_v);
				
				-- IF stage
				string_v := padded("IF: Instruction " & to_string(pc) & " is being fetched. instruction = " & to_hstring(instruct_IF));
				write(line_v, string_v);
				writeline(write_file, line_v);
				
				-- ID stage
				string_v := padded("ID: instruction = " & to_hstring(instruct_ID) & ", rs1 = " & to_hstring(rs1) & ", rs2 = " & to_hstring(rs2) & ", rs3 = " & to_hstring(rs3));
				write(line_v, string_v);
				writeline(write_file, line_v);
				
				-- EX stage
				string_v := padded("EX: instruct = " & to_hstring(instruct_EX) & ", rs1 = " & to_hstring(reg_ALU_1) & ", rs2 = " & to_hstring(reg_ALU_2) & ", rs3 = " & to_hstring(reg_ALU_3) & ", rd = " & to_hstring(reg_ALU_out));
				write(line_v, string_v);
				writeline(write_file, line_v);
				string_v := padded("Forwarding: Muxes = " & to_string(Mux1) & to_string(Mux2) & to_string(Mux3) & ", forwarded data = " & to_hstring(Mux_rd));
				write(line_v, string_v);
				writeline(write_file, line_v);
				if ((Mux1 = '1' or Mux2 = '1' or Mux3 = '1') and i > 6) then
					string_v := padded("Forwarding detected.");
					write(line_v, string_v);
					writeline(write_file, line_v);
				end if;
				
				
				-- WB stage
				if (wr_en = '1' and i > 6) then
					string_v := padded("WB: Writing " & to_hstring(rd_WB) & " at $" & to_string(to_integer(unsigned(rd_index))));
					write(line_v, string_v);
					writeline(write_file, line_v);
				else
					string_v := padded("WB: No write.");
					write(line_v, string_v);
					writeline(write_file, line_v);
				end if;
			end if;
			
			wait for period/2;
			clk <= not clk;
		end loop;
		file_close(write_file);
		
		
		-- Compare to Expected_Results file	in the end
		for i in 0 to 31 loop
	      readline(read_file, line_v);
	      read(line_v, reg_v);
		  
		  assert reg_array(i) = reg_v
		  report "Unexpected result at register $" & to_string(i) & ". Expected " & to_hstring(reg_v) & ". Got " & to_hstring(reg_array(i))
		  severity error;
		  
	    end loop;
		file_close(read_file);
		
		report "Simulation was successful.";
		
		std.env.finish;
	end process;

end Behavioral;

