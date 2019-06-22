#
# Makefile for Mini-XML, a small XML-like file parsing library.
#
# https://www.msweet.org/mxml
#
# Copyright © 2003-2019 by Michael R Sweet.
#
# Licensed under Apache License v2.0.  See the file "LICENSE" for more
# information.
#

#
# Compiler tools definitions...
#

AR		=	ar
ARFLAGS		=	crvs
ARCHFLAGS	=	
CC		=	gcc
CFLAGS		=	$(OPTIM) $(ARCHFLAGS) -Wall -D_GNU_SOURCE   -D_THREAD_SAFE -D_REENTRANT
CP		=	/usr/bin/cp
DSO		=	$(CC)
DSOFLAGS	=	 -Wl,-soname,libmxml.so.1 -shared $(OPTIM)
LDFLAGS		=	$(OPTIM) $(ARCHFLAGS) 
INSTALL		=	/usr/bin/install -c
LIBMXML		=	libmxml.so.1.6
LIBS		=	 -lpthread
LN		=	/usr/bin/ln -s
MKDIR		=	/usr/bin/mkdir
OPTIM		=	-fPIC -Os -g
RANLIB		=	ranlib
RM		=	/usr/bin/rm -f
SHELL		=	/bin/sh


#
# Configured directories...
#

prefix		=	/usr/local/mxml
exec_prefix	=	/usr/local/mxml
bindir		=	${exec_prefix}/bin
datarootdir	=	${prefix}/share
includedir	=	${prefix}/include
libdir		=	${exec_prefix}/lib
mandir		=	${datarootdir}/man
docdir		=	${datarootdir}/doc/mxml
BUILDROOT	=	$(DSTROOT)


#
# Install commands...
#

INSTALL_BIN	=	$(LIBTOOL) $(INSTALL) -m 755
INSTALL_DATA	=	$(INSTALL) -m 644
INSTALL_DIR	=	$(INSTALL) -d
INSTALL_LIB	=	$(LIBTOOL) $(INSTALL) -m 755
INSTALL_MAN	=	$(INSTALL) -m 644
INSTALL_SCRIPT	=	$(INSTALL) -m 755


#
# Rules...
#

.SILENT:
.SUFFIXES:	.c .man .o
.c.o:
	echo Compiling $<
	$(CC) $(CFLAGS) -c -o $@ $<


#
# Targets...
#

DOCFILES	=	doc/mxml.html doc/mxmldoc.xsd README.md COPYING CHANGES.md
PUBLIBOBJS	=	mxml-attr.o mxml-entity.o mxml-file.o mxml-get.o \
			mxml-index.o mxml-node.o mxml-search.o mxml-set.o
LIBOBJS		=	$(PUBLIBOBJS) mxml-private.o mxml-string.o
OBJS		=	TestMXml.o $(LIBOBJS)
ALLTARGETS	=	$(LIBMXML) TestMXml
CROSSTARGETS	=	$(LIBMXML)
TARGETS		=	$(ALLTARGETS)


#
# Make everything...
#

all:		$(TARGETS)


#
# Clean everything...
#

clean:
	echo Cleaning build files...
	$(RM) $(OBJS) $(ALLTARGETS)
	$(RM) mxml1.dll
	$(RM) libmxml.a
	$(RM) libmxml.so.1.6
	$(RM) libmxml.sl.1
	$(RM) libmxml.1.dylib


#
# Really clean everything...
#

distclean:	clean
	echo Cleaning distribution files...
	$(RM) config.cache config.log config.status
	$(RM) Makefile config.h
	$(RM) -r autom4te*.cache
	$(RM) *.bck *.bak
	$(RM) -r clang


#
# Run the clang.llvm.org static code analysis tool on the C sources.
#

.PHONY: clang clang-changes
clang:
	echo Doing static code analysis of all code using CLANG...
	$(RM) -r clang
	scan-build -V -k -o `pwd`/clang $(MAKE) $(MFLAGS) clean all
clang-changes:
	echo Doing static code analysis of changed code using CLANG...
	scan-build -V -k -o `pwd`/clang $(MAKE) $(MFLAGS) all


