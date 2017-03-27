lexer: lex.yy.c
	gcc $< -lfl -o lexer

lex.yy.c: lexer.l
	flex -s -o lexer.c lexer.l

clean:
	$(RM) *.o lex.yy.c

distclean: clean
	$(RM) lexer
