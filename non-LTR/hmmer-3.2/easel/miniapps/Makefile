top_srcdir = ../..
srcdir     = .

SHELL      = /bin/sh

# Package information
#
PACKAGE         = HMMER
PACKAGE_VERSION = 3.2
PACKAGE_TARNAME = hmmer
BASENAME        = hmmer
RELEASE         = 0.44
RELEASEDATE     = "June 2018"
COPYRIGHT       = "Copyright (C) 2018 Howard Hughes Medical Institute."
LICENSELINE     = "Freely distributed under the BSD open source license."

## Installation targets
#
prefix      = /usr/local
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
bindir      = ${exec_prefix}/bin
libdir      = ${exec_prefix}/lib
includedir  = ${prefix}/include
mandir      = ${datarootdir}/man
docdir      = ${datarootdir}/doc/${PACKAGE_TARNAME}
pdfdir      = ${docdir}
mandir      = ${datarootdir}/man
man1dir     = ${mandir}/man1
man1ext     = .1

INSTALL     = /usr/bin/install -c

## your compiler and compiler flags.
#
CC        = gcc
CFLAGS    = -O3 -pthread 
CPPFLAGS  = 
LDFLAGS   = 
DEFS      = -DHAVE_CONFIG_H
LIBS      = -leasel    -lm

## list of the miniapps to compile.
#
PROGS = esl-afetch\
	esl-alimanip\
	esl-alimap\
	esl-alimask\
	esl-alimerge\
	esl-alipid\
	esl-alirev\
	esl-alistat\
	esl-compalign\
	esl-compstruct\
	esl-construct\
	esl-histplot\
	esl-mask\
	esl-reformat\
	esl-selectn\
	esl-seqrange\
	esl-seqstat\
	esl-sfetch\
	esl-shuffle\
	esl-ssdraw\
        esl-translate\
	esl-weight

# beautification magic stolen from git 
#
QUIET_SUBDIR0 = +${MAKE} -C #space separator after -c
QUIET_SUBDIR1 = 
ifndef V
	QUIET_CC      = @echo '    ' CC $@;
	QUIET_GEN     = @echo '    ' GEN $@;
	QUIET_AR      = @echo '    ' AR $@;
	QUIET_SUBDIR0 = +@subdir=
	QUIET_SUBDIR1 = ; echo '    ' SUBDIR  $$subdir; \
		        ${MAKE} -s -C $$subdir
endif


.PHONY: all dev tests check install uninstall clean distclean 

all: 	${PROGS}
dev:    ${PROGS}
tests:  ${PROGS}
check:  ${PROGS}

${PROGS}: % : %.c ../libeasel.a 
	${QUIET_GEN}${CC} ${CFLAGS} ${DEFS} ${LDFLAGS} -L.. -I. -I.. -I${srcdir} -I${srcdir}/.. -o $@ $< ${LIBS}

install: ${PROGS} 
	for file in ${PROGS}; do \
	   ${INSTALL} -m 0755 $$file ${DESTDIR}${bindir}/ ;\
	done
	for file in ${PROGS}; do \
	   ${INSTALL} -m 0644 $$file.man ${DESTDIR}${man1dir}/$${file}${man1ext} ;\
	done

uninstall:
	for file in $(PROGS); do \
	   rm ${DESTDIR}${bindir}/$$file ;\
	done
	for file in ${PROGS}; do \
	   rm ${DESTDIR}${man1dir}/$${file}${man1ext} ;\
	done

clean:
	-rm -f ${PROGS}
	-rm -f *.o *~
	-rm -f *.gcno *.gcda *.gcov
	-rm -f TAGS
	for prog in ${PROGS}; do\
	   if test -d $$prog.dSYM; then rm -rf $$prog.dSYM; fi;\
	done
ifndef V
	@echo '     ' CLEAN miniapps
endif


distclean: clean
	-rm -f ${PROGS}
	-rm -f *.man
	-rm -f Makefile


