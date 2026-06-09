# Makefile for GNU Cobol

WARN_FLAGS = -Wall -Wextra -Wcolumn-overflow -Wtruncate -Wunreachable
HARDEN_FLAGS = -t "-D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Wformat-security"

all: wastecutter

wastecutter: hello.cbl
	cobc -x -o wastecutter hello.cbl

check: hello.cbl
	cobc -x -o wastecutter $(WARN_FLAGS) $(HARDEN_FLAGS) hello.cbl

clean:
	rm -f wastecutter wastecutter.exe hello

.PHONY: all check clean