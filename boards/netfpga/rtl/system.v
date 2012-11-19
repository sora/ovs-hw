//`timescale 1ns / 1ps
`include "../rtl/setup.v"

module system #(
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
// RX-TX0 FIFO
//-----------------------------------
wire [ 8:0] rx0tx0_din, rx0tx0_dout,
            rx0tx1_din, rx0tx1_dout,
            rx0tx2_din, rx0tx2_dout,
            rx0tx3_din, rx0tx3_dout;
wire [11:0] rx0tx0_data_count,
            rx0tx1_data_count,
            rx0tx2_data_count,
            rx0tx3_data_count;
wire        rx0tx0_full, rx0tx0_wr_en,
            rx0tx1_full, rx0tx1_wr_en,
            rx0tx2_full, rx0tx2_wr_en,
            rx0tx3_full, rx0tx3_wr_en;
wire        rx0tx0_empty, rx0tx0_rd_en,
            rx0tx1_empty, rx0tx1_rd_en,
            rx0tx2_empty, rx0tx2_rd_en,
            rx0tx3_empty, rx0tx3_rd_en;

wire [ 8:0] rx1tx0_din, rx1tx0_dout,
            rx1tx1_din, rx1tx1_dout,
            rx1tx2_din, rx1tx2_dout,
            rx1tx3_din, rx1tx3_dout;
wire [11:0] rx1tx0_data_count,
            rx1tx1_data_count,
            rx1tx2_data_count,
            rx1tx3_data_count;
wire        rx1tx0_full, rx1tx0_wr_en,
            rx1tx1_full, rx1tx1_wr_en,
            rx1tx2_full, rx1tx2_wr_en,
            rx1tx3_full, rx1tx3_wr_en;
wire        rx1tx0_empty, rx1tx0_rd_en,
            rx1tx1_empty, rx1tx1_rd_en,
            rx1tx2_empty, rx1tx2_rd_en,
            rx1tx3_empty, rx1tx3_rd_en;

wire [ 8:0] rx2tx0_din, rx2tx0_dout,
            rx2tx1_din, rx2tx1_dout,
            rx2tx2_din, rx2tx2_dout,
            rx2tx3_din, rx2tx3_dout;
wire [11:0] rx2tx0_data_count,
            rx2tx1_data_count,
            rx2tx2_data_count,
            rx2tx3_data_count;
wire        rx2tx0_full, rx2tx0_wr_en,
            rx2tx1_full, rx2tx1_wr_en,
            rx2tx2_full, rx2tx2_wr_en,
            rx2tx3_full, rx2tx3_wr_en;
wire        rx2tx0_empty, rx2tx0_rd_en,
            rx2tx1_empty, rx2tx1_rd_en,
            rx2tx2_empty, rx2tx2_rd_en,
            rx2tx3_empty, rx2tx3_rd_en;

wire [ 8:0] rx3tx0_din, rx3tx0_dout,
            rx3tx1_din, rx3tx1_dout,
            rx3tx2_din, rx3tx2_dout,
            rx3tx3_din, rx3tx3_dout;
wire [11:0] rx3tx0_data_count,
            rx3tx1_data_count,
            rx3tx2_data_count,
            rx3tx3_data_count;
wire        rx3tx0_full, rx3tx0_wr_en,
            rx3tx1_full, rx3tx1_wr_en,
            rx3tx2_full, rx3tx2_wr_en,
            rx3tx3_full, rx3tx3_wr_en;
wire        rx3tx0_empty, rx3tx0_rd_en,
            rx3tx1_empty, rx3tx1_rd_en,
            rx3tx2_empty, rx3tx2_rd_en,
            rx3tx3_empty, rx3tx3_rd_en;

`ifdef SIMULATION
sfifo # (
    .DATA_WIDTH(9)
  , .ADDR_WIDTH(12)
) rx0tx0_q (
    .clk(sys_clk)
  , .rst(sys_rst)
  , .din(rx0tx0_din)
  , .full(rx0tx0_full)
  , .wr_cs(rx0tx0_wr_en)
  , .wr_en(rx0tx0_wr_en)
  , .dout(rx0tx0_dout)
  , .empty(rx0tx0_empty)
  , .rd_cs(rx0tx0_rd_en)
  , .rd_en(rx0tx0_rd_en)
  , .data_count(rx0tx0_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx0tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx1_din),
  .full(rx0tx1_full),
  .wr_cs(rx0tx1_wr_en),
  .wr_en(rx0tx1_wr_en),

  .dout(rx0tx1_dout),
  .empty(rx0tx1_empty),
  .rd_cs(rx0tx1_rd_en),
  .rd_en(rx0tx1_rd_en),

  .data_count(rx0tx1_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx0tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx2_din),
  .full(rx0tx2_full),
  .wr_cs(rx0tx2_wr_en),
  .wr_en(rx0tx2_wr_en),

  .dout(rx0tx2_dout),
  .empty(rx0tx2_empty),
  .rd_cs(rx0tx2_rd_en),
  .rd_en(rx0tx2_rd_en),

  .data_count(rx0tx2_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx0tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx3_din),
  .full(rx0tx3_full),
  .wr_cs(rx0tx3_wr_en),
  .wr_en(rx0tx3_wr_en),

  .dout(rx0tx3_dout),
  .empty(rx0tx3_empty),
  .rd_cs(rx0tx3_rd_en),
  .rd_en(rx0tx3_rd_en),

  .data_count(rx0tx3_data_count)
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
sfifo9_12 rx0tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx1_din),
  .full(rx0tx1_full),
  .wr_en(rx0tx1_wr_en),

  .dout(rx0tx1_dout),
  .empty(rx0tx1_empty),
  .rd_en(rx0tx1_rd_en),

  .data_count(rx0tx1_data_count)
);
`ifdef ENABLE_RGMII2
sfifo9_12 rx0tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx2_din),
  .full(rx0tx2_full),
  .wr_en(rx0tx2_wr_en),

  .dout(rx0tx2_dout),
  .empty(rx0tx2_empty),
  .rd_en(rx0tx2_rd_en),

  .data_count(rx0tx2_data_count)
);
`else
assign rx0tx2_empty = 1'b1;
`endif
`ifdef ENABLE_RGMII3
sfifo9_12 rx0tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx0tx3_din),
  .full(rx0tx3_full),
  .wr_en(rx0tx3_wr_en),

  .dout(rx0tx3_dout),
  .empty(rx0tx3_empty),
  .rd_en(rx0tx3_rd_en),

  .data_count(rx0tx3_data_count)
);
`else
assign rx0tx3_empty = 1'b1;
`endif
`endif

`ifdef SIMULATION
sfifo # (
    .DATA_WIDTH(9)
  , .ADDR_WIDTH(12)
) rx1tx0_q (
    .clk(sys_clk)
  , .rst(sys_rst)
  , .din(rx1tx0_din)
  , .full(rx1tx0_full)
  , .wr_cs(rx1tx0_wr_en)
  , .wr_en(rx1tx0_wr_en)
  , .dout(rx1tx0_dout)
  , .empty(rx1tx0_empty)
  , .rd_cs(rx1tx0_rd_en)
  , .rd_en(rx1tx0_rd_en)
  , .data_count(rx1tx0_data_count)
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
) rx1tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx1tx2_din),
  .full(rx1tx2_full),
  .wr_cs(rx1tx2_wr_en),
  .wr_en(rx1tx2_wr_en),

  .dout(rx1tx2_dout),
  .empty(rx1tx2_empty),
  .rd_cs(rx1tx2_rd_en),
  .rd_en(rx1tx2_rd_en),

  .data_count(rx1tx2_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx1tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx1tx3_din),
  .full(rx1tx3_full),
  .wr_cs(rx1tx3_wr_en),
  .wr_en(rx1tx3_wr_en),

  .dout(rx1tx3_dout),
  .empty(rx1tx3_empty),
  .rd_cs(rx1tx3_rd_en),
  .rd_en(rx1tx3_rd_en),

  .data_count(rx1tx3_data_count)
);
`else
sfifo9_12 rx1tx0_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx1tx0_din),
  .full(rx1tx0_full),
  .wr_en(rx1tx0_wr_en),

  .dout(rx1tx0_dout),
  .empty(rx1tx0_empty),
  .rd_en(rx1tx0_rd_en),

  .data_count(rx1tx0_data_count)
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
sfifo9_12 rx1tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx1tx2_din),
  .full(rx1tx2_full),
  .wr_en(rx1tx2_wr_en),

  .dout(rx1tx2_dout),
  .empty(rx1tx2_empty),
  .rd_en(rx1tx2_rd_en),

  .data_count(rx1tx2_data_count)
);
`else
assign rx1tx2_empty = 1'b1;
`endif
`ifdef ENABLE_RGMII3
sfifo9_12 rx1tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx1tx3_din),
  .full(rx1tx3_full),
  .wr_en(rx1tx3_wr_en),

  .dout(rx1tx3_dout),
  .empty(rx1tx3_empty),
  .rd_en(rx1tx3_rd_en),

  .data_count(rx1tx3_data_count)
);
`else
assign rx1tx3_empty = 1'b1;
`endif
`endif


`ifdef SIMULATION
sfifo # (
    .DATA_WIDTH(9)
  , .ADDR_WIDTH(12)
) rx2tx0_q (
    .clk(sys_clk)
  , .rst(sys_rst)
  , .din(rx2tx0_din)
  , .full(rx2tx0_full)
  , .wr_cs(rx2tx0_wr_en)
  , .wr_en(rx2tx0_wr_en)
  , .dout(rx2tx0_dout)
  , .empty(rx2tx0_empty)
  , .rd_cs(rx2tx0_rd_en)
  , .rd_en(rx2tx0_rd_en)
  , .data_count(rx2tx0_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx2tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx2tx1_din),
  .full(rx2tx1_full),
  .wr_cs(rx2tx1_wr_en),
  .wr_en(rx2tx1_wr_en),

  .dout(rx2tx1_dout),
  .empty(rx2tx1_empty),
  .rd_cs(rx2tx1_rd_en),
  .rd_en(rx2tx1_rd_en),

  .data_count(rx2tx1_data_count)
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
) rx2tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx2tx3_din),
  .full(rx2tx3_full),
  .wr_cs(rx2tx3_wr_en),
  .wr_en(rx2tx3_wr_en),

  .dout(rx2tx3_dout),
  .empty(rx2tx3_empty),
  .rd_cs(rx2tx3_rd_en),
  .rd_en(rx2tx3_rd_en),

  .data_count(rx2tx3_data_count)
);
`else
sfifo9_12 rx2tx0_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx2tx0_din),
  .full(rx2tx0_full),
  .wr_en(rx2tx0_wr_en),

  .dout(rx2tx0_dout),
  .empty(rx2tx0_empty),
  .rd_en(rx2tx0_rd_en),

  .data_count(rx2tx0_data_count)
);
sfifo9_12 rx2tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx2tx1_din),
  .full(rx2tx1_full),
  .wr_en(rx2tx1_wr_en),

  .dout(rx2tx1_dout),
  .empty(rx2tx1_empty),
  .rd_en(rx2tx1_rd_en),

  .data_count(rx2tx1_data_count)
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
sfifo9_12 rx2tx3_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx2tx3_din),
  .full(rx2tx3_full),
  .wr_en(rx2tx3_wr_en),

  .dout(rx2tx3_dout),
  .empty(rx2tx3_empty),
  .rd_en(rx2tx3_rd_en),

  .data_count(rx2tx3_data_count)
);
`else
assign rx2tx3_empty = 1'b1;
`endif
`endif


