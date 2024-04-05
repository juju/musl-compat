topdir          :=$(dir $(realpath $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))

CC              ?=cc
CFLAGS          ?=-O2 -g

prefix          ?=/usr/local
exec_prefix     ?=$(prefix)
bindir          ?=$(exec_prefix)/bin
includedir      ?=$(exec_prefix)/include
datarootdir     ?=$(prefix)/share
datadir         ?=$(datarootdir)
docdir          ?=$(datarootdir)/doc/musl-compat-$(VERSION)
mandir          ?=$(datarootdir)/man

BINS            := $(notdir $(basename $(wildcard $(topdir)/bin/*.c)))
BINS_SH         := $(notdir $(basename $(basename $(wildcard $(topdir)/bin/*.sh.in))))
INCLUDES        := $(shell find "$(topdir)/include" -type f -name '*.h')
INCLUDES        := $(INCLUDES:$(topdir)/include/%=%)

VERSION         =5

build:	$(foreach b,$(BINS),$(topdir)/bin/$(b).o) $(foreach b,$(BINS_SH),$(topdir)/bin/$(b).sh)

$(topdir)/bin/%.sh: $(topdir)/bin/%.sh.in
	cp "$<" "$@"
	chmod +x "$@"

$(topdir)/bin/%.o: $(topdir)/bin/%.c
	$(CC) -I"$(topdir)/include" $(CFLAGS) $(LDFLAGS) "$<" -o "$@"

$(DESTDIR)$(bindir)/%: $(topdir)/bin/$(notdir %)
	install -D -m 755 "$<" "$(basename $@)"

$(DESTDIR)$(includedir)/%: $(topdir)/include/$(notdir %)
	install -D -m 644 "$<" "$@"

install: $(foreach b,$(BINS),$(DESTDIR)$(bindir)/$(b).o) $(foreach b,$(BINS_SH),$(DESTDIR)$(bindir)/$(b).sh) $(foreach i,$(INCLUDES),$(DESTDIR)$(includedir)/$(i))

clean:
	rm -rf $(foreach b,$(BINS),$(topdir)/bin/$(b).o) $(foreach b,$(BINS_SH),$(topdir)/bin/$(b).sh)

.PHONY:	all build clean install
