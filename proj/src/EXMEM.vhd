
library IEEE;
use IEEE.std_logic_1164.all;

entity EXMEM is

  generic(N : integer := 178);--ADJUST THIS TO BE THE TOTAL SIZE

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
       o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output

end EXMEM;

architecture structure of EXMEM is

    component dffg
      port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
    end component;

begin

	--MAKE THIS SEGMENTED TO BE THE REQUIRED SIZE FOR THE REGISTER
	--NEEDS TO BE CHANGED FROM DEFAULT


	Branch_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(0),     -- Data value input
                   o_Q => o_Q(0));   -- Data value output


	MemRead_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(1),     -- Data value input
                   o_Q => o_Q(1));   -- Data value output


	MemtoReg_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(2),     -- Data value input
                   o_Q => o_Q(2));   -- Data value output

	--No ALUOp necessary

	MemWrite_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(3),     -- Data value input
                   o_Q => o_Q(3));   -- Data value output


	ALUSrc_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(4),     -- Data value input
                   o_Q => o_Q(4));   -- Data value output


	RegWrite_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(5),     -- Data value input
                   o_Q => o_Q(5));   -- Data value output


	LUI_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(6),     -- Data value input
                   o_Q => o_Q(6));   -- Data value output


	UJ_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(7),     -- Data value input
                   o_Q => o_Q(7));   -- Data value output


	AUIPC_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(8),     -- Data value input
                   o_Q => o_Q(8));   -- Data value output


	SB_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(9),     -- Data value input
                   o_Q => o_Q(9));   -- Data value output


	Store_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(10),     -- Data value input
                   o_Q => o_Q(10));   -- Data value output


	Jump_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(11),     -- Data value input
                   o_Q => o_Q(11));   -- Data value output


	jalr_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(12),     -- Data value input
                   o_Q => o_Q(12));   -- Data value output


	Halt_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(13),     -- Data value input
                   o_Q => o_Q(13));   -- Data value output


	fetchInstAdd_dffg : dffg --IGNORE
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(14),     -- Data value input
                   o_Q => o_Q(14));   -- Data value output


    regdata_dffgs : for i in 15 to 46 generate
	rd_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate regdata_dffgs;


    set_dffgs : for i in 47 to 78 generate
	s_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate set_dffgs;


    ALUB_dffgs : for i in 79 to 110 generate
	B_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate ALUB_dffgs;


    ext_dffgs : for i in 111 to 142 generate
	e_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate ext_dffgs;


	sign_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(143),     -- Data value input
                   o_Q => o_Q(143));   -- Data value output


    inst_dffgs : for i in 144 to 175 generate
	inst_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate inst_dffgs;


	lh_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(176),     -- Data value input
                   o_Q => o_Q(176));   -- Data value output


	lb_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(177),     -- Data value input
                   o_Q => o_Q(177));   -- Data value output



end structure;
