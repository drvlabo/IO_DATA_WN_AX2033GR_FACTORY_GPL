PO = client_list

include ../../build/config.mk
include ../../build/module.mk
include ../../build/gccconfig.mk

STAINFO_LDFLAGS    = -ldl
STAINFO_CFLAGS     =
STAINFO_BIN        = luci-stainfo
STAINFO_OBJ        = src/luci-stainfo.o

%.o: %.c
	$(COMPILE) $(STAINFO_CFLAGS) $(LUA_CFLAGS) $(FPIC) -c -o $@ $<

compile: build-clean $(STAINFO_OBJ)
	$(LINK) -o src/$(STAINFO_BIN) $(STAINFO_OBJ) $(STAINFO_LDFLAGS)
	mkdir -p dist/usr/bin
	cp src/$(STAINFO_BIN) dist/usr/bin/$(STAINFO_BIN)

install: build
	cp -pR dist/usr/bin/$(STAINFO_BIN) /usr/bin/$(STAINFO_BIN)

clean: build-clean

build-clean:
	rm -f src/*.o src/$(STAINFO_BIN)
