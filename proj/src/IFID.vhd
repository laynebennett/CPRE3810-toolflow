
library IEEE;
use IEEE.std_logic_1164.all;

entity IFID is

  generic(N : integer := 96);--ADJUST THIS TO BE THE TOTAL SIZE

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_Flush : in std_logic;
       i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
       o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output

end IFID;

architecture structure of IFID is

    component dffg
      port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
    end component;
    signal s_D : std_logic_vector(N-1 downto 0);

begin
     -- If flushing, drive zeros into the register (NOP); else pass through i_D
     s_D <= (others => '0') when i_Flush = '1' else i_D;

	--MAKE THIS SEGMENTED TO BE THE REQUIRED SIZE FOR THE REGISTER
    instruction_dffgs : for i in 0 to 31 generate
	i_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => s_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate instruction_dffgs;


	fetchInstAddPlus4_dffgs : for i in 32 to 63 generate
	i_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => '0',     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
	end generate fetchInstAddPlus4_dffgs;


	fetchInstAdd_dffgs : for i in 64 to 95 generate
	i_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => '0',     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
	end generate fetchInstAdd_dffgs;



end structure;
