BASEDIR=${CURDIR}

SYNTOOL?=xst
BOARD?=netfpga

bit: tools
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile

load: bit
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile load

test:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile sim

lint:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile lint

doc:
	make -C ${BASEDIR}/doc/block_diagram -f Makefile

.PHONY: clean load-bitstream tools doc lint test
clean:
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f common.mak clean
	make -C ${BASEDIR}/boards/${BOARD}/synthesis -f Makefile clean
	make -C ${BASEDIR}/doc/block_diagram -f Makefile clean
