`timescale 1ps / 1ps
`define SIMULATION

module tb_top;

/* --------------------------------------- */
/* Clocks */
// 125MHz system clock
// verilator lint_save
// verilator lint_off STMTDLY
reg sys_clk;
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

// 33MHz PCI clock
reg pci_clk;
initial pci_clk = 1'b0;
always #30 pci_clk = ~pci_clk;

// 62.5MHz CPCI clock
reg cpci_clk;
initial cpci_clk = 1'b0;
always #16 cpci_clk = ~cpci_clk;

// 125MHz RX clock
reg phy_rx_clk;
initial phy_rx_clk = 1'b0;
always #8 phy_rx_clk = ~phy_rx_clk;

// 125MHz TX clock
reg phy_tx_clk;
initial phy_tx_clk = 1'b0;
always #8 phy_tx_clk = ~phy_tx_clk;
// verilator lint_restore

/* --------------------------------------- */
/* testbench */
reg      sys_rst;
reg      phy_rx_dv;
reg[7:0] phy_rxd;

wire[7:0] gmii_0_txd, gmii_1_txd;
wire[7:0] gmii_0_rxd, gmii_1_rxd;
wire      gmii_0_gtx_clk, gmii_1_gtx_clk;
wire      gmii_0_rst, gmii_1_rst;
wire      gmii_0_tx_en, gmii_1_tx_en;
wire      gmii_0_rx_dv, gmii_1_rx_dv;
wire      gmii_0_rx_er, gmii_1_rx_er;
wire      gmii_0_col, gmii_1_col;
wire      gmii_0_crs, gmii_1_crs;
wire      phy_mii_clk;
wire[3:0] mii_0_txd, mii_1_txd;
wire[7:0] dip_data;
wire[7:0] led_data;


top top_ins (
    .rstn(~sys_rst)

  , .phy0_rx_clk(phy_rx_clk)
  , .phy0_rx_er(gmii_0_rx_er)
  , .phy0_rx_dv(phy_rx_dv)
  , .phy0_rxd(phy_rxd)
  , .phy0_tx_clk()
  , .phy0_tx_en(gmii_0_tx_en)
  , .phy0_txd(gmii_0_txd)
  , .phy0_gtx_clk(gmii_0_gtx_clk)
  , .phy0_125M_clk(phy_tx_clk)

  , .phy1_rx_clk(phy_rx_clk)
  , .phy1_rx_er(gmii_1_rx_er)
  , .phy1_rx_dv(phy_rx_dv)
  , .phy1_rxd(phy_rxd)
  , .phy1_tx_clk()
  , .phy1_tx_en(gmii_1_tx_en)
  , .phy1_txd(gmii_1_txd)
  , .phy1_gtx_clk(gmii_1_gtx_clk)
  , .phy1_125M_clk(phy_tx_clk)

  , .dip_switch(dip_data)
  , .led(led_data)
);

/* --------------------------------------- */
/* a clock */
`ifndef ENABLE_LINT
task waitclock;
begin
  @(posedge sys_clk);
  #1;
end
endtask
`endif

/* --------------------------------------- */
/* monitor */
//initial
//  $monitor("phy_rx_dv: %x, phy_rxd: %x", phy_rx_dv, phy_rxd);

/* --------------------------------------- */
/* scinario */
reg[8:0]  rom[0:1024];
reg[11:0] counter = 12'b0;

always @(posedge phy_rx_clk) begin
  { phy_rx_dv, phy_rxd } <= rom[counter];
  counter                <= counter + 1;
  $display("phy_rx_dv: %x, phy_rxd: %x", phy_rx_dv, phy_rxd);
end

initial begin
`ifndef ENABLE_LINT
  $dumpfile("./test.vcd");
  $dumpvars(0, tb_top); 
  $readmemh("t_data.hex", rom);
`endif
  sys_rst = 1'b1;
  counter = 0;

`ifndef ENABLE_LINT
  waitclock;
  waitclock;
`endif

  sys_rst = 1'b0;

`ifndef ENABLE_LINT
  waitclock;
`endif

  // verilator lint_off STMTDLY
  #10000;
  $finish;
end

endmodule


