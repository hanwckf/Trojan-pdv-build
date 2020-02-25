DIR := $(shell pwd)
STAGEDIR := $(DIR)/stage
DL_DIR := $(DIR)/dl

TROJAN_STATIC_BUILD := OFF
ifeq ($(BUILD_STATIC),y)
TROJAN_STATIC_BUILD := ON
endif

CPUFLAGS := -mips32r2 -march=mips32r2
ifeq ($(MT7621),y)
CPUFLAGS += -mtune=1004kc
endif

CFLAGS := -O3 -ffunction-sections -fdata-sections
CXXFLAGS := -O3 -ffunction-sections -fdata-sections
LDFLAGS := -Wl,--gc-sections

CROSS_ROOT = $(STAGEDIR)/mipsel-linux-uclibc
CROSS_COMPILE = $(CROSS_ROOT)/bin/mipsel-linux-uclibc-
CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++

all: dl extract
	make build

build:
	make build_boost
	make build_openssl
	make build_trojan

build_prepare:
	@mkdir -p $(STAGEDIR)/root

Boost_libs := date_time,program_options,system

build_boost: build_prepare
	( cd $(STAGEDIR)/$(Boost_SRC); \
		./bootstrap.sh --with-libraries=$(Boost_libs) --prefix=../root ; \
		echo "using gcc : mips : $(CXX) : <compileflags>\"$(CPUFLAGS)\" <cxxflags>\"$(CXXFLAGS)\" <cflags>\"$(CFLAGS)\" <linkflags>\"$(LDFLAGS)\" ;" >> project-config.jam ; \
		./b2 toolset=gcc-mips link=static variant=release runtime-link=shared install ; \
	)

OPENSSL_OPT = no-shared no-ssl3-method no-sm2 no-sm3 no-sm4 no-idea no-seed no-whirlpool no-deprecated no-tests

build_openssl: build_prepare
	( cd $(STAGEDIR)/$(OpenSSL_SRC); \
		./Configure linux-mips32 --prefix=/ $(OPENSSL_OPT) $(CPUFLAGS) $(CFLAGS) $(LDFLAGS) ; \
		make -j4 CROSS_COMPILE=$(CROSS_COMPILE) CC=$(CC) all ; \
		make CROSS_COMPILE=$(CROSS_COMPILE) CC=$(CC) DESTDIR=../root install_sw install_ssldirs ; \
	)

build_trojan: build_prepare
	( cd $(STAGEDIR)/$(Trojan_SRC); mkdir -p build ; cd build ; \
		CROSS_ROOT=$(CROSS_ROOT) STAGEDIR=$(STAGEDIR)/root \
		CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" CPUFLAGS="$(CPUFLAGS)" \
		cmake \
			-DCMAKE_TOOLCHAIN_FILE=$(DIR)/cross-mipsel-linux.cmake \
			-DBoost_USE_STATIC_LIBS=ON \
			-DENABLE_MYSQL=OFF \
			-DENABLE_REUSE_PORT=OFF \
			-DSYSTEMD_SERVICE=OFF \
			-DENABLE_STATIC=$(TROJAN_STATIC_BUILD) \
			.. ; \
		make -j4 && $(CROSS_COMPILE)strip trojan ; \
	)

clean:
	rm -rf $(STAGEDIR)

distclean: clean
	rm -rf $(DL_DIR)

include dl.mk
include extract.mk

