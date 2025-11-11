-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

	-----CONTROL

    component control
	port(
	i_instruction : in std_logic_vector(6 downto 0);
	Branch : out std_logic;
	MemRead : out std_logic;
	MemtoReg : out std_logic;
	ALUOp : out std_logic_vector(1 downto 0);
	MemWrite : out std_logic;
	ALUSrc : out std_logic;
	RegWrite : out std_logic	
	);
    end component;


	-----REGISTER FILE

    component regfile
      port(i_CLK        : in std_logic;     -- Clock input
       i_WA        : in std_logic_vector(4 downto 0);     -- 5 bit Write Address input
       i_RA1        : in std_logic_vector(4 downto 0);     -- 5 bit Read Address input
       i_RA2        : in std_logic_vector(4 downto 0);     -- 5 bit Read Address input
       i_WE         : in std_logic;     -- Write enable input
       i_DATA   : in std_logic_vector(N-1 downto 0);  -- n-bit data input (32 bit)
       i_RST_ALL : in std_logic; --Clear all registers
       o_Q1   : out std_logic_vector(N-1 downto 0);  -- n-bit data output
       o_Q2   : out std_logic_vector(N-1 downto 0));  -- n-bit data output
    end component;


	-----EXTENDER

    component extender
	port (
	i_in12	        : in std_logic_vector(11 downto 0);
	i_unsigned	: in std_logic; --1 for unsigned
	o_out32		: out std_logic_vector((31) downto 0));
    end component;

	-----ALU_control

    component ALU_control
        port (
        ALUOp    : in  std_logic_vector(1 downto 0);
        instruction    : in  std_logic_vector(3 downto 0); --instruction[30, 14-12]
	
	o_AltEn  : out std_logic; --enables shift and gates
	o_ShiftEn: out  std_logic; --selects between shift (1) or and/xor/or/nor gates (0)
	o_GateEn : out  std_logic_vector(1 downto 0); --00 = and, 01 = xor, 10 = or, 11 = nor
	o_BranchSel : out std_logic_vector(1 downto 0); --00 = BEQ, 01 = BGE, 10 = BLT, 11 = BNE 
	o_ShiftDir : out std_logic; --0 = left, 1 = right
	o_ShiftArith : out std_logic; 
        o_Sub  : out  std_logic); -- 0 = add, 1 = sub
    end component;	

	-----busmux2to1

    component busmux2to1
	port(i_S : in std_logic;
	     i_D0 : in std_logic_vector(31 downto 0);
	     i_D1 : in std_logic_vector(31 downto 0);
	     o_Q : out std_logic_vector(31 downto 0));
    end component;

	-----FETCH

    component fetch
	port (
	i_CLK : in std_logic;
        i_addimm    : in  std_logic_vector(31 downto 0);
	i_branch : in std_logic;
	i_zero : in std_logic;
	o_instruction : out std_logic_vector(31 downto 0));
    end component;


begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

    fetch_i : fetch
	port map(
	i_CLK => i_CLK,
        i_addimm => s_ext,
	i_branch => s_Branch,
	i_zero => s_ALUzero,
	o_instruction => s_instruction);


    regfile_i : regfile
	port map(
	i_CLK => i_CLK,
	i_WA => s_Inst(11 downto 7),
        i_RA1 => s_Inst(19 downto 15),
        i_RA2 => s_Inst(24 downto 20),
        i_WE => s_RegWr,
        i_DATA => s_RegWrData,
        i_RST_ALL => i_RST_ALL,
        o_Q1 => s_regout1,
        o_Q2 => s_regout2);
	
    ALU_i : ALU
	port map(
	i_A => s_regout1,
        i_B => s_regout2,
	i_imm => s_ext,
	ALUSrc => s_ALUSrc,
	AltEn => s_AltEn,
	ShiftEn => s_ShiftEn,
	GateEn => s_GateEn,
	BranchSel => s_BranchSel,
	ShiftDir => s_ShiftDir,
	ShiftArith => s_ShiftArith,
        i_Sub  => s_Sub,
        o_ALU  => s_ALUout,
        o_Cout => open,
	o_zero => s_ALUzero);

    extender_i : extender
	port map(
	i_in12 => s_instruction(31 downto 20),--TODO
	i_unsigned => '1',--TODO
	o_out32 => s_ext);	

    busmux_i : busmux2to1
	port map(
	i_S => s_MemtoReg,
	i_D0 => s_memout,
	i_D1 => s_ALUout,
	o_Q => s_out);

    control_i : control
	port map(
	i_instruction => s_instruction(6 downto 0),
	Branch => s_Branch,
	MemRead => s_MemRead,
	MemtoReg => s_MemtoReg,
	ALUOp => s_ALUOp,
	MemWrite => s_MemWrite,
	ALUSrc => s_ALUSrc,
	RegWrite => s_RegWrite); 

end structure;

