FUENTE = trabajo
PRUEBA = p1_test.txt

all: compile run

compile:
	flex $(FUENTE).l
	gcc -o $(FUENTE) lex.yy.c -lfl

clean:
	rm $(FUENTE) lex.yy.c 

run:
	./$(FUENTE) < $(PRUEBA)

