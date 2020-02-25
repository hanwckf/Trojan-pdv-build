.PHONY: extract

extract: extract_prepare $(STAGEDIR)/mipsel-linux-uclibc $(STAGEDIR)/$(Trojan_SRC) $(STAGEDIR)/$(OpenSSL_SRC) $(STAGEDIR)/$(Boost_SRC)

extract_prepare:
	@mkdir -p $(STAGEDIR)

$(STAGEDIR)/mipsel-linux-uclibc:
	mkdir -p $(STAGEDIR)/mipsel-linux-uclibc
	tar -xf $(DL_DIR)/$(Toolchain_Archive) -C $(STAGEDIR)/mipsel-linux-uclibc

$(STAGEDIR)/$(Trojan_SRC):
	tar -xf $(DL_DIR)/$(Trojan_SRC).tar.gz -C $(STAGEDIR)

$(STAGEDIR)/$(OpenSSL_SRC):
	tar -xf $(DL_DIR)/$(OpenSSL_SRC).tar.gz -C $(STAGEDIR)

$(STAGEDIR)/$(Boost_SRC):
	7z x -bsp0 -o$(STAGEDIR) $(DL_DIR)/$(Boost_SRC).7z

