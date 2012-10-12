## ovs-hw

An open source implementation of open vswitch hardware engine

### Supported FPGA board

* [Lattice ECP3 Versa Development Kit](http://www.latticesemi.com/products/developmenthardware/developmentkits/ecp3versadevelopmentkit/index.cfm)

### Directory Structure

    /cores/              -- Cores library, with Verilog sources, test benches and documentation.
    /boards/             -- Difrrent boards supported
    /boards/ecp3versa    -- Lattice ECP3 Versa Development Kit

### How to build

Lattice ECP3 Verse

* [Lattice Diamond](http://www.latticesemi.com/products/designsoftware/diamond/downloads.cfm)

Simulation tool on Mac

* [Icarus Verilog](http://www.icarus.com/eda/verilog/) -- `brew install icarus-verilog`
* [GPL Cver](http://www.pragmatic-c.com/gpl-cver/) -- `brew install gplcver`
* [GTKWave](http://gtkwave.sourceforge.net/) -- `brew install gtkwave`
* [Verilator](http://www.veripool.org/wiki/verilator) -- `brew install verilator`

testbench

    $ brew install icarus-verilog gplcver gtkwave
    $ make test
    $ gtkwave test.vcd

lint only

    $ brew install verilator
    $ make lint

### How to build
### Quickstart (build and FPGA configuration)
