CC      ?= cc
CFLAGS  ?= -std=c99 -O2 -Wall -Wextra -I.
LDLIBS  ?= -lm

all: atom_thermal_test

atom_thermal_test: thermal.c test_main.c thermal.h
	$(CC) $(CFLAGS) -o $@ thermal.c test_main.c $(LDLIBS)

clean:
	rm -f atom_thermal_test

.PHONY: all clean
