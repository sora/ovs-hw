SOURCES=tb_lookupflow.v $(wildcard ../rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_lookupflow
	./tb_lookupflow

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_lookupflow verilog.log test.vcd

tb_lookupflow: $(SOURCES)
	iverilog -o tb_lookupflow $(SOURCES)

.PHONY: clean isim cversim gtk
