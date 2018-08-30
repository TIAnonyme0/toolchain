#----------------------------
# Makefile
#----------------------------

RELEASE_NAME := CEdev

# define some common makefile things
empty :=
space := $(empty) $(empty)
comma := ,

# common/os specific things
ifeq ($(OS),Windows_NT)
SHELL      = cmd.exe
NATIVEPATH = $(subst /,\,$1)
RM         = del /f 2>nul
RMDIR      = call && (if exist $1 rmdir /s /q $1)
MKDIR      = call && (if not exist $1 mkdir $1)
PREFIX    ?= C:
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = copy /y
EXMPL_DIR  = $(call NATIVEPATH,$(INSTALLLOC)/CEdev/examples)
CPDIR      = xcopy /e /i /q /r /y /b
CP_EXMPLS  = $(call MKDIR,$(EXMPL_DIR)) && $(CPDIR) $(call NATIVEPATH,$(CURDIR)/examples) $(EXMPL_DIR)
ARCH       = $(call MKDIR,release) && cd tools\installer && iscc.exe /DAPP_VERSION=8.4 /DDIST_PATH=$(call NATIVEPATH,$(DESTDIR)$(PREFIX)/CEdev) installer.iss && \
             cd ..\.. && move /y tools\installer\CEdev.exe release\\
QUOTE_ARG  = "$(subst ",',$1" #'
APPEND     = echo$(if $1, $(subst \,^\,$(subst &,^&,$(subst |,^|,$(subst >,^>,$(subst <,^<,$(subst ^,^^,$1)))))),.) >>$@
else
NATIVEPATH = $(subst \,/,$1)
RM         = rm -f
RMDIR      = rm -rf $1
MKDIR      = mkdir -p $1
PREFIX    ?= $(HOME)
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = cp
CPDIR      = cp -r
CP_EXMPLS  = $(CPDIR) $(call NATIVEPATH,$(CURDIR)/examples) $(call NATIVEPATH,$(INSTALLLOC)/CEdev)
ARCH       = cd $(INSTALLLOC) && tar -czf $(RELEASE_NAME).tar.gz $(RELEASE_NAME) ; \
             cd $(CURDIR) && $(call MKDIR,release) && mv -f $(INSTALLLOC)/$(RELEASE_NAME).tar.gz release
CHMOD      = find $(BIN) -name "*.exe" -exec chmod +x {} \;
QUOTE_ARG  = '$(subst ','\'',$1)' #'
APPEND     = @echo $(call QUOTE_ARG,$1) >>$@
endif
FASMG_FILES  = $(subst $(space),$(comma) ,$(patsubst %,"%",$(subst ",\",$(subst \,\\,$(call NATIVEPATH,$1))))) #"

TOOLSDIR   := $(call NATIVEPATH,$(CURDIR)/tools)
SRCDIR     := $(call NATIVEPATH,$(CURDIR)/src)
FASMGDIR   := $(call NATIVEPATH,$(TOOLSDIR)/fasmg)
CONVHEXDIR := $(call NATIVEPATH,$(TOOLSDIR)/convhex)
CONVPNGDIR := $(call NATIVEPATH,$(TOOLSDIR)/convpng)
CONVTILDIR := $(call NATIVEPATH,$(TOOLSDIR)/convtile)
CEDIR      := $(call NATIVEPATH,$(SRCDIR)/ce)
STDDIR     := $(call NATIVEPATH,$(SRCDIR)/std)
STARTDIR   := $(call NATIVEPATH,$(SRCDIR)/startup)

FASMG      := $(call NATIVEPATH,$(FASMGDIR)/fasmg)
CONVHEX    := $(call NATIVEPATH,$(CONVHEXDIR)/convhex)
CONVPNG    := $(call NATIVEPATH,$(CONVPNGDIR)/convpng)
CONVTILE   := $(call NATIVEPATH,$(CONVTILDIR)/convtile)

ifeq ($(OS),Windows_NT)
FASMG      := $(call NATIVEPATH,$(FASMGDIR)/fasmg.exe)
CONVHEX    := $(call NATIVEPATH,$(CONVHEXDIR)/convhex.exe)
CONVPNG    := $(call NATIVEPATH,$(CONVPNGDIR)/convpng.exe)
CONVTILE   := $(call NATIVEPATH,$(CONVTILDIR)/convtile.exe)
endif

BIN        := $(call NATIVEPATH,$(TOOLSDIR)/zds)

GRAPHXDIR  := $(call NATIVEPATH,$(SRCDIR)/graphx)
KEYPADCDIR := $(call NATIVEPATH,$(SRCDIR)/keypadc)
FILEIOCDIR := $(call NATIVEPATH,$(SRCDIR)/fileioc)
LIBLOADDIR := $(call NATIVEPATH,$(SRCDIR)/libload)

CEDEVDIR   := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME))
INSTALLBIN := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/bin)
INSTALLBF  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/include/fasmg-ez80)
INSTALLINC := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/include)
INSTALLLIB := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib)
INSTALLLL  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/libload)
INSTALLIO  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/fileio)
INSTALLSH  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/shared)
INSTALLST  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/static)
INSTALLLI  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/linked)
DIRS       := $(INSTALLINC) $(INSTALLBIN) $(INSTALLLIB)
DIRS       := $(call NATIVEPATH,$(DIRS))

