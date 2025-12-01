library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity resizer is
    port 
    (
        i_in32    : in std_logic_vector(31 downto 0);
        i_unsigned : in std_logic; -- 1 for unsigned
        i_h        : in std_logic; -- 1 for halfword
        i_b        : in std_logic; -- 1 for byte
	i_en	   : in std_logic; -- 1 to enable h/b
        o_out32    : out std_logic_vector(31 downto 0)
    );
end resizer;

architecture structure of resizer is

    component busmux2to1    
        port(
            i_S  : in std_logic;
            i_D0 : in std_logic_vector(31 downto 0);
            i_D1 : in std_logic_vector(31 downto 0);
            o_Q  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal s_halfword : std_logic_vector(31 downto 0);
    signal s_byte     : std_logic_vector(31 downto 0);
    signal s_default  : std_logic_vector(31 downto 0);
    signal s_out32    : std_logic_vector(31 downto 0);
    signal s_out32_1    : std_logic_vector(31 downto 0);
    signal s_out32_2    : std_logic_vector(31 downto 0);

begin

    -- Halfword resizing: extract the lower 16 bits and extend
    process(i_in32, i_unsigned)
    begin
        if i_unsigned = '1' then
            s_halfword <= std_logic_vector(resize(unsigned(i_in32(15 downto 0)), 32));
        else
            s_halfword <= std_logic_vector(resize(signed(i_in32(15 downto 0)), 32));
        end if;
    end process;

    -- Byte resizing: extract the lower 8 bits and extend
    process(i_in32, i_unsigned)
    begin
        if i_unsigned = '1' then
            s_byte <= std_logic_vector(resize(unsigned(i_in32(7 downto 0)), 32));
        else
            s_byte <= std_logic_vector(resize(signed(i_in32(7 downto 0)), 32));
        end if;
    end process;

    -- Default case: no resizing, just pass the input
    s_default <= i_in32;

    -- Select between halfword, byte, and default using the busmux2to1
    mux_h : busmux2to1
        port map (
            i_S => i_h,
            i_D0 => s_default,
            i_D1 => s_halfword,   
            o_Q => s_out32
        );

    mux_b : busmux2to1
        port map (
            i_S => i_b,
            i_D0 => s_out32,  
            i_D1 => s_byte,   
            o_Q => s_out32_1
        );

    mux_final : busmux2to1
        port map (
            i_S => i_en,
            i_D0 => s_default,      
            i_D1 => s_out32_1,     
            o_Q => s_out32_2
        );

o_out32 <= s_out32_2;


end structure;
