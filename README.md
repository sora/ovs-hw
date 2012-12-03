## ovs-hw

An open source implementation of open vswitch hardware engine

### Supported FPGA board

* [NetFPGA-1G](http://netfpga.org/)
  * we don't use NetFPGA frameworks. please see here how to bypass it.
* [~~Lattice ECP3 Versa Development Kit~~](http://www.latticesemi.com/products/developmenthardware/developmentkits/ecp3versadevelopmentkit/index.cfm)

### Directory Structure

    /cores/              -- Cores library, with Verilog sources, test benches and documentation.
    /boards/             -- Difrrent boards supported
    /boards/netfpga      -- NetFPGA-1G
    /boards/ecp3versa    -- Lattice ECP3 Versa Development Kit

### Development software

NetFPGA-1G

* [Xilinx ISE 10.1SP3](http://www.xilinx.com/support/download/index.htm)

~~Lattice ECP3 Verse~~

* [Lattice Diamond](http://www.latticesemi.com/products/designsoftware/diamond/downloads.cfm)

Simulation tool on Mac and Linux

* [Icarus Verilog](http://www.icarus.com/eda/verilog/) -- `brew install icarus-verilog`
* [GPL Cver](http://www.pragmatic-c.com/gpl-cver/) -- `brew install gplcver`
* [GTKWave](http://gtkwave.sourceforge.net/) -- `brew install gtkwave`
* [Verilator](http://www.veripool.org/wiki/verilator) -- `brew install verilator`

### Quickstart (Simulation and FPGA configuration)

lint

    $ brew install verilator
    $ make lint

testbench

    $ brew install icarus-verilog gplcver gtkwave
    $ make test

build

    $ make bit

load

    $ make load
