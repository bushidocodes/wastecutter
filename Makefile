# Makefile for GNU Cobol

all: hello

hello: hello.cbl
	cobc -x -o hello hello.cbl

clean:
	rm -f hello

.PHONY: all clean