#!/bin/bash

# Inicializar variables
Npaso=4000000
Nveces=5
Ninicio=10000000
Nfinal=50000000


echo "Running serie..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	for ((i=0; i < Nveces ; i ++)); do
		echo "N: $N / $Nfinal..."

		./pescalar_serie $N

	done

done

echo "Running paralelo..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

	for((j=1 ; j<=4 ; j++)); do

		for ((i=0; i < Nveces ; i ++)); do
			echo "N: $N / $Nfinal..."

			./pescalar_par2 $N $j

		done

	done

done
