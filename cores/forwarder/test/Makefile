SOURCES=tb_forwarder.v $(wildcard ../rtl/*.v) $(wildcard ../../sfifo/rtl/*.v) $(wildcard ../../lookupflow/rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_forwarder
	./tb_forwarder

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_forwarder verilog.log test.vcd

tb_forwarder: $(SOURCES)
	iverilog -o tb_forwarder $(SOURCES)

.PHONY: clean isim cversim gtk