#
# Install everything...
#

install:	$(TARGETS) install-$(LIBMXML) install-libmxml.a
	echo Installing documentation in $(BUILDROOT)$(docdir)...
	$(INSTALL_DIR) $(BUILDROOT)$(docdir)
	for file in $(DOCFILES); do \
		$(INSTALL_MAN) $$file $(BUILDROOT)$(docdir)/`basename $$file .md`; \
	done
	echo Installing header files in $(BUILDROOT)$(includedir)...
	$(INSTALL_DIR) $(BUILDROOT)$(includedir)
	$(INSTALL_DATA) mxml.h $(BUILDROOT)$(includedir)
	echo Installing pkgconfig files in $(BUILDROOT)$(libdir)/pkgconfig...
	$(INSTALL_DIR) $(BUILDROOT)$(libdir)/pkgconfig
	$(INSTALL_DATA) mxml.pc $(BUILDROOT)$(libdir)/pkgconfig
	echo Installing man pages in $(BUILDROOT)$(mandir)...
	$(INSTALL_DIR) $(BUILDROOT)$(mandir)/man3
	$(INSTALL_MAN) doc/mxml.3 $(BUILDROOT)$(mandir)/man3/mxml.3

install-libmxml.a:	libmxml.a
	echo Installing libmxml.a to $(BUILDROOT)$(libdir)...
	$(INSTALL_DIR) $(BUILDROOT)$(libdir)
	$(INSTALL_LIB) libmxml.a $(BUILDROOT)$(libdir)
	$(RANLIB) $(BUILDROOT)$(libdir)/libmxml.a

install-libmxml.so.1.6:	libmxml.so.1.6
	echo Installing libmxml.so to $(BUILDROOT)$(libdir)...
	$(INSTALL_DIR) $(BUILDROOT)$(libdir)
	$(INSTALL_LIB) libmxml.so.1.6 $(BUILDROOT)$(libdir)
	$(RM) $(BUILDROOT)$(libdir)/libmxml.so
	$(LN) libmxml.so.1.6 $(BUILDROOT)$(libdir)/libmxml.so
	$(RM) $(BUILDROOT)$(libdir)/libmxml.so.1
	$(LN) libmxml.so.1.6 $(BUILDROOT)$(libdir)/libmxml.so.1

install-libmxml.1.dylib: libmxml.1.dylib
	echo Installing libmxml.dylib to $(BUILDROOT)$(libdir)...
	$(INSTALL_DIR) $(BUILDROOT)$(libdir)
	$(INSTALL_LIB) libmxml.1.dylib $(BUILDROOT)$(libdir)
	$(RM) $(BUILDROOT)$(libdir)/libmxml.dylib
	$(LN) libmxml.1.dylib $(BUILDROOT)$(libdir)/libmxml.dylib


#
# Uninstall everything...
#

uninstall: uninstall-$(LIBMXML) uninstall-libmxml.a
	echo Uninstalling documentation from $(BUILDROOT)$(docdir)...
	$(RM) -r $(BUILDROOT)$(docdir)
	echo Uninstalling headers from $(BUILDROOT)$(includedir)...
	$(RM) $(BUILDROOT)$(includedir)/mxml.h
	echo Uninstalling pkgconfig files from $(BUILDROOT)$(libdir)/pkgconfig...
	$(RM) $(BUILDROOT)$(libdir)/pkgconfig/mxml.pc
	echo Uninstalling man pages from $(BUILDROOT)$(mandir)...
	$(RM) $(BUILDROOT)$(mandir)/man3/mxml.3

uninstall-libmxml.a:
	echo Uninstalling libmxml.a from $(BUILDROOT)$(libdir)...
	$(RM) $(BUILDROOT)$(libdir)/libmxml.a

uninstall-libmxml.so.1.6:
	echo Uninstalling libmxml.so from $(BUILDROOT)$(libdir)...
	$(RM) $(BUILDROOT)$(libdir)/libmxml.so
	$(RM) $(BUILDROOT)$(libdir)/libmxml.so.1
	$(RM) $(BUILDROOT)$(libdir)/libmxml.so.1.4