STATIC_FILES = $(wildcard src/std/static/*.src src/std/static/build/*.src)
LINKED_FILES = $(wildcard src/std/linked/*.src src/std/linked/build/*.src)
SHARED_FILES = $(wildcard src/ce/*.src src/std/shared/*.src src/std/shared/build/*.src)
FILEIO_FILES = $(wildcard src/std/fileio/*.src src/std/fileio/build/*.src)

all: fasmg $(CONVHEX) $(CONVPNG) $(CONVTILE) graphx fileioc keypadc libload ce std startup
	@echo Toolchain built.

clean: clean-graphx clean-fileioc clean-keypadc clean-ce clean-std clean-libload clean-startup
	$(MAKE) -C $(FASMGDIR) clean
	$(MAKE) -C $(CONVHEXDIR) clean
	$(MAKE) -C $(CONVPNGDIR) clean
	$(MAKE) -C $(CONVTILDIR) clean
	$(RM) linker_script
	$(call RMDIR,release)
	$(call RMDIR,clibraries)
	$(call RMDIR,doxygen)

#----------------------------
# tool rules
#----------------------------
fasmg:
	$(MAKE) -C $(FASMGDIR)
$(CONVHEX):
	$(MAKE) -C $(CONVHEXDIR)
$(CONVPNG):
	$(MAKE) -C $(CONVPNGDIR)
$(CONVTILE):
	$(MAKE) -C $(CONVTILDIR)
#----------------------------

#----------------------------
# ce rules
#----------------------------
ce:
	$(MAKE) -C $(CEDIR) BIN=$(BIN)
clean-ce:
	$(MAKE) -C $(CEDIR) clean
#----------------------------

#----------------------------
# std rules
#----------------------------
std:
	$(MAKE) -C $(STDDIR) BIN=$(BIN)
clean-std:
	$(MAKE) -C $(STDDIR) clean
#----------------------------

#----------------------------
# template rules
#----------------------------
template: $(FASMG)
	$(MAKE) -C $(TEMPLATEDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-template:
	$(MAKE) -C $(TEMPLATEDIR) clean
#----------------------------

#----------------------------
# graphx rules
#----------------------------
graphx: $(FASMG)
	$(MAKE) -C $(GRAPHXDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-graphx:
	$(MAKE) -C $(GRAPHXDIR) clean
#----------------------------

#----------------------------
# fileioc rules
#----------------------------
fileioc: $(FASMG)
	$(MAKE) -C $(FILEIOCDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-fileioc:
	$(MAKE) -C $(FILEIOCDIR) clean
#----------------------------

#----------------------------
# keypadc rules
#----------------------------
keypadc: $(FASMG)
	$(MAKE) -C $(KEYPADCDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-keypadc:
	$(MAKE) -C $(KEYPADCDIR) clean
#----------------------------

#----------------------------
# libload rules
#----------------------------
libload: $(FASMG)
	$(MAKE) -C $(LIBLOADDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-libload:
	$(MAKE) -C $(LIBLOADDIR) clean
#----------------------------

#----------------------------
# startup rules
#----------------------------
startup:
	$(MAKE) -C $(STARTDIR) BIN=$(BIN)
clean-startup:
	$(MAKE) -C $(STARTDIR) clean
#----------------------------

#----------------------------
# uninstall rule
#----------------------------
uninstall:
	$(call RMDIR,$(call NATIVEPATH,$(INSTALLLOC)/CEdev))
#----------------------------

#----------------------------
# install rule
#----------------------------
install: $(DIRS) chmod all linker_script
	$(CP_EXMPLS)
	$(CP) $(call NATIVEPATH,$(SRCDIR)/startup/*.src) $(call NATIVEPATH,$(INSTALLLIB))
	$(CP) $(call NATIVEPATH,$(SRCDIR)/makefile.mk) $(call NATIVEPATH,$(INSTALLINC)/.makefile)
	$(CP) $(call NATIVEPATH,linker_script) $(call NATIVEPATH,$(INSTALLINC)/.linker_script)
	$(CP) $(FASMG) $(INSTALLBIN)
	$(CP) $(CONVHEX) $(INSTALLBIN)
	$(CP) $(CONVPNG) $(INSTALLBIN)
	$(CP) $(CONVTILE) $(INSTALLBIN)
	$(CP) $(call NATIVEPATH,$(BIN)/*) $(INSTALLBIN)
	$(MAKE) -C $(FASMGDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(GRAPHXDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(KEYPADCDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(FILEIOCDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(LIBLOADDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(CEDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(STDDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(CPDIR) $(call NATIVEPATH,$(SRCDIR)/compatibility/*) $(call NATIVEPATH,$(INSTALLINC))

$(DIRS):
	$(call MKDIR,$(INSTALLBIN))
	$(call MKDIR,$(INSTALLLIB))
	$(call MKDIR,$(INSTALLINC))
	$(call MKDIR,$(INSTALLBF))
	$(call MKDIR,$(INSTALLLL))
	$(call MKDIR,$(INSTALLIO))
	$(call MKDIR,$(INSTALLSH))
	$(call MKDIR,$(INSTALLST))
	$(call MKDIR,$(INSTALLLI))

chmod:
	$(CHMOD)
#----------------------------

#----------------------------
# release rule
#----------------------------
dist: release
release: install
	$(ARCH)
#----------------------------

#----------------------------
# libraries release rules
#----------------------------
dist-libs: release-libs
release-libs: clibraries
	$(CP) $(call NATIVEPATH,src/graphx/graphx.8xv) $(call NATIVEPATH,clibraries/graphx.8xv)
	$(CP) $(call NATIVEPATH,src/fileioc/fileioc.8xv) $(call NATIVEPATH,clibraries/fileioc.8xv)
	$(CP) $(call NATIVEPATH,src/keypadc/keypadc.8xv) $(call NATIVEPATH,clibraries/keypadc.8xv)
	$(CP) $(call NATIVEPATH,src/libload/libload.8xv) $(call NATIVEPATH,clibraries/libload.8xv)
clibraries:
	$(call MKDIR,clibraries)
#----------------------------

#----------------------------
# doxygen rule
#----------------------------
doxygen:
	cd $(call NATIVEPATH,tools/doxygen) && doxygen config
#----------------------------

#----------------------------
# linker script rule
#----------------------------
linker_script: $(STATIC_FILES) $(LINKED_FILES) $(SHARED_FILES) $(FILEIO_FILES)
	@echo Generating linker script...
	@$(RM) $@
	$(call APPEND,symbol __low_bss = bss.base)
	$(call APPEND,symbol __len_bss = bss.length)
	$(call APPEND,symbol __heaptop = bss.high)
	$(call APPEND,symbol __heapbot = bss.top)
	$(call APPEND,order $(subst $(space),$(comma) ,header icon launcher libs startup cleanup exit code data strsect text))
	$(call APPEND,if STATIC)
	$(call APPEND,	srcs $(call FASMG_FILES,$(addprefix ../../lib/static/,$(notdir $(STATIC_FILES)))))
	$(call APPEND,else)
	$(call APPEND,	srcs $(call FASMG_FILES,$(addprefix ../../lib/linked/,$(notdir $(LINKED_FILES)))))
	$(call APPEND,end if)
	$(call APPEND,srcs $(call FASMG_FILES,$(addprefix ../../lib/shared/,$(notdir $(SHARED_FILES))) $(addprefix ../../lib/fileio/,$(notdir $(FILEIO_FILES)))))

#----------------------------
# makefile help rule
#----------------------------
help:
	@echo Available targets:
	@echo all
	@echo ce
	@echo asm
	@echo std
	@echo fasmg
	@echo graphx
	@echo fileioc
	@echo keypadc
	@echo clean
	@echo clean-ce
	@echo clean-asm
	@echo clean-std
	@echo clean-graphx
	@echo clean-fileioc
	@echo clean-keypadc
	@echo doxygen
	@echo install
	@echo uninstall
	@echo release
	@echo release-libs
	@echo help

#----------------------------
.PHONY: clean-libload libload release-libs clibraries doxygen chmod all clean graphx clean-graphx fileioc clean-fileioc keypadc clean-keypadc install uninstall help release fasmg

