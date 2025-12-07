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

signal s_Branch :  std_logic;
signal s_MemRead :  std_logic;
signal s_MemtoReg :  std_logic;
signal s_ALUOp :  std_logic_vector(1 downto 0);
signal s_MemWrite :  std_logic;
signal s_ALUSrc :  std_logic;
signal s_RegWrite :  std_logic;	
signal s_regin : std_logic_vector(31 downto 0);
signal s_regout1 : std_logic_vector(31 downto 0);
signal s_regout2 : std_logic_vector(31 downto 0);
signal s_ext : std_logic_vector(31 downto 0);
--signal s_ALUOp    :  std_logic_vector(1 downto 0);
signal s_ALUinstruction    : std_logic_vector(3 downto 0); --instruction[30, 14-12]
	
signal s_AltEn  : std_logic; --enables shift and gates
signal s_ShiftEn: std_logic; --selects between shift (1) or and/xor/or/nor gates (0)
signal s_GateEn : std_logic_vector(1 downto 0); --00 = and, 01 = xor, 10 = or, 11 = nor
signal s_BranchSel : std_logic_vector(1 downto 0); --00 = BEQ, 01 = BGE, 10 = BLT, 11 = BNE 
signal s_ShiftDir : std_logic; --0 = left, 1 = right
signal s_ShiftArith : std_logic; 
signal s_Sub  :   std_logic; -- 0 = add, 1 = sub
signal s_LUI : std_logic;
signal s_UJ : std_logic;
signal s_SB : std_logic;
signal s_Store : std_logic;
signal s_Jump : std_logic;
signal s_jalr : std_logic;
signal s_unsign : std_logic;
signal s_Set : std_logic;
signal s_zero_extended : std_logic_vector(31 downto 0);
signal s_resizerstore : std_logic_vector(31 downto 0);
signal s_resizerload : std_logic_vector(31 downto 0);
signal s_lh : std_logic;
signal s_lb : std_logic;
signal s_HaltALMOST : std_logic; --because of ecall
signal s_LUImuxsel : std_logic;

signal s_add4 : std_logic_vector(31 downto 0);
signal s_PCAdd : std_logic;
signal s_ALUA : std_logic_vector(31 downto 0);
signal s_ALUout : std_logic_vector(31 downto 0);
signal s_ALUzero : std_logic;
signal s_memout : std_logic_vector(31 downto 0);
signal s_out : std_logic_vector(31 downto 0);
signal s_ALUorPCplus4 : std_logic_vector(31 downto 0);
signal s_ALUorSet : std_logic_vector(31 downto 0);
signal s_ALUorLUI : std_logic_vector(31 downto 0);
signal s_RSTInst : std_logic_vector(31 downto 0);
signal s_RSTDFFG : std_logic;

signal s_Instmux         : std_logic_vector(N-1 downto 0);

--IFID regouts
signal s_Inst_regout1 : std_logic_vector(31 downto 0);
signal s_FetchInstAddr4_regout1 : std_logic_vector(31 downto 0);
signal s_FetchInstAddr_regout1 : std_logic_vector(31 downto 0);

