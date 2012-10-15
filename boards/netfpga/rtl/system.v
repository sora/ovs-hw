`default_nettype none
`define ECP3VERSA

module system (
	  input        clock
  , input        reset_n
// PHY0
  , output       phy0_rstn
  , input        phy0_rx_clk      // MII 25MHz
  , input        phy0_rx_er
  , input        phy0_rx_dv
  , input  [7:0] phy0_rxd
  , input        phy0_tx_clk      // MII 25MHz
  , output       phy0_tx_en
  , output [7:0] phy0_txd
  , output       phy0_gtx_clk     // GMII 125MHz
  , input        phy0_125M_clk
  , output       phy0_mii_clk
  , output       phy0_mii_data
// PHY1
  , output       phy1_rstn
  , input        phy1_rx_clk
  , input        phy1_rx_er
  , input        phy1_rx_dv
  , input  [7:0] phy1_rxd
  , input        phy1_tx_clk
  , output       phy1_tx_en
  , output [7:0] phy1_txd
  , output       phy1_gtx_clk
  , input        phy1_125M_clk
  , output       phy1_mii_clk
  , output       phy1_mii_data
// Switch and LED
  //, input  [7:0]  switch
  //, output [14:0] segled
  , output [7:0]  led
);

wire   phy0_25M_clk  = phy0_tx_clk;
wire   phy1_25M_clk  = phy1_tx_clk;
assign phy0_mii_clk  = 1'b0;
assign phy0_mii_data = 1'b0;
assign phy1_mii_clk  = 1'b0;
assign phy1_mii_data = 1'b0;


/* --------------------------------------- */
/* base clock (125MHz) */
wire sys_clk = phy0_125M_clk;

/* --------------------------------------- */
/* system reset and initial cold reset */
`ifndef SIMULATION
reg       sys_rstn;                  // sys reset
reg[19:0] rstn_cnt;
always @(posedge sys_clk or negedge reset_n) begin
  if (!reset_n) begin
    rstn_cnt <= 20'b0;
    sys_rstn <= 1'b0;
  end else begin
    if (rstn_cnt[19])
      sys_rstn <= 1'b1;
    else
      rstn_cnt <= rstn_cnt + 20'b1;
  end
end
wire sys_rst = ~sys_rstn;

assign phy0_rstn = sys_rstn;
assign phy1_rstn = sys_rstn;
`else
  wire sys_rst = ~reset_n;
`endif

/* --------------------------------------- */
/* Ethernet MAC */

// PHY0
wire      rd0_en;
wire[8:0] rd0_data;
wire      rd0_empty;
wire      wr0_en;
wire[8:0] wr0_data;
wire      wr0_full;
// PHY1
wire      rd1_en;
wire[8:0] rd1_data;
wire      rd1_empty;
wire      wr1_en;
wire[8:0] wr1_data;
wire      wr1_full;

assign phy0_gtx_clk = phy0_125M_clk;
assign phy1_gtx_clk = phy1_125M_clk;

rx rx0 (
    .sys_rst(sys_rst)
  , .phy_rx_clk(phy0_rx_clk)
  , .phy_rx_dv(phy0_rx_dv)
  , .phy_rxd(phy0_rxd)
  , .rd_clk(sys_clk)
  , .rd_en(rd0_en)
  , .rd_data(rd0_data)
  , .rd_empty(rd0_empty)
);

tx tx0 (
    .sys_rst(sys_rst)
  , .wr_clk(sys_clk)
  , .wr_en(wr0_en)
  , .wr_data(wr0_data)
  , .phy_gtx_clk(phy0_125M_clk)
  , .phy_tx_en(phy0_tx_en)
  , .phy_txd(phy0_txd)
);

rx rx1 (
    .sys_rst(sys_rst)
  , .phy_rx_clk(phy1_rx_clk)
  , .phy_rx_dv(phy1_rx_dv)
  , .phy_rxd(phy1_rxd)
  , .rd_clk(sys_clk)
  , .rd_en(rd1_en)
  , .rd_data(rd1_data)
  , .rd_empty(rd1_empty)
);

tx tx1 (
    .sys_rst(sys_rst)
  , .wr_clk(sys_clk)
  , .wr_en(wr1_en)
  , .wr_data(wr1_data)
  , .phy_gtx_clk(phy1_125M_clk)
  , .phy_tx_en(phy1_tx_en)
  , .phy_txd(phy1_txd)
);

filter filter (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
// PHY0->PHY1
  , .rd0_en(rd0_en)
  , .rd0_data(rd0_data)
  , .rd0_empty(rd0_empty)
  , .wr0_en(wr0_en)
  , .wr0_data(wr0_data)
  , .wr0_full(wr0_full)
// PHY1->PHY0
  , .rd1_en(rd1_en)
  , .rd1_data(rd1_data)
  , .rd1_empty(rd1_empty)
  , .wr1_en(wr1_en)
  , .wr1_data(wr1_data)
  , .wr1_full(wr1_full)
);

/* --------------------------------------- */
/* LED */
reg[31:0] led_cnt = 32'b0;
always @(posedge clock) begin
  if (sys_rst)
    led_cnt <= 32'b0;
  else
    led_cnt <= led_cnt + 32'b1;
end
assign led = ~led_cnt[29:22];
endmodule

`default_nettype wire
