DIR := $(shell pwd)
STAGEDIR := $(DIR)/stage
DL_DIR := $(DIR)/dl

BUILD_STATIC ?= n
ARCH ?= mips24kec

TROJAN_REUSEPORT := ON
ifeq ($(ENABLE_REUSEPORT),n)
TROJAN_REUSEPORT := OFF
endif

CPU_OVERLOAD	= 1
HOST_NCPU = $(shell if [ -f /proc/cpuinfo ]; then n=`grep -c processor /proc/cpuinfo`; if [ $$n -gt 1 ];then expr $$n \* ${CPU_OVERLOAD}; else echo $$n; fi; else echo 1; fi)

CFLAGS := -O3 -ffunction-sections -fdata-sections
CXXFLAGS := -O3 -ffunction-sections -fdata-sections
LDFLAGS := -Wl,--gc-sections

CROSS_ROOT = $(STAGEDIR)/toolchain/$(ARCH)
ifeq ($(ARCH),aarch64)
CROSS_COMPILE := $(CROSS_ROOT)/bin/aarch64-linux-musl-
OPENSSL_ARCH := linux-aarch64
else
ifeq ($(ARCH),armhf)
CROSS_COMPILE := $(CROSS_ROOT)/bin/armv7l-linux-musleabihf-
OPENSSL_ARCH := linux-generic32
CFLAGS += -DOPENSSL_PREFER_CHACHA_OVER_GCM
CXXFLAGS += -Wno-psabi
else
ifeq ($(ARCH),mips1004kec)
CPUFLAGS := -mips32r2 -march=mips32r2 -mtune=1004kc
CFLAGS += -DOPENSSL_PREFER_CHACHA_OVER_GCM
#CROSS_COMPILE := $(CROSS_ROOT)/bin/mipsel-linux-uclibc-
CROSS_COMPILE := $(CROSS_ROOT)/bin/mipsel-linux-musl-
OPENSSL_ARCH := linux-mips32
else
ifeq ($(ARCH),mips24kec)
CPUFLAGS := -mips32r2 -march=mips32r2
CFLAGS += -DOPENSSL_PREFER_CHACHA_OVER_GCM
#CROSS_COMPILE := $(CROSS_ROOT)/bin/mipsel-linux-uclibc-
CROSS_COMPILE := $(CROSS_ROOT)/bin/mipsel-linux-musl-
OPENSSL_ARCH := linux-mips32
else
ifeq ($(ARCH),x86_64)
CROSS_COMPILE := $(CROSS_ROOT)/bin/x86_64-linux-musl-
OPENSSL_ARCH := linux-x86_64
endif
endif
endif
endif
endif

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++

help:
	@echo "Usage: make all [ARCH=x86_64|mips24kec|mips1004kec|aarch64|armhf] [BUILD_STATIC=y|N] [ENABLE_REUSEPORT=Y|n]"

all: dl extract
	make build
	cp -f $(STAGEDIR)/$(Trojan_SRC)/build/trojan trojan

build:
	make build_boost
	make build_openssl
	make build_trojan

build_prepare:
	@mkdir -p $(STAGEDIR)/root

#Boost_libs := date_time,program_options,system
Boost_libs := date_time,program_options,system,atomic,contract,chrono,exception,iostreams,random,thread,timer

build_boost: build_prepare
	( cd $(STAGEDIR)/$(Boost_SRC); \
		./bootstrap.sh --with-libraries=$(Boost_libs) --prefix=../root ; \
		echo "using gcc : cross : $(CXX) : <compileflags>\"$(CPUFLAGS)\" <cxxflags>\"$(CXXFLAGS)\" <cflags>\"$(CFLAGS)\" <linkflags>\"$(LDFLAGS)\" ;" >> project-config.jam ; \
		./b2 -d 0 -j $(HOST_NCPU) toolset=gcc-cross link=static variant=release runtime-link=shared install ; \
	)

OPENSSL_OPT = no-shared no-ssl3-method no-sm2 no-sm3 no-sm4 \
  no-idea no-seed no-whirlpool no-deprecated no-tests no-pic \
  no-engine no-comp no-gost no-dtls no-mdc2 no-aria no-cms \
  no-rfc3779 no-blake2 no-psk no-srp no-sse2 no-cast

build_openssl: build_prepare
	( cd $(STAGEDIR)/$(OpenSSL_SRC); \
		./Configure $(OPENSSL_ARCH) --prefix=/ $(OPENSSL_OPT) $(CPUFLAGS) $(CFLAGS) $(LDFLAGS) ; \
		make -j$(HOST_NCPU) CROSS_COMPILE=$(CROSS_COMPILE) CC=$(CC) all ; \
		make CROSS_COMPILE=$(CROSS_COMPILE) CC=$(CC) DESTDIR=../root install_sw install_ssldirs ; \
	)

TROJAN_LDFLAGS := $(LDFLAGS)
ifeq ($(BUILD_STATIC),y)
TROJAN_LDFLAGS += -static
endif

build_trojan: build_prepare
	( cd $(STAGEDIR)/$(Trojan_SRC); mkdir -p build ; cd build ; \
		CROSS_ROOT=$(CROSS_ROOT) CC=$(CC) CXX=$(CXX) STAGEDIR=$(STAGEDIR)/root \
		CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(TROJAN_LDFLAGS)" CPUFLAGS="$(CPUFLAGS)" \
		cmake \
			-DCMAKE_TOOLCHAIN_FILE=$(DIR)/cross-linux.cmake \
			-DBoost_USE_STATIC_LIBS=ON \
			-DENABLE_MYSQL=OFF \
			-DENABLE_REUSE_PORT=$(TROJAN_REUSEPORT) \
			-DFORCE_TCP_FASTOPEN=ON \
			-DSYSTEMD_SERVICE=OFF \
			.. ; \
		make -j$(HOST_NCPU) && $(CROSS_COMPILE)strip trojan ; \
	)

clean_trojan:
	rm -rf $(STAGEDIR)/$(Trojan_SRC)/build

clean:
	rm -rf $(STAGEDIR) trojan

distclean: clean
	rm -rf $(DL_DIR)

include dl.mk
include extract.mk

