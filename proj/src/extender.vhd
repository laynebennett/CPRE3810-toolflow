
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity extender is

	generic(N : integer := 12);

	port 
	(
		i_in32	        : in std_logic_vector(31 downto 0);
		i_unsigned	: in std_logic; --1 for unsigned
		i_LUI		: in std_logic; --1 for LUI
		i_SB		: in std_logic; --1 for SB
		o_out32		: out std_logic_vector(31 downto 0)
	);

end extender;

architecture structure of extender is

    signal muxtoadd : std_logic_vector(31 downto 0);
    signal s_sign   : std_logic;
    signal upper    : std_logic_vector(18 downto 0);
    signal s_in13   : std_logic_vector(12 downto 0);
    signal s_opcode : std_logic_vector(6 downto 0);
    signal s_LUI    : std_logic_vector(31 downto 0);

    component busmux2to1    
      port(
        i_S  : in std_logic;
        i_D0 : in std_logic_vector(31 downto 0);
        i_D1 : in std_logic_vector(31 downto 0);
        o_Q  : out std_logic_vector(31 downto 0)
      );
    end component;

begin

    --s_in13 <= i_in32(31 downto 20);
    s_sign <= s_in13(12);
    s_opcode <= i_in32(6 downto 0);

    -- Pick sign bits for signed case
    busmux2to1_i : busmux2to1
      port map(
        i_S  => s_sign,
        i_D0 => x"00000000",
        i_D1 => x"FFFFFFFF",
        o_Q  => muxtoadd
      );

    -- 
    s_in13 <= (i_in32(31)&i_in32(31 downto 20)) when (i_SB = '0') else (i_in32(31)&i_in32(7)&i_in32(30 downto 25)&i_in32(11 downto 8)&'0');
    --s_in12 <= (i_in32(31 downto 20)) when (i_SB = '0') else (i_in32(7)&i_in32(30 downto 25)&i_in32(11 downto 8)&'0');
   
    -- Choose between signed and unsigned upper bits
    upper <= (others => '0') when (i_unsigned = '1') else muxtoadd(18 downto 0);

    -- SET LUI 
    s_LUI <= std_logic_vector(signed(i_in32(31 downto 12) & x"000")); 

    -- Combine high and low halves
    o_out32 <= (upper & s_in13) when (i_LUI = '0') else s_LUI;

end structure;
