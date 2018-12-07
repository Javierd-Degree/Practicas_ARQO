#!/bin/bash

# Inicializar variables
Npaso=4
P=3
Ninicio=$((64*$P))
Nfinal=$((64*($P+1)))
file=mult.dat
fPNG1=mult_cache.png
fPNG2=mult_time.png

# Borrar el fichero DAT y el fichero PNG
rm -f $file $fPNG1 $fPNG2

# Generar el fichero DAT vacío
touch $file

echo "Running matrix products..."

	# Ejecutamos los programas slow y fast con todos los N
	# varias veces, como se indica en el enunciado.
	# Guardamos los resultados en un array para luego guardarlo
	# en el fichero directamente
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "Tamaño: $N / $Nfinal..."

		# Filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		normalTime=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_matrix_mult.dat ./matrix_mult $N | grep 'time' | awk '{print $3}')
		transposeTime=$(valgrind --tool=cachegrind --cachegrind-out-file=cgout_matrix_mult_trans.dat ./matrix_mult_trans $N | grep 'time' | awk '{print $3}')

    	normalResults=$(cg_annotate cgout_matrix_mult.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')
		transposeResults=$(cg_annotate cgout_matrix_mult_trans.dat | head -n 30 | grep 'TOTALS' | awk '{print $5"\t"$8}' | sed -e 's/,//g')

		echo "$N	$normalTime	$normalResults	$transposeTime	$transposeResults" >> $file

	done

# Borramos archivos innecesarios
rm -f cgout_*

echo "Generating time plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Matrix multiplication time"
set ylabel "Time"
set xlabel "N"
set key right bottom
set grid
set term png
set output "$fPNG2"
plot "$file" using 1:2 with lines lw 2 title "Normal", \
     "$file" using 1:5 with lines lw 2 title "Transpose"
replot
quit
END_GNUPLOT

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Matrix multiplication cache errors"
set ylabel "Cache errors"
set xlabel "N"
set key right bottom
set grid
set term png
set output "$fPNG1"
plot "$file" using 1:3 with lines lw 2 title "Normal - Read", \
     "$file" using 1:4 with lines lw 2 title "Normal - Write", \
     "$file" using 1:6 with lines lw 2 title "Transpose - Read", \
     "$file" using 1:7 with lines lw 2 title "Transpose - Write"
replot
quit
END_GNUPLOT
