Trojan_VERSION := 1.14.1
Trojan_SRC := trojan-$(Trojan_VERSION)
Trojan_URL := https://github.com/trojan-gfw/trojan/archive/v$(Trojan_VERSION).tar.gz

OpenSSL_VERSION := 1.1.1d
OpenSSL_SRC := openssl-$(OpenSSL_VERSION)
OpenSSL_URL := https://www.openssl.org/source/$(OpenSSL_SRC).tar.gz

Boost_VERSION_MAJOR := 1
Boost_VERSION_MINOR := 72
Boost_VERSION_PATCH := 0
Boost_SRC := boost_$(Boost_VERSION_MAJOR)_$(Boost_VERSION_MINOR)_$(Boost_VERSION_PATCH)
#Boost_URL := https://dl.bintray.com/boostorg/release/$(Boost_VERSION_MAJOR).$(Boost_VERSION_MINOR).$(Boost_VERSION_PATCH)/source/$(Boost_SRC).7z
Boost_URL := https://sourceforge.net/projects/boost/files/boost/$(Boost_VERSION_MAJOR).$(Boost_VERSION_MINOR).$(Boost_VERSION_PATCH)/$(Boost_SRC).7z

Toolchain_URL := https://github.com/hanwckf/padavan-toolchain/releases/download/v1.1/mipsel-linux-uclibc.tar.xz
Toolchain_Archive := mipsel-linux-uclibc.tar.xz

.PHONY : dl

CURL = curl --create-dirs -L

dl: $(DL_DIR)/$(Trojan_SRC).tar.gz $(DL_DIR)/$(OpenSSL_SRC).tar.gz $(DL_DIR)/$(Boost_SRC).7z $(DL_DIR)/$(Toolchain_Archive)

$(DL_DIR)/$(Trojan_SRC).tar.gz:
	$(CURL) $(Trojan_URL) -o $(DL_DIR)/$(Trojan_SRC).tar.gz

$(DL_DIR)/$(OpenSSL_SRC).tar.gz:
	$(CURL) $(OpenSSL_URL) -o $(DL_DIR)/$(OpenSSL_SRC).tar.gz

$(DL_DIR)/$(Boost_SRC).7z:
	$(CURL) $(Boost_URL) -o $(DL_DIR)/$(Boost_SRC).7z

$(DL_DIR)/$(Toolchain_Archive):
	$(CURL) $(Toolchain_URL) -o $(DL_DIR)/$(Toolchain_Archive)

