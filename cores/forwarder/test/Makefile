SOURCES=tb_router.v $(wildcard ../rtl/*.v) $(wildcard ../../sfifo/rtl/*.v) $(wildcard ../../lookupfib/rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_router
	./tb_router

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_router verilog.log test.vcd

tb_router: $(SOURCES)
	iverilog -o tb_router $(SOURCES)

.PHONY: clean isim cversim gtk
