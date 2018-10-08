--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2018-19
--
-- Grupo 1311
-- Javier Delgado del Cerro
-- Javier López Cano
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 

--Signals
signal OpA, OpB, OpBExtSigno, Result, Rd1, Rd2, Wd3 : std_logic_vector (31 downto 0);
signal D, Addr, NextAddr, PCJump, PCBranchAux : std_logic_vector (31 downto 0);
signal OpCode, Funct : std_logic_vector (5 downto 0);
signal A1, A2, A3 : std_logic_vector(4 downto 0);
signal ALUControl : std_logic_vector (3 downto 0);
signal ZFlag, We3, Branch, MemToReg, MemWrite, MemRead, ALUSrc, RegWrite, RegDst, Jump : std_logic;

signal NextAddrID, IDataInID, NextAddrEX, OpBExtSignoEX, Rd2EX, Rd1EX, PCBranchEX, ResultMEM, PCBranchMEM, DDataOutMEM, DDataInWB, ResultWB : std_logic_vector (31 downto 0);
signal A31ID, A32ID, A31EX, A32EX, A3EX, A3MEM, A3WB : std_logic_vector(4 downto 0);
signal RegDstEX, ALUSrcEX, BranchEX, MemToRegEX, MemWriteEX, MemReadEX, RegWriteEX, ZFlagEX, PCSrcEX, PCSrcMEM, MemWriteMEM, MemReadMEM, MemToRegWB, MemToRegMEM, RegWriteMEM, RegWriteWB : std_logic;
signal ALUControlEX : std_logic_vector (3 downto 0);


component alu is
   port (
      OpA     : in  std_logic_vector (31 downto 0); -- Operando A
      OpB     : in  std_logic_vector (31 downto 0); -- Operando B
      Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
      Result  : out std_logic_vector (31 downto 0); -- Resultado
      ZFlag   : out std_logic                       -- Flag Z
   );
end component;

component reg_bank is
   port (
      Clk   : in std_logic; -- Reloj activo en flanco de subida
      Reset : in std_logic; -- Reset asíncrono a nivel alto
      A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
      Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
      A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
      Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
      A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
      Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
      We3   : in std_logic -- Habilitación de la escritura de Wd3
   ); 
end component;

component control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUControl  : out  std_logic_vector (3 downto 0); -- Control de la ALU, evitamos ALUControl
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd
      --Seniales para J:
      Jump : out std_logic -- 1=jump
   );
end component;

begin   
 

AluPM : alu port map(
   OpA => OpA,
   OpB => OpB,
   Control => ALUControlEX,
   Result => Result,
   ZFlag => ZFlag
);


reg_bankPM : reg_bank port map(
   Clk => Clk,
   We3 => We3,
   Reset => Reset,
   Wd3 => Wd3,
   A1 => A1,
   A2 => A2,
   A3 => A3,
   Rd1 => Rd1,
   Rd2 => Rd2
);

control_unitPM : control_unit port map(
   OpCode => OpCode,
   Funct => Funct,
   Branch => Branch,
   MemToReg => MemToReg,
   MemWrite => MemWrite,
   MemRead => MemRead,
   ALUSrc => ALUSrc,
   ALUControl => ALUControl,
   RegWrite => RegWrite,
   RegDst => RegDst,
   Jump => Jump
);


Registro_IFID: process(Clk, Reset)
begin
   if reset = '1' then
      NextAddrID <= (others => '0');
      IDataInID <= (others => '0');
   elsif rising_edge(Clk) then
      NextAddrID <= NextAddr;
      IDataInID <= IDataIn;
   end if;
end process;

Registro_IDEX: process(Clk, Reset)
begin
   if reset = '1' then
      A31EX <= (others => '0');
	  A32EX <= (others => '0');
	  Rd1EX <= (others => '0');
	  Rd2EX <= (others => '0');
	  NextAddrEX <= (others => '0');
	  OpBExtSignoEX <= (others => '0');
	  ALUSrcEX <= '0';
	  ALUControlEX <= (others => '0');
	  BranchEX <= '0';
	  MemToRegEX <= '0';
	  MemWriteEX <= '0';
	  MemReadEX <= '0';
	  RegWriteEX <='0';
	  RegDstEX <= '0';
	  ZFlagEX <= '0';

   elsif rising_edge(Clk) then
      A31EX <= A31ID;
	  A32EX <= A32ID;
	  Rd1EX <= Rd1;
	  Rd2EX <= Rd2;
	  NextAddrEX <= NextAddrID;
	  OpBExtSignoEX <= OpBExtSigno;
	  ALUSrcEX <= ALUSrc;
	  ALUControlEX <= ALUControl;
	  BranchEX <= Branch;
	  MemToRegEX <= MemToReg;
	  MemWriteEX <= MemWrite;
	  MemReadEX <= MemRead;
	  RegWriteEX <= RegWrite;
	  RegDstEX <= RegDst;
	  ZFlagEX <= ZFlag;

   end if;
