prom: build/top.mcs

timing: build/top-routed.twr

usage: build/top-routed.xdl
	../../../tools/xdlanalyze.pl build/top-routed.xdl 0

load: build/top.bit
	cd build && impact -batch ../load.cmd

loadonly:
	cd build && impact -batch ../load.cmd

flash: build/top.mcs
	cd build && impact -batch ../flash.cmd

build/top.ncd: build/top.ngd
	cd build && map top.ngd

build/top-routed.ncd: build/top.ncd
	cd build && par -ol high -xe n -w top.ncd top-routed.ncd

build/top.bit: build/top-routed.ncd
	cd build && bitgen -w top-routed.ncd top.bit

build/top.mcs: build/top.bit
	cd build && promgen -w -u 0 top

build/top-routed.xdl: build/top-routed.ncd
	cd build && xdl -ncd2xdl top-routed.ncd top-routed.xdl

build/top-routed.twr: build/top-routed.ncd
	cd build && trce -v 10 top-routed.ncd top.pcf

sim:
	cd ../test && make gtk

lint:
	make -C ../test -f Makefile lint

clean:
	rm -rf build/*

.PHONY: prom timing usage load clean
