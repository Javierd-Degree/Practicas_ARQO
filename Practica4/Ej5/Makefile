LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all: pi_par5 pi_par6 pi_par7 pi_par4 clear

pi_par5: pi_par5.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par6: pi_par6.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par7: pi_par7.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pi_par4: pi_par4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ pi_par5 pi_par6 pi_par7 pi_par4
	
clear:
	rm -f *.o *~
