CROSS_COMPILE ?= aarch64-linux-gnu-
MKDIR ?= mkdir -p
CP ?= cp
CAT ?= cat
TAR ?= tar
PWD = $(shell pwd)
SUDO ?= $(and $(filter pip,$(shell whoami)),sudo)
NATIVE_TRIPLE ?= amd64-linux-gnu

all: build/busybocs.tar

%/:
	$(MKDIR) $@

clean:
	rm -rf build

build/busybocs.tar: build/done/install/emacs build/done/install/busybox build/done/install/kexec-tools build/done/install/memtool
	rm -rf build/install/share/info
	rm -rf build/install/share/emacs/*/lisp/gnus
	rm -rf build/install/share/emacs/*/lisp/cedet
	rm -rf build/install/share/emacs/*/lisp/leim
	rm -rf build/install/share/emacs/*/etc/images
	rm -rf build/install/share/emacs/*/lisp/erc
	rm -rf build/install/share/emacs/*/etc/tutorials
	rm -rf build/install/share/emacs/*/lisp/emulation
	rm -rf build/install/lib/*.a
	rm -rf build/install/include
	rm -rf build/install/share/icons
	tar -C build/install -cvf $@ .

build/done/install/memtool: build/done/build/memtool | build/done/install/
	$(MAKE) -C build/memtool install
	touch $@

build/done/build/memtool: build/done/configure/memtool | build/done/build/
	$(MAKE) -C build/memtool
	touch $@

build/done/configure/memtool: build/done/copy/memtool | build/done/configure/
	(cd build/memtool; autoreconf -fi)
	(cd build/memtool; ./configure --host=aarch64-linux-gnu --prefix=$(PWD)/build/install)
	touch $@

build/done/copy/memtool: | build/memtool/ build/done/copy/
	cp -a subrepo/memtool/* build/memtool
	touch $@

build/done/install/kexec-tools: build/done/build/kexec-tools | build/done/install/
	$(MAKE) -C build/kexec-tools install
	touch $@

build/done/build/kexec-tools: build/done/configure/kexec-tools | build/done/build/
	$(MAKE) -C build/kexec-tools
	touch $@

build/done/configure/kexec-tools: build/done/copy/kexec-tools | build/done/configure/
	(cd build/kexec-tools; autoreconf -fi)
	(cd build/kexec-tools; ./configure --host=aarch64-linux-gnu --prefix=$(PWD)/build/install)
	touch $@

build/done/copy/kexec-tools: | build/kexec-tools/ build/done/copy/
	cp -a subrepo/kexec-tools/* build/kexec-tools
	touch $@

build/done/install/busybox: build/done/build/busybox | build/done/install/
	$(MAKE) -C build/busybox install
	touch $@

build/done/build/busybox: build/done/configure/busybox | build/done/build/
	$(MAKE) -C build/busybox
	touch $@

build/done/configure/busybox: build/done/copy/busybox | build/done/configure/
	$(MAKE) -C build/busybox defconfig
	touch $@

build/done/copy/busybox: | build/busybox/ build/done/copy/
	cp -a subrepo/busybox/* build/busybox
	touch $@

build/done/install/emacs: build/done/build/emacs | build/done/install/
	$(MAKE) -C build/emacs DESTDIR=$(PWD)/build/install/ install
	touch $@

build/done/build/emacs: build/done/configure/emacs | build/done/build/
	$(MAKE) -C build/emacs/src emacs
	touch $@

build/done/configure/emacs: build/done/clean0/emacs build/done/install/ncurses | build/done/configure/
	(cd build/emacs; sh autogen.sh)
	(cd build/emacs; ./configure --without-all --without-json --without-x --host=aarch64-linux-gnu LDFLAGS="-L$(PWD)/build/install/lib" CFLAGS="-static" --target=aarch64-linux-gnu --prefix=/)
	touch $@

build/done/clean0/emacs: build/done/build0/emacs | build/done/clean0/
	$(MAKE) -C build/emacs mostlyclean
	touch $@

build/done/build0/emacs: build/done/configure0/emacs | build/done/build0/
	$(MAKE) -C build/emacs
	touch $@

build/done/configure0/emacs: build/done/copy/emacs | build/done/configure0/
	(cd build/emacs; sh autogen.sh)
	(cd build/emacs; ./configure --without-all --without-json --without-x --prefix=/)
	touch $@

build/done/copy/emacs: | build/emacs/ build/done/copy/
	cp -a subrepo/emacs/* build/emacs
	touch $@

build/done/install/ncurses: build/done/build/ncurses | build/done/install/
	$(MAKE) -C build/ncurses install
	touch $@

build/done/build/ncurses: build/done/configure/ncurses | build/done/build/
	$(MAKE) -C build/ncurses
	touch $@

build/done/configure/ncurses: build/done/copy/ncurses | build/done/configure/
	(cd build/ncurses; ./configure --host=aarch64-linux-gnu --target=aarch64-linux-gnu --prefix=$(PWD)/build/install --disable-stripping)
	touch $@

build/done/copy/ncurses: | build/ncurses/ build/done/copy/
	cp -a subrepo/ncurses/* build/ncurses
	touch $@

include github/github.mk
