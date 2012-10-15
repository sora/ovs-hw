SOURCES=tb_fifo9togmii.v $(wildcard ../rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_fifo9togmii
	./tb_fifo9togmii

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_fifo9togmii verilog.log test.vcd

tb_fifo9togmii: $(SOURCES)
	iverilog -o tb_fifo9togmii $(SOURCES)

.PHONY: clean isim cversim gtk
