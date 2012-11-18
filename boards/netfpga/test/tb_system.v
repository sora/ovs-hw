`timescale 1ps / 1ps
`define SIMULATION
`include "../rtl/setup.v"
module tb_system();

/* 125MHz system clock */
reg sys_clk;
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

/* 33MHz PCI clock */
reg pci_clk;
initial pci_clk = 1'b0;
always #30 pci_clk = ~pci_clk;

/* 62.5MHz CPCI clock */
reg cpci_clk;
initial cpci_clk = 1'b0;
always #16 cpci_clk = ~cpci_clk;

/* 125MHz RX clock */
reg phy_rx_clk;
initial phy_rx_clk = 1'b0;
always #8 phy_rx_clk = ~phy_rx_clk;

/* 125MHz TX clock */
reg phy_tx_clk;
initial phy_tx_clk = 1'b0;
always #8 phy_tx_clk = ~phy_tx_clk;


reg sys_rst;
reg phy_rx_dv;
reg [7:0] phy_rxd;
wire [7:0] gmii_0_txd, gmii_1_txd, gmii_2_txd, gmii_3_txd;
wire gmii_0_tx_en, gmii_1_tx_en, gmii_2_tx_en, gmii_3_tx_en;

system system_inst (
    .sys_rst(sys_rst)
  , .sys_clk(phy_rx_clk)
  , .gmii_tx_clk(phy_tx_clk)

  , .gmii_0_txd(gmii_0_txd)
  , .gmii_0_tx_en(gmii_0_tx_en)
  , .gmii_0_rxd(phy_rxd)
  , .gmii_0_rx_dv(phy_rx_dv)
  , .gmii_0_rx_clk(phy_rx_clk)

  , .gmii_1_txd(gmii_1_txd)
  , .gmii_1_tx_en(gmii_1_tx_en)
  , .gmii_1_rxd(8'h00)
  , .gmii_1_rx_dv(1'b0)
  , .gmii_1_rx_clk(phy_rx_clk)

  , .gmii_2_txd(gmii_2_txd)
  , .gmii_2_tx_en(gmii_2_tx_en)
  , .gmii_2_rxd(8'h00)
  , .gmii_2_rx_dv(1'b0)
  , .gmii_2_rx_clk(phy_rx_clk)

  , .gmii_3_txd(gmii_3_txd)
  , .gmii_3_tx_en(gmii_3_tx_en)
  , .gmii_3_rxd(8'h00)
  , .gmii_3_rx_dv(1'b0)
  , .gmii_3_rx_clk(phy_rx_clk)
);

task waitclock;
begin
  @(posedge sys_clk);
  #1;
end
endtask

/*
always @(posedge Wclk) begin
  if (WriteEn_in == 1'b1)
    $display("Data_in: %x", Data_in);
end
*/

reg [11:0] rom [0:4095];
reg [11:0] counter;

always @(posedge phy_rx_clk) begin
  {phy_rx_dv, phy_rxd} <= rom[counter];
  counter <= counter + 1;
end

initial begin
  $dumpfile("./test.vcd");
  $dumpvars(0, tb_system); 
  $readmemh("./phy_pingto5hosts.hex", rom);
  /* Reset / Initialize our logic */
  sys_rst = 1'b1;
  counter = 0;

  waitclock;
  waitclock;

  sys_rst = 1'b0;

  waitclock;


  #30000;

  $finish;
end

endmodule
