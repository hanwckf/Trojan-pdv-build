ifeq ($(TROJAN_PLUS),y)
Trojan_VERSION := master
Trojan_URL := https://github.com/Trojan-Plus-Group/trojan-plus.git
else
Trojan_VERSION := 1.16.0
Trojan_URL := https://github.com/trojan-gfw/trojan/archive/v$(Trojan_VERSION).tar.gz
endif

Trojan_SRC := trojan-$(Trojan_VERSION)

OpenSSL_VERSION := 1.1.1m
OpenSSL_SRC := openssl-$(OpenSSL_VERSION)
OpenSSL_URL := https://www.openssl.org/source/$(OpenSSL_SRC).tar.gz

Boost_VERSION_MAJOR := 1
Boost_VERSION_MINOR := 78
Boost_VERSION_PATCH := 0
Boost_SRC := boost_$(Boost_VERSION_MAJOR)_$(Boost_VERSION_MINOR)_$(Boost_VERSION_PATCH)
#Boost_URL := https://dl.bintray.com/boostorg/release/$(Boost_VERSION_MAJOR).$(Boost_VERSION_MINOR).$(Boost_VERSION_PATCH)/source/$(Boost_SRC).7z
Boost_URL := https://sourceforge.net/projects/boost/files/boost/$(Boost_VERSION_MAJOR).$(Boost_VERSION_MINOR).$(Boost_VERSION_PATCH)/$(Boost_SRC).7z

ifeq ($(ARCH),aarch64)
Toolchain_Archive := aarch64-linux-musl-cross.tgz
Toolchain_URL := https://more.musl.cc/10/x86_64-linux-musl/$(Toolchain_Archive)
TAR_EXT_ARGS = --strip-components 1
else
ifeq ($(ARCH),armhf)
Toolchain_Archive := armv7l-linux-musleabihf-cross.tgz
Toolchain_URL := https://more.musl.cc/10/x86_64-linux-musl/$(Toolchain_Archive)
TAR_EXT_ARGS = --strip-components 1
else
ifeq ($(ARCH),x86_64)
Toolchain_Archive := x86_64-linux-musl-cross.tgz
Toolchain_URL := https://more.musl.cc/10/x86_64-linux-musl/$(Toolchain_Archive)
TAR_EXT_ARGS = --strip-components 1
else
#Toolchain_Archive := mipsel-linux-uclibc.tar.xz
#Toolchain_URL := https://github.com/hanwckf/padavan-toolchain/releases/download/v1.1/$(Toolchain_Archive)
Toolchain_Archive := mipsel-linux-musl-cross.tgz
Toolchain_URL := https://more.musl.cc/10/x86_64-linux-musl/$(Toolchain_Archive)
TAR_EXT_ARGS = --strip-components 1
endif
endif
endif

.PHONY : dl

CURL = curl --create-dirs -L

dl: $(DL_DIR)/$(Trojan_SRC).tar.gz $(DL_DIR)/$(OpenSSL_SRC).tar.gz $(DL_DIR)/$(Boost_SRC).7z $(DL_DIR)/$(Toolchain_Archive)

$(DL_DIR)/$(Trojan_SRC).tar.gz:
ifneq ($(TROJAN_PLUS),y)
	$(CURL) $(Trojan_URL) -o $(DL_DIR)/$(Trojan_SRC).tar.gz
endif

$(DL_DIR)/$(OpenSSL_SRC).tar.gz:
	$(CURL) $(OpenSSL_URL) -o $(DL_DIR)/$(OpenSSL_SRC).tar.gz

$(DL_DIR)/$(Boost_SRC).7z:
	$(CURL) $(Boost_URL) -o $(DL_DIR)/$(Boost_SRC).7z

$(DL_DIR)/$(Toolchain_Archive):
	$(CURL) $(Toolchain_URL) -o $(DL_DIR)/$(Toolchain_Archive)

