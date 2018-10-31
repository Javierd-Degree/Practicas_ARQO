# Arquitectura de Computadores - Practica 2

#### Desarrollada por Javier Delgado del Cerro y Javier López Cano

Como en nuestra práctica anterior eliminamos *ALU Control*, de forma que es la *Unidad de Control*  la que determina la operación de la ALU, incluimos el archivo `runsim.do`,  en el que hemos eliminadola inclusión del archivo `alu_control.vhd`.

Comentar también en el caso del ejercicio uno, que hemos creado las señales de la unidad de detección de adelantamientos y de riesgos dentro de la arquitectura de *Processor*, como se indicaba en el enunciado, y a la hora de hacer el adelantamiento en el banco de registros, hemos optado por usar la escritura en flanco de bajada, pues de esta forma, al ser la lectura asíncrona, durante el flanco de bajada escribimos en el registro, y es en el siguiente flanco de subida cuando lo leeremos para guardarlo en el registro ID/EX, de forma que ya estará actualizado.

En el programa de prueba del ejercicio dos, hemos probado todas las combinaciones posibles que podrían producir fallos en el branch para comprobar que funciona correctamente.

Entregamos por tanto los ficheros VHDL de la práctica junto el fichero `programa.asm` del ejercicio dos, y el archivo `runsim.do`modificado, para facilitar la simulación de ambos ejercicios.

