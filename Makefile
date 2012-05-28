all: test-deps

# ------ Perl environment ------

WGET = wget
PERL = perl
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120330

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

local-perl perl-version perl-exec \
pmb-install pmb-update \
: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@

GIT = git

submodule-update:
	$(GIT) submodule update --init

# ------ Tests ------

PROVE = prove

test: test-deps test-main

test-deps: submodule-update pmb-install

test-deps-travis: test-deps-debian

test-deps-debian:
	sudo apt-get install gmp-devel

test-main:
	PATH=$(PERL_PATH):$(PATH) PERL5LIB=$(shell cat config/perl/libs.txt) \
	    $(PROVE) t/karasuma-id/*.t