`ifdef SIMULATION
sfifo # (
    .DATA_WIDTH(9)
  , .ADDR_WIDTH(12)
) rx3tx0_q (
    .clk(sys_clk)
  , .rst(sys_rst)
  , .din(rx3tx0_din)
  , .full(rx3tx0_full)
  , .wr_cs(rx3tx0_wr_en)
  , .wr_en(rx3tx0_wr_en)
  , .dout(rx3tx0_dout)
  , .empty(rx3tx0_empty)
  , .rd_cs(rx3tx0_rd_en)
  , .rd_en(rx3tx0_rd_en)
  , .data_count(rx3tx0_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx3tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx3tx1_din),
  .full(rx3tx1_full),
  .wr_cs(rx3tx1_wr_en),
  .wr_en(rx3tx1_wr_en),

  .dout(rx3tx1_dout),
  .empty(rx3tx1_empty),
  .rd_cs(rx3tx1_rd_en),
  .rd_en(rx3tx1_rd_en),

  .data_count(rx3tx1_data_count)
);
sfifo # (
  .DATA_WIDTH(9),
  .ADDR_WIDTH(12)
) rx3tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx3tx2_din),
  .full(rx3tx2_full),
  .wr_cs(rx3tx2_wr_en),
  .wr_en(rx3tx2_wr_en),

  .dout(rx3tx2_dout),
  .empty(rx3tx2_empty),
  .rd_cs(rx3tx2_rd_en),
  .rd_en(rx3tx2_rd_en),

  .data_count(rx3tx2_data_count)
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
sfifo9_12 rx3tx0_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx3tx0_din),
  .full(rx3tx0_full),
  .wr_en(rx3tx0_wr_en),

  .dout(rx3tx0_dout),
  .empty(rx3tx0_empty),
  .rd_en(rx3tx0_rd_en),

  .data_count(rx3tx0_data_count)
);
sfifo9_12 rx3tx1_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx3tx1_din),
  .full(rx3tx1_full),
  .wr_en(rx3tx1_wr_en),

  .dout(rx3tx1_dout),
  .empty(rx3tx1_empty),
  .rd_en(rx3tx1_rd_en),

  .data_count(rx3tx1_data_count)
);
`ifdef ENABLE_RGMII2
sfifo9_12 rx3tx2_q (
  .clk(sys_clk),
  .rst(sys_rst),

  .din(rx3tx2_din),
  .full(rx3tx2_full),
  .wr_en(rx3tx2_wr_en),

  .dout(rx3tx2_dout),
  .empty(rx3tx2_empty),
  .rd_en(rx3tx2_rd_en),

  .data_count(rx3tx2_data_count)
);
`else
assign rx3tx2_empty = 1'b1;
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

  .din(rx0_phyq_din),
  .full(rx0_phyq_full),
  .wr_en(rx0_phyq_wr_en),
  .wr_clk()
);
gmii2fifo9 # (
  .Gap(4'h8)
) rx1gmii2fifo (
  .sys_rst(sys_rst),

  .gmii_rx_clk(gmii_1_rx_clk),
  .gmii_rx_dv(gmii_1_rx_dv),
  .gmii_rxd(gmii_1_rxd),

  .din(rx1_phyq_din),
  .full(rx1_phyq_full),
  .wr_en(rx1_phyq_wr_en),
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
// lookup flow table
//-----------------------------------
wire         port0of_lookup_req;
wire [115:0] port0of_lookup_data;
wire         port0of_lookup_ack;
wire         port0of_lookup_err;
wire [3:0]   port0of_lookup_fwd_port;
wire         port1of_lookup_req;
wire [115:0] port1of_lookup_data;
wire         port1of_lookup_ack;
wire         port1of_lookup_err;
wire [3:0]   port1of_lookup_fwd_port;
wire         port2of_lookup_req;
wire [115:0] port2of_lookup_data;
wire         port2of_lookup_ack;
wire         port2of_lookup_err;
wire [3:0]   port2of_lookup_fwd_port;
wire         port3of_lookup_req;
wire [115:0] port3of_lookup_data;
wire         port3of_lookup_ack;
wire         port3of_lookup_err;
wire [3:0]   port3of_lookup_fwd_port;

lookupflow #(
    .NPORT(4'h4)
  , .PORT_NUM(4'b0001)
) port0lookupflow_inst (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(port0of_lookup_req)
  , .of_lookup_data(port0of_lookup_data)
  , .of_lookup_ack(port0of_lookup_ack)
  , .of_lookup_err(port0of_lookup_err)
  , .of_lookup_fwd_port(port0of_lookup_fwd_port)
);

lookupflow #(
    .NPORT(4'h4)
  , .PORT_NUM(4'b0010)
) port1lookupflow_inst (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(port1of_lookup_req)
  , .of_lookup_data(port1of_lookup_data)
  , .of_lookup_ack(port1of_lookup_ack)
  , .of_lookup_err(port1of_lookup_err)
  , .of_lookup_fwd_port(port1of_lookup_fwd_port)
);

lookupflow #(
    .NPORT(4'h4)
  , .PORT_NUM(4'b0100)
) port2lookupflow_inst (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(port2of_lookup_req)
  , .of_lookup_data(port2of_lookup_data)
  , .of_lookup_ack(port2of_lookup_ack)
  , .of_lookup_err(port2of_lookup_err)
  , .of_lookup_fwd_port(port2of_lookup_fwd_port)
);

lookupflow #(
    .NPORT(4'h4)
  , .PORT_NUM(4'b1000)
) port3lookupflow_inst (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(port3of_lookup_req)
  , .of_lookup_data(port3of_lookup_data)
  , .of_lookup_ack(port3of_lookup_ack)
  , .of_lookup_err(port3of_lookup_err)
  , .of_lookup_fwd_port(port3of_lookup_fwd_port)
);

//-----------------------------------
// FORWARD module (port0)
//-----------------------------------
wire [8:0] rx0nic_din;
reg        rx0nic_full;
wire       rx0nic_wr_en;
forwarder #(
    .NPORT(4'h4)
  , .PORT_NUM(4'h0)
) forwarder_port0 (
    .sys_rst(sys_rst)
  , .sys_clk(sys_clk)

  , .rx_dout(rx0_phyq_dout)
  , .rx_empty(rx0_phyq_empty)
  , .rx_rd_en(rx0_phyq_rd_en)

  , .port0tx_din(rx0tx0_din)
  , .port0tx_full(rx0tx0_full)
  , .port0tx_wr_en(rx0tx0_wr_en)
  , .port1tx_din(rx0tx1_din)
  , .port1tx_full(rx0tx1_full)
  , .port1tx_wr_en(rx0tx1_wr_en)
  , .port2tx_din(rx0tx2_din)
  , .port2tx_full(rx0tx2_full)
  , .port2tx_wr_en(rx0tx2_wr_en)
  , .port3tx_din(rx0tx3_din)
  , .port3tx_full(rx0tx3_full)
  , .port3tx_wr_en(rx0tx3_wr_en)

  , .nic_din(rx0nic_din)
  , .nic_full(rx0nic_full)
  , .nic_wr_en(rx0nic_wr_en)

  , .of_lookup_req(port0of_lookup_req)
  , .of_lookup_data(port0of_lookup_data)
  , .of_lookup_ack(port0of_lookup_ack)
  , .of_lookup_err(port0of_lookup_err)
  , .of_lookup_fwd_port(port0of_lookup_fwd_port)
);

//-----------------------------------
// FORWARD module (port1)
//-----------------------------------
wire [8:0] rx1nic_din;
reg        rx1nic_full;
wire       rx1nic_wr_en;
forwarder #(
    .NPORT(4'h4)
  , .PORT_NUM(4'h1)
) forwarder_port1 (
    .sys_rst(sys_rst)
  , .sys_clk(sys_clk)

  , .rx_dout(rx1_phyq_dout)
  , .rx_empty(rx1_phyq_empty)
  , .rx_rd_en(rx1_phyq_rd_en)

  , .port0tx_din(rx1tx0_din)
  , .port0tx_full(rx1tx0_full)
  , .port0tx_wr_en(rx1tx0_wr_en)
  , .port1tx_din(rx1tx1_din)
  , .port1tx_full(rx1tx1_full)
  , .port1tx_wr_en(rx1tx1_wr_en)
  , .port2tx_din(rx1tx2_din)
  , .port2tx_full(rx1tx2_full)
  , .port2tx_wr_en(rx1tx2_wr_en)
  , .port3tx_din(rx1tx3_din)
  , .port3tx_full(rx1tx3_full)
  , .port3tx_wr_en(rx1tx3_wr_en)

  , .nic_din(rx1nic_din)
  , .nic_full(rx1nic_full)
  , .nic_wr_en(rx1nic_wr_en)

  , .of_lookup_req(port1of_lookup_req)
  , .of_lookup_data(port1of_lookup_data)
  , .of_lookup_ack(port1of_lookup_ack)
  , .of_lookup_err(port1of_lookup_err)
  , .of_lookup_fwd_port(port1of_lookup_fwd_port)
);

//-----------------------------------
// FORWARD module (port2)
//-----------------------------------
wire [8:0] rx2nic_din;
reg        rx2nic_full;
wire       rx2nic_wr_en;
forwarder #(
    .NPORT(4'h4)
  , .PORT_NUM(4'h2)
) forwarder_port2 (
    .sys_rst(sys_rst)
  , .sys_clk(sys_clk)

  , .rx_dout(rx2_phyq_dout)
  , .rx_empty(rx2_phyq_empty)
  , .rx_rd_en(rx2_phyq_rd_en)

  , .port0tx_din(rx2tx0_din)
  , .port0tx_full(rx2tx0_full)
  , .port0tx_wr_en(rx2tx0_wr_en)
  , .port1tx_din(rx2tx1_din)
  , .port1tx_full(rx2tx1_full)
  , .port1tx_wr_en(rx2tx1_wr_en)
  , .port2tx_din(rx2tx2_din)
  , .port2tx_full(rx2tx2_full)
  , .port2tx_wr_en(rx2tx2_wr_en)
  , .port3tx_din(rx2tx3_din)
  , .port3tx_full(rx2tx3_full)
  , .port3tx_wr_en(rx2tx3_wr_en)

  , .nic_din(rx2nic_din)
  , .nic_full(rx2nic_full)
  , .nic_wr_en(rx2nic_wr_en)

  , .of_lookup_req(port2of_lookup_req)
  , .of_lookup_data(port2of_lookup_data)
  , .of_lookup_ack(port2of_lookup_ack)
  , .of_lookup_err(port2of_lookup_err)
  , .of_lookup_fwd_port(port2of_lookup_fwd_port)
);

//-----------------------------------
// FORWARD module (port3)
//-----------------------------------
wire [8:0] rx3nic_din;
reg        rx3nic_full;
wire       rx3nic_wr_en;
forwarder #(
    .NPORT(4'h4)
  , .PORT_NUM(4'h3)
) forwarder_port3 (
    .sys_rst(sys_rst)
  , .sys_clk(sys_clk)

  , .rx_dout(rx3_phyq_dout)
  , .rx_empty(rx3_phyq_empty)
  , .rx_rd_en(rx3_phyq_rd_en)

  , .port0tx_din(rx3tx0_din)
  , .port0tx_full(rx3tx0_full)
  , .port0tx_wr_en(rx3tx0_wr_en)
  , .port1tx_din(rx3tx1_din)
  , .port1tx_full(rx3tx1_full)
  , .port1tx_wr_en(rx3tx1_wr_en)
  , .port2tx_din(rx3tx2_din)
  , .port2tx_full(rx3tx2_full)
  , .port2tx_wr_en(rx3tx2_wr_en)
  , .port3tx_din(rx3tx3_din)
  , .port3tx_full(rx3tx3_full)
  , .port3tx_wr_en(rx3tx3_wr_en)

  , .nic_din(rx3nic_din)
  , .nic_full(rx3nic_full)
  , .nic_wr_en(rx3nic_wr_en)

  , .of_lookup_req(port3of_lookup_req)
  , .of_lookup_data(port3of_lookup_data)
  , .of_lookup_ack(port3of_lookup_ack)
  , .of_lookup_err(port3of_lookup_err)
  , .of_lookup_fwd_port(port3of_lookup_fwd_port)
);


//-----------------------------------
// TX0,TX1,TX2,TX3_PHYQ FIFO
//-----------------------------------
wire [8:0] tx0_phyq_din, tx0_phyq_dout;
wire tx0_phyq_full, tx0_phyq_wr_en;
wire tx0_phyq_empty, tx0_phyq_rd_en;

wire [8:0] tx1_phyq_din, tx1_phyq_dout;
wire tx1_phyq_full, tx1_phyq_wr_en;
wire tx1_phyq_empty, tx1_phyq_rd_en;

wire [8:0] tx2_phyq_din, tx2_phyq_dout;
wire tx2_phyq_full, tx2_phyq_wr_en;
wire tx2_phyq_empty, tx2_phyq_rd_en;

wire [8:0] tx3_phyq_din, tx3_phyq_dout;
wire tx3_phyq_full, tx3_phyq_wr_en;
wire tx3_phyq_empty, tx3_phyq_rd_en;

`ifndef SIMULATION
asfifo9_12 tx0_phyq (
  .din(tx0_phyq_din),
  .full(tx0_phyq_full),
  .wr_en(tx0_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx0_phyq_dout),
  .empty(tx0_phyq_empty),
  .rd_en(tx0_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
asfifo9_12 tx1_phyq (
  .din(tx1_phyq_din),
  .full(tx1_phyq_full),
  .wr_en(tx1_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx1_phyq_dout),
  .empty(tx1_phyq_empty),
  .rd_en(tx1_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`ifdef ENABLE_RGMII2
asfifo9_12 tx2_phyq (
  .din(tx2_phyq_din),
  .full(tx2_phyq_full),
  .wr_en(tx2_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx2_phyq_dout),
  .empty(tx2_phyq_empty),
  .rd_en(tx2_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`endif
`ifdef ENABLE_RGMII3
asfifo9_12 tx3_phyq (
  .din(tx3_phyq_din),
  .full(tx3_phyq_full),
  .wr_en(tx3_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx3_phyq_dout),
  .empty(tx3_phyq_empty),
  .rd_en(tx3_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`endif
`else
asfifo # (
  .DATA_WIDTH(9),
  .ADDRESS_WIDTH(12)
) tx0fifo (
  .din(tx0_phyq_din),
  .full(tx0_phyq_full),
  .wr_en(tx0_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx0_phyq_dout),
  .empty(tx0_phyq_empty),
  .rd_en(tx0_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
asfifo # (
  .DATA_WIDTH(9),
  .ADDRESS_WIDTH(12)
) tx1fifo (
  .din(tx1_phyq_din),
  .full(tx1_phyq_full),
  .wr_en(tx1_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx1_phyq_dout),
  .empty(tx1_phyq_empty),
  .rd_en(tx1_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`ifdef ENABLE_RGMII2
asfifo # (
  .DATA_WIDTH(9),
  .ADDRESS_WIDTH(12)
) tx2fifo (
  .din(tx2_phyq_din),
  .full(tx2_phyq_full),
  .wr_en(tx2_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx2_phyq_dout),
  .empty(tx2_phyq_empty),
  .rd_en(tx2_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`endif
`ifdef ENABLE_RGMII3
asfifo # (
  .DATA_WIDTH(9),
  .ADDRESS_WIDTH(12)
) tx3fifo (
  .din(tx3_phyq_din),
  .full(tx3_phyq_full),
  .wr_en(tx3_phyq_wr_en),
  .wr_clk(sys_clk),

  .dout(tx3_phyq_dout),
  .empty(tx3_phyq_empty),
  .rd_en(tx3_phyq_rd_en),
  .rd_clk(gmii_tx_clk),

  .rst(sys_rst)
);
`endif
`endif


//-----------------------------------
// MIXER module
//-----------------------------------
mixer tx0mixer (
  .sys_rst(sys_rst),
  .sys_clk(sys_clk),

  .port0_dout(rx0tx0_dout),
  .port0_empty(rx0tx0_empty),
  .port0_rd_en(rx0tx0_rd_en),
  .port1_dout(rx1tx0_dout),
  .port1_empty(rx1tx0_empty),
  .port1_rd_en(rx1tx0_rd_en),
  .port2_dout(rx2tx0_dout),
  .port2_empty(rx2tx0_empty),
  .port2_rd_en(rx2tx0_rd_en),
  .port3_dout(rx3tx0_dout),
  .port3_empty(rx3tx0_empty),
  .port3_rd_en(rx3tx0_rd_en),
  .nic_dout(),
  .nic_empty(1'b1),
  .nic_rd_en(),

  .din(tx0_phyq_din),
  .full(tx0_phyq_full),
  .wr_en(tx0_phyq_wr_en)
);
mixer tx1mixer (
  .sys_rst(sys_rst),
  .sys_clk(sys_clk),

  .port0_dout(rx0tx1_dout),
  .port0_empty(rx0tx1_empty),
  .port0_rd_en(rx0tx1_rd_en),
  .port1_dout(rx1tx1_dout),
  .port1_empty(rx1tx1_empty),
  .port1_rd_en(rx1tx1_rd_en),
  .port2_dout(rx2tx1_dout),
  .port2_empty(rx2tx1_empty),
  .port2_rd_en(rx2tx1_rd_en),
  .port3_dout(rx3tx1_dout),
  .port3_empty(rx3tx1_empty),
  .port3_rd_en(rx3tx1_rd_en),
  .nic_dout(),
  .nic_empty(1'b1),
  .nic_rd_en(),

  .din(tx1_phyq_din),
  .full(tx1_phyq_full),
  .wr_en(tx1_phyq_wr_en)
);
`ifdef ENABLE_RGMII2
mixer tx2mixer (
  .sys_rst(sys_rst),
  .sys_clk(sys_clk),

  .port0_dout(rx0tx2_dout),
  .port0_empty(rx0tx2_empty),
  .port0_rd_en(rx0tx2_rd_en),
  .port1_dout(rx1tx2_dout),
  .port1_empty(rx1tx2_empty),
  .port1_rd_en(rx1tx2_rd_en),
  .port2_dout(rx2tx2_dout),
  .port2_empty(rx2tx2_empty),
  .port2_rd_en(rx2tx2_rd_en),
  .port3_dout(rx3tx2_dout),
  .port3_empty(rx3tx2_empty),
  .port3_rd_en(rx3tx2_rd_en),
  .nic_dout(),
  .nic_empty(1'b1),
  .nic_rd_en(),

  .din(tx2_phyq_din),
  .full(tx2_phyq_full),
  .wr_en(tx2_phyq_wr_en)
);
`endif
`ifdef ENABLE_RGMII3
mixer tx3mixer (
  .sys_rst(sys_rst),
  .sys_clk(sys_clk),

  .port0_dout(rx0tx3_dout),
  .port0_empty(rx0tx3_empty),
  .port0_rd_en(rx0tx3_rd_en),
  .port1_dout(rx1tx3_dout),
  .port1_empty(rx1tx3_empty),
  .port1_rd_en(rx1tx3_rd_en),
  .port2_dout(rx2tx3_dout),
  .port2_empty(rx2tx3_empty),
  .port2_rd_en(rx2tx3_rd_en),
  .port3_dout(rx3tx3_dout),
  .port3_empty(rx3tx3_empty),
  .port3_rd_en(rx3tx3_rd_en),
  .nic_dout(),
  .nic_empty(1'b1),
  .nic_rd_en(),

  .din(tx3_phyq_din),
  .full(tx3_phyq_full),
  .wr_en(tx3_phyq_wr_en)
);
`endif

//-----------------------------------
// FIFO9TOGMII module
//-----------------------------------
fifo9togmii tx0fifo2gmii (
  .sys_rst(sys_rst),

  .dout(tx0_phyq_dout),
  .empty(tx0_phyq_empty),
  .rd_en(tx0_phyq_rd_en),
  .rd_clk(),

  .gmii_tx_clk(gmii_tx_clk),
  .gmii_tx_en(gmii_0_tx_en),
  .gmii_txd(gmii_0_txd)
);
fifo9togmii tx1fifo2gmii (
  .sys_rst(sys_rst),

  .dout(tx1_phyq_dout),
  .empty(tx1_phyq_empty),
  .rd_en(tx1_phyq_rd_en),
  .rd_clk(),

  .gmii_tx_clk(gmii_tx_clk),
  .gmii_tx_en(gmii_1_tx_en),
  .gmii_txd(gmii_1_txd)
);
`ifdef ENABLE_RGMII2
fifo9togmii tx2fifo2gmii (
  .sys_rst(sys_rst),

  .dout(tx2_phyq_dout),
  .empty(tx2_phyq_empty),
  .rd_en(tx2_phyq_rd_en),
  .rd_clk(),

  .gmii_tx_clk(gmii_tx_clk),
  .gmii_tx_en(gmii_2_tx_en),
  .gmii_txd(gmii_2_txd)
);
`endif
`ifdef ENABLE_RGMII3
fifo9togmii tx3fifo2gmii (
  .sys_rst(sys_rst),

  .dout(tx3_phyq_dout),
  .empty(tx3_phyq_empty),
  .rd_en(tx3_phyq_rd_en),
  .rd_clk(),

  .gmii_tx_clk(gmii_tx_clk),
  .gmii_tx_en(gmii_3_tx_en),
  .gmii_txd(gmii_3_txd)
);
`endif



endmodule
