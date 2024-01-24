-------------------------------------------------------------------------------
--
-- Project Title	: Pipelined SIMD Multimedia Unit Design
-- Authors      	: Dylan Li, Alec Lempert
-- Company      	: Stony Brook University
-- Component		: Pipelined Multimedia Unit
--
-------------------------------------------------------------------------------
--
-- Description : Combines all components and connects all signals through structural model
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use work.all;


entity Pipelined_Multimedia_Unit is
	port( clk : in std_logic );
end Pipelined_Multimedia_Unit;


architecture Structural of Pipelined_Multimedia_Unit is
	
	-- From Buffer to IF/ID
	signal instruct_Buffer2Pipeline : std_logic_vector(24 downto 0);
	
	-- From IF/ID to RegFile
	signal instruct_Pipeline2RegFile : std_logic_vector(24 downto 0);
	
	-- From RegFile to ID/EX
	signal instruct_RegFile2Pipeline : std_logic_vector(24 downto 0);
	signal rs1_ID : std_logic_vector(127 downto 0);
	signal rs2_ID : std_logic_vector(127 downto 0);
	signal rs3_ID : std_logic_vector(127 downto 0);
	
	-- From ID/EX to Muxes
	signal rs1_EX : std_logic_vector(127 downto 0);
	signal rs2_EX : std_logic_vector(127 downto 0);
	signal rs3_EX : std_logic_vector(127 downto 0);
	
	-- From Muxes to ALU
	signal rs1_ALU : std_logic_vector(127 downto 0);
	signal rs2_ALU : std_logic_vector(127 downto 0);
	signal rs3_ALU : std_logic_vector(127 downto 0);
	
	-- From ID/EX to ALU, Forwarding Unit, and EX/WB
	signal instruct_Pipeline2ALU : std_logic_vector(24 downto 0);
	
	-- From ALU to EX/WB
	signal rd_ALU : std_logic_vector(127 downto 0);
	
	-- From EX/WB to RegFile
	signal wr_en : std_logic;
	
	-- From EX/WB to Forwarding Unit and RegFile
	signal rd_index : std_logic_vector(4 downto 0);
	
	-- From EX/WB to RegFile and Forwarding Unit
	signal rd_WB : std_logic_vector(127 downto 0);
	
	-- From Forwarding Unit to Muxes
	signal rd_Fwd : std_logic_vector(127 downto 0);
	signal mux_ctrl_1 : std_logic;
	signal mux_ctrl_2 : std_logic;
	signal mux_ctrl_3 : std_logic;
	
begin

	In_Buffer: entity Instruction_Buffer port map(
			clk => clk,
			instruct =>	instruct_Buffer2Pipeline
		);
		
	IF_ID: entity IF_ID_reg port map(
			clk => clk,
			instruction_in => instruct_Buffer2Pipeline,
			instruction_out => instruct_Pipeline2RegFile
		);
		
	RegFile: entity Register_File port map(
			clk => clk,
			instruct_in => instruct_Pipeline2RegFile,
			rd_index => rd_index,
			wr_en => wr_en,
			data => rd_WB,
			rs1 => rs1_ID,
			rs2 => rs2_ID,
			rs3 => rs3_ID,
			instruct_out =>	instruct_RegFile2Pipeline
		);
		
	ID_EX: entity ID_EX_reg port map(
			clk => clk,
			rs1_in => rs1_ID,
			rs2_in => rs2_ID,
			rs3_in => rs3_ID,
			instruction_in => instruct_RegFile2Pipeline,
			instruction_out => instruct_Pipeline2ALU,
			rs1_out => rs1_EX,
			rs2_out => rs2_EX,
			rs3_out => rs3_EX
		);
		
	Muxes: entity Forwarding_Muxes port map(
			rs1_in => rs1_EX,
			rs2_in => rs2_EX,
			rs3_in => rs3_EX,
			mux_1 => mux_ctrl_1,
			mux_2 => mux_ctrl_2,
			mux_3 => mux_ctrl_3,
			rd => rd_Fwd,
			rs1_out => rs1_ALU,
			rs2_out => rs2_ALU,
			rs3_out => rs3_ALU
		);
		
	ALU: entity Multimedia_ALU port map(
			InReg1 => rs1_ALU,
			InReg2 => rs2_ALU,
			InReg3 => rs3_ALU,
			Instruct => instruct_Pipeline2ALU,
			OutReg => rd_ALU
		);
		
	EX_WB: entity EX_WB_reg port map(
			clk => clk,
			instruction => instruct_Pipeline2ALU,
			rd_in => rd_ALU,
			wr_en => wr_en,
			rd_out => rd_WB,
			rd_index => rd_index
		);
		
	Forward: entity Forwarding_Unit port map(
			instruction_EX => instruct_Pipeline2ALU,
			rd_index => rd_index,
			rd_in => rd_WB,
			rd_out => rd_Fwd,
			mux_ctrl_1 => mux_ctrl_1,
			mux_ctrl_2 => mux_ctrl_2,
			mux_ctrl_3 => mux_ctrl_3
		);
		
end Structural;