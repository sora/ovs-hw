BASEDIR=${CURDIR}

SYNTOOL?=xst
BOARD?=netfpga

bit: tools
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile

load: bitstream
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile load

test:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile sim

lint:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile lint

.PHONY: clean load-bitstream tools
clean:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f common.mak clean
