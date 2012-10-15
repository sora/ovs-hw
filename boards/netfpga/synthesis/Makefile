BOARD_DIR=../rtl
CORES_DIR=../../../cores

include ../sources.mak
SRC=$(BOARD_SRC) $(CORES_SRC)

all: build/top.bit

build/top.ucf: common.ucf xst.ucf
	cat common.ucf xst.ucf > build/top.ucf

build/top.prj: $(SRC)
	rm -f build/top.prj
	for i in `echo $^`; do \
	    echo "verilog work ../$$i" >> build/top.prj; \
	done

build/top.ngc: build/top.prj
	cd build && xst -ifn ../top.xst
	cp -p ../../../cores/coregen/*.ngc build/.

build/top.ngd: build/top.ngc build/top.ucf
	cd build && ngdbuild -uc top.ucf top.ngc

include common.mak

