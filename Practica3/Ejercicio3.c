#include "arqo3.h"


tipo ** compute(tipo **matrix1, tipo **matrix2, int n);
void imprimirMatriz(tipo **matrix, int n, char* text);

int main( int argc, char *argv[])
{
	int n;
	tipo **m1, **m2, **res =NULL;
	struct timeval fin,ini;
	printf("Word size: %ld bits\n",8*sizeof(tipo));

	if( argc!=2 )
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n=atoi(argv[1]);
	m1=generateMatrix(n);
	m2=generateMatrix(n);
	if( !m1 || !m2 )
	{
		return -1;
	}


	imprimirMatriz(m1, n, "M1");
	imprimirMatriz(m2, n, "M2");
	gettimeofday(&ini,NULL);
	/* Main computation */
	res = compute(m1, m2, n);
	/* End of computation */
	gettimeofday(&fin,NULL);

	imprimirMatriz(res, n, "Res");


	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	


	free(m1);
	free(m2);
	free(res);
	return 0;
}

tipo ** compute(tipo **m1, tipo **m2, int n){
	int i,j,k;

	tipo **res = NULL;
	res = generateEmptyMatrix(n);
	if(res == NULL){
		return NULL;
	}
	
	// Multiplying matrix firstMatrix and secondMatrix and storing in array mult.
	for(i = 0; i < n; ++i){
		for(j = 0; j < n; ++j){
			for(k=0; k<n; ++k){
				res[i][j] += m1[i][k] * m2[k][j];
			}
		}
	}

	return res;
}

void imprimirMatriz(tipo **matrix, int n, char* text){
	int i, j;

	if(matrix == NULL){
		printf("Error, la matrix es NULL\n");
		return;
	}

	printf("%s\n", text);
	for(i = 0; i < n; ++i){
		for(j = 0; j < n; ++j){
			printf("%lf ", matrix[i][j]);
		}
		printf("\n");
	}

	printf("\n");
}