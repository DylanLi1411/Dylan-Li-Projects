-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Multimedia ALU
--
-------------------------------------------------------------------------------
--
-- Description : Does arithmetic and logical operations based on 25-bit instruction
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Multimedia_ALU is
    Port (
        -- Input Registers
        InReg1 : in std_logic_vector(127 downto 0);		-- rs1 / rd if instruction in load immediate format
        InReg2 : in std_logic_vector(127 downto 0);		-- rs2
        InReg3 : in std_logic_vector(127 downto 0);		-- rs3
        
		-- Instruction Input
		Instruct : in std_logic_vector(24 downto 0);	-- 25-bit instruction
		
        -- Output Register
        OutReg : out std_logic_vector(127 downto 0)		-- rd
    );
end entity Multimedia_ALU;


architecture Behavioral of Multimedia_ALU is
	-- all the Max and Min signed values needed for saturation
	constant MAX_16_VALUE : signed(15 downto 0) := (15 => '0', others => '1');
	constant MIN_16_VALUE : signed(15 downto 0) := (15 => '1', others => '0');
	constant MAX_32_VALUE : signed(31 downto 0) := (31 => '0', others => '1');
	constant MIN_32_VALUE : signed(31 downto 0) := (31 => '1', others => '0');
	constant MAX_64_VALUE : signed(63 downto 0) := (63 => '0', others => '1');
	constant MIN_64_VALUE : signed(63 downto 0) := (63 => '1', others => '0');
