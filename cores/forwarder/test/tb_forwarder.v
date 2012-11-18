`define SIMULATION
module tb_forwarder();

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

wire of_lookup_req;
wire [242:0] of_lookup_data;
wire of_lookup_ack;
wire of_lookup_err;
wire [3:0] of_lookup_fwd_port;
lookupflow # (
    .NPORT(4'h4)
) lookupflow_tb (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(of_lookup_req)
  , .of_lookup_data(of_lookup_data)
  , .of_lookup_ack(of_lookup_ack)
  , .of_lookup_err(of_lookup_err)
  , .of_lookup_fwd_port(of_lookup_fwd_port)
);

reg [8:0] rx_dout;
reg rx_empty;
wire rx_rd_en;
wire [7:0] port0tx_din, port1tx_din, port2tx_din, port3tx_din, nic_din;
reg port0tx_full, port1tx_full, port2tx_full, port3tx_full, nic_full;
wire port0tx_wr_en, port1tx_wr_en, port2tx_wr_en, port3tx_wr_en, nic_wr_en;
forwarder #(
    .NPORT(4'h4)
  , .PORT_NUM(4'h0)
) forwarder_tb (
    .sys_rst(sys_rst)
  , .sys_clk(sys_clk)

  , .rx_dout(rx_dout)
  , .rx_empty(rx_empty)
  , .rx_rd_en(rx_rd_en)

  , .port0tx_din(port0tx_din)
  , .port0tx_full(port0tx_full)
  , .port0tx_wr_en(port0tx_wr_en)
  , .port1tx_din(port1tx_din)
  , .port1tx_full(port1tx_full)
  , .port1tx_wr_en(port1tx_wr_en)
  , .port2tx_din(port2tx_din)
  , .port2tx_full(port2tx_full)
  , .port2tx_wr_en(port2tx_wr_en)
  , .port3tx_din(port3tx_din)
  , .port3tx_full(port3tx_full)
  , .port3tx_wr_en(port3tx_wr_en)

  , .nic_din(nic_din)
  , .nic_full(nic_full)
  , .nic_wr_en(nic_wr_en)

  , .of_lookup_req(of_lookup_req)
  , .of_lookup_data(of_lookup_data)
  , .of_lookup_ack(of_lookup_ack)
  , .of_lookup_err(of_lookup_err)
  , .of_lookup_fwd_port(of_lookup_fwd_port)
);

task waitclock;
begin
  @(posedge sys_clk);
  #1;
end
endtask

always @(posedge sys_clk) begin
  if (rx_rd_en == 1'b1)
    $display("empty: %x dout: %x", rx_empty, rx_dout);
end

reg [11:0] counter;
reg [8:0] rom [0:511];

always #1
  {rx_empty, rx_dout} <= rom[counter];

always @(posedge phy_tx_clk) begin
  if (rx_rd_en == 1'b1)
    counter <= counter + 1;
end

initial begin
  $dumpfile("./test.vcd");
  $dumpvars(0, tb_forwarder);
  $readmemh("./phy_pingto5hosts.hex", rom);
  /* Reset / Initialize our logic */
  sys_rst = 1'b1;
  counter = 0;

  waitclock;
  waitclock;

  sys_rst = 1'b0;

  waitclock;

  #10000;

  $finish;
end

endmodule
