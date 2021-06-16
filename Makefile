CROSS_COMPILE ?= aarch64-linux-gnu-
MKDIR ?= mkdir -p
CP ?= cp
CAT ?= cat
TAR ?= tar
PWD = $(shell pwd)
SUDO ?= $(and $(filter pip,$(shell whoami)),sudo)
NATIVE_TRIPLE ?= amd64-linux-gnu

MY_CFLAGS = -Os --sysroot=$(PWD)/build/busybocs/install -B$(PWD)/build/busybocs/install -L$(PWD)/build/busybocs/install/lib -I$(PWD)/build/busybocs/install/include

all: build/busybocs.tar

%/:
	$(MKDIR) $@

clean:
	rm -rf build

build/targets: Makefile | build/
	egrep '^build\/.*?:' $< | while read TARGET DEPS; do echo $$TARGET | sed -e 's/:$$//g'; done > $@

build/busybocs.tar: build/busybocs/done/clean
	tar -C build/busybocs/clean -cf $@ .

build/busybocs/done/install: build/emacs/done/install build/busybox/done/install build/kexec-tools/done/install build/memtool/done/install build/cryptsetup/done/install build/wpa_supplicant/done/install build/lvm2/done/install build/perl/done/install | build/busybocs/done/
	touch $@

build/busybocs/done/clean: build/busybocs/done/install | build/busybocs/clean/
	cp -a build/busybocs/install/* build/busybocs/clean/
	chmod u+w -R build/busybocs/clean
	rm -rf build/busybocs/clean/bin/aarch64-linux-gnu-*
	rm -rf build/busybocs/clean/bin/ctags
	rm -rf build/busybocs/clean/bin/etags
	rm -rf build/busybocs/clean/bin/emacsclient
	rm -rf build/busybocs/clean/bin/locale
	rm -rf build/busybocs/clean/bin/localedef
	rm -rf build/busybocs/clean/bin/openssl
	rm -rf build/busybocs/clean/bin/ncurses6-config
	rm -rf build/busybocs/clean/bin/mtrace
	rm -rf build/busybocs/clean/bin/ebrowse
	rm -rf build/busybocs/clean/lib/cmake
	rm -rf build/busybocs/clean/lib/cmake
	rm -rf build/busybocs/clean/lib/pkgconfig
	rm -rf build/busybocs/clean/share/doc
	rm -rf build/busybocs/clean/share/i18n
	rm -rf build/busybocs/clean/share/info
	rm -rf build/busybocs/clean/share/locale
	rm -rf build/busybocs/clean/share/man
	rm -rf build/busybocs/clean/share/emacs/*/lisp/gnus
	rm -rf build/busybocs/clean/share/emacs/*/lisp/cedet
	rm -rf build/busybocs/clean/share/emacs/*/lisp/leim
	rm -rf build/busybocs/clean/share/emacs/*/etc/images
	rm -rf build/busybocs/clean/share/emacs/*/lisp/erc
	rm -rf build/busybocs/clean/share/emacs/*/etc/tutorials
	rm -rf build/busybocs/clean/share/emacs/*/lisp/emulation
	rm -rf build/busybocs/clean/lib/*.a
	rm -rf build/busybocs/clean/include
	rm -rf build/busybocs/clean/share/icons
	rm -rf build/busybocs/clean/libexec/emacs/*/*/hexl
	rm -rf build/busybocs/clean/libexec/emacs/*/*/movemail
	rm -rf build/busybocs/clean/libexec/emacs/*/*/rcs2log
	rm -rf build/busybocs/clean/libexec/getconf
	rm -rf build/busybocs/clean/sbin/zic
	rm -rf build/busybocs/clean/sbin/veritysetup
	for a in build/busybocs/clean/bin/* build/busybocs/clean/sbin/*; do aarch64-linux-gnu-strip $$a || true; done
	touch $@

build/memtool/done/install: build/memtool/done/build | build/memtool/done/ build/busybocs/install/
	$(MAKE) -C build/memtool/build install
	touch $@

build/memtool/done/build: build/memtool/done/configure | build/memtool/done/
	$(MAKE) -C build/memtool/build
	touch $@

build/memtool/done/configure: build/memtool/done/copy build/glibc/done/install | build/memtool/done/
	(cd build/memtool/build; autoreconf -fi)
	(cd build/memtool/build; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=$(PWD)/build/busybocs/install CFLAGS="$(MY_CFLAGS)")
	touch $@

build/memtool/done/copy: | build/memtool/build/ build/memtool/done/
	cp -a subrepo/memtool/* build/memtool/build
	touch $@

build/kexec-tools/done/install: build/kexec-tools/done/build | build/kexec-tools/done/ build/busybocs/install/
	$(MAKE) -C build/kexec-tools/build install
	touch $@

build/kexec-tools/done/build: build/kexec-tools/done/configure | build/kexec-tools/done/
	$(MAKE) -C build/kexec-tools/build
	touch $@

build/kexec-tools/done/configure: build/kexec-tools/done/copy build/glibc/done/install | build/kexec-tools/done/
	(cd build/kexec-tools/build; autoreconf -fi)
	(cd build/kexec-tools/build; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu CFLAGS="$(MY_CFLAGS)" --prefix=$(PWD)/build/busybocs/install)
	touch $@

build/kexec-tools/done/copy: | build/kexec-tools/build/ build/kexec-tools/done/
	cp -a subrepo/kexec-tools/* build/kexec-tools/build
	touch $@

build/busybox/done/install: build/busybox/done/build | build/busybox/done/ build/busybocs/install/
	$(MAKE) -C build/busybox/build CROSS_COMPILE=aarch64-linux-gnu- CFLAGS="$(MY_CFLAGS)" install
	touch $@

build/busybox/done/build: build/busybox/done/configure | build/busybox/done/
	$(MAKE) -C build/busybox/build CROSS_COMPILE=aarch64-linux-gnu- CFLAGS="$(MY_CFLAGS)"
	touch $@

build/busybox/done/configure: build/busybox/done/copy build/glibc/done/install | build/busybox/done/
	$(MAKE) -C build/busybox/build CROSS_COMPILE=aarch64-linux-gnu- CFLAGS="$(MY_CFLAGS)" defconfig
	touch $@

build/busybox/done/copy: | build/busybox/build/ build/busybox/done/
	cp -a subrepo/busybox/* build/busybox/build
	touch $@

build/emacs/done/install: build/emacs/done/build | build/ build/busybocs/install/
	QEMU_LD_PREFIX=$(PWD)/build/busybocs/install LD_LIBRARY_PATH=$(PWD)/build/busybocs/install/lib $(MAKE) -C build/emacs/build DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/emacs/done/build: build/emacs/done/configure | build/emacs/done/
	QEMU_LD_PREFIX=$(PWD)/build/busybocs/install LD_LIBRARY_PATH=$(PWD)/build/busybocs/install/lib $(MAKE) -C build/emacs/build/src emacs
	touch $@

build/emacs/done/configure: build/emacs/done/clean0 build/ncurses/done/install build/glibc/done/install | build/emacs/done/
	(cd build/emacs/build; sh autogen.sh)
	(cd build/emacs/build; ./configure --without-all --without-json --without-x --host=aarch64-linux-gnu CFLAGS="$(MY_CFLAGS)" LDFLAGS="-L$(PWD)/build/busybocs/install/lib" --enable-optimize="-Os" --target=aarch64-linux-gnu --prefix=/)
	touch $@

build/emacs/done/clean0: build/emacs/done/copy0 | build/emacs/done/
	$(MAKE) -C build/emacs/build mostlyclean
	touch $@

build/emacs/done/copy0: build/emacs/done/build0 | build/emacs/done/ build/emacs/build/
	$(CP) -a build/emacs/build0/* build/emacs/build
	touch $@

build/emacs/done/build0: build/emacs/done/configure0 | build/emacs/done/
	$(MAKE) -C build/emacs/build0
	touch $@

build/emacs/done/configure0: build/emacs/done/copy | build/emacs/done/
	(cd build/emacs/build0; sh autogen.sh)
	(cd build/emacs/build0; ./configure --without-all --without-json --without-x --prefix=/)
	touch $@

build/emacs/done/copy: | build/emacs/build0/ build/emacs/done/
	cp -a subrepo/emacs/* build/emacs/build0
	touch $@

build/ncurses/done/install: build/ncurses/done/build | build/ncurses/done/ build/busybocs/install/
	$(MAKE) -C build/ncurses/build install
	touch $@

build/ncurses/done/build: build/ncurses/done/configure | build/ncurses/done/
	$(MAKE) -C build/ncurses/build
	touch $@

build/ncurses/done/configure: build/ncurses/done/copy build/glibc/done/install | build/ncurses/done/
	(cd build/ncurses/build; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ --with-install-prefix=$(PWD)/build/busybocs/install --disable-stripping CFLAGS="$(MY_CFLAGS)" CXXFLAGS="$(MY_CFLAGS)")
	touch $@

build/ncurses/done/copy: | build/ncurses/build/ build/ncurses/done/
	cp -a subrepo/ncurses/* build/ncurses/build
	touch $@

build/glibc/done/install: build/glibc/done/build | build/glibc/done/ build/busybocs/install/
	$(MAKE) -C build/glibc/build DESTDIR=$(PWD)/build/busybocs/install/ install
	sudo cp -a $(PWD)/build/busybocs/install/lib/* /usr/aarch64-linux-gnu/lib
	touch $@

build/glibc/done/build: build/glibc/done/configure | build/glibc/done/
	$(MAKE) -C build/glibc/build
	touch $@

build/glibc/done/configure: build/glibc/done/copy | build/glibc/done/
	$(MKDIR) build/glibc/build/
	(cd build/glibc/build; $(PWD)/build/glibc/configure/configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ --host=aarch64-linux-gnu --target=aarch64-linux-gnu CFLAGS="$(MY_CFLAGS)")
	touch $@

build/glibc/done/copy: | build/glibc/configure/ build/glibc/done/
	cp -a subrepo/glibc/* build/glibc/configure
	touch $@

build/libnl/done/install: build/libnl/done/build | build/libnl/done/ build/busybocs/install/
	$(MAKE) -C build/libnl/build DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/libnl/done/build: build/libnl/done/configure | build/libnl/done/
	$(MAKE) -C build/libnl/build
	touch $@

build/libnl/done/configure: build/libnl/done/copy build/glibc/done/install | build/libnl/done/
	(cd build/libnl/build; sh autogen.sh)
	(cd build/libnl/build; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS)" LDFLAGS="-L$(PWD)/build/busybocs/install/lib")
	touch $@

build/libnl/done/copy: | build/libnl/build/ build/libnl/done/
	cp -a subrepo/libnl/* build/libnl/build
	touch $@

build/lvm2/done/install: build/lvm2/done/build | build/lvm2/done/ build/busybocs/install/
	$(MAKE) -C build/lvm2/build DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/lvm2/done/build: build/lvm2/done/configure | build/lvm2/done/
	$(MAKE) -C build/lvm2/build
	touch $@

build/lvm2/done/configure: build/lvm2/done/copy build/libaio/done/install build/libblkid/done/install build/glibc/done/install | build/lvm2/done/
	(cd build/lvm2/build; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS) -I." LDFLAGS="-L$(PWD)/build/busybocs/install/lib")
	touch $@

build/lvm2/done/copy: | build/lvm2/build/ build/lvm2/done/
	cp -a subrepo/lvm2/* build/lvm2/build
	touch $@

build/libblkid/done/install: build/libblkid/done/build | build/libblkid/done/ build/busybocs/install/
	$(MAKE) -C build/libblkid/build DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/libblkid/done/build: build/libblkid/done/configure | build/libblkid/done/
	$(MAKE) -C build/libblkid/build
	touch $@

build/libblkid/done/configure: build/libblkid/done/copy build/glibc/done/install | build/libblkid/done/
	(cd build/libblkid/build; autoreconf -fi)
	(cd build/libblkid/build; ./configure --disable-all-programs --enable-libblkid --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS)" LDFLAGS="-L$(PWD)/build/busybocs/install/lib")
	touch $@

build/libblkid/done/copy: | build/libblkid/build/ build/libblkid/done/
	cp -a subrepo/util-linux/* build/libblkid/build
	touch $@

build/libuuid/done/install: build/libuuid/done/build | build/libuuid/done/ build/busybocs/install/
	$(MAKE) -C build/libuuid/build DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/libuuid/done/build: build/libuuid/done/configure | build/libuuid/done/
	$(MAKE) -C build/libuuid/build
	touch $@

build/libuuid/done/configure: build/libuuid/done/copy build/glibc/done/install | build/libuuid/done/
	(cd build/libuuid/build; autoreconf -fi)
	(cd build/libuuid/build; ./configure --disable-all-programs --enable-libuuid --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS)" LDFLAGS="-L$(PWD)/build/busybocs/install/lib")
	touch $@

build/libuuid/done/copy: | build/libuuid/build/ build/libuuid/done/
	cp -a subrepo/util-linux/* build/libuuid/build
	touch $@

build/libaio/done/install: build/libaio/done/build | build/libaio/done/ build/ build/busybocs/install/
	$(MAKE) -C build/libaio/build CC=aarch64-linux-gnu-gcc CFLAGS="$(MY_CFLAGS) -I." DESTDIR=$(PWD)/build/busybocs/install/ install
	touch $@

build/libaio/done/build: build/libaio/done/copy build/glibc/done/install | build/libaio/done/
	$(MAKE) -C build/libaio/build CC=aarch64-linux-gnu-gcc CFLAGS="$(MY_CFLAGS) -I."
	touch $@

build/libaio/done/copy: | build/libaio/build/ build/libaio/done/
	cp -a subrepo/libaio/* build/libaio/build
	touch $@

build/wpa_supplicant/done/install: build/wpa_supplicant/done/build | build/wpa_supplicant/done/ build/ build/busybocs/install/
	$(MAKE) -C build/wpa_supplicant/build/wpa_supplicant LIBDIR=$(PWD)/build/busybocs/install/lib INCDIR=$(PWD)/build/busybocs/install/include BINDIR=$(PWD)/build/busybocs/install/sbin install
	touch $@

build/wpa_supplicant/done/build: build/wpa_supplicant/done/configure | build/wpa_supplicant/done/
	$(MAKE) -C build/wpa_supplicant/build/wpa_supplicant CC=aarch64-linux-gnu-gcc EXTRA_CFLAGS="$(MY_CFLAGS) -I$(PWD)/build/busybocs/install/include/libnl3" LDFLAGS="--sysroot=$(PWD)/build/busybocs/install -I$(PWD)/build/busybocs/install/include -L$(PWD)/build/busybocs/install/lib"
	touch $@

build/wpa_supplicant/done/configure: build/wpa_supplicant/done/copy build/openssl/done/install build/libnl/done/install build/glibc/done/install | build/wpa_supplicant/done/
	sed -i -e 's/^CONFIG_CTRL_IFACE_DBUS/# CONFIG_CTRL_IFACE_DBUS/g' build/wpa_supplicant/build/wpa_supplicant/defconfig
	$(CP) build/wpa_supplicant/build/wpa_supplicant/defconfig build/wpa_supplicant/build/wpa_supplicant/.config
	touch $@

build/wpa_supplicant/done/copy: | build/wpa_supplicant/build/ build/wpa_supplicant/done/
	cp -a subrepo/wpa/* build/wpa_supplicant/build/
	touch $@

build/openssl/done/install: build/openssl/done/build | build/openssl/done/ build/busybocs/install/
	$(MAKE) -C build/openssl/build install
	touch $@

build/openssl/done/build: build/openssl/done/configure | build/openssl/done/
	$(MAKE) CFLAGS="$(MY_CFLAGS)" -C build/openssl/build
	touch $@

build/openssl/done/configure: build/openssl/done/copy build/glibc/done/install | build/openssl/done/
	(cd build/openssl/build/; CC=aarch64-linux-gnu-gcc CFLAGS="$(MY_CFLAGS)" ./Configure linux-aarch64 --prefix=$(PWD)/build/busybocs/install)
	touch $@

build/openssl/done/copy: | build/openssl/build/ build/openssl/done/
	cp -a subrepo/openssl/* build/openssl/build/
	touch $@

build/cryptsetup/done/install: build/cryptsetup/done/build | build/cryptsetup/done/ build/busybocs/install/
	$(MAKE) -C build/cryptsetup/build DESTDIR=$(PWD)/build/busybocs/install install
	touch $@

build/cryptsetup/done/build: build/cryptsetup/done/configure | build/cryptsetup/done/
	$(MAKE) -C build/cryptsetup/build
	touch $@

build/cryptsetup/done/configure: build/cryptsetup/done/copy build/libuuid/done/install build/json-c/done/install build/popt/done/install build/libblkid/done/install build/lvm2/done/install build/openssl/done/install build/glibc/done/install | build/cryptsetup/done/
	(cd build/cryptsetup/build; sh autogen.sh)
	(cd build/cryptsetup/build; ./configure --target=aarch64-linux-gnu --host=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS)"  JSON_C_CFLAGS="-I$(PWD)/build/busybocs/install/include" JSON_C_LIBS="-ljson-c")
	touch $@

build/cryptsetup/done/copy: | build/cryptsetup/build/ build/cryptsetup/done/
	cp -a subrepo/cryptsetup/* build/cryptsetup/build/
	touch $@

build/popt/done/install: build/popt/done/build | build/popt/done/ build/busybocs/install/
	$(MAKE) -C build/popt/build DESTDIR="$(PWD)/build/busybocs/install" install
	touch $@

build/popt/done/build: build/popt/done/configure | build/popt/done/
	$(MAKE) -C build/popt/build
	touch $@

build/popt/done/configure: build/popt/done/copy build/libuuid/done/install build/glibc/done/install | build/popt/done/
	(cd build/popt/build; sh autogen.sh)
	(cd build/popt/build; ./configure --target=aarch64-linux-gnu --host=aarch64-linux-gnu --prefix=/ CFLAGS="$(MY_CFLAGS)")
	touch $@

build/popt/done/copy: | build/popt/build/ build/popt/done/
	cp -a subrepo/popt/* build/popt/build/
	touch $@

build/json-c/done/install: build/json-c/done/build | build/json-c/done/ build/busybocs/install/
	$(MAKE) -C build/json-c/build DESTDIR="$(PWD)/build/busybocs/install" install
	touch $@

build/json-c/done/build: build/json-c/done/configure | build/json-c/done/
	$(MAKE) CC=aarch64-linux-gnu-gcc -C build/json-c/build
	touch $@

build/json-c/done/configure: build/json-c/done/copy build/libuuid/done/install build/glibc/done/install | build/json-c/done/
	(cd build/json-c/build; cmake -DCMAKE_LINKER=aarch64-linux-gnu-ld CMAKE_SHARED_LINKER=aarch64-linux-gnu-ld -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_C_FLAGS="-I$(PWD)/build/busybocs/install/include -L$(PWD)/build/busybocs/install/lib --sysroot=$(PWD)/build/busybocs/install" .)
	touch $@

build/json-c/done/copy: | build/json-c/build/ build/json-c/done/
	cp -a subrepo/json-c/* build/json-c/build/
	touch $@

build/perl/done/install: build/perl/done/build | build/perl/done/
	QEMU_LD_PREFIX=$(PWD)/build/busybocs/install LD_LIBRARY_PATH=$(PWD)/build/busybocs/install/lib $(MAKE) -C build/perl/build install
	touch $@

build/perl/done/build: build/perl/done/configure | build/perl/done/
	QEMU_LD_PREFIX=$(PWD)/build/busybocs/install LD_LIBRARY_PATH=$(PWD)/build/busybocs/install/lib $(MAKE) -C build/perl/build
	touch $@

build/perl/done/configure: build/perl/done/copy build/glibc/done/install | build/perl/done/
	(cd build/perl/build; QEMU_LD_PREFIX=$(PWD)/build/busybocs/install LD_LIBRARY_PATH=$(PWD)/build/busybocs/install/lib sh ./Configure -der -Uversiononly -Uusemymalloc -Dcc="aarch64-linux-gnu-gcc $(MY_CFLAGS)" -Dccflags="$(MY_CFLAGS)" -Doptimize="$(MY_CFLAGS) -fno-strict-aliasing" -Dincpth='' -Dcccdlflags="-fPIC -Wl,--shared -shared" -Dlddlflags="-Wl,--shared -shared" -Dusedevel -Dprefix="$(PWD)/build/busybocs/install")
	touch $@

build/perl/done/copy: | build/perl/build/ build/perl/done/
	cp -a subrepo/perl/* $(addprefix subrepo/perl/.,dir-locals.el editorconfig lgtm.yml metaconf-exclusions.txt travis.yml) build/perl/build/
	touch $@

build/busybocs/install/:
	$(MKDIR) $@
	ln -sf . $@/usr
	ln -sf . $@/local

include github/github.mk
