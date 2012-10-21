SOURCES=tb_mixer.v $(wildcard ../rtl/*.v) $(wildcard ../../sfifo/rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_mixer
	./tb_mixer

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_mixer verilog.log test.vcd

tb_mixer: $(SOURCES)
	iverilog -o tb_mixer $(SOURCES)

.PHONY: clean isim cversim gtk
