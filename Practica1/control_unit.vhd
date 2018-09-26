--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2018
--
-- Grupo 1311
-- Javier Delgado del Cerro
-- Javier López Cano
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
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
end control_unit;

architecture rtl of control_unit is
  
  --TODO: PROBAR QUE NOP FUNCIONA BIEN.

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
   constant OP_ADDI   : t_opCode := "001000";
   constant OP_SLTI   : t_opCode := "001010";
   constant OP_J      : t_opCode := "000010";
   
   
   -- Codigos de control de la ALU:
   constant ALU_OR   : t_aluControl := "0111";   
   constant ALU_NOT  : t_aluControl := "0101";
   constant ALU_XOR  : t_aluControl := "0110";
   constant ALU_AND  : t_aluControl := "0100";
   constant ALU_SUB  : t_aluControl := "0001";
   constant ALU_ADD  : t_aluControl := "0000";
   constant ALU_SLT  : t_aluControl := "1010";
   constant ALU_S16  : t_aluControl := "1101";

begin

MemToReg <= '1' when OpCode = OP_LW else '0';
MemWrite <= '1' when OpCode = OP_SW else '0';

Branch <= '1' when OpCode = OP_BEQ else '0';

--TODO A lo mejor hay que quitar SW y LW, en la tabla de EC no están marcadas pero en la practica si
ALUSrc <= '1' when (OpCode = OP_LUI) or (OpCode = OP_ADDI) or (OpCode = OP_SLTI) or (OpCode = OP_LW) or (OpCode = OP_SW) else '0'; 
ALUControl <= ALU_OR when (OpCode = OP_RTYPE) and (Funct = "100101") else --OR
              ALU_XOR when (OpCode = OP_RTYPE) and (Funct = "100110") else --XOR
              ALU_AND when (OpCode = OP_RTYPE) and (Funct = "100100") else --AND
              ALU_SUB when (OpCode = OP_RTYPE) and (Funct = "100010") else --SUB
              ALU_ADD when (OpCode = OP_RTYPE) and (Funct = "100000") else --ADD
              ALU_ADD when (OpCode = OP_LW) or (OpCode = OP_SW) else --SW y SW
              ALU_SUB when (OpCode = OP_BEQ) else --BEQ
              ALU_ADD when (OpCode = OP_ADDI) else --ADDI
              ALU_SLT when (OpCode = OP_SLTI) else --SLTI
              ALU_S16 when (OpCode = OP_LUI) else --LUI
              "----";


RegDst <= '1' when OpCode = OP_RTYPE else '0';
RegWrite <= '1' when (OpCode = OP_RTYPE) or (OpCode = OP_LW) or (OpCode = OP_LUI) or (OpCode = OP_SLTI) or (OpCode = OP_ADDI) else '0';

Jump <= '1' when OpCode = OP_JUMP else '0';

end architecture;
