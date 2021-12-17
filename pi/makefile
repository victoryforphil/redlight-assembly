# Makefile
all: redlight

redlight: redlight.o
	gcc -lwiringPi -o $@ $+

redlight.o: redlight.s
	gcc -lwiringPi -g  -o $@ $<

clean:
	rm -rf redlight *.o