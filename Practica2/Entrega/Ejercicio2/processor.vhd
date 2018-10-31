--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline y unidades de detección de riesgos
-- y errores y soluciones a los fallos del branch. 
-- Curso Arquitectura 2018-19
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
signal A1, A2, A3, A1EX, A2EX : std_logic_vector(4 downto 0);
signal ALUControl : std_logic_vector (3 downto 0);
signal ZFlag, We3, Branch, MemToReg, MemWrite, MemRead, ALUSrc, RegWrite, RegDst, Jump : std_logic;

signal NextAddrID, IDataInID, NextAddrEX, OpBExtSignoEX, Rd2EX, Rd1EX, PCBranchEX, ResultMEM, PCBranchMEM, DDataOutMEM, DDataInWB, ResultWB : std_logic_vector (31 downto 0);
signal A31ID, A32ID, A31EX, A32EX, A3EX, A3MEM, A3WB : std_logic_vector(4 downto 0);
signal RegDstEX, ALUSrcEX, BranchEX, MemToRegEX, MemWriteEX, MemReadEX, RegWriteEX, PCSrcEX, PCSrcMEM, MemWriteMEM, MemReadMEM, MemToRegWB, MemToRegMEM, RegWriteMEM, RegWriteWB : std_logic;
signal PCWrite, IDWrite, Hazard, HazardLW, HazardBranch, HazardBranchLW : std_logic;
signal ALUControlEX : std_logic_vector (3 downto 0);

signal ForwardA, ForwardB : std_logic_vector (1 downto 0);


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
   elsif rising_edge(Clk) and (IDWrite = '1') then
      NextAddrID <= NextAddr;
      if PCSrcMEM = '1' then
        IDataInID <= (others => '0');
      else
        IDataInID <= IDataIn;
      end if;
   end if;
end process;

Registro_IDEX: process(Clk, Reset)
begin
   if reset = '1' then
      A31EX <= (others => '0');
	  A32EX <= (others => '0');
	  A1EX <= (others => '0');
	  A2EX <= (others => '0');
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

   elsif rising_edge(Clk) then
     A31EX <= A31ID;
	  A32EX <= A32ID;
	  A1EX <= A1;
	  A2EX <= A2;
	  Rd1EX <= Rd1;
	  Rd2EX <= Rd2;
	  NextAddrEX <= NextAddrID;
	  OpBExtSignoEX <= OpBExtSigno;
	  
	  if Hazard = '1' or PCSrcMEM = '1' then
		  ALUSrcEX <= '0';
		  ALUControlEX <= (others => '0');
		  BranchEX <= '0';
		  MemToRegEX <= '0';
		  MemWriteEX <= '0';
		  MemReadEX <= '0';
		  RegWriteEX <='0';
		  RegDstEX <= '0';
	   else
		  ALUSrcEX <= ALUSrc;
		  ALUControlEX <= ALUControl;
		  BranchEX <= Branch;
		  MemToRegEX <= MemToReg;
		  MemWriteEX <= MemWrite;
		  MemReadEX <= MemRead;
		  RegWriteEX <= RegWrite;
		  RegDstEX <= RegDst;
		end if;

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
      DDataOutMEM <= Rd2EX;
      ResultMEM <= Result;
      A3MEM <= A3EX;
      if PCSrcMEM = '1' then
        PCSrcMEM <= '0';
        MemWriteMEM <= MemWriteEX;
        MemReadMEM <= MemReadEX;
        MemToRegMEM <= MemToRegEX;
        RegWriteMEM <= RegWriteEX;
      else
        PCSrcMEM <= PCSrcEX;
        MemWriteMEM <= MemWriteEX;
        MemReadMEM <= MemReadEX;
        MemToRegMEM <= MemToRegEX;
        RegWriteMEM <= RegWriteEX;

      end if;
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

A3 <= A3WB; 
We3 <= RegWriteWB;
Wd3 <= ResultWB when MemToRegWB = '0' else DDataInWB;

-- Extensor Signo para datos inmediatos en la ALU
OpBExtSigno(31 downto 16) <= (others =>  IDataInID(15));
OpBExtSigno(15 downto 0) <= IDataInID(15 downto 0);

-- Entradas de la ALU
OpA <= Rd1EX when ForwardA = "00" else Wd3 when ForwardA = "01" else ResultMEM;
OpB <= OpBExtSignoEX when ALUSrcEX = '1' else Rd2EX when ForwardB = "00" else Wd3 when ForwardB = "01" else ResultMEM;


-- Posibles PC y sus multiplexores
PCSrcEX <= ZFlag AND BranchEX;

NextAddr <= Addr + 4;

PCJump(31 downto 28) <= NextAddrID(31 downto 28);
PCJump(27 downto 0) <= IDataInID(25 downto 0) & "00";

PCBranchAux <= OpBExtSignoEX(29 downto 0) & "00";
PCBranchEX <= PCBranchAux + NextAddrEX;

D <= PCJump when Jump = '1' else
   PCBranchMEM when PCSrcMEM = '1' else
   NextAddr;
   
   
-- Unidad de adelantamiento
ForwardA <= "10" when ((RegWriteMEM = '1') and (A3MEM /= "00000") and (A3MEM = A1EX)) else
			"01" when ((RegWriteWB = '1') and (A3WB /= "00000") and (A3WB = A1EX) and not ((RegWriteMEM = '1') and (A3MEM /= "00000") and (A3MEM = A1EX))) else
			"00";
				
ForwardB <= "10" when ((RegWriteMEM = '1') and (A3MEM /= "00000") and (A3MEM = A2EX)) else
			"01" when ((RegWriteWB = '1') and (A3WB /= "00000") and (A3WB = A2EX) and not ((RegWriteMEM = '1') and (A3MEM /= "00000") and (A3MEM = A2EX))) else
			"00";

-- Unidad de deteccion de riesgos
 HazardLW <= '1' when (MemReadEX = '1') and ((A3EX = A1) or (A3EX = A2)) else '0';
 HazardBranchLW <='1' when (branch = '1') and ( (MemReadEX = '1' and ((A3EX = A1) or (A3EX = A2))) or (MemReadMEM = '1' and ((A3MEM = A1) or (A3MEM = A2))) ) else '0';
 HazardBranch <='1' when (branch = '1') and (RegWriteEX = '1' and ((A3EX = A1) or (A3EX = A2))) else '0';
 
 Hazard <= HazardLW or HazardBranch or HazardBranchLW;
 PCWrite <= '0' when Hazard = '1' else '1';
 IDWrite <= '0' when Hazard = '1' else '1';
			
--Controlamos los ciclos de reloj, etc
-- Reset asíncrono activo a nivel alto y reloj en flanco de subida
process(Clk, Reset)
begin
   if Reset = '1' then 
      Addr <= x"00000000";
   elsif  rising_edge(Clk) and (PCWrite = '1') then
      Addr <= D;
   end if;
end process;

end architecture;
