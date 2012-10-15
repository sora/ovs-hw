//`timescale 1ns / 1ps
`include "../rtl/setup.v"

module system # (
	parameter MaxPort = 2'h3
) (
	input         sys_rst,
	input         sys_clk,

	input         gmii_tx_clk,

	// GMII interfaces for 4 MACs
	output [7:0]  gmii_0_txd,
	output        gmii_0_tx_en,
	input  [7:0]  gmii_0_rxd,
	input         gmii_0_rx_dv,
	input         gmii_0_rx_clk,

	output [7:0]  gmii_1_txd,
	output        gmii_1_tx_en,
	input  [7:0]  gmii_1_rxd,
	input         gmii_1_rx_dv,
	input         gmii_1_rx_clk,

	output [7:0]  gmii_2_txd,
	output        gmii_2_tx_en,
	input  [7:0]  gmii_2_rxd,
	input         gmii_2_rx_dv,
	input         gmii_2_rx_clk,

	output [7:0]  gmii_3_txd,
	output        gmii_3_tx_en,
	input  [7:0]  gmii_3_rxd,
	input         gmii_3_rx_dv,
	input         gmii_3_rx_clk

);

//-----------------------------------
// RX0,RX1,RX2,RX3_PHYQ FIFO
//-----------------------------------
wire [8:0] rx0_phyq_din, rx0_phyq_dout;
wire rx0_phyq_full, rx0_phyq_wr_en;
wire rx0_phyq_empty, rx0_phyq_rd_en;

wire [8:0] rx1_phyq_din, rx1_phyq_dout;
wire rx1_phyq_full, rx1_phyq_wr_en;
wire rx1_phyq_empty, rx1_phyq_rd_en;

wire [8:0] rx2_phyq_din, rx2_phyq_dout;
wire rx2_phyq_full, rx2_phyq_wr_en;
wire rx2_phyq_empty, rx2_phyq_rd_en;

wire [8:0] rx3_phyq_din, rx3_phyq_dout;
wire rx3_phyq_full, rx3_phyq_wr_en;
wire rx3_phyq_empty, rx3_phyq_rd_en;

`ifndef SIMULATION
asfifo9_12 rx0_phyq (
	.din(rx0_phyq_din),
	.full(rx0_phyq_full),
	.wr_en(rx0_phyq_wr_en),
	.wr_clk(gmii_0_rx_clk),

	.dout(rx0_phyq_dout),
	.empty(rx0_phyq_empty),
	.rd_en(rx0_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
asfifo9_12 rx1_phyq (
	.din(rx1_phyq_din),
	.full(rx1_phyq_full),
	.wr_en(rx1_phyq_wr_en),
	.wr_clk(gmii_1_rx_clk),

	.dout(rx1_phyq_dout),
	.empty(rx1_phyq_empty),
	.rd_en(rx1_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`ifdef ENABLE_RGMII2
asfifo9_12 rx2_phyq (
	.din(rx2_phyq_din),
	.full(rx2_phyq_full),
	.wr_en(rx2_phyq_wr_en),
	.wr_clk(gmii_2_rx_clk),

	.dout(rx2_phyq_dout),
	.empty(rx2_phyq_empty),
	.rd_en(rx2_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`else
assign rx2_phyq_empty = 1'b1;
`endif
`ifdef ENABLE_RGMII3
asfifo9_12 rx3_phyq (
	.din(rx3_phyq_din),
	.full(rx3_phyq_full),
	.wr_en(rx3_phyq_wr_en),
	.wr_clk(gmii_3_rx_clk),

	.dout(rx3_phyq_dout),
	.empty(rx3_phyq_empty),
	.rd_en(rx3_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`else
assign rx3_phyq_empty = 1'b1;
`endif
`else
asfifo # (
	.DATA_WIDTH(9),
	.ADDRESS_WIDTH(12)
) rx0fifo (
	.din(rx0_phyq_din),
	.full(rx0_phyq_full),
	.wr_en(rx0_phyq_wr_en),
	.wr_clk(gmii_0_rx_clk),

	.dout(rx0_phyq_dout),
	.empty(rx0_phyq_empty),
	.rd_en(rx0_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
asfifo # (
	.DATA_WIDTH(9),
	.ADDRESS_WIDTH(12)
) rx1fifo (
	.din(rx1_phyq_din),
	.full(rx1_phyq_full),
	.wr_en(rx1_phyq_wr_en),
	.wr_clk(gmii_1_rx_clk),

	.dout(rx1_phyq_dout),
	.empty(rx1_phyq_empty),
	.rd_en(rx1_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`ifdef ENABLE_RGMII2
asfifo # (
	.DATA_WIDTH(9),
	.ADDRESS_WIDTH(12)
) rx2fifo (
	.din(rx2_phyq_din),
	.full(rx2_phyq_full),
	.wr_en(rx2_phyq_wr_en),
	.wr_clk(gmii_2_rx_clk),

	.dout(rx2_phyq_dout),
	.empty(rx2_phyq_empty),
	.rd_en(rx2_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`else
assign rx2_phyq_empty = 1'b1;
`endif
`ifdef ENABLE_RGMII3
asfifo # (
	.DATA_WIDTH(9),
	.ADDRESS_WIDTH(12)
) rx3fifo (
	.din(rx3_phyq_din),
	.full(rx3_phyq_full),
	.wr_en(rx3_phyq_wr_en),
	.wr_clk(gmii_3_rx_clk),

	.dout(rx3_phyq_dout),
	.empty(rx3_phyq_empty),
	.rd_en(rx3_phyq_rd_en),
	.rd_clk(sys_clk),

	.rst(sys_rst)
);
`else
assign rx3_phyq_empty = 1'b1;
`endif
`endif

//-----------------------------------
// RX-TX FIFO
//-----------------------------------
wire [8:0] rx0tx0_din, rx0tx0_dout;
wire rx0tx0_full, rx0tx0_wr_en;
wire rx0tx0_empty, rx0tx0_rd_en;
wire [11:0] rx0tx0_data_count;

wire [8:0] rx1tx1_din, rx1tx1_dout;
wire rx1tx1_full, rx1tx1_wr_en;
wire rx1tx1_empty, rx1tx1_rd_en;
wire [11:0] rx1tx1_data_count;

wire [8:0] rx2tx2_din, rx2tx2_dout;
wire rx2tx2_full, rx2tx2_wr_en;
wire rx2tx2_empty, rx2tx2_rd_en;
wire [11:0] rx2tx2_data_count;

wire [8:0] rx3tx3_din, rx3tx3_dout;
wire rx3tx3_full, rx3tx3_wr_en;
wire rx3tx3_empty, rx3tx3_rd_en;
wire [11:0] rx3tx3_data_count;

`ifdef SIMULATION
sfifo # (
	.DATA_WIDTH(9),
	.ADDR_WIDTH(12)
) rx0tx0_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx0tx0_din),
	.full(rx0tx0_full),
	.wr_cs(rx0tx0_wr_en),
	.wr_en(rx0tx0_wr_en),

	.dout(rx0tx0_dout),
	.empty(rx0tx0_empty),
	.rd_cs(rx0tx0_rd_en),
	.rd_en(rx0tx0_rd_en),

	.data_count(rx0tx0_data_count)
);
sfifo # (
	.DATA_WIDTH(9),
	.ADDR_WIDTH(12)
) rx1tx1_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx1tx1_din),
	.full(rx1tx1_full),
	.wr_cs(rx1tx1_wr_en),
	.wr_en(rx1tx1_wr_en),

	.dout(rx1tx1_dout),
	.empty(rx1tx1_empty),
	.rd_cs(rx1tx1_rd_en),
	.rd_en(rx1tx1_rd_en),

	.data_count(rx1tx1_data_count)
);
sfifo # (
	.DATA_WIDTH(9),
	.ADDR_WIDTH(12)
) rx2tx2_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx2tx2_din),
	.full(rx2tx2_full),
	.wr_cs(rx2tx2_wr_en),
	.wr_en(rx2tx2_wr_en),

	.dout(rx2tx2_dout),
	.empty(rx2tx2_empty),
	.rd_cs(rx2tx2_rd_en),
	.rd_en(rx2tx2_rd_en),

	.data_count(rx2tx2_data_count)
);
sfifo # (
	.DATA_WIDTH(9),
	.ADDR_WIDTH(12)
) rx3tx3_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx3tx3_din),
	.full(rx3tx3_full),
	.wr_cs(rx3tx3_wr_en),
	.wr_en(rx3tx3_wr_en),

	.dout(rx3tx3_dout),
	.empty(rx3tx3_empty),
	.rd_cs(rx3tx3_rd_en),
	.rd_en(rx3tx3_rd_en),

	.data_count(rx3tx3_data_count)
);
`else
sfifo9_12 rx0tx0_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx0tx0_din),
	.full(rx0tx0_full),
	.wr_en(rx0tx0_wr_en),

	.dout(rx0tx0_dout),
	.empty(rx0tx0_empty),
	.rd_en(rx0tx0_rd_en),

	.data_count(rx0tx0_data_count)
);
sfifo9_12 rx1tx1_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx1tx1_din),
	.full(rx1tx1_full),
	.wr_en(rx1tx1_wr_en),

	.dout(rx1tx1_dout),
	.empty(rx1tx1_empty),
	.rd_en(rx1tx1_rd_en),

	.data_count(rx1tx1_data_count)
);
`ifdef ENABLE_RGMII2
sfifo9_12 rx2tx2_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx2tx2_din),
	.full(rx2tx2_full),
	.wr_en(rx2tx2_wr_en),

	.dout(rx2tx2_dout),
	.empty(rx2tx2_empty),
	.rd_en(rx2tx2_rd_en),

	.data_count(rx2tx2_data_count)
);
`else
assign rx2tx2_empty = 1'b1;
`endif
`ifdef ENABLE_RGMII3
sfifo9_12 rx3tx3_q (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(rx3tx3_din),
	.full(rx3tx3_full),
	.wr_en(rx3tx3_wr_en),

	.dout(rx3tx3_dout),
	.empty(rx3tx3_empty),
	.rd_en(rx3tx3_rd_en),

	.data_count(rx3tx3_data_count)
);
`else
assign rx3tx3_empty = 1'b1;
`endif
`endif


//-----------------------------------
// GMII2FIFO9 module
//-----------------------------------
gmii2fifo9 # (
	.Gap(4'h8)
) rx0gmii2fifo (
	.sys_rst(sys_rst),

	.gmii_rx_clk(gmii_0_rx_clk),
	.gmii_rx_dv(gmii_0_rx_dv),
	.gmii_rxd(gmii_0_rxd),

	.din(rx0tx0_din),
	.full(rx0tx0_full),
	.wr_en(rx0tx0_wr_en),
	.wr_clk()
);
gmii2fifo9 # (
	.Gap(4'h8)
) rx1gmii2fifo (
	.sys_rst(sys_rst),

	.gmii_rx_clk(gmii_1_rx_clk),
	.gmii_rx_dv(gmii_1_rx_dv),
	.gmii_rxd(gmii_1_rxd),

	.din(rx1tx1_din),
	.full(rx1tx1_full),
	.wr_en(rx1tx1_wr_en),
	.wr_clk()
);
`ifdef ENABLE_RGMII2
gmii2fifo9 # (
	.Gap(4'h8)
) rx2gmii2fifo (
	.sys_rst(sys_rst),

	.gmii_rx_clk(gmii_2_rx_clk),
	.gmii_rx_dv(gmii_2_rx_dv),
	.gmii_rxd(gmii_2_rxd),

	.din(rx2_phyq_din),
	.full(rx2_phyq_full),
	.wr_en(rx2_phyq_wr_en),
	.wr_clk()
);
`endif
`ifdef ENABLE_RGMII3
gmii2fifo9 # (
	.Gap(4'h8)
) rx3gmii2fifo (
	.sys_rst(sys_rst),

	.gmii_rx_clk(gmii_3_rx_clk),
	.gmii_rx_dv(gmii_3_rx_dv),
	.gmii_rxd(gmii_3_rxd),

	.din(rx3_phyq_din),
	.full(rx3_phyq_full),
	.wr_en(rx3_phyq_wr_en),
	.wr_clk()
);
`endif

//-----------------------------------
// FIFO9TOGMII module
//-----------------------------------
fifo9togmii tx0fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx1tx1_dout),
	.empty(rx1tx1_empty),
	.rd_en(rx1tx1_rd_en),
	.rd_clk(),

	.gmii_tx_clk(gmii_tx_clk),
	.gmii_tx_en(gmii_0_tx_en),
	.gmii_txd(gmii_0_txd)
);
fifo9togmii tx1fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx0tx0_dout),
	.empty(rx0tx0_empty),
	.rd_en(rx0tx0_rd_en),
	.rd_clk(),

	.gmii_tx_clk(gmii_tx_clk),
	.gmii_tx_en(gmii_1_tx_en),
	.gmii_txd(gmii_1_txd)
);
`ifdef ENABLE_RGMII2
fifo9togmii tx2fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx2tx2_dout),
	.empty(rx2tx2_empty),
	.rd_en(rx2tx2_rd_en),
	.rd_clk(),

	.gmii_tx_clk(gmii_tx_clk),
	.gmii_tx_en(gmii_2_tx_en),
	.gmii_txd(gmii_2_txd)
);
`endif
`ifdef ENABLE_RGMII3
fifo9togmii tx3fifo2gmii (
	.sys_rst(sys_rst),

	.dout(rx3tx3_dout),
	.empty(rx3tx3_empty),
	.rd_en(rx3tx3_rd_en),
	.rd_clk(),

	.gmii_tx_clk(gmii_tx_clk),
	.gmii_tx_en(gmii_3_tx_en),
	.gmii_txd(gmii_3_txd)
);
`endif

endmodule
