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
signal D, Addr, NextAddr, PCJump, PCBranch, PCBranchAux : std_logic_vector (31 downto 0);
signal OpCode, Funct : std_logic_vector (5 downto 0);
signal A1, A2, A3 : std_logic_vector(4 downto 0);
signal ALUControl : std_logic_vector (3 downto 0);
signal ZFlag, We3, Branch, MemToReg, MemWrite, MemRead, ALUSrc, RegWrite, RegDst, Jump, PCSrc : std_logic;

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
   Control => ALUControl,
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


-- Informacion de la instruccion
OpCode <= IDataIn(31 downto 26);
Funct <= IDataIn(5 downto 0);

-- Memoria de datos
DAddr <= Result;
DDataOut <= Rd2;
DWrEn <= MemWrite;
DRdEn <= MemRead;

--Memoria de instrucciones
IAddr <= Addr;

-- Banco de registros
A1 <= IDataIn(25 downto 21);
A2 <= IDataIn(20 downto 16);
A3 <= IDataIn(20 downto 16) when RegDst = '0' else IDataIn(15 downto 11);
We3 <= RegWrite;
Wd3 <= Result when MemToReg = '0' else DDataIn;

-- Extensor Signo para datos inmediatos en la ALU
OpBExtSigno(31 downto 16) <= (others =>  IDataIn(15));
OpBExtSigno(15 downto 0) <= IDataIn(15 downto 0);

-- Entradas de la ALU
OpA <= Rd1;
OpB <= Rd2 when ALUSrc = '0' else OpBExtSigno;


-- Posibles PC y sus multiplexores
PCSrc <= ZFlag AND Branch;

NextAddr <= Addr + 4;

PCJump(31 downto 28) <= NextAddr(31 downto 28);
PCJump(27 downto 0) <= IDataIn(25 downto 0) & "00";

PCBranchAux <= OpBExtSigno(29 downto 0) & "00";
PCBranch <= PCBranchAux + NextAddr;

D <= PCJump when Jump = '1' else
   PCBranch when PCSrc = '1' else
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
