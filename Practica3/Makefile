LIBS = 
LIB_DIR =  
FLAGS = -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow matrix_mult matrix_mult_trans

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mult: matrix_mult.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matrix_mult_trans: matrix_mult_trans.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow matrix_mult matrix_mult_trans
