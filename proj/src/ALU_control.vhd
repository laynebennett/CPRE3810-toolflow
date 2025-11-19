

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_control is
    port (
        ALUOp    : in  std_logic_vector(1 downto 0);
        instruction    : in  std_logic_vector(3 downto 0); --instruction[30, 14-12]
	
	o_AltEn  : out std_logic; --enables shift and gates
	o_ShiftEn: out  std_logic; --selects between shift (1) or and/xor/or/nor gates (0)
	o_GateEn : out  std_logic_vector(1 downto 0); --00 = and, 01 = xor, 10 = or, 11 = nor
	o_BranchSel : out std_logic_vector(1 downto 0); --00 = BEQ, 01 = BGE, 10 = BLT, 11 = BNE 
	o_ShiftDir : out std_logic; --0 = left, 1 = right
	o_ShiftArith : out std_logic; 
        o_Sub  : out  std_logic -- 0 = add, 1 = sub
    );
end ALU_control;

architecture behavioral of ALU_control is

signal input : std_logic_vector(5 downto 0);

begin

input(5 downto 4) <= ALUOp(1 downto 0);
input(3 downto 0) <= instruction(3 downto 0);


----------------------------------------R TYPE---ALUOp = 10

-----------addsub

	process (input)
	begin
	--add
		if input = "100000" then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';
			
	--sub
		elsif input = "101000" then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '1';


-------------------gate

	--and
		elsif input = "100111" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';
	--xor
		elsif input = "100100" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "01";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--or
		elsif input = "100110" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "10";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--nor CUSTOM
		elsif input = "101111" then
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "11";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

----------------shift

	--sll
		elsif input = "100001" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--srl
		elsif input = "100101" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '1' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--sra
		elsif input = "101101" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '1' ;
			o_ShiftArith <= '1';
			o_Sub <= '0';

------------------------------B TYPE---ASSUME FUNCT7=0---ALUOp = 01 --EDIT SO 01X000

------------branch

	--beq
		elsif (ALUOp = "01" and instruction(2 downto 0) = "000") then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '1';

	--bge
		elsif (ALUOp = "01" and instruction(2 downto 0) = "101") then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "01";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '1';

	--blt
		elsif (ALUOp = "01" and instruction(2 downto 0) = "100") then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "10";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '1';

	--bne
		elsif (ALUOp = "01" and instruction(2 downto 0) = "001") then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "11";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '1';

------------------------------------ALUOp = 00

------------lw-sw




		elsif ALUOp = "00" then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

----------------------------------------I TYPE---ALUOp = 11

-----------addsub

	--addi
		elsif input = "110000" then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';
			
	--addi also
		elsif input = "111000" then
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';


-------------------gate

	--and
		elsif input = "110111" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';
	--xor
		elsif input = "110100" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "01";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--or
		elsif input = "110110" then --
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "10";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--nor CUSTOM
		elsif input = "111111" then
			o_AltEn <= '1';
			o_ShiftEn <= '0';
			o_GateEn <= "11";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

----------------shift

	--sll
		elsif input = "110001" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--srl
		elsif input = "110101" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '1' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';

	--sra
		elsif input = "111101" then
			o_AltEn <= '1';
			o_ShiftEn <= '1';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '1' ;
			o_ShiftArith <= '1';
			o_Sub <= '0';

		else
			o_AltEn <= '0';
			o_ShiftEn <= '0';
			o_GateEn <= "00";
			o_BranchSel <= "00";
			o_ShiftDir <= '0' ;
			o_ShiftArith <= '0';
			o_Sub <= '0';


		end if;

	end process;

end behavioral;