--IDEX regouts
signal s_Branch_regout2        : std_logic;
signal s_MemRead_regout2       : std_logic;
signal s_MemtoReg_regout2      : std_logic;
signal s_dummy		       : std_logic;
signal s_DMemWr_regout2        : std_logic;
signal s_ALUSrc_regout2        : std_logic;
signal s_RegWr_regout2         : std_logic;
signal s_LUI_regout2           : std_logic;
signal s_UJ_regout2            : std_logic;
signal s_PCAdd_regout2         : std_logic;
signal s_SB_regout2            : std_logic;
signal s_Store_regout2         : std_logic;
signal s_Jump_regout2          : std_logic;
signal s_jalr_regout2          : std_logic;
signal s_HaltALMOST_regout2    : std_logic;
signal s_unsign_regout2        : std_logic;
signal s_AltEn_regout2         : std_logic;
signal s_ShiftEn_regout2       : std_logic;
signal s_ShiftDir_regout2      : std_logic;
signal s_ShiftArith_regout2    : std_logic;
signal s_Sub_regout2           : std_logic;
signal s_Set_regout2           : std_logic;
signal s_lh_regout2            : std_logic;
signal s_lb_regout2            : std_logic;
signal s_ALUA_regout2          : std_logic_vector(31 downto 0);
signal s_regout2_regout2       : std_logic_vector(31 downto 0);
signal s_ext_regout2           : std_logic_vector(31 downto 0);
signal s_GateEn_regout2        : std_logic_vector(1 downto 0);
signal s_BranchSel_regout2     : std_logic_vector(1 downto 0);
signal s_FetchInstAddr4_regout2 : std_logic_vector(31 downto 0);
signal s_Inst_regout2 : std_logic_vector(31 downto 0);

signal s_dummyBIG : std_logic_vector(156 downto 0);

signal s_Inst_regout4 : std_logic_vector(31 downto 0);
signal s_temp_regout4 : std_logic_vector(31 downto 0);

