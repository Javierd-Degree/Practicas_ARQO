#!/bin/bash

# Inicializar variables
Npaso=36400000
Nveces=5
Ninicio=16000000
Nfinal=380000000
fDAT1=times.dat
fDAT2=accelerations.dat
fPNG1=times.png
fPNG2=accelerations.png
serieResults=()
parResults=()
parResults1=()
parResults2=()
parResults3=()
parResults4=()
parResults5=()
parResults6=()

# Borrar el fichero DAT y el fichero PNG
rm -f $fDAT1 $fDAT2 $fPNG1 $fPNG2 

# Generar el fichero DAT vacío
touch $fDAT1 $fDAT2

echo "Running serie..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	j=$(((N - Ninicio)/Npaso))

	for ((i=0; i < Nveces ; i ++)); do
		echo "N: $N / $Nfinal..."

		serieTime=$(./pescalar_serie $N | grep 'Tiempo' | awk '{print $2}')

		if [ ${#serieResults[*]} -gt $j ]; then
			serieResults[$j]=$(awk "BEGIN {print ${serieResults[$j]}+$serieTime; exit}")
		else
			serieResults[$j]=$serieTime
		fi

	done
done

echo "Running paralelo..."

for((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
	k=$(((N - Ninicio)/Npaso))

	for((j=1, l=0 ; j<=6 ; j++, l+=100)); do

		for ((i=0; i < Nveces ; i++)); do
			echo "N: $N / $Nfinal..."

			parTime=$(./pescalar_par2 $N $j | grep 'Tiempo' | awk '{print $2}')

			if [ ${#parResults[*]} -gt $(($k+$l)) ]; then
				parResults[$k+$l]=$(awk "BEGIN {print ${parResults[$k+$l]}+$parTime; exit}")
			else
				parResults[$k+$l]=$parTime
			fi

		done

	done

done

Nelementos=${#serieResults[*]}
for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	# Tenemos que dividir para hacer la media
	serieResults[$i]=$(awk "BEGIN {print ${serieResults[$i]}/$Nveces; exit}")
	parResults1[$i]=$(awk "BEGIN {print ${parResults[$i]}/$Nveces; exit}")
	parResults2[$i]=$(awk "BEGIN {print ${parResults[$i+100]}/$Nveces; exit}")
	parResults3[$i]=$(awk "BEGIN {print ${parResults[$i+200]}/$Nveces; exit}")
	parResults4[$i]=$(awk "BEGIN {print ${parResults[$i+300]}/$Nveces; exit}")
	parResults5[$i]=$(awk "BEGIN {print ${parResults[$i+400]}/$Nveces; exit}")
	parResults6[$i]=$(awk "BEGIN {print ${parResults[$i+500]}/$Nveces; exit}")
	echo "$N	${serieResults[$i]}	${parResults1[$i]} ${parResults2[$i]} ${parResults3[$i]} ${parResults4[$i]} ${parResults5[$i]} ${parResults6[$i]}" >> $fDAT1
done

for ((i = 0 ; i < Nelementos ; i++)); do
	N=$((Ninicio + i*Npaso))

	# Tenemos que dividir para hacer la media
	parResults1[$i]=$(awk "BEGIN {print ${parResults1[$i]}/${serieResults[$i]}; exit}")
	parResults2[$i]=$(awk "BEGIN {print ${parResults2[$i]}/${serieResults[$i]}; exit}")
	parResults3[$i]=$(awk "BEGIN {print ${parResults3[$i]}/${serieResults[$i]}; exit}")
	parResults4[$i]=$(awk "BEGIN {print ${parResults4[$i]}/${serieResults[$i]}; exit}")
	parResults5[$i]=$(awk "BEGIN {print ${parResults5[$i]}/${serieResults[$i]}; exit}")
	parResults6[$i]=$(awk "BEGIN {print ${parResults6[$i]}/${serieResults[$i]}; exit}")
	echo "$N	${parResults1[$i]} ${parResults2[$i]} ${parResults3[$i]} ${parResults4[$i]} ${parResults5[$i]} ${parResults6[$i]}" >> $fDAT2
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Execution Time"
set ylabel "Execution time (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG1"
plot "$fDAT1" using 1:2 with lines lw 2 title "serie", \
     "$fDAT1" using 1:3 with lines lw 2 title "par1", \
     "$fDAT1" using 1:4 with lines lw 2 title "par2", \
     "$fDAT1" using 1:5 with lines lw 2 title "par3", \
     "$fDAT1" using 1:6 with lines lw 2 title "par4", \
     "$fDAT1" using 1:7 with lines lw 2 title "par5", \
     "$fDAT1" using 1:8 with lines lw 2 title "par6"
replot
quit
END_GNUPLOT

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Acceleration"
set ylabel "Acceleration (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG2"
plot "$fDAT2" using 1:2 with lines lw 2 title "par1", \
     "$fDAT2" using 1:3 with lines lw 2 title "par2", \
     "$fDAT2" using 1:4 with lines lw 2 title "par3", \
     "$fDAT2" using 1:5 with lines lw 2 title "par4", \
     "$fDAT2" using 1:6 with lines lw 2 title "par5", \
     "$fDAT2" using 1:7 with lines lw 2 title "par6"
replot
quit
END_GNUPLOT