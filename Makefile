# openbsd Makefile for lsof revision 4.85

CC=	cc

CCV=	6.0.0 (tags/RELEASE_600/final) (based on LLVM 6.0.0)

LIB=	lib/liblsof.a

CFGF=	 -DOPENBSDV=3090 -DN_UNIXV=/dev/ksyms -DHASNFSPROTO -DHASIPv6 -DHAS9660FS=1 -DHASMSDOSFS=1 -DHASI_E2FS_PTR -DHASEXT2FS=2 -DHASEFFNLINK=i_effnlink -DHAS_DINODE_U -DHASI_FFS1 -DHAS_UM_UFS -DHASNCVPID -DUVM -DHAS_UVM_INCL -DHAS_SYS_PIPEH -DHAS_STRFTIME -DLSOF_VSTR=\"6.4\"

CFGL=	 -L./lib -llsof  -lkvm

DEBUG=	-O

DINC=	-I/usr/include -I/sys

# N+OBSD Makefile
#
# $Id: Makefile,v 1.12 2008/04/15 13:30:14 abe Exp $

PROG=	lsof

BIN=	${DESTDIR}

DOC=	${DESTDIR}

I=/usr/include
S=/usr/include/sys
L=/usr/include/local
P=

CDEF=
CDEFS=  ${CDEF} ${CFGF}
INCL=	${DINC}
CFLAGS=	${CDEFS} ${INCL} ${DEBUG}

GRP=

HDR=    lsof.h lsof_fields.h dlsof.h machine.h proto.h dproto.h

SRC=    dmnt.c dnode.c dnode1.c dproc.c dsock.c dstore.c \
	arg.c main.c misc.c node.c print.c proc.c store.c usage.c \
	util.c

OBJ=	dmnt.o dnode.o dnode1.o dproc.o dsock.o dstore.o \
	arg.o main.o misc.o node.o print.o proc.o store.o usage.o \
	util.o

MAN=	lsof.8
MANLCL=	lsof.0

OTHER=	

SHELL=	/bin/sh

SOURCE=	Makefile ${OTHER} ${MAN} ${HDR} ${SRC}

all: ${PROG}

${MANLCL}: ${MAN}
	rm -f ${MANLCL}
	nroff -mandoc -Tlp ${MAN} > ${MANLCL}

${PROG}: ${LIB} ${P} ${OBJ}
	${CC} -o $@ ${CFLAGS} ${OBJ} ${CFGL}

clean: FRC
	rm -f Makefile.bak ${PROG} a.out core *.core errs lint.out tags *.o
	rm -f machine.h.old new_machine.h version.h
	(cd lib; ${MAKE} -f Makefile.skel clean)

install: all ${MANLCL} FRC
	@echo ''
	@echo 'Please write your own install rule.  Lsof should be installed'
	@echo 'setgid to the group that can can read /dev/kmem.  Normally'
	@echo 'that is the kmem group.  Your install rule actions might look'
	@echo 'something like this:'
	@echo ''
	@echo '    install -cs -m 2755 -g $${GRP} $${PROG} $${BIN}/$${PROG}'
	@echo '    install -c -m 444 $${MANLCL} $${DOC}/$${MANLCL}'
	@echo ''
	@echo 'You will have to complete the skeletons for the BIN, DOC, and'
	@echo 'GRP strings given at the beginning of this Makefile, e.g.,'
	@echo ''
	@echo '    BIN= $${DESTDIR}/usr/local/etc'
	@echo '    DOC= $${DESTDIR}/usr/local/man/man8'
	@echo '    GRP= kmem'
	@echo ''

${LIB}: FRC
	(cd lib; ${MAKE} DEBUG="${DEBUG}" CFGF="${CFGF}")

version.h:	FRC
	@echo Constructing version.h
	@rm -f version.h
	@echo '#define	LSOF_BLDCMT	"${LSOF_BLDCMT}"' > version.h;
	@echo '#define	LSOF_CC		"${CC}"' >> version.h
	@echo '#define	LSOF_CCV	"${CCV}"' >> version.h
	@echo '#define	LSOF_CCDATE	"'`date`'"' >> version.h
	@echo '#define	LSOF_CCFLAGS	"'`echo ${CFLAGS} | sed 's/\\\\(/\\(/g' | sed 's/\\\\)/\\)/g' | sed 's/"/\\\\"/g'`'"' >> version.h
	@if [ "X${LSOF_HOST}" = "X" ]; then \
	  echo '#define	LSOF_HOST	"'`uname -n`'"' >> version.h; \
	else \
	  if [ "${LSOF_HOST}" = "none" ]; then \
	    echo '#define	LSOF_HOST	""' >> version.h; \
	  else \
	    echo '#define	LSOF_HOST	"${LSOF_HOST}"' >> version.h; \
	  fi \
	fi
	@echo '#define	LSOF_LDFLAGS	"${CFGL}"' >> version.h
	@if [ "X${LSOF_LOGNAME}" = "X" ]; then \
	  echo '#define	LSOF_LOGNAME	"${LOGNAME}"' >> version.h; \
	else \
	  if [ "${LSOF_LOGNAME}" = "none" ]; then \
	    echo '#define	LSOF_LOGNAME	""' >> version.h; \
	  else \
	    echo '#define	LSOF_LOGNAME	"${LSOF_LOGNAME}"' >> version.h; \
	  fi; \
	fi
	@if [ "X${LSOF_SYSINFO}" = "X" ]; then \
	    echo '#define	LSOF_SYSINFO	"'`uname -a`'"' >> version.h; \
	else \
	  if [ "${LSOF_SYSINFO}" = "none" ]; then \
	    echo '#define	LSOF_SYSINFO	""' >> version.h; \
	  else \
	    echo '#define	LSOF_SYSINFO	"${LSOF_SYSINFO}"' >> version.h; \
	  fi \
	fi
	@if [ "X${LSOF_USER}" = "X" ]; then \
	  echo '#define	LSOF_USER	"${USER}"' >> version.h; \
	else \
	  if [ "${LSOF_USER}" = "none" ]; then \
	    echo '#define	LSOF_USER	""' >> version.h; \
	  else \
	    echo '#define	LSOF_USER	"${LSOF_USER}"' >> version.h; \
	  fi \
	fi
	@sed '/VN/s/.ds VN \(.*\)/#define	LSOF_VERSION	"\1"/' < version >> version.h

FRC:

# DO NOT DELETE THIS LINE - make depend DEPENDS ON IT

dmnt.o:		${HDR} dmnt.c

dnode.o:	${HDR} dnode.c

dnode1.o:	${HDR} dnode1.c

dproc.o:	${HDR} dproc.c

dsock.o:	${HDR} dsock.c

dstore.o:	${HDR} dstore.c

arg.o:		${HDR} arg.c

main.o:		${HDR} main.c

misc.o:		${HDR} misc.c

node.o:		${HDR} node.c

print.o:	${HDR} print.c

proc.o:		${HDR} proc.c

store.o:	${HDR} store.c

usage.o:	${HDR} version.h usage.c

util.o:		${HDR} util.c

# *** Do not add anything here - It will go away. ***
