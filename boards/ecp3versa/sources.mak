BOARD_SRC=$(wildcard ../rtl/*.v)

ASFIFO_SRC=../cores/asfifo9/asfifo9.v
SIM_ASFIFO_SRC=$(wildcard ../../../cores/asfifo/rtl/*.v)
CRC_SRC=$(wildcard ../../../cores/crc/rtl/*.v)
FILTER_SRC=$(wildcard ../../../cores/filter/rtl/*.v)

SIM_CORES_SRC=$(SIM_ASFIFO_SRC) $(CRC_SRC) $(FILTER_SRC)
CORES_SRC=$(ASFIFO_SRC) $(CRC_SRC) $(FILTER_SRC)
