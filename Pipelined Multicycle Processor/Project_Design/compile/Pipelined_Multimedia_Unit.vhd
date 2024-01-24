-------------------------------------------------------------------------------
--
-- Title       : 
-- Design      : Project_Design
-- Author      : dylan.li@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:\Users\dylan\Documents\Aldec\ESE 345\Project\Project_Design\compile\Pipelined_Multimedia_Unit.vhd
-- Generated   : Sat Dec  2 21:32:58 2023
-- From        : C:\Users\dylan\Documents\Aldec\ESE 345\Project\Project_Design\src\Pipelined_Multimedia_Unit.bde
-- By          : Bde2Vhdl ver. 2.6
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
-- Design unit header --
library ieee;
use ieee.std_logic_1164.all;

entity Pipelined_Multimedia_Unit is
  port(
       clk : in STD_LOGIC
  );
end Pipelined_Multimedia_Unit;

architecture Structural of Pipelined_Multimedia_Unit is

---- Component declarations -----

component EX_WB_reg
  port(
       clk : in STD_LOGIC;
       instruction : in STD_LOGIC_VECTOR(24 downto 0);
       rd_in : in STD_LOGIC_VECTOR(127 downto 0);
       wr_en : out STD_LOGIC;
       rd_out : out STD_LOGIC_VECTOR(127 downto 0);
       rd_index : out STD_LOGIC_VECTOR(4 downto 0)
  );
end component;
component Forwarding_Muxes
  port(
       rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
       rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
       rs3_in : in STD_LOGIC_VECTOR(127 downto 0);
       mux_1 : in STD_LOGIC;
       mux_2 : in STD_LOGIC;
       mux_3 : in STD_LOGIC;
       rd : in STD_LOGIC_VECTOR(127 downto 0);
       rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
       rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
       rs3_out : out STD_LOGIC_VECTOR(127 downto 0)
  );
end component;
component Forwarding_Unit
  port(
       instruction_EX : in STD_LOGIC_VECTOR(24 downto 0);
       rd_index : in STD_LOGIC_VECTOR(4 downto 0);
       rd_in : in STD_LOGIC_VECTOR(127 downto 0);
       rd_out : out STD_LOGIC_VECTOR(127 downto 0);
       mux_ctrl_1 : out STD_LOGIC;
       mux_ctrl_2 : out STD_LOGIC;
       mux_ctrl_3 : out STD_LOGIC
  );
end component;
component ID_EX_reg
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
end component;
component IF_ID_reg
  port(
       clk : in STD_LOGIC;
       instruction_in : in STD_LOGIC_VECTOR(24 downto 0);
       instruction_out : out STD_LOGIC_VECTOR(24 downto 0)
  );
end component;
component Instruction_Buffer
  port(
       clk : in STD_LOGIC;
       instruct : out STD_LOGIC_VECTOR(24 downto 0)
  );
end component;
component Multimedia_ALU
  port(
       InReg1 : in STD_LOGIC_VECTOR(127 downto 0);
       InReg2 : in STD_LOGIC_VECTOR(127 downto 0);
       InReg3 : in STD_LOGIC_VECTOR(127 downto 0);
       Instruct : in STD_LOGIC_VECTOR(24 downto 0);
       OutReg : out STD_LOGIC_VECTOR(127 downto 0)
  );
end component;
component Register_File
  port(
       clk : in STD_LOGIC;
       instruct_in : in STD_LOGIC_VECTOR(24 downto 0);
       rd_index : in STD_LOGIC_VECTOR(4 downto 0);
       wr_en : in STD_LOGIC;
       data : in STD_LOGIC_VECTOR(127 downto 0);
       rs1 : out STD_LOGIC_VECTOR(127 downto 0);
       rs2 : out STD_LOGIC_VECTOR(127 downto 0);
       rs3 : out STD_LOGIC_VECTOR(127 downto 0);
       instruct_out : out STD_LOGIC_VECTOR(24 downto 0)
  );
end component;

---- Signal declarations used on the diagram ----

signal mux_ctrl_1 : STD_LOGIC;
signal mux_ctrl_2 : STD_LOGIC;
signal mux_ctrl_3 : STD_LOGIC;
signal wr_en : STD_LOGIC;
signal instruct_Buffer2Pipeline : STD_LOGIC_VECTOR(24 downto 0);
signal instruct_Pipeline2ALU : STD_LOGIC_VECTOR(24 downto 0);
signal instruct_Pipeline2RegFile : STD_LOGIC_VECTOR(24 downto 0);
signal instruct_RegFile2Pipeline : STD_LOGIC_VECTOR(24 downto 0);
signal rd_ALU : STD_LOGIC_VECTOR(127 downto 0);
signal rd_Fwd : STD_LOGIC_VECTOR(127 downto 0);
signal rd_index : STD_LOGIC_VECTOR(4 downto 0);
signal rd_WB : STD_LOGIC_VECTOR(127 downto 0);
signal rs1_ALU : STD_LOGIC_VECTOR(127 downto 0);
signal rs1_EX : STD_LOGIC_VECTOR(127 downto 0);
signal rs1_ID : STD_LOGIC_VECTOR(127 downto 0);
signal rs2_ALU : STD_LOGIC_VECTOR(127 downto 0);
signal rs2_EX : STD_LOGIC_VECTOR(127 downto 0);
signal rs2_ID : STD_LOGIC_VECTOR(127 downto 0);
signal rs3_ALU : STD_LOGIC_VECTOR(127 downto 0);
signal rs3_EX : STD_LOGIC_VECTOR(127 downto 0);
signal rs3_ID : STD_LOGIC_VECTOR(127 downto 0);

begin

----  Component instantiations  ----

ALU : Multimedia_ALU
  port map(
       InReg1 => rs1_ALU,
       InReg2 => rs2_ALU,
       InReg3 => rs3_ALU,
       Instruct => instruct_Pipeline2ALU,
       OutReg => rd_ALU
  );

EX_WB : EX_WB_reg
  port map(
       clk => clk,
       instruction => instruct_Pipeline2ALU,
       rd_in => rd_ALU,
       wr_en => wr_en,
       rd_out => rd_WB,
       rd_index => rd_index
  );

Forward : Forwarding_Unit
  port map(
       instruction_EX => instruct_Pipeline2ALU,
       rd_index => rd_index,
       rd_in => rd_WB,
       rd_out => rd_Fwd,
       mux_ctrl_1 => mux_ctrl_1,
       mux_ctrl_2 => mux_ctrl_2,
       mux_ctrl_3 => mux_ctrl_3
  );

ID_EX : ID_EX_reg
  port map(
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

IF_ID : IF_ID_reg
  port map(
       clk => clk,
       instruction_in => instruct_Buffer2Pipeline,
       instruction_out => instruct_Pipeline2RegFile
  );

In_Buffer : Instruction_Buffer
  port map(
       clk => clk,
       instruct => instruct_Buffer2Pipeline
  );

Muxes : Forwarding_Muxes
  port map(
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

RegFile : Register_File
  port map(
       clk => clk,
       instruct_in => instruct_Pipeline2RegFile,
       rd_index => rd_index,
       wr_en => wr_en,
       data => rd_WB,
       rs1 => rs1_ID,
       rs2 => rs2_ID,
       rs3 => rs3_ID,
       instruct_out => instruct_RegFile2Pipeline
  );


end Structural;