signal s_Halt_in : std_logic;

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
	RegWrite : out std_logic;
	LUI : out std_logic;
	UJ : out std_logic;
	AUIPC : out std_logic;
	SB : out std_logic;
	Store : out std_logic;
	Jump : out std_logic;
	jalr : out std_logic;
	Halt : out std_logic
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
	i_in32	        : in std_logic_vector(31 downto 0);
	i_unsigned	: in std_logic; --1 for unsigned
	i_LUI		: in std_logic;
	i_UJ		: in std_logic;
	i_SB		: in std_logic;
	i_store		: in std_logic;
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
        o_Sub  : out  std_logic;-- 0 = add, 1 = sub
	o_Set : out std_logic;
	o_h	: out std_logic;
	o_b	: out std_logic); 
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
        i_regData    : in  std_logic_vector(31 downto 0);
	i_jalr : in std_logic;
	i_branch : in std_logic;
	i_jump : in std_logic;
	i_zero : in std_logic;
	i_rst : in std_logic;
	o_add4 : out std_logic_vector(31 downto 0);
	o_addr : out std_logic_vector(31 downto 0)
    	);
    end component;

	-----ALU


     component ALU
         generic(N : integer := 32);
         port (
         i_A    : in  std_logic_vector(N-1 downto 0);
         i_B    : in  std_logic_vector(N-1 downto 0);
	 i_imm  : in  std_logic_vector(N-1 downto 0);
	 ALUSrc : in  std_logic; --1 = use imm, 0 = use B
	 AltEn  : in std_logic; --enables shift and gates
	 ShiftEn: in  std_logic; --selects between shift (1) or and/xor/or/nor gates (0)
	 GateEn : in  std_logic_vector(1 downto 0); --00 = and, 01 = xor, 10 = or, 11 = nor
	 BranchSel : in std_logic_vector(1 downto 0); --00 = BEQ, 01 = BGE, 10 = BLT, 11 = BNE 
	 ShiftDir : in std_logic; --0 = left, 1 = right
	 ShiftArith : in std_logic; 
	 i_unsigned : in std_logic;
         i_Sub  : in  std_logic; -- 0 = add, 1 = sub
         o_ALU  : out std_logic_vector(N-1 downto 0);
         o_Cout : out std_logic;
	 o_zero : out std_logic;
	 o_Ovf : out std_logic
    	 );
	 end component;

	----Sign

	component sign
	port (
	i_instruction : in std_logic_vector(31 downto 0);
	i_load : in std_logic;
	i_ALUOp : in std_logic_vector(1 downto 0);
	i_branch : std_logic;
	o_unsign : out std_logic
	);
	end component;

	----Resizer

	component resizer
    	port 
    	(
        i_in32    : in std_logic_vector(31 downto 0);
        i_unsigned : in std_logic; -- 1 for unsigned
        i_h        : in std_logic; -- 1 for halfword
	i_b	    : in std_logic;
        i_en        : in std_logic; -- 0 for default
        o_out32    : out std_logic_vector(31 downto 0)
   	);
	end component;

	--REGS
	
	component IFID
        generic(N : integer := 96);--ADJUST THIS TO BE THE TOTAL SIZE
	port(
	i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
        o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output
	end component;

	component IDEX
        generic(N : integer := 188);--ADJUST THIS TO BE THE TOTAL SIZE
	port(
	i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
        o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output
	end component;

	component EXMEM
        generic(N : integer := 144);--ADJUST THIS TO BE THE TOTAL SIZE
	port(
	i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
        o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output
	end component;

	component MEMWB
        generic(N : integer := 112);--ADJUST THIS TO BE THE TOTAL SIZE
	port(
	i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D   : in std_logic_vector(N-1 downto 0);  -- n-bit data input
        o_Q   : out std_logic_vector(N-1 downto 0));  -- n-bit data output
	end component;

	component dffg
	port(i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D          : in std_logic;     -- Data value input
        o_Q          : out std_logic);   -- Data value output
	end component;
	

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


    fetch_i : fetch
    port map(
      i_CLK     => iCLK,
      i_addimm => s_ext_regout2,
      i_regData => s_ALUA_regout2,
      i_jalr => s_jalr_regout2,
      i_branch => s_Branch_regout2,
      i_jump => s_Jump_regout2,
      i_zero   => s_ALUzero,
      i_rst	=> iRST,
      o_add4	=> s_add4,
      o_addr     => s_NextInstAddr
    );


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Instmux);


     busmux_rst : busmux2to1
	port map(
	i_S => iRST,
	i_D0 => s_Instmux,
	i_D1 => x"00000000",
	o_Q => s_Inst);


  


--IF/ID

   


   IFID_i : IFID
	port map(
	i_CLK => iCLK,
	i_RST => iRST,--RST off for instruction addresses, need to fix lingering i_D = 0 issue in fetch reg PC
	i_WE => '1',
	i_D(31 downto 0) => s_Inst,
	i_D(63 downto 32) => s_add4,
	i_D(95 downto 64) => s_NextInstAddr,
	o_Q(31 downto 0) => s_Inst_regout1,
	o_Q(63 downto 32) => s_FetchInstAddr4_regout1,
	o_Q(95 downto 64) => s_FetchInstAddr_regout1
	);


    control_i : control
	port map(
	i_instruction => s_Inst_regout1(6 downto 0),
	Branch => s_Branch,
	MemRead => s_MemRead,
	MemtoReg => s_MemtoReg,
	ALUOp => s_ALUOp,
	MemWrite => s_DMemWr,
	ALUSrc => s_ALUSrc,
	RegWrite => s_RegWrite,
	LUI => s_LUI,
	UJ => s_UJ,
	AUIPC => s_PCAdd,
	SB => s_SB,
	Store => s_Store,
	Jump => s_Jump,
	jalr => s_jalr,
	Halt => s_HaltALMOST); 


    regfile_i : regfile
	port map(
	i_CLK => iCLK,
	i_WA => s_RegWrAddr,
        i_RA1 => s_Inst_regout1(19 downto 15),
        i_RA2 => s_Inst_regout1(24 downto 20),
        i_WE => s_RegWr_regout2,
        i_DATA => s_RegWrData,
        i_RST_ALL => iRST,
        o_Q1 => s_regout1,
        o_Q2 => s_regout2);

s_RegWrAddr <= s_Inst_regout2(11 downto 7); --IDK...maybe make this from last stage reg
s_RegWrData <= s_out; --maybe this too from last stage
s_RegWr <= s_RegWr_regout2;


     ALU_control_i : ALU_control
        port map(
        ALUOp => s_ALUOp,
        instruction(3) => s_Inst_regout1(30),
	instruction(2 downto 0) => s_Inst_regout1(14 downto 12),
	
	o_AltEn => s_AltEn,
	o_ShiftEn => s_ShiftEn,
	o_GateEn => s_GateEn,
	o_BranchSel => s_BranchSel,
	o_ShiftDir => s_ShiftDir,
	o_ShiftArith => s_ShiftArith,
        o_Sub => s_Sub,
	o_Set => s_Set,
	o_h => s_lh,
	o_b => s_lb);


    extender_i : extender
	port map(
	i_in32 => s_Inst_regout1,
	i_unsigned => s_unsign,
	i_LUI => s_LUI,
	i_UJ => s_UJ,
	i_SB => s_SB,
	i_store => s_Store,
	o_out32 => s_ext);	


    sign_i : sign
	port map(
	i_instruction => s_Inst_regout1,
	i_load => s_MemtoReg,
	i_ALUOp => s_ALUOp,
	i_branch => s_SB,
	o_unsign => s_unsign);


     busmux_pcadd : busmux2to1
	port map(
	i_S => s_PCAdd,
	i_D0 => s_regout1,
	i_D1 => s_FetchInstAddr4_regout1,
	o_Q => s_resizerstore);


     storeresizer : resizer
    	port map(
        i_in32 => s_resizerstore,
        i_unsigned => s_unsign,
        i_h => s_lh,
	i_b => s_lb,
        i_en => s_Store,
        o_out32 => s_ALUA);


--ID/EX

   IDEX_i : IDEX
	port map(
	i_CLK => iCLK,
	i_RST => iRST,--RST off for instruction addresses, need to fix lingering i_D = 0 issue in fetch reg PC
	i_WE => '1',
	--i_D => (others => '0'),
	i_D(0) => s_Branch,
	i_D(1) => s_MemRead,
	i_D(2) => s_MemtoReg,
	i_D(3) => s_DMemWr,
	i_D(4) => s_ALUSrc,
	i_D(5) => s_RegWrite,
	i_D(6) => s_LUI,
	i_D(7) => s_UJ,
	i_D(8) => s_PCAdd,
	i_D(9) => s_SB,
	i_D(10) => s_Store,
	i_D(11) => s_Jump,
	i_D(12) => s_jalr,
	i_D(13) => s_HaltALMOST,
	i_D(14) => '0',
	i_D(46 downto 15) => s_ALUA,
	i_D(78 downto 47) => s_regout2,
	i_D(110 downto 79) => s_ext,
	i_D(111) => s_unsign,
	i_D(112) => s_AltEn,
	i_D(113) => s_ShiftEn,
	i_D(115 downto 114) => s_GateEn,
	i_D(117 downto 116) => s_BranchSel,
	i_D(118) => s_ShiftDir,
	i_D(119) => s_ShiftArith,
	i_D(120) => s_Sub,
	i_D(121) => s_Set,
	i_D(122) => s_lh,
	i_D(123) => s_lb,
	i_D(155 downto 124) => s_FetchInstAddr4_regout1,
	i_D(187 downto 156) => s_Inst_regout1,
	o_Q(0) => s_Branch_regout2,
	o_Q(1) => s_MemRead_regout2,
	o_Q(2) => s_MemtoReg_regout2,
	o_Q(3) => s_DMemWr_regout2,
	o_Q(4) => s_ALUSrc_regout2,
	o_Q(5) => s_RegWr_regout2,
	o_Q(6) => s_LUI_regout2,
	o_Q(7) => s_UJ_regout2,
	o_Q(8) => s_PCAdd_regout2,
	o_Q(9) => s_SB_regout2,
	o_Q(10) => s_Store_regout2,
	o_Q(11) => s_Jump_regout2,
	o_Q(12) => s_jalr_regout2,
	o_Q(13) => s_HaltALMOST_regout2,
	o_Q(14) => s_dummy,
	o_Q(46 downto 15) => s_ALUA_regout2,
	o_Q(78 downto 47) => s_regout2_regout2,
	o_Q(110 downto 79) => s_ext_regout2,
	o_Q(111) => s_unsign_regout2,
	o_Q(112) => s_AltEn_regout2,
	o_Q(113) => s_ShiftEn_regout2,
	o_Q(115 downto 114) => s_GateEn_regout2,
	o_Q(117 downto 116) => s_BranchSel_regout2,
	o_Q(118) => s_ShiftDir_regout2,
	o_Q(119) => s_ShiftArith_regout2,
	o_Q(120) => s_Sub_regout2,
	o_Q(121) => s_Set_regout2,
	o_Q(122) => s_lh_regout2,
	o_Q(123) => s_lb_regout2,
	o_Q(155 downto 124) => s_FetchInstAddr4_regout2,
	o_Q(187 downto 156) => s_Inst_regout2
	);


    ALU_i : ALU
	port map(
	i_A => s_ALUA_regout2,
        i_B => s_regout2_regout2,
	i_imm => s_ext_regout2,
	ALUSrc => s_ALUSrc_regout2,
	AltEn => s_AltEn_regout2,
	ShiftEn => s_ShiftEn_regout2,
	GateEn => s_GateEn_regout2,
	BranchSel => s_BranchSel_regout2,
	ShiftDir => s_ShiftDir_regout2,
	ShiftArith => s_ShiftArith_regout2,
	i_unsigned => s_unsign_regout2,
        i_Sub  => s_Sub_regout2,
        o_ALU  => s_ALUout,
        o_Cout => open,
	o_Ovf => open,
	o_zero => s_ALUzero);


     busmux_set : busmux2to1
	port map(
	i_S => s_Set_regout2,
	i_D0 => s_ALUout,
	i_D1 => s_zero_extended,
	o_Q => s_ALUorSet);


     busmux_regdata : busmux2to1
	port map(
	i_S => s_Jump_regout2,
	i_D0 => s_ALUorSet,
	i_D1 => s_FetchInstAddr4_regout2,
	o_Q => s_ALUorPCplus4);


--EX/MEM

  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);


--MEM/WB


   --MEMWB_i : MEMWB --TESTING, NEED TO CHANGE LATER
	--port map(
	--i_CLK => iCLK,
	--i_RST => iRST,
	--i_WE => '1',
	--i_D(31 downto 0) => open,
	--i_D(63 downto 32) => open,
	--o_Q(31 downto 0) => open,
	--o_Q(63 downto 32) => open
	--);


    busmux_MemtoReg : busmux2to1
	port map(
	i_S => s_MemtoReg,
	i_D0 => s_ALUorPCplus4,
	i_D1 => s_DMemOut,
	o_Q => s_resizerload);


     loadresizer : resizer
    	port map(
        i_in32 => s_resizerload,
        i_unsigned => s_unsign,
        i_h => s_lh,
	i_b => s_lb,
        i_en => s_MemtoReg,
        o_out32 => s_ALUorLUI);


     busmux_ALUorLUI : busmux2to1
	port map(
	i_S => s_LUImuxsel,
	i_D0 => s_ALUorLUI,
	i_D1 => s_ext,
	o_Q => s_out);





s_DMemAddr <= s_ALUout;
s_DMemData <= s_regout2;
oALUOut <= s_ALUout;

s_Ovfl <= '0';
s_zero_extended <= x"0000000" & "000" & s_ALUzero;
s_Halt_in <= s_HaltALMOST_regout2 and s_Inst_regout2(20); --MAKE THIS THE HALT FROM THE LAST STAGE

    halt_dffg: dffg
	port map(
	i_CLK => iCLK,
        i_RST => iRST,
        i_WE => '1',
        i_D => s_Halt_in,
        o_Q => s_Halt);

s_LUImuxsel <= s_LUI and (not s_PCAdd);

end structure;

