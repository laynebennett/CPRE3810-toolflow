

library IEEE;
use IEEE.std_logic_1164.all;

entity PCreg is

  generic(N : integer := 32);

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
       o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output

end PCreg;

architecture structure of PCreg is

    component dffg
      port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
    end component;

    component special_dffg
      port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
    end component;

begin

    g_dffgs : for i in 0 to 21 generate
	i_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate g_dffgs;

    special_dffg_i : special_dffg
	port map(i_CLK => i_CLK,     -- Clock input
     		 i_RST => i_RST,     -- Reset input
  	         i_WE => i_WE,     -- Write enable input
                 i_D => i_D(22),     -- Data value input
                 o_Q => o_Q(22));   -- Data value output

    g_dffgs2 : for i in 23 to N-1 generate
	i_dffg : dffg
	  port map(i_CLK => i_CLK,     -- Clock input
     		   i_RST => i_RST,     -- Reset input
  	           i_WE => i_WE,     -- Write enable input
                   i_D => i_D(i),     -- Data value input
                   o_Q => o_Q(i));   -- Data value output
    end generate g_dffgs2;


end structure;