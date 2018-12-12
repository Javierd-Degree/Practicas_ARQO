#!/bin/bash

# Inicializar variables
Npaso=700
Ninicio=1150
Nfinal=1850
numHilos=6
fDAT0=times0.dat
fDAT1=times1.dat
fDAT2=times2.dat
fDAT3=times3.dat
fDAT4=accelerations1.dat
fDAT5=accelerations2.dat
fDAT6=accelerations3.dat
serieResults=()
parResults=()
parResults1=()
parResults2=()
parResults3=()


# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT0 $fDAT1 $fDAT2 $fDAT3 $fDAT4 $fDAT5 $fDAT6

# Generar el fichero DAT vacío
touch $fDAT0 $fDAT1 $fDAT2 $fDAT3 $fDAT4 $fDAT5 $fDAT6

echo "Running serie..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	j=$(((N - Ninicio)/Npaso))
	echo "N: $N / $Nfinal..."

	serieTime=$(./matrix_mult $N | grep 'time' | awk '{print $3}')

	serieResults[$j]=$serieTime

done

echo "Running paralelo bucle 1..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	k=$(((N - Ninicio)/Npaso))
	for((j=1, i=0 ; j<=numHilos ; j++, i+=2)); do
		echo "N: $N / $Nfinal..."
		parTime1=$(./matrix_mult_1 $N $j | grep 'time' | awk '{print $3}')

		parResults1[$k+$i]=$parTime1

	done

done

echo "Running paralelo bucle 2..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	k=$(((N - Ninicio)/Npaso))
	for((j=1, i=0 ; j<=numHilos ; j++, i+=2)); do

		echo "N: $N / $Nfinal..."

		parTime2=$(./matrix_mult_2 $N $j | grep 'time' | awk '{print $3}')

		parResults2[$k+$i]=$parTime2

	done

done

echo "Running paralelo bucle 3..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	k=$(((N - Ninicio)/Npaso))
	for((j=1, i=0 ; j<=numHilos ; j++, i+=2)); do

		echo "N: $N / $Nfinal..."

		parTime3=$(./matrix_mult_3 $N $j | grep 'time' | awk '{print $3}')

		parResults3[$k+$i]=$parTime3

	done

done

Nelementos=${#serieResults[*]}
for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	echo "$N	${serieResults[$i]}" >> $fDAT0
	echo "$N	${parResults1[$i]} ${parResults1[$i+2]} ${parResults1[$i+4]} ${parResults1[$i+6]} ${parResults1[$i+8]} ${parResults1[$i+10]}" >> $fDAT1
	echo "$N	${parResults2[$i]} ${parResults2[$i+2]} ${parResults2[$i+4]} ${parResults2[$i+6]} ${parResults2[$i+8]} ${parResults2[$i+10]}" >> $fDAT2
	echo "$N	${parResults3[$i]} ${parResults3[$i+2]} ${parResults3[$i+4]} ${parResults3[$i+6]} ${parResults3[$i+8]} ${parResults3[$i+10]}" >> $fDAT3

done

for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	for((j=0 ; j<=10 ; j+=2)); do

		parResults1[$i+$j]=$(awk "BEGIN {print ${parResults1[$i+$j]}/${serieResults[$i]}; exit}")
		parResults2[$i+$j]=$(awk "BEGIN {print ${parResults2[$i+$j]}/${serieResults[$i]}; exit}")
		parResults3[$i+$j]=$(awk "BEGIN {print ${parResults3[$i+$j]}/${serieResults[$i]}; exit}")

	done

	echo "$N	${parResults1[$i]} ${parResults1[$i+2]} ${parResults1[$i+4]} ${parResults1[$i+6]} ${parResults1[$i+8]} ${parResults1[$i+10]}" >> $fDAT4
	echo "$N	${parResults2[$i]} ${parResults2[$i+2]} ${parResults2[$i+4]} ${parResults2[$i+6]} ${parResults2[$i+8]} ${parResults2[$i+10]}" >> $fDAT5
	echo "$N	${parResults3[$i]} ${parResults3[$i+2]} ${parResults3[$i+4]} ${parResults3[$i+6]} ${parResults3[$i+8]} ${parResults3[$i+10]}" >> $fDAT6

done
