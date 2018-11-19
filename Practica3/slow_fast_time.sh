#!/bin/bash

# Inicializar variables
Npaso=64
Nveces=20
P=10
Ninicio=$((10000+1024*$P))
Nfinal=$((10000+1024*($P+1)))
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
slowResults=()
fastResults=()

# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# Generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."

for((i = 0; i < Nveces; i++)); do
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
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')

		if [ ${#slowResults[*]} -gt $j ]; then
			slowResults[$j]=$(awk "BEGIN {print ${slowResults[$j]}+$slowTime; exit}")
		else
			slowResults[$j]=$slowTime
		fi

	done

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "Fast N: $N / $Nfinal..."
		j=$(((N - Ninicio)/Npaso))

		# Filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		if [ ${#fastResults[*]} -gt $j ]; then
			fastResults[$j]=$(awk "BEGIN {print ${fastResults[$j]}+$fastTime; exit}")
		else
			fastResults[$j]=$fastTime
		fi

	done
done

for ((i = 0 ; i < Nveces ; i++)); do
	N=$((Ninicio + i*Npaso))

	# Tenemos que dividir para hacer la media
	slowResults[$i]=$(awk "BEGIN {print ${slowResults[$i]}/$Nveces; exit}")
	fastResults[$i]=$(awk "BEGIN {print ${fastResults[$i]}/$Nveces; exit}")
	echo "$N	${slowResults[$i]}	${fastResults[$i]}" >> $fDAT
done


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
