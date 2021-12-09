# Makefile
all: redlight

redlight: redlight.o
	gcc -o $@ $+

redlight.o: redlight.s
	as -o $@ $<

clean:
	rm -rf redlight *.o