begin
	
	-- Arithmetic Logic Unit
    ALU: process (all)
		variable output_v : std_logic_vector(127 downto 0) := (others => '0'); -- this will write to OutReg at the end
		variable count : natural; -- for CNT1H
		
		variable prod_4, prod_3, prod_2, prod_1: signed(31 downto 0); --Variables for products
		variable sum_int_4, sum_int_3, sum_int_2, sum_int_1: signed(31 downto 0); --Variables for int(32) 
		variable diff_int_4, diff_int_3, diff_int_2, diff_int_1: signed(31 downto 0); --Variables for differences.
			
		variable prod_long_2, prod_long_1: signed(63 downto 0); 
		variable sum_long_2, sum_long_1: signed(63 downto 0); --Variables for long(64) 	 
		variable diff_long_2, diff_long_1: signed(63 downto 0);
			
		variable combined_sum: signed(127 downto 0);
		variable combined_diff: signed(127 downto 0);
    begin
		
		-- Check MSB and 2nd MSB(if necessary) of Instruction
		if Instruct(24) = '0' then								-- load immediate
			output_v := InReg1; -- load rd as source
			output_v( (to_integer(unsigned(Instruct(23 downto 21))) *16) + 15 downto to_integer(unsigned(Instruct(23 downto 21)))*16) := Instruct(20 downto 5);
			
		elsif Instruct(24) = '1' and Instruct(23) = '0' then	-- R4-Instruction
			case Instruct(22 downto 20) is 
				
				when "000" => 	
					--Signed Integer Multiply-Add Low with Saturation
				
					-- Extract low 16-bit fields from rs3 and rs2. Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2  
            		prod_4 := signed(InReg3(111 downto 96)) * signed(InReg2(111 downto 96));
					prod_3 := signed(InReg3(79 downto 64)) * signed(InReg2(79 downto 64));
					prod_2 := signed(InReg3(47 downto 32)) * signed(InReg2(47 downto 32));
					prod_1 := signed(InReg3(15 downto 0)) * signed(InReg2(15 downto 0)); 
				
					
					-- Add resized 32-bit products to corresponding resized 32-bit fields of rs1 with saturation
					if resize(signed(prod_4), 64) + resize(signed(InReg1(127 downto 96)), 64) > MAX_32_VALUE then
						sum_int_4 := MAX_32_VALUE;
					elsif resize(signed(prod_4), 64) + resize(signed(InReg1(127 downto 96)), 64) < MIN_32_VALUE then
						sum_int_4 := MIN_32_VALUE;
					else
						sum_int_4 := signed(prod_4) + signed(InReg1(127 downto 96));
					end if;
					
					if resize(signed(prod_3), 64) + resize(signed(InReg1(95 downto 64)), 64) > MAX_32_VALUE then
						sum_int_3 := MAX_32_VALUE;
					elsif resize(signed(prod_3), 64) + resize(signed(InReg1(95 downto 64)), 64) < MIN_32_VALUE then
						sum_int_3 := MIN_32_VALUE;
					else
						sum_int_3 := signed(prod_3) + signed(InReg1(95 downto 64));
					end if;
					
					if resize(signed(prod_2), 64) + resize(signed(InReg1(63 downto 32)), 64) > MAX_32_VALUE then
						sum_int_2 := MAX_32_VALUE;
					elsif resize(signed(prod_2), 64) + resize(signed(InReg1(63 downto 32)), 64) < MIN_32_VALUE then
						sum_int_2 := MIN_32_VALUE;
					else
						sum_int_2 := signed(prod_2) + signed(InReg1(63 downto 32));
					end if;
					
					if resize(signed(prod_1), 64) + resize(signed(InReg1(31 downto 0)), 64) > MAX_32_VALUE then
						sum_int_1 := MAX_32_VALUE;
					elsif resize(signed(prod_1), 64) + resize(signed(InReg1(31 downto 0)), 64) < MIN_32_VALUE then
						sum_int_1 := MIN_32_VALUE;
					else
						sum_int_1 := signed(prod_1) + signed(InReg1(31 downto 0));
					end if;
					
					combined_sum := sum_int_4 & sum_int_3 & sum_int_2 & sum_int_1;	
					
					output_v := std_logic_vector(combined_sum); --Save result in rd
				--Finished
				
				when "001" =>  
					--Signed Integer Multiply-Add High with Saturation 
				
					-- Extract high 16-bit fields from rs3 and rs2 and sign extend. Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2  
            		prod_4 := signed(InReg3(127 downto 112)) * signed(InReg2(127 downto 112));
					prod_3 := signed(InReg3(95 downto 80)) * signed(InReg2(95 downto 80));
					prod_2 := signed(InReg3(63 downto 48)) * signed(InReg2(63 downto 48));
					prod_1 := signed(InReg3(31 downto 16)) * signed(InReg2(31 downto 16)); 
				
					
					-- Add resized 32-bit products to corresponding resized 32-bit fields of rs1 with saturation
					if resize(signed(prod_4), 64) + resize(signed(InReg1(127 downto 96)), 64) > MAX_32_VALUE then
						sum_int_4 := MAX_32_VALUE;
					elsif resize(signed(prod_4), 64) + resize(signed(InReg1(127 downto 96)), 64) < MIN_32_VALUE then
						sum_int_4 := MIN_32_VALUE;
					else
						sum_int_4 := signed(prod_4) + signed(InReg1(127 downto 96));
					end if;
					
					if resize(signed(prod_3), 64) + resize(signed(InReg1(95 downto 64)), 64) > MAX_32_VALUE then
						sum_int_3 := MAX_32_VALUE;
					elsif resize(signed(prod_3), 64) + resize(signed(InReg1(95 downto 64)), 64) < MIN_32_VALUE then
						sum_int_3 := MIN_32_VALUE;
					else
						sum_int_3 := signed(prod_3) + signed(InReg1(95 downto 64));
					end if;
					
					if resize(signed(prod_2), 64) + resize(signed(InReg1(63 downto 32)), 64) > MAX_32_VALUE then
						sum_int_2 := MAX_32_VALUE;
					elsif resize(signed(prod_2), 64) + resize(signed(InReg1(63 downto 32)), 64) < MIN_32_VALUE then
						sum_int_2 := MIN_32_VALUE;
					else
						sum_int_2 := signed(prod_2) + signed(InReg1(63 downto 32));
					end if;
					
					if resize(signed(prod_1), 64) + resize(signed(InReg1(31 downto 0)), 64) > MAX_32_VALUE then
						sum_int_1 := MAX_32_VALUE;
					elsif resize(signed(prod_1), 64) + resize(signed(InReg1(31 downto 0)), 64) < MIN_32_VALUE then
						sum_int_1 := MIN_32_VALUE;
					else
						sum_int_1 := signed(prod_1) + signed(InReg1(31 downto 0));
					end if;
					
					combined_sum := sum_int_4 & sum_int_3 & sum_int_2 & sum_int_1;	
					
					output_v := std_logic_vector(combined_sum); --Save result in rd
				--Finished
				
				when "010" =>
				--Signed Integer Multiply-Subtract Low with Saturation
				
				-- Extract low 16-bit fields from rs3 and rs2 and sign extend. Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2  
            		prod_4 := signed(InReg3(111 downto 96)) * signed(InReg2(111 downto 96));
					prod_3 := signed(InReg3(79 downto 64)) * signed(InReg2(79 downto 64));
					prod_2 := signed(InReg3(47 downto 32)) * signed(InReg2(47 downto 32));
					prod_1 := signed(InReg3(15 downto 0)) * signed(InReg2(15 downto 0)); 
				
					
					-- Subtract 32-bit products from corresponding 32-bit fields of rs1 with saturation 
					if resize(signed(InReg1(127 downto 96)), 64) - resize(signed(prod_4), 64) > MAX_32_VALUE then
						diff_int_4 := MAX_32_VALUE;
					elsif resize(signed(InReg1(127 downto 96)), 64) - resize(signed(prod_4), 64) < MIN_32_VALUE then
						diff_int_4 := MIN_32_VALUE;
					else
						diff_int_4 := signed(InReg1(127 downto 96)) - signed(prod_4);
					end if;
					
					if resize(signed(InReg1(95 downto 64)), 64) - resize(signed(prod_3), 64) > MAX_32_VALUE then
						diff_int_3 := MAX_32_VALUE;
					elsif resize(signed(InReg1(95 downto 64)), 64) - resize(signed(prod_3), 64) < MIN_32_VALUE then
						diff_int_3 := MIN_32_VALUE;
					else
						diff_int_3 := signed(InReg1(95 downto 64)) - signed(prod_3);
					end if;
					
					if resize(signed(InReg1(63 downto 32)), 64) - resize(signed(prod_2), 64) > MAX_32_VALUE then
						diff_int_2 := MAX_32_VALUE;
					elsif resize(signed(InReg1(63 downto 32)), 64) - resize(signed(prod_2), 64) < MIN_32_VALUE then
						diff_int_2 := MIN_32_VALUE;
					else
						diff_int_2 := signed(InReg1(63 downto 32)) - signed(prod_2);
					end if;
					
					if resize(signed(InReg1(31 downto 0)), 64) - resize(signed(prod_1), 64) > MAX_32_VALUE then
						diff_int_1 := MAX_32_VALUE;
					elsif resize(signed(InReg1(31 downto 0)), 64) - resize(signed(prod_1), 64) < MIN_32_VALUE then
						diff_int_1 := MIN_32_VALUE;
					else
						diff_int_1 := signed(InReg1(31 downto 0)) - signed(prod_1);
					end if;	  
					
					combined_diff := diff_int_4 & diff_int_3 & diff_int_2 & diff_int_1;	
					
					output_v := std_logic_vector(combined_diff); 
				
				when "011" =>
					--Signed Integer Multiply-Subtract High with Saturation	
				
					-- Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2  
            		prod_4 := signed(InReg3(127 downto 112)) * signed(InReg2(127 downto 112));
					prod_3 := signed(InReg3(95 downto 80)) * signed(InReg2(95 downto 80));
					prod_2 := signed(InReg3(63 downto 48)) * signed(InReg2(63 downto 48));
					prod_1 := signed(InReg3(31 downto 16)) * signed(InReg2(31 downto 16)); 
				
					
					-- Subtract 32-bit products from corresponding 32-bit fields of rs1 with saturation 
					if resize(signed(InReg1(127 downto 96)), 64) - resize(signed(prod_4), 64) > MAX_32_VALUE then
						diff_int_4 := MAX_32_VALUE;
					elsif resize(signed(InReg1(127 downto 96)), 64) - resize(signed(prod_4), 64) < MIN_32_VALUE then
						diff_int_4 := MIN_32_VALUE;
					else
						diff_int_4 := signed(InReg1(127 downto 96)) - signed(prod_4);
					end if;
					
					if resize(signed(InReg1(95 downto 64)), 64) - resize(signed(prod_3), 64) > MAX_32_VALUE then
						diff_int_3 := MAX_32_VALUE;
					elsif resize(signed(InReg1(95 downto 64)), 64) - resize(signed(prod_3), 64) < MIN_32_VALUE then
						diff_int_3 := MIN_32_VALUE;
					else
						diff_int_3 := signed(InReg1(95 downto 64)) - signed(prod_3);
					end if;
					
					if resize(signed(InReg1(63 downto 32)), 64) - resize(signed(prod_2), 64) > MAX_32_VALUE then
						diff_int_2 := MAX_32_VALUE;
					elsif resize(signed(InReg1(63 downto 32)), 64) - resize(signed(prod_2), 64) < MIN_32_VALUE then
						diff_int_2 := MIN_32_VALUE;
					else
						diff_int_2 := signed(InReg1(63 downto 32)) - signed(prod_2);
					end if;
					
					if resize(signed(InReg1(31 downto 0)), 64) - resize(signed(prod_1), 64) > MAX_32_VALUE then
						diff_int_1 := MAX_32_VALUE;
					elsif resize(signed(InReg1(31 downto 0)), 64) - resize(signed(prod_1), 64) < MIN_32_VALUE then
						diff_int_1 := MIN_32_VALUE;
					else
						diff_int_1 := signed(InReg1(31 downto 0)) - signed(prod_1);
					end if;	  
					
					combined_diff := diff_int_4 & diff_int_3 & diff_int_2 & diff_int_1;	
					
					output_v := std_logic_vector(combined_diff); 
					--Finished
					
				when "100" =>
					--Signed Long Integer Multiply-Add Low with Saturation 
				
					--Multiply low 32-bit-fields of each 64-bit field of registers rs3 and rs2
					prod_long_2 := signed(InReg3(95 downto 64)) * signed(InReg2(95 downto 64));
					prod_long_1 := signed(InReg3(31 downto 0)) * signed(InReg2(31 downto 0));
					
					-- Add resized 64-bit products to corresponding resized 64-bit fields of rs1 with saturation
					if resize(signed(prod_long_2), 128) + resize(signed(InReg1(127 downto 64)), 128) > MAX_64_VALUE then
						sum_long_2 := MAX_64_VALUE;
					elsif resize(signed(prod_long_2), 128) + resize(signed(InReg1(127 downto 64)), 128) < MIN_64_VALUE then
						sum_long_2 := MIN_64_VALUE;
					else
						sum_long_2 := signed(prod_long_2) + signed(InReg1(127 downto 64)); 
					end if;
					
					if resize(signed(prod_long_1), 128) + resize(signed(InReg1(63 downto 0)), 128) > MAX_64_VALUE then
						sum_long_1 := MAX_64_VALUE;
					elsif resize(signed(prod_long_1), 128) + resize(signed(InReg1(63 downto 0)), 128) < MIN_64_VALUE then
						sum_long_1 := MIN_64_VALUE;
					else
						sum_long_1 := signed(prod_long_1) + signed(InReg1(63 downto 0)); 
					end if;
					
					combined_sum := sum_long_2 & sum_long_1;	
					
					output_v := std_logic_vector(combined_sum); --Save result in rd
				
				when "101" =>
					--Signed Long Integer Multiply-Add High with Saturation	
				
					--Multiply high 32-bit-fields of each 64-bit field of registers rs3 and rs2
					prod_long_2 := signed(InReg3(127 downto 96)) * signed(InReg2(127 downto 96));
					prod_long_1 := signed(InReg3(63 downto 32)) * signed(InReg2(63 downto 32));
					
					-- Add resized 64-bit products to corresponding resized 64-bit fields of rs1 with saturation
					if resize(signed(prod_long_2), 128) + resize(signed(InReg1(127 downto 64)), 128) > MAX_64_VALUE then
						sum_long_2 := MAX_64_VALUE;
					elsif resize(signed(prod_long_2), 128) + resize(signed(InReg1(127 downto 64)), 128) < MIN_64_VALUE then
						sum_long_2 := MIN_64_VALUE;
					else
						sum_long_2 := signed(prod_long_2) + signed(InReg1(127 downto 64)); 
					end if;
					
					if resize(signed(prod_long_1), 128) + resize(signed(InReg1(63 downto 0)), 128) > MAX_64_VALUE then
						sum_long_1 := MAX_64_VALUE;
					elsif resize(signed(prod_long_1), 128) + resize(signed(InReg1(63 downto 0)), 128) < MIN_64_VALUE then
						sum_long_1 := MIN_64_VALUE;
					else
						sum_long_1 := signed(prod_long_1) + signed(InReg1(63 downto 0)); 
					end if;
					
					combined_sum := sum_long_2 & sum_long_1;	
					
					output_v := std_logic_vector(combined_sum); --Save result in rd
				
				when "110" => 
					--Signed Long Integer Multiply-Subtract Low with Saturation			 
				
					--Multiply low 32-bit-fields of each 64-bit field of registers rs3 and rs2
					prod_long_2 := signed(InReg3(95 downto 64)) * signed(InReg2(95 downto 64));
					prod_long_1 := signed(InReg3(31 downto 0)) * signed(InReg2(31 downto 0));
					
					-- Subtract resized 64-bit products from corresponding resized 64-bit fields of rs1 with saturation
					if resize(signed(InReg1(127 downto 64)), 128) - resize(signed(prod_long_2), 128) > MAX_64_VALUE then
						diff_long_2 := MAX_64_VALUE;
					elsif resize(signed(InReg1(127 downto 64)), 128) - resize(signed(prod_long_2), 128) < MIN_64_VALUE then
						diff_long_2 := MIN_64_VALUE;
					else
						diff_long_2 := signed(InReg1(127 downto 64)) - signed(prod_long_2); 
					end if;
					
					if resize(signed(InReg1(63 downto 0)), 128) - resize(signed(prod_long_1), 128) > MAX_64_VALUE then
						diff_long_1 := MAX_64_VALUE;
					elsif resize(signed(InReg1(63 downto 0)), 128) - resize(signed(prod_long_1), 128) < MIN_64_VALUE then
						diff_long_1 := MIN_64_VALUE;
					else
						diff_long_1 := signed(InReg1(63 downto 0)) - signed(prod_long_1); 
					end if;
					
					combined_diff := diff_long_2 & diff_long_1;	
					
					output_v := std_logic_vector(combined_diff); --Save result in rd
					
				when "111" =>
				--Signed Long Integer Multiply-Subtract High with Saturation  
					--Multiply high 32-bit-fields of each 64-bit field of registers rs3 and rs2
					prod_long_2 := signed(InReg3(127 downto 96)) * signed(InReg2(127 downto 96));
					prod_long_1 := signed(InReg3(63 downto 32)) * signed(InReg2(63 downto 32));
					
					-- Subtract resized 64-bit products from corresponding resized 64-bit fields of rs1 with saturation
					if resize(signed(InReg1(127 downto 64)), 128) - resize(signed(prod_long_2), 128) > MAX_64_VALUE then
						diff_long_2 := MAX_64_VALUE;
					elsif resize(signed(InReg1(127 downto 64)), 128) - resize(signed(prod_long_2), 128) < MIN_64_VALUE then
						diff_long_2 := MIN_64_VALUE;
					else
						diff_long_2 := signed(InReg1(127 downto 64)) - signed(prod_long_2); 
					end if;
					
					if resize(signed(InReg1(63 downto 0)), 128) - resize(signed(prod_long_1), 128) > MAX_64_VALUE then
						diff_long_1 := MAX_64_VALUE;
					elsif resize(signed(InReg1(63 downto 0)), 128) - resize(signed(prod_long_1), 128) < MIN_64_VALUE then
						diff_long_1 := MIN_64_VALUE;
					else
						diff_long_1 := signed(InReg1(63 downto 0)) - signed(prod_long_1); 
					end if;
					
					combined_diff := diff_long_2 & diff_long_1;	
					
					output_v := std_logic_vector(combined_diff); --Save result in rd	
					
				when others => null; 
			end case;
			
		elsif Instruct(24) = '1' and Instruct(23) = '1' then	-- R3-Instruction
			
			case Instruct(18 downto 15) is
				when "0000" =>			-- NOP
					output_v := (others => '0'); -- component after ALU will take care of no write
				
				when "0001" =>			-- SHRHI
					output_v := InReg1;
				
					for i in 1 to to_integer(unsigned(Instruct(13 downto 10))) loop -- shift this number of times
						for j in 0 to 7 loop -- for each 8 halfwords
							output_v(((j*16) + 15) downto (j*16)) := '0' & output_v(((j*16) + 15) downto ((j*16) + 1)); -- shift right
						end loop;
					end loop;
					
				when "0010" =>			-- AU
					for i in 0 to 3 loop -- for each 4 words
						output_v(((i*32) + 31) downto (i*32)) := std_logic_vector(unsigned(InReg1(((i*32) + 31) downto (i*32))) + unsigned(InReg2(((i*32) + 31) downto (i*32)))); -- add
					end loop;
				
				when "0011" => 			-- CNT1H
					for i in 0 to 7 loop -- each 8 halfwords
						count := 0;
						for j in 0 to 15 loop -- the 16 bits
							if InReg1((i*16) + j) = '1' then
								count := count + 1;
							end if;
						end loop;
						
						output_v((i*16) + 15 downto i*16) := std_logic_vector(to_unsigned(count, 16));
					end loop;		
				
				when "0100" => 			-- AHS
					for i in 0 to 7 loop -- 8 halfwords
						if ( resize(signed(InReg1((i*16) + 15 downto i*16)), 32) + resize(signed(InReg2((i*16) + 15 downto i*16)), 32) ) > MAX_16_VALUE then -- saturation
							output_v((i*16) + 15 downto i*16) := std_logic_vector(MAX_16_VALUE);
						elsif ( resize(signed(InReg1((i*16) + 15 downto i*16)), 32) + resize(signed(InReg2((i*16) + 15 downto i*16)), 32) ) < MIN_16_VALUE then
							output_v((i*16) + 15 downto i*16) := std_logic_vector(MIN_16_VALUE);
						else
							output_v((i*16) + 15 downto i*16) := std_logic_vector(signed(InReg1((i*16) + 15 downto i*16)) + signed(InReg2((i*16) + 15 downto i*16)));
						end if;
					end loop;
				
				when "0101" => 			-- OR
					output_v := InReg1 or InReg2;
				
				when "0110" => 			-- BCW
					for i in 0 to 3 loop -- 4 words
						output_v((i*32) + 31 downto i*32) := InReg1(31 downto 0); -- assign every word in OutReg to the rightmost word of InReg1
					end loop;
				
				when "0111" => 	   		-- MAXWS
					for i in 0 to 3 loop -- 4 words
						if signed(InReg1((i*32) + 31 downto i*32)) > signed(InReg2((i*32) + 31 downto i*32)) then -- check for higher value
							output_v((i*32) + 31 downto i*32) := InReg1((i*32) + 31 downto i*32);
						else
							output_v((i*32) + 31 downto i*32) := InReg2((i*32) + 31 downto i*32);
						end if;
					end loop;
				
				when "1000" => 		   	-- MINWS
					for i in 0 to 3 loop -- 4 words
						if signed(InReg1((i*32) + 31 downto i*32)) < signed(InReg2((i*32) + 31 downto i*32)) then -- check for lower value
							output_v((i*32) + 31 downto i*32) := InReg1((i*32) + 31 downto i*32);
						else
							output_v((i*32) + 31 downto i*32) := InReg2((i*32) + 31 downto i*32);
						end if;
					end loop;
				
				when "1001" => 		 	-- MLHU
					for i in 0 to 3 loop -- 4 words
						output_v((i*32) + 31 downto i*32) := std_logic_vector(unsigned(InReg1((i*32) + 15 downto i*32)) * unsigned(InReg2((i*32) + 15 downto i*32)));
					end loop;
				
				when "1010" => 		 	-- MLHSS
					for i in 0 to 7 loop -- 8 halfwords
						if signed(InReg2((i*16) + 15 downto i*16)) < 0 then 		-- check negative
							if ( signed( InReg1( (i*16) + 15 downto i*16) ) * (-1)) > MAX_16_VALUE then -- saturation (multiplying by -1 gives twice number of bits product)
								output_v((i*16) + 15 downto i*16) := std_logic_vector(MAX_16_VALUE);
							else
								output_v((i*16) + 15 downto i*16) := std_logic_vector(resize( signed( InReg1( (i*16) + 15 downto i*16) ) * (-1) , 16));
							end if;
						elsif signed(InReg2((i*16) + 15 downto i*16)) = 0 then 	-- check zero
							output_v((i*16) + 15 downto i*16) := (others => '0');
						else 							-- positive = leave unchanged (multiply by 1)
							output_v((i*16) + 15 downto i*16) := InReg1((i*16) + 15 downto i*16);
						end if;
					end loop;
				
				when "1011" => 			-- AND
					output_v := InReg1 and InReg2;
				
				when "1100" => 	   		-- INVB
					output_v := not InReg1;	
				
				when "1101" => 			-- ROTW
					output_v := InReg1;
				
					for i in 0 to 3 loop -- 4 words
						for j in 1 to to_integer(unsigned(InReg2((i*32) + 4 downto i*32))) loop -- rotate this number of times
							output_v((i*32) + 31 downto i*32) := output_v(i*32) & output_v((i*32) + 31 downto (i*32) + 1); -- rotate right
						end loop;
					end loop;
				
				when "1110" => 	   		-- SFWU
					for i in 0 to 3 loop -- 4 words
						output_v((i*32) + 31 downto i*32) := std_logic_vector(unsigned(InReg2((i*32) + 31 downto i*32)) - unsigned(InReg1((i*32) + 31 downto i*32)));
					end loop;
				
				when "1111" => 	   		-- SFHS
					for i in 0 to 7 loop -- 8 halfwords
						if ( resize(signed(InReg2((i*16) + 15 downto i*16)), 32) - resize(signed(InReg1((i*16) + 15 downto i*16)), 32) ) < MIN_16_VALUE then -- saturation
							output_v((i*16) + 15 downto i*16) := std_logic_vector(MIN_16_VALUE);
						elsif ( resize(signed(InReg2((i*16) + 15 downto i*16)), 32) - resize(signed(InReg1((i*16) + 15 downto i*16)), 32) ) > MAX_16_VALUE then
							output_v((i*16) + 15 downto i*16) := std_logic_vector(MAX_16_VALUE);
						else
							output_v((i*16) + 15 downto i*16) := std_logic_vector(signed(InReg2((i*16) + 15 downto i*16)) - signed(InReg1((i*16) + 15 downto i*16)));
						end if;
					end loop;
				
				when others => 			-- no valid opcode = nop
					output_v := (others => '0');
				
			end case;
			
		end if;
		
		OutReg <= output_v;		-- assign result to rd
    end process;
	
end Behavioral;