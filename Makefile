# Makefile for GNU Cobol

all: wastecutter

wastecutter: hello.cbl
	cobc -x -o wastecutter hello.cbl

clean:
	rm -f wastecutter wastecutter.exe hello

.PHONY: all clean