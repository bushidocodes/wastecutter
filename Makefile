# Makefile for GNU Cobol

all: hello

hello: hello.cob
	cobc -x -o hello hello.cob

clean:
	rm -f hello

.PHONY: all clean