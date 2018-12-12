// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "arqo4.h"

int main(int argc, char *argv[])
{

	if(argc != 3){
		printf("Número de parámetros incorrectos.\n");
		return -1;
	}

	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	int n;
	unsigned long long int M2;

	M2 = strtoull(argv[1], NULL ,10);
	printf("Tamaño %llu\n", M2);
	n = atoi(argv[2]);
	omp_set_num_threads(n);


	A = generateVector(M2);
	B = generateVector(M2);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}

	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<M2;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
