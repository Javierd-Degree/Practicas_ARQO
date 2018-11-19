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
fPNG1=slow_fast_read.png
fPNG2=slow_fast_write.png

# Borrar los ficheros DAT y PNG
rm -f $fDAT1024 $fDAT2048 $fDAT4096 $fDAT8192 $fPNG1 $fPNG2

# Generar los ficheros DAT vacíos
touch $fDAT $fDAT2048 $fDAT4096 $fDAT8192

echo "Running slow and fast..."

	# Ejecutamos los programas slow y fast con todos los N
	# una sola vez, como se nos indica.
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "Slow N: $N / $Nfinal..."

		# Ejecutamos los programas con cachegrind para poder obtener los fallos de cache producidos
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow1024.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./slow $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow2048.dat --I1=2048,1,64 --D1=2048,1,64 --LL=8388608,1,64 ./slow $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow4096.dat --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 ./slow $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_slow8192.dat --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 ./slow $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast1024.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast2048.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast4096.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N
		valgrind --tool=cachegrind --cachegrind-out-file=cgout_fast8192.dat --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N

		# Mediante grep y awk cogemos de los ficheros en los que se han guardado los resultados del cachegrind,
		# los datos que representan los fallos de cache de lectura y de escritura y con sed quitamos las comas.
    	slowResults1024=$(cg_annotate cgout_slow1024.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		slowResults2048=$(cg_annotate cgout_slow2048.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		slowResults4096=$(cg_annotate cgout_slow4096.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		slowResults8192=$(cg_annotate cgout_slow8192.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		fastResults1024=$(cg_annotate cgout_fast1024.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		fastResults2048=$(cg_annotate cgout_fast2048.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		fastResults4096=$(cg_annotate cgout_fast4096.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		fastResults8192=$(cg_annotate cgout_fast8192.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')

		# Vamos imprimiendo los distintos datos en los ficheros DAT como se nos pide en el enunciado.
		echo "$N	${slowResults1024}	${fastResults1024}" >> $fDAT1024
		echo "$N	${slowResults2048}	${fastResults2048}" >> $fDAT2048
		echo "$N	${slowResults4096}	${fastResults4096}" >> $fDAT4096
		echo "$N	${slowResults8192}	${fastResults8192}" >> $fDAT8192

	done

# Borramos archivos innecesarios
rm -f cgout_*

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
set output "$fPNG1"
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
set output "$fPNG2"
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
