# Arquitectura de Computadores - Practica 1

#### Desarrollada por Javier Delgado del Cerro y Javier López Cano

Como detalles de la implementación, mencionar que hemos eliminado *ALU Control*, de forma que es la *Unidad de Control*  la que determina la operación de la ALU.
Esto implica que el archivo `runsim.do` dado no funciona correctamente, por lo que tuvimos que editarlo eliminando la inclusión del archivo `alu_control.vhd`.

Entregamos por tanto los ficheros VHDL de la práctica junto con este archivo, para facilitar la simulación de ambos ejercicios.