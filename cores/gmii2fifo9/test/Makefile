SOURCES=tb_gmii2fifo9.v $(wildcard ../rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_gmii2fifo9
	./tb_gmii2fifo9

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_gmii2fifo9 verilog.log test.vcd

tb_gmii2fifo9: $(SOURCES)
	iverilog -o tb_gmii2fifo9 $(SOURCES)

.PHONY: clean isim cversim gtk
