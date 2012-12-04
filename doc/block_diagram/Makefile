TARGET=netfpga
FILE=$(TARGET).gv
PDF=$(TARGET).pdf
PNG=$(TARGET).png

pdf: $(FILE)
	dot -Gsplines=none $(FILE) | neato -n -Gsplines=ortho -Tpdf -o$(PDF)
png: $(FILE)
	dot -Gsplines=none $(FILE) | neato -n -Gsplines=ortho -Tpng -o$(PNG)
clean:
	rm -f *.png *.pdf

.PHONY: clean pdf png