uninstall-libmxml.1.dylib:
	echo Uninstalling libmxml.dylib from $(BUILDROOT)$(libdir)...
	$(RM) $(BUILDROOT)$(libdir)/libmxml.dylib
	$(RM) $(BUILDROOT)$(libdir)/libmxml.1.dylib


#
# Figure out lines-of-code...
#

.PHONY: sloc

sloc:
	echo "libmxml: \c"
	sloccount $(LIBOBJS:.o=.c) mxml-private.c mxml.h 2>/dev/null | \
		grep "Total Physical" | awk '{print $$9}'


#
# libmxml.a
#

libmxml.a:	$(LIBOBJS)
	echo Creating $@...
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	$(RANLIB) $@

$(LIBOBJS):	mxml.h
mxml-entity.o mxml-file.o mxml-private.o: mxml-private.h


#
# mxml1.dll
#

mxml1.dll:	$(LIBOBJS)
	echo Creating $@...
	$(DSO) $(DSOFLAGS) $(LDFLAGS) -o $@ $(LIBOBJS) $(LIBS)


#
# libmxml.so.1.6
#

libmxml.so.1.6:	$(LIBOBJS)
	echo Creating $@...
	$(DSO) $(DSOFLAGS) $(LDFLAGS) -o libmxml.so.1.6 $(LIBOBJS) $(LIBS)
	$(RM) libmxml.so libmxml.so.1
	$(LN) libmxml.so.1.6 libmxml.so
	$(LN) libmxml.so.1.6 libmxml.so.1


#
# libmxml.1.dylib
#

libmxml.1.dylib:	$(LIBOBJS)
	echo Creating $@...
	$(DSO) $(DSOFLAGS) $(LDFLAGS) -o libmxml.1.dylib \
		-install_name $(libdir)/libmxml.dylib \
		-current_version 1.6.0 \
		-compatibility_version 1.0.0 \
		$(LIBOBJS) $(LIBS)
	$(RM) libmxml.dylib
	$(LN) libmxml.1.dylib libmxml.dylib


#
# TestMXml
#

TestMXml:	libmxml.a TestMXml.o
	echo Linking $@...
	$(CC) $(LDFLAGS) -o $@ TestMXml.o libmxml.a $(LIBS)
	@echo Testing library...
	./TestMXml test.xml temp1s.xml >temp1.xml
	./TestMXml temp1.xml temp2s.xml >temp2.xml
	@if cmp temp1.xml temp2.xml; then \
		echo Stdio file test passed!; \
		$(RM) temp2.xml temp2s.xml; \
	else \
		echo Stdio file test failed!; \
	fi
	@if cmp temp1.xml temp1s.xml; then \
		echo String test passed!; \
		$(RM) temp1.xml temp1s.xml; \
	else \
		echo String test failed!; \
	fi
	@if cmp test.xml test.xmlfd; then \
		echo File descriptor test passed!; \
		$(RM) test.xmlfd; \
	else \
		echo File descriptor test failed!; \
	fi

TestMXml-vg:	$(LIBOBJS) TestMXml.o
	echo Linking $@...
	$(CC) $(LDFLAGS) -o $@ TestMXml.o $(LIBOBJS) $(LIBS)

TestMXml.o:	mxml.h


#
# Documentation (depends on separate codedoc utility)
#

.PHONY: doc
doc:	mxml.h $(PUBLIBOBJS:.o=.c) \
		doc/body.md doc/body.man doc/footer.man \
		doc/mxml-cover.png
	echo Generating API documentation...
	$(RM) mxml.xml
	codedoc --body doc/body.md \
		--coverimage doc/mxml-cover.png \
		mxml.xml mxml.h $(PUBLIBOBJS:.o=.c) >doc/mxml.html
	codedoc --body doc/body.md \
		--coverimage doc/mxml-cover.png \
		--epub doc/mxml.epub mxml.xml
	codedoc --man mxml --title "Mini-XML API" \
		--body doc/body.man --footer doc/footer.man \
		mxml.xml >doc/mxml.3
	$(RM) mxml.xml


#
# All object files depend on the makefile and config header...
#

$(OBJS):	Makefile config.h
