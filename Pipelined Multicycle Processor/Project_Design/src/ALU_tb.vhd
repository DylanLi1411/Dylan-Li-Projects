-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: ALU Testbench
--
-------------------------------------------------------------------------------
--
-- Description : Testbench for testing the ALU
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;


entity ALU_tb is
end entity ALU_tb;


architecture testbench of ALU_tb is

	-- Registers
	signal rs1, rs2, rs3, rd : std_logic_vector(127 downto 0);
	
	-- Instruction
	signal instruct : std_logic_vector(24 downto 0);

	constant period : time := 10ns;
	
	-- Make printing easier
	function print_hex_g (rd_func : std_logic_vector(127 downto 0)) return string is
	begin
		return "0x" & to_hstring(rd_func(127 downto 112)) & "_" & to_hstring(rd_func(111 downto 96)) & "_"
					& to_hstring(rd_func(95 downto 80)) & "_" & to_hstring(rd_func(79 downto 64)) & "_"
					& to_hstring(rd_func(63 downto 48)) & "_" & to_hstring(rd_func(47 downto 32)) & "_"
					& to_hstring(rd_func(31 downto 16)) & "_" & to_hstring(rd_func(15 downto 0));
	end function print_hex_g;

begin
	
	-- Unit Under Test is ALU
	uut: entity Multimedia_ALU port map (
			InReg1 => rs1,
			InReg2 => rs2,
			InReg3 => rs3,
			instruct => instruct,
			OutReg => rd
		);

	test: process
	variable string_var : string (1 to 41);
	begin
		
		---------------------------------------- Load Immed ---------------------------------------------
		--Test: Load "0001000100010001" into index 1 (31 downto 16) of rs1
		
		rs1 <= x"FFFF_9842_1111_0000_0111_0100_0200_0000";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"0_001_0001000100010001_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFF_9842_1111_0000_0111_0100_1111_0000"
		report "Error for LI. Expected rd = " & "0xFFFF_9842_1111_0000_0111_0100_1111_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SIMALS ----------------------------------------------
		--Test: From each word left-to-right: no saturation, round min, round max, check low only
		
		rs1 <= x"00000001_80000001_7FFFFFFE_00000000";
		rs2 <= x"0000_FFFC_0000_FFFC_0000_0004_1111_0000";
		rs3 <= x"0000_0002_0000_0002_0000_0003_1111_0000";
		instruct <= b"10_000_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFFFFF9_80000000_7FFFFFFF_00000000"
		report "Error for SIMALS. Expected rd = " & "0xFFFFFFF9_80000000_7FFFFFFF_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SIMAHS ----------------------------------------------
		--Test: From each word left-to-right: no saturation, round min, round max, check high only
		
		rs1 <= x"00000001_80000001_7FFFFFFE_00000000";
		rs2 <= x"0001_0000_FFFF_0000_0001_0000_0000_1111";
		rs3 <= x"0002_0000_0002_0000_0002_0000_0000_1111";
		instruct <= b"10_001_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"00000003_80000000_7FFFFFFF_00000000"
		report "Error for SIMAHS. Expected rd = " & "0x00000003_80000000_7FFFFFFF_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SIMSLS ----------------------------------------------
		--Test: From each word left-to-right: no saturation, round min, round max, check low only
		
		rs1 <= x"00000001_80000001_7FFFFFFE_00000000";
		rs2 <= x"0000_0004_0000_0100_0000_FFFC_1111_0000";
		rs3 <= x"0000_0003_0000_0003_0000_0003_1111_0000";
		instruct <= b"10_010_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFFFFF5_80000000_7FFFFFFF_00000000"
		report "Error for SIMSLS. Expected rd = " & "0xFFFFFFF5_80000000_7FFFFFFF_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SIMSHS ----------------------------------------------
		--Test: From each word left-to-right: no saturation, round min, round max, check high only
		
		rs1 <= x"00000001_80000001_7FFFFFFE_00000000";
		rs2 <= x"0001_0000_0001_0000_FFFF_0000_0000_1111";
		rs3 <= x"0002_0000_0002_0000_0002_0000_0000_1111";
		instruct <= b"10_011_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFFFFFF_80000000_7FFFFFFF_00000000"
		report "Error for SIMSHS. Expected rd = " & "0xFFFFFFFF_80000000_7FFFFFFF_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SLMALS ----------------------------------------------
		--Test1: no saturation and check low only
		
		rs1 <= x"0000000000000001_0000000000000000";
		rs2 <= x"00000000_11111111_00011111_00000000";
		rs3 <= x"00000000_00000003_00000011_00000000";
		instruct <= b"10_100_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0000000033333334_0000000000000000"
		report "Error for SLMALS. Expected rd = " & "0x0000000033333334_0000000000000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		
		--Test2: round min and round max
		
		rs1 <= x"8000000000000001_7FFFFFFFFFFFFFFE";
		rs2 <= x"00000000_11111111_00000000_11111111";
		rs3 <= x"00000000_FFFFFFFD_00000000_00000003";
		instruct <= b"10_100_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"8000000000000000_7FFFFFFFFFFFFFFF"
		report "Error for SLMALS. Expected rd = " & "0x8000000000000000_7FFFFFFFFFFFFFFF. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		-------------------------------------------- SLMAHS ---------------------------------------------
		--Test1: no saturation and check high only
		
		rs1 <= x"0000000000000001_0000000000000000";
		rs2 <= x"11111111_00000000_00000000_11111111";
		rs3 <= x"00000003_00000000_00000000_00000001";
		instruct <= b"10_101_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0000000033333334_0000000000000000"
		report "Error for SLMAHS. Expected rd = " & "0x0000000033333334_0000000000000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		
		--Test2: round min and round max
		
		rs1 <= x"8000000000000001_7FFFFFFFFFFFFFFE";
		rs2 <= x"11111111_00000000_11111111_00000000";
		rs3 <= x"FFFFFFFD_00000000_00000003_00000000";
		instruct <= b"10_101_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"8000000000000000_7FFFFFFFFFFFFFFF"
		report "Error for SLMAHS. Expected rd = " & "0x8000000000000000_7FFFFFFFFFFFFFFF. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		-------------------------------------------- SLMSLS ---------------------------------------------
		--Test1: no saturation and check low only
		
		rs1 <= x"0000000033333334_0000000000000000";
		rs2 <= x"00000000_11111111_FFFFFFFF_00000000";
		rs3 <= x"00000000_00000003_00000001_00000000";
		instruct <= b"10_110_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0000000000000001_0000000000000000"
		report "Error for SLMSLS. Expected rd = " & "0x0000000000000001_0000000000000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		
		--Test2: round min and round max
		
		rs1 <= x"8000000000000001_7FFFFFFFFFFFFFFE";
		rs2 <= x"00000000_11111111_00000000_11111111";
		rs3 <= x"00000000_00000003_00000000_FFFFFFFD";
		instruct <= b"10_110_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"8000000000000000_7FFFFFFFFFFFFFFF"
		report "Error for SLMSLS. Expected rd = " & "0x8000000000000000_7FFFFFFFFFFFFFFF. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		-------------------------------------------- SLMSHS ---------------------------------------------
		--Test1: no saturation and check high only
		
		rs1 <= x"0000000033333334_0000000000000000";
		rs2 <= x"11111111_00000000_00000000_FFFFFFFF";
		rs3 <= x"00000003_00000000_00000000_00000001";
		instruct <= b"10_111_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0000000000000001_0000000000000000"
		report "Error for SLMSHS. Expected rd = " & "0x0000000000000001_0000000000000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		
		--Test2: round min and round max
		
		rs1 <= x"8000000000000001_7FFFFFFFFFFFFFFE";
		rs2 <= x"11111111_00000000_11111111_00000000";
		rs3 <= x"00000003_00000000_FFFFFFFD_00000000";
		instruct <= b"10_111_00000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"8000000000000000_7FFFFFFFFFFFFFFF"
		report "Error for SLMSHS. Expected rd = " & "0x8000000000000000_7FFFFFFFFFFFFFFF. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- NOP -------------------------------------------------
		--Test: Do nothing
		
		rs1 <= (others => '0');
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00000000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = std_logic_vector(to_unsigned(0, 128))
		report "Error for NOP. Expected rd = 0. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------

		------------------------------------------- SHRHI -----------------------------------------------
		--Test1: Shift right rs1 10 times packed halfword
		
		rs1 <= x"FFFF_9842_1111_0000_0111_0200_0400_0000";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00000001_01010_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"003F_0026_0004_0000_0000_0000_0001_0000"
		report "Error for SHRHI. Expected rd = " & "0x003F_0026_0004_0000_0000_0000_0001_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		
		
		--Test2: no shift
		
		rs1 <= x"FFFF_9842_1111_0000_0111_0200_0400_0000";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00000001_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFF_9842_1111_0000_0111_0200_0400_0000"
		report "Error for SHRHI. Expected rd = " & "0xFFFF_9842_1111_0000_0111_0200_0400_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		-------------------------------------------- AU -------------------------------------------------
		--Test: Add unsigned rs1 + rs2 packed word
		
		rs1 <= x"FFFF9842_1111F000_80000000_70000000";
		rs2 <= x"00010020_11111000_80000000_70000000";
		rs3 <= (others => '0');
		instruct <= b"11_00000010_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"00009862_22230000_00000000_E0000000"
		report "Error for AU. Expected rd = " & "0x00009862_22230000_00000000_E0000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------ CNT1H ------------------------------------------------
		--Test: Count 1's in rs1 packed halfword
		
		rs1 <= x"FFFF_9842_1111_0000_0111_0200_0400_0000";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00000011_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0010_0005_0004_0000_0003_0001_0001_0000"
		report "Error for CNT1H. Expected rd = " & "0x0010_0005_0004_0000_0003_0001_0001_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------		
		
		------------------------------------------- AHS -------------------------------------------------
		--Test: rs1 + rs2 saturated packed halfword
		
		rs1 <= x"7FFE_9842_1111_8000_8000_0000_7FFF_8000";
		rs2 <= x"000F_0020_1111_8000_0111_0000_8000_FFFF";
		rs3 <= (others => '0');
		instruct <= b"11_00000100_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"7FFF_9862_2222_8000_8111_0000_FFFF_8000"
		report "Error for AHS. Expected rd = " & "0x7FFF_9862_2222_8000_8111_0000_FFFF_8000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		-------------------------------------------- OR -------------------------------------------------
		--Test: rs1 OR rs2
		
		rs1 <= x"7FFF_0000_1111_FFFF_0060_0000_0000_1000";
		rs2 <= x"7FFC_0000_1111_0101_0700_0000_0000_2000";
		rs3 <= (others => '0');
		instruct <= b"11_00000101_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"7FFF_0000_1111_FFFF_0760_0000_0000_3000"
		report "Error for OR. Expected rd = " & "0x7FFF_0000_1111_FFFF_0760_0000_0000_3000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- BCW -------------------------------------------------
		--Test: copy rightmost word of rs1 to rd
		
		rs1 <= x"FFFF9842_1111F000_80000000_70000000";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00000110_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"70000000_70000000_70000000_70000000"
		report "Error for BCW. Expected rd = " & "0x70000000_70000000_70000000_70000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- MAXWS -----------------------------------------------
		--Test: Max signed word between rs1 and rs2 into rd
		
		rs1 <= x"FFFFFFFF_00000000_80000000_00000000";
		rs2 <= x"F0000000_00000001_70000000_00000000";
		rs3 <= (others => '0');
		instruct <= b"11_00000111_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"FFFFFFFF_00000001_70000000_00000000"
		report "Error for MAXWS. Expected rd = " & "0xFFFFFFFF_00000001_70000000_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- MINWS -----------------------------------------------
		--Test: Min signed word between rs1 and rs2 into rd
		
		rs1 <= x"FFFFFFFF_00000000_80000000_00000000";
		rs2 <= x"F0000000_00000001_70000000_00000000";
		rs3 <= (others => '0');
		instruct <= b"11_00001000_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"F0000000_00000000_80000000_00000000"
		report "Error for MINWS. Expected rd = " & "0xF0000000_00000000_80000000_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- MLHU ------------------------------------------------
		--Test: Multiply unsigned right halfword of rs1 and rs2 and put result into word of rd
		
		rs1 <= x"0000_1000_0000_FFFF_0000_1111_1111_0000";
		rs2 <= x"0000_0011_0000_FFFF_0000_0000_0002_0000";
		rs3 <= (others => '0');
		instruct <= b"11_00001001_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"00011000_FFFE0001_00000000_00000000"
		report "Error for MLHU. Expected rd = " & "0x00011000_FFFE0001_00000000_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- MLHSS -----------------------------------------------
		--Test: Multiply halfword rs1 by the sign(+/-) of rs2 or zero if halfword rs2 is zero
		
		rs1 <= x"8000_0770_1111_0222_7FFF_0000_0000_0000";
		rs2 <= x"8000_0007_0000_F000_8000_0000_0000_0000";
		rs3 <= (others => '0');
		instruct <= b"11_00001010_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"7FFF_0770_0000_FDDE_8001_0000_0000_0000"
		report "Error for MLHSS. Expected rd = " & "0x7FFF_0770_0000_FDDE_8001_0000_0000_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- AND -------------------------------------------------
		--Test: rs1 AND rs2
		
		rs1 <= x"0001_0300_00F0_000C_1111_0000_0000_0000";
		rs2 <= x"000F_0200_0010_0003_1111_0000_0000_0000";
		rs3 <= (others => '0');
		instruct <= b"11_00001011_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0001_0200_0010_0000_1111_0000_0000_0000"
		report "Error for AND. Expected rd = " & "0x0001_0200_0010_0000_1111_0000_0000_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- INVB ------------------------------------------------
		--Test: Invert rs1
		
		rs1 <= x"FFFF_0000_1111_9876_FFFF_FFFF_FFFF_FFFF";
		rs2 <= (others => '0');
		rs3 <= (others => '0');
		instruct <= b"11_00001100_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0000_FFFF_EEEE_6789_0000_0000_0000_0000"
		report "Error for INVB. Expected rd = " & "0x0000_FFFF_EEEE_6789_0000_0000_0000_0000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- ROTW ------------------------------------------------
		--Test: Each word of rs1 rotated right by 5 LSBs of rs2 times
		
		rs1 <= x"FFFFFFFE_12345678_88888888_00000001";
		rs2 <= x"00000001_FFFFFFE0_0000001F_00000001";
		rs3 <= (others => '0');
		instruct <= b"11_00001101_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"7FFFFFFF_12345678_11111111_80000000"
		report "Error for ROTW. Expected rd = " & "0x7FFFFFFF_12345678_11111111_80000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SFWU ------------------------------------------------
		--Test: rs2 - rs1 unsigned word
		
		rs1 <= x"EDCBA987_00000002_00000000_00000000";
		rs2 <= x"FEDCBA98_00000001_00000000_00000000";
		rs3 <= (others => '0');
		instruct <= b"11_00001110_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"11111111_FFFFFFFF_00000000_00000000"
		report "Error for SFWU. Expected rd = " & "0x11111111_FFFFFFFF_00000000_00000000. " &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		------------------------------------------- SFHS ------------------------------------------------
		--Test: rs2 - rs1 signed halfword
		
		rs1 <= x"7FFE_FFFE_7FFF_F000_0002_0000_0000_0000";
		rs2 <= x"7FFF_FFFF_8000_7FFF_0001_0000_0000_0000";
		rs3 <= (others => '0');
		instruct <= b"11_00001111_00000_00000_00000";
		
		wait for period;
		string_var := print_hex_g(rd);
		
		assert rd = x"0001_0001_8000_7FFF_FFFF_0000_0000_0000"
		report "Error for SFHS. Expected rd = " & "0x0001_0001_8000_7FFF_FFFF_0000_0000_0000" &
						"Actual ouput was rd = " & string_var & "."
		severity error;
		-------------------------------------------------------------------------------------------------
		
		report "All Tests finished.";
		
		std.env.finish;
	end process;
	
end testbench;