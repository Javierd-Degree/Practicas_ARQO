#!/bin/bash

# Inicializar variables
Npaso=1000
Nveces=5
Ninicio=1000
Nfinal=5000


echo "Running serie..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	echo "N: $N / $Nfinal..."

	./matrix_mult $N

done

echo "Running paralelo bucle 1..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	for((j=1 ; j<=4 ; j++)); do

		echo "N: $N / $Nfinal..."

		./matrix_mult_1 $N $j

	done

done

echo "Running paralelo bucle 2..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	for((j=1 ; j<=4 ; j++)); do

		echo "N: $N / $Nfinal..."

		./matrix_mult_2 $N $j

	done

done

echo "Running paralelo bucle 3..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	for((j=1 ; j<=4 ; j++)); do

		echo "N: $N / $Nfinal..."

		./matrix_mult_3 $N $j

	done

done
