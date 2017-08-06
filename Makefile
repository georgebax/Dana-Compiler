.PHONY: clean distclean install uninstall default

CC=gcc
CFLAGS=-Wall 
BINPATH = /usr/local/bin/dana
PREFIX = /usr/local/bin/

default: dana

lexer.c: lexer.l
	flex -s -o lexer.c lexer.l

lexer.o: lexer.c parser.h

parser.h parser.c: parser.y
	bison -dv -o parser.c parser.y

parser.o: parser.c

dana: lexer.o parser.o ast.o general.o error.o symbol.o
	$(CC) $(CFLAGS) -o dana $^ -lfl

install: dana
ifeq ($(wildcard $(BINPATH)),)
	@install ./dana $(PREFIX)dana
	@echo "Dana installed successfully!"
else
	@echo "Dana is already installed in your system!"
endif

uninstall: dana
ifeq ($(wildcard $(BINPATH)),)
	@echo "Dana is not installed in your system!"`1
else
	@rm $(PREFIX)dana
	@echo "Dana uninstalled successfully!"
endif


clean:
	$(RM) lexer.c parser.c parser.h parser.output *.o *~

distclean: clean
	$(RM) dana

