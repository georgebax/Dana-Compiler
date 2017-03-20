###############################################################################
#  CVS version:
#     $Id: Makefile,v 1.2 2004/05/05 22:00:08 nickie Exp $
###############################################################################
#
#  Makefile    : Makefile
#  Project     : PCL Compiler
#  Version     : 1.0 alpha
#  Written by  : Nikolaos S. Papaspyrou (nickie@softlab.ntua.gr)
#  Date        : May 14, 2003
#  Description : Generic symbol table in C
#
#  Comments: (in Greek iso-8859-7)
#  ---------
#  ������ �������� �����������.
#  ����� ������������ ��������� ��� ��������� �����������.
#  ������ ����������� ������������ ��� �����������.
#  ���������� ����������� ����������


.PHONY: clean distclean count

# OS type: Linux/Win DJGPP
ifdef OS
   EXE=.exe
else
   EXE=
endif

CFILES   = symbol.c error.c general.c symbtest.c
HFILES   = symbol.h error.h general.h
OBJFILES = $(patsubst %.c,%.o,$(CFILES))
EXEFILES = symbtest$(EXE)
SRCFILES = $(HFILES) $(CFILES)

CC=gcc
CFLAGS=-Wall -ansi -pedantic -g

%.o : %.c
	$(CC) $(CFLAGS) -c $<

symbtest$(EXE): symbtest.o symbol.o error.o general.o
	$(CC) $(CFLAGS) -o $@ $^

general.o  : general.c general.h error.h
error.o    : error.c general.h error.h
symbol.o   : symbol.c symbol.h general.h error.h
symbtest.o : symbtest.c symbol.h error.h

clean:
	$(RM) $(OBJFILES) *~

distclean: clean
	$(RM) $(EXEFILES)

count:
	wc -l -c Makefile $(SRCFILES)

bonus.zip: distclean
	zip bonus.zip Makefile $(SRCFILES)

bonus.tgz:
	tar cvfzh bonus.tgz Makefile $(SRCFILES)
