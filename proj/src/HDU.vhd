library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV_types.all;

entity HDU is 
port(
i_IFID_RS1 : in std_logic_vector(4 downto 0);
i_IFID_RS2 : in std_logic_vector(4 downto 0);
i_IDEX_RD  : in std_logic_vector(4 downto 0);
i_EXMEM_RD : in std_logic_vector(4 downto 0);
i_IDEX_MemRead : in std_logic;
i_EX_BranchTaken : in std_logic;
i_HasImm : in std_logic;
i_Store_IFID : in std_logic;
i_Store_IDEX : in std_logic;
i_Store_EXMEM : in std_logic;
i_SB_IDEX : in std_logic;
i_SB_EXMEM : in std_logic;

--i_isNOP : in std_logic; --for IDEX
--i_isNOP2 : in std_logic; --for EXMEM

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
signal s_rd_nonzero2   : std_logic;
signal s_rs1_match    : std_logic;
signal s_rs2_match    : std_logic;
signal s_rs1_match2    : std_logic;
signal s_rs2_match2    : std_logic;
signal s_load_use_haz : std_logic;
signal s_reg_use_haz : std_logic;
signal s_haz : std_logic;
signal validrs2Hazard : std_logic;
signal s_rs2_matchNOTIMM    : std_logic;
signal s_rs2_match2NOTIMM    : std_logic;
signal validrdHazard1 : std_logic;
signal validrdHazard2 : std_logic; 

begin

	validrs2Hazard <= ((not i_HasImm) or (i_Store_IFID));-- or (i_IDEX_MemRead); --may cause issues, remove MemRead part if not necessary
	validrdHazard1 <= (not (i_Store_IDEX or i_SB_IDEX));
	validrdHazard2 <= (not (i_Store_EXMEM or i_SB_EXMEM));


	s_rd_nonzero <= '1' when (i_IDEX_RD /= "00000")  else '0';
	s_rd_nonzero2 <= '1' when (i_EXMEM_RD /= "00000") else '0';

	--Checks for read after write
	s_rs1_match  <= '1' when (i_IDEX_RD = i_IFID_RS1) and (validrdHazard1 = '1') else '0'; --for IDEX stage
	s_rs2_match  <= '1' when (i_IDEX_RD = i_IFID_RS2) and (validrdHazard1 = '1') else '0';
	s_rs1_match2  <= '1' when (i_EXMEM_RD = i_IFID_RS1) and (validrdHazard2 = '1') else '0'; --for EXMEM stage
	s_rs2_match2  <= '1' when (i_EXMEM_RD = i_IFID_RS2) and (validrdHazard2 = '1') else '0';

	s_rs2_matchNOTIMM <= s_rs2_match and validrs2Hazard;
	s_rs2_match2NOTIMM <= s_rs2_match2 and validrs2Hazard;
	
	

 	s_reg_use_haz <= '1' when 
	(s_rd_nonzero = '1' and
         (s_rs1_match = '1' or s_rs2_matchNOTIMM = '1'))
        else '0';

 	s_load_use_haz <= '1' when 
	(s_rd_nonzero2 = '1' and
         (s_rs1_match2 = '1' or s_rs2_match2NOTIMM = '1'))
        else '0';

	s_haz <= ((s_reg_use_haz or s_load_use_haz));-- and (not i_Store));

--PC write enables stall on hazard
o_PC_WEn <= '0' when s_haz = '1' else '1';

--IF/ID wrte enable stall on hazard	
o_IFID_WEn <= '0' when s_haz = '1' else '1';

--Bubble on hazard
o_IDEX_Flush <= '1' when (s_haz = '1') or (i_EX_BranchTaken = '1') else '0';

--Flush when Branch or jump is taken
o_IFID_Flush <= '1' when (i_EX_BranchTaken = '1') else '0';

end structure;

	


	
	
