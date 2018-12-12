#!/bin/bash

# Inicializar variables
Npaso=64
P=10
Ninicio=$((512+$P))
Nfinal=$((1024+512+$P))
numHilos=6

fDAT0=timesSerie.dat
fDAT1=timesPar.dat
fDAT2=accPar.dat
fPNG1=times.png
fPNG2=acceleration.png
serieResults=()
parResults=()



# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT0 $fDAT1 $fDAT2 $fPNG1 $fPNG2

# Generar el fichero DAT vacío
touch $fDAT0 $fDAT1 $fDAT2

echo "Running serie..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	j=$(((N - Ninicio)/Npaso))
	echo "N: $N / $Nfinal..."

	serieTime=$(./matrix_mult $N | grep 'time' | awk '{print $3}')

	serieResults[$j]=$serieTime

done


echo "Running paralelo bucle 3..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	j=$(((N - Ninicio)/Npaso))

	echo "N: $N / $Nfinal..."

	parTime=$(./matrix_mult_3 $N $numHilos | grep 'time' | awk '{print $3}')

	parResults[$j]=$parTime


done


Nelementos=${#serieResults[*]}
for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	echo "$N	${serieResults[$i]}" >> $fDAT0
	echo "$N	${parResults[$i]}" >> $fDAT1

done

for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	for((j=0 ; j<numHilos ; j++)); do

		parResults[$i]=$(awk "BEGIN {print ${parResults[$i]}/${serieResults[$i]}; exit}")

	done

	echo "$N	${parResults[$i]}" >> $fDAT2

done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG1"
plot "$fDAT0" using 1:2 with lines lw 2 title "serie", \
     "$fDAT1" using 1:2 with lines lw 2 title "parallel"
replot
quit
END_GNUPLOT

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Acceleration"
set ylabel "Acceleration (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG2"
plot "$fDAT2" using 1:2 with lines lw 2 title "parallel"
replot
quit
END_GNUPLOT
