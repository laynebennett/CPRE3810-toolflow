library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV_types.all;

entity HDU is 
port(
i_IFIF_RS1 : in std_logic_vector(4 downto 0);
i_IFIF_RS2 : in std_logic_vector(4 downto 0);
i_IDEX_RD  : in std_logic_vector(4 downto 0);
i_IDEX_MemRead : in std_logic;
i_EX_BranchTaken : in std_logic;

 -- PC write enable: 1 = normal update, 0 = stall PC
o_PC_WEn : out std_logic;

 -- IF/ID write enable: 1 = update IF/ID, 0 = stall ID
o_IFID_WEn : out std_logic;

 -- IF/ID flush: 1 = squash instruction in IF/ID = NOP
o_IFID_Flush : out std_logic;

 -- ID/EX flush: 1 = squash instruction in ID/EX = bubble
o_IDEX_Flush : out std_logic
);
end HDU;

architecture structure of HDU is

signal s_rd_nonzero   : std_logic;
  	signal s_rs1_match    : std_logic;gi
  	signal s_rs2_match    : std_logic;
  	signal s_load_use_haz : std_logic;

begin
	s_rd_nonzero <= '1' when i_IDEX_RD /= "00000" else '0';
	--Checks for read after write
	s_rs1_match  <= '1' when i_IDEX_RD = i_IFID_RS1 else '0';
	s_rs2_match  <= '1' when i_IDEX_RD = i_IFID_RS2 else '0';

 	s_load_use_haz <= '1' when 
	(i_IDEX_MemRead = '1' and
         s_rd_nonzero = '1' and
         (s_rs1_match = '1' or s_rs2_match = '1'))
        else '0';

--PC write enables stall on hazard
o_PC_WE <= '0' when s_load_use_haz = '1' else '1';

--IF/ID wrte enable stall on hazard	
o_IFID_WE <= '0' when s_load_use_haz = '1' else '1';

--Bubble on hazard
o_IDEX_Flush <= '1' when s_load_use_haz = '1' else '0';

--Flush when Branch or jump is taken
o_IFID_Flush <= '1' when i_EX_BranchTaken = '1' else '0';

end structure;

	


	
	
