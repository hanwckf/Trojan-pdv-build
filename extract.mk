.PHONY: extract

extract: extract_prepare $(STAGEDIR)/toolchain $(STAGEDIR)/$(Trojan_SRC) $(STAGEDIR)/$(OpenSSL_SRC) $(STAGEDIR)/$(Boost_SRC)

extract_prepare:
	@mkdir -p $(STAGEDIR)

$(STAGEDIR)/toolchain:
	mkdir -p $(STAGEDIR)/toolchain
	tar -xf $(DL_DIR)/$(Toolchain_Archive) -C $(STAGEDIR)/toolchain

$(STAGEDIR)/$(Trojan_SRC):
	tar -xf $(DL_DIR)/$(Trojan_SRC).tar.gz -C $(STAGEDIR)

$(STAGEDIR)/$(OpenSSL_SRC):
	tar -xf $(DL_DIR)/$(OpenSSL_SRC).tar.gz -C $(STAGEDIR)
	for p in $$(ls patches/openssl/*.patch); do patch -p1 -d $(STAGEDIR)/$(OpenSSL_SRC) < $$p; done

$(STAGEDIR)/$(Boost_SRC):
	7z x -bsp0 -o$(STAGEDIR) $(DL_DIR)/$(Boost_SRC).7z

