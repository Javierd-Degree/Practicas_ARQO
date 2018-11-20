#!/bin/bash

# Inicializar variables
Npaso=64
P=10
Ninicio=$((2000+1024*$P))
Nfinal=$((2000+1024*($P+1)))
fDAT1024=cache_1024.dat
fDAT2048=cache_2048.dat
fDAT4096=cache_4096.dat
fDAT8192=cache_8192.dat
fRES=cache_total.dat
fPNG=slow_fast_time.png
slowResults=(0,0,0,0)
slowResults1024=()
slowResults2048=()
slowResults4096=()
slowResults8192=()
fastResults=(0,0,0,0)
fastResults1024=()
fastResults2048=()
fastResults4096=()
fastResults8192=()

# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT1024 $fDAT2048 $fDAT4096 $fDAT8192 $fRES fPNG 

# Generar el fichero DAT vacío
touch $fDAT $fDAT2048 $fDAT4096 $fDAT8192 $fRES

echo "Running slow and fast..."

	# Ejecutamos los programas slow y fast con todos los N
	# varias veces, como se indica en el enunciado.
	# Guardamos los resultados en un array para luego guardarlo
	# en el fichero directamente
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "Slow N: $N / $Nfinal..."
		j=$(((N - Ninicio)/Npaso))

		# Filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		slow1024=$(valgrind --tool=cachegrind --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./slow $N | grep 'TOTALS' | awk '{print $5 $8}')
		slow2048=$(valgrind --tool=cachegrind --I1=2048,1,64 --D1=2048,1,64 --LL=8388608,1,64 ./slow $N | grep 'TOTALS' | awk '{print $5 $8}')
		slow4096=$(valgrind --tool=cachegrind --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 ./slow $N | grep 'TOTALS' | awk '{print $5 $8}')
		slow8192=$(valgrind --tool=cachegrind --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 ./slow $N | grep 'TOTALS' | awk '{print $5 $8}')

    	slowResults1024[$j]=$slow1024
		slowResults2048[$j]=$slow2048
		slowResults4096[$j]=$slow4096
		slowResults8192[$j]=$slow8192

		slowResults[0]=$(awk "BEGIN {print ${slowResults[0]}+$slow1024; exit}")
		slowResults[1]=$(awk "BEGIN {print ${slowResults[1]}+$slow2048; exit}")
		slowResults[2]=$(awk "BEGIN {print ${slowResults[2]}+$slow4096; exit}")
		slowResults[3]=$(awk "BEGIN {print ${slowResults[3]}+$slow8192; exit}")

	done

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "Fast N: $N / $Nfinal..."
		j=$(((N - Ninicio)/Npaso))

		# Filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		fast1024=$(valgrind --tool=cachegrind --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N | grep 'TOTALS' | awk '{print $5 $8}')
		fast2048=$(valgrind --tool=cachegrind --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N | grep 'TOTALS' | awk '{print $5 $8}')
		fast4096=$(valgrind --tool=cachegrind --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N | grep 'TOTALS' | awk '{print $5 $8}')
		fast8192=$(valgrind --tool=cachegrind --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N | grep 'TOTALS' | awk '{print $5 $8}')

		fastResults1024[$j]=$fast1024
		fastResults2048[$j]=$fast2048
		fastResults4096[$j]=$fast4096
		fastResults8192[$j]=$fast8192

		fastResults[0]=$(awk "BEGIN {print ${fastResults[0]}+$fast1024; exit}")
		fastResults[1]=$(awk "BEGIN {print ${fastResults[1]}+$fast2048; exit}")
		fastResults[2]=$(awk "BEGIN {print ${fastResults[2]}+$fast4096; exit}")
		fastResults[3]=$(awk "BEGIN {print ${fastResults[3]}+$fast8192; exit}")

	done

Nelementos=${#slowResults1024[*]}
for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	echo "$N	${slowResults1024[$i]}	${fastResults1024[$i]}" >> $fDAT1024
	echo "$N	${slowResults2048[$i]}	${fastResults2048[$i]}" >> $fDAT2048
	echo "$N	${slowResults4096[$i]}	${fastResults4096[$i]}" >> $fDAT4096
	echo "$N	${slowResults8192[$i]}	${fastResults8192[$i]}" >> $fDAT8192
	echo "1024	${slowResults[0]}	${fastResults[0]}" >> $fRES
	echo "2048	${slowResults[1]}	${fastResults[1]}" >> $fRES
	echo "4096	${slowResults[2]}	${fastResults[2]}" >> $fRES
	echo "8192	${slowResults[3]}	${fastResults[3]}" >> $fRES

done



echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast cache errors"
set ylabel "Cache errors"
set xlabel "Cache size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fRES" using 1:2 with lines lw 2 title "slow", \
     "$fRES" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
