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
fPNG=slow_fast_time.png
slowResults1024=()
slowResults2048=()
slowResults4096=()
slowResults8192=()
fastResults1024=()
fastResults2048=()
fastResults4096=()
fastResults8192=()

# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT1024 $fDAT2048 $fDAT4096 $fDAT8192 fPNG

# Generar el fichero DAT vacío
touch $fDAT $fDAT2048 $fDAT4096 $fDAT8192

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
		slow1024=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow1024.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./slow $N)
		slow2048=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow2048.dat --I1=2048,1,64 --D1=2048,1,64 --LL=8388608,1,64 ./slow $N)
		slow4096=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow4096.dat --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 ./slow $N)
		slow8192=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow8192.dat --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 ./slow $N)
		fast1024=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast1024.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N)
		fast2048=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast2048.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N)
		fast4096=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast4096.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N)
		fast8192=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast8192.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N)

    	slowResults1024[$j]=$(cg_annotate cgout_slow1024.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		slowResults2048[$j]=$(cg_annotate cgout_slow2048.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		slowResults4096[$j]=$(cg_annotate cgout_slow4096.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		slowResults8192[$j]=$(cg_annotate cgout_slow8192.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		fastResults1024[$j]=$(cg_annotate cgout_fast1024.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		fastResults2048[$j]=$(cg_annotate cgout_fast2048.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		fastResults4096[$j]=$(cg_annotate cgout_fast4096.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')
		fastResults8192[$j]=$(cg_annotate cgout_fast8192.dat | head -n 30 | grep 'TOTALS' | awk '{print $5	$8}' | sed -e 's/,//g')

		echo "$N	${slowResults1024[$i]}	${fastResults1024[$i]}" >> $fDAT1024
		echo "$N	${slowResults2048[$i]}	${fastResults2048[$i]}" >> $fDAT2048
		echo "$N	${slowResults4096[$i]}	${fastResults4096[$i]}" >> $fDAT4096
		echo "$N	${slowResults8192[$i]}	${fastResults8192[$i]}" >> $fDAT8192

	done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast cache read errors"
set ylabel "Cache errors"
set xlabel "N"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT1024" using 1:2 with lines lw 2 title "slow1024", \
     "$fDAT1024" using 1:4 with lines lw 2 title "fast1024", \
     "$fDAT2048" using 1:2 with lines lw 2 title "slow2048", \
     "$fDAT2048" using 1:4 with lines lw 2 title "fast2048", \
     "$fDAT4096" using 1:2 with lines lw 2 title "slow4096", \
     "$fDAT4096" using 1:4 with lines lw 2 title "fast4096", \
     "$fDAT8192" using 1:2 with lines lw 2 title "slow8192", \
     "$fDAT8192" using 1:4 with lines lw 2 title "fast8192"
replot
quit
END_GNUPLOT

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast cache write errors"
set ylabel "Cache errors"
set xlabel "N"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT1024" using 1:3 with lines lw 2 title "slow1024", \
     "$fDAT1024" using 1:5 with lines lw 2 title "fast1024", \
     "$fDAT2048" using 1:3 with lines lw 2 title "slow2048", \
     "$fDAT2048" using 1:5 with lines lw 2 title "fast2048", \
     "$fDAT4096" using 1:3 with lines lw 2 title "slow4096", \
     "$fDAT4096" using 1:5 with lines lw 2 title "fast4096", \
     "$fDAT8192" using 1:3 with lines lw 2 title "slow8192", \
     "$fDAT8192" using 1:5 with lines lw 2 title "fast8192"
replot
quit
END_GNUPLOT