end process;

Registro_EXMEM: process(Clk, Reset)
begin
   if reset = '1' then
      PCBranchMEM <= (others => '0');
      PCSrcMEM <= '0';
      DDataOutMEM <= (others => '0');
      ResultMEM <= (others => '0');
      MemWriteMEM <= '0';
      MemReadMEM <= '0';
      MemToRegMEM <= '0';
      RegWriteMEM <= '0';
      A3MEM <= (others => '0');
   elsif rising_edge(Clk) then
      PCBranchMEM <= PCBranchEX;
      PCSrcMEM <= PCSrcEX;
      DDataOutMEM <= Rd2EX;
      ResultMEM <= Result;
      MemWriteMEM <= MemWriteEX;
      MemReadMEM <= MemReadEX;
      MemToRegMEM <= MemToRegEX;
      RegWriteMEM <= RegWriteEX;
      A3MEM <= A3EX;
   end if;
end process;

Registro_MEMWB: process(Clk, Reset)
begin
   if reset = '1' then
      DDataInWB <= (others => '0');
      ResultWB <= (others => '0');
      A3WB <= (others => '0');
      MemToRegWB <= '0';
      RegWriteWB <= '0';
   elsif rising_edge(Clk) then
      DDataInWB <= DDataIn;
      ResultWB <= ResultMEM;
      A3WB <= A3MEM;
      MemToRegWB <= MemToRegMEM;
      RegWriteWB <= RegWriteMEM;
   end if;
end process;


-- Informacion de la instruccion
OpCode <= IDataInID(31 downto 26);
Funct <= IDataInID(5 downto 0);

-- Memoria de datos
DAddr <= ResultMEM;
DDataOut <= DDataOutMEM;
DWrEn <= MemWriteMEM;
DRdEn <= MemReadMEM;

--Memoria de instrucciones
IAddr <= Addr;

-- Banco de registros
A1 <= IDataInID(25 downto 21);
A2 <= IDataInID(20 downto 16);
A31ID <= IDataInID(20 downto 16);
A32ID <= IDataInID(15 downto 11);
A3EX <= A32EX when RegDstEX = '1' else A31EX;

A3 <= A3WB; --TODO CAMBIAR A REGISTRO WB
We3 <= RegWriteWB;
Wd3 <= ResultWB when MemToRegWB = '0' else DDataInWB; --TODO ACTUALIZAR CON Wd3WB

-- Extensor Signo para datos inmediatos en la ALU
OpBExtSigno(31 downto 16) <= (others =>  IDataInID(15));
OpBExtSigno(15 downto 0) <= IDataInID(15 downto 0);

-- Entradas de la ALU
OpA <= Rd1EX;
OpB <= Rd2EX when ALUSrcEX = '0' else OpBExtSignoEX;


-- Posibles PC y sus multiplexores
PCSrcEX <= ZFlagEX AND BranchEX;

NextAddr <= Addr + 4;

PCJump(31 downto 28) <= NextAddrID(31 downto 28);
PCJump(27 downto 0) <= IDataInID(25 downto 0) & "00";

PCBranchAux <= OpBExtSignoEX(29 downto 0) & "00";
PCBranchEX <= PCBranchAux + NextAddrEX;

D <= PCJump when Jump = '1' else
   PCBranchMEM when PCSrcMEM = '1' else
   NextAddr;

--Controlamos los ciclos de reloj, etc
-- Reset asíncrono activo a nivel alto y reloj en flanco de subida
process(Clk, Reset)
begin
   if Reset = '1' then 
      Addr <= x"00000000";
   elsif  rising_edge(Clk) then
      Addr <= D;
   end if;
end process;

end architecture;
