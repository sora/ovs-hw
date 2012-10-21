`timescale 1ns / 1ps
`include "../rtl/setup.v"

//`define DEBUG

module top (
	input         cpci_reset,	// CPCI
	input         cpci_clk,
	input         gtx_clk,     // common TX clk reference 125MHz.

	// RGMII interfaces for 4 MACs
	output [3:0]  rgmii_0_txd,
	output        rgmii_0_tx_ctl,
	output        rgmii_0_txc,
	input  [3:0]  rgmii_0_rxd,
	input         rgmii_0_rx_ctl,
	input         rgmii_0_rxc,

	output [3:0]  rgmii_1_txd,
	output        rgmii_1_tx_ctl,
	output        rgmii_1_txc,
	input  [3:0]  rgmii_1_rxd,
	input         rgmii_1_rx_ctl,
	input         rgmii_1_rxc,

	output [3:0]  rgmii_2_txd,
	output        rgmii_2_tx_ctl,
	output        rgmii_2_txc,
	input  [3:0]  rgmii_2_rxd,
	input         rgmii_2_rx_ctl,
	input         rgmii_2_rxc,

	output [3:0]  rgmii_3_txd,
	output        rgmii_3_tx_ctl,
	output        rgmii_3_txc,
	input  [3:0]  rgmii_3_rxd,
	input         rgmii_3_rx_ctl,
	input         rgmii_3_rxc

);

wire sys_clk;

reg [9:0] reset_counter = 10'h0;
always @(posedge sys_clk) begin
	if (reset_counter[9] == 1'b0)
		reset_counter <= reset_counter + 10'd1;
end

assign reset   = ~reset_counter[9];
//assign reset   = ~cpci_reset;
//assign sys_clk = cpci_clk;

wire [7:0]    gmii_0_txd,   gmii_1_txd,   gmii_2_txd,   gmii_3_txd;
wire [7:0]    gmii_0_rxd,   gmii_1_rxd,   gmii_2_rxd,   gmii_3_rxd;
wire          gmii_0_link,  gmii_1_link,  gmii_2_link,  gmii_3_link;
wire [1:0]    gmii_0_speed, gmii_1_speed, gmii_2_speed, gmii_3_speed;
wire          gmii_0_duplex,gmii_1_duplex,gmii_2_duplex,gmii_3_duplex;

IBUF ibufg_gtx_clk (.I(gtx_clk), .O(gtx_clk_ibufg));
assign sys_clk = gtx_clk_ibufg;


wire tx_clk0, tx_clk90;
DCM RGMII_TX_DCM (
	.CLKIN(gtx_clk_ibufg),
	.CLKFB(rgmii_tx_clk_int),
	.DSSEN(1'b0),
	.PSINCDEC(1'b0),
	.PSEN(1'b0),
	.PSCLK(1'b0),
	.RST(reset),
	.CLK0(tx_clk0),
	.CLK90(tx_clk90),
	.CLK180(),
	.CLK270(),
	.CLK2X(),
	.CLK2X180(),
	.CLKDV(),
	.CLKFX(),
	.CLKFX180(),
	.PSDONE(),
	.STATUS(),
	.LOCKED());
BUFGMUX BUFGMUX_TXCLK (
	.O(rgmii_tx_clk_int),
	.I0(tx_clk0),
	.I1(tx_clk90),  // not used
	.S(1'b0)
);
BUFGMUX BUFGMUX_TXCLK90 (
	.O(rgmii_tx_clk90),
	.I1(tx_clk0),  // not used
	.I0(tx_clk90),
	.S(1'b0)
);
FDDRRSE gmii_0_tx_clk_ddr_iob (
	.Q (rgmii_0_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_1_tx_clk_ddr_iob (
	.Q (rgmii_1_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_2_tx_clk_ddr_iob (
	.Q (rgmii_2_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
FDDRRSE gmii_3_tx_clk_ddr_iob (
	.Q (rgmii_3_txc_obuf),
	.D0(1'b1),
	.D1(1'b0),
	.C0(rgmii_tx_clk90),
	.C1(~rgmii_tx_clk90),
	.CE(1'b1),
	.R (reset),
	.S (1'b0)
);
OBUF drive_rgmii_0_txc (.I(rgmii_0_txc_obuf), .O(rgmii_0_txc));
OBUF drive_rgmii_1_txc (.I(rgmii_1_txc_obuf), .O(rgmii_1_txc));
OBUF drive_rgmii_2_txc (.I(rgmii_2_txc_obuf), .O(rgmii_2_txc));
OBUF drive_rgmii_3_txc (.I(rgmii_3_txc_obuf), .O(rgmii_3_txc));

assign not_rgmii_tx_clk   = ~rgmii_tx_clk_int;
assign rgmii_tx_clk       = not_rgmii_tx_clk;

rgmii_io rgmii_0_io (
	.rgmii_txd             (rgmii_0_txd),
	.rgmii_tx_ctl          (rgmii_0_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_0_rxd),
	.rgmii_rx_ctl          (rgmii_0_rx_ctl),
	.rgmii_rx_clk          (~rgmii_0_rxc),
	.gmii_txd              (gmii_0_txd),
	.gmii_tx_en            (gmii_0_tx_en),
	.gmii_tx_er            (gmii_0_tx_er),
	.gmii_rxd              (gmii_0_rxd),
	.gmii_rx_dv            (gmii_0_rx_dv),
	.gmii_rx_er            (gmii_0_rx_er),
	.link                  (gmii_0_link),
	.speed                 (gmii_0_speed),
	.duplex                (gmii_0_duplex),
	.reset                 (reset)
);

rgmii_io rgmii_1_io (
	.rgmii_txd             (rgmii_1_txd),
	.rgmii_tx_ctl          (rgmii_1_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_1_rxd),
	.rgmii_rx_ctl          (rgmii_1_rx_ctl),
	.rgmii_rx_clk          (~rgmii_1_rxc),
	.gmii_txd              (gmii_1_txd),
	.gmii_tx_en            (gmii_1_tx_en),
	.gmii_tx_er            (gmii_1_tx_er),
	.gmii_rxd              (gmii_1_rxd),
	.gmii_rx_dv            (gmii_1_rx_dv),
	.gmii_rx_er            (gmii_1_rx_er),
	.link                  (gmii_1_link),
	.speed                 (gmii_1_speed),
	.duplex                (gmii_1_duplex),
	.reset                 (reset)
);

`ifdef ENABLE_RGMII2
rgmii_io rgmii_2_io (
	.rgmii_txd             (rgmii_2_txd),
	.rgmii_tx_ctl          (rgmii_2_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_2_rxd),
	.rgmii_rx_ctl          (rgmii_2_rx_ctl),
	.rgmii_rx_clk          (~rgmii_2_rxc),
	.gmii_txd              (gmii_2_txd),
	.gmii_tx_en            (gmii_2_tx_en),
	.gmii_tx_er            (gmii_2_tx_er),
	.gmii_rxd              (gmii_2_rxd),
	.gmii_rx_dv            (gmii_2_rx_dv),
	.gmii_rx_er            (gmii_2_rx_er),
	.link                  (gmii_2_link),
	.speed                 (gmii_2_speed),
	.duplex                (gmii_2_duplex),
	.reset                 (reset)
);
`else
assign rgmii_2_txd     = 4'hz;
assign rgmii_2_tx_ctl  = 1'h0;
assign rgmii_2_txc     = 1'hz;
`endif

`ifdef ENABLE_RGMII3
rgmii_io rgmii_3_io (
	.rgmii_txd             (rgmii_3_txd),
	.rgmii_tx_ctl          (rgmii_3_tx_ctl),
	.rgmii_tx_clk_int      (rgmii_tx_clk_int),
	.not_rgmii_tx_clk      (not_rgmii_tx_clk),
	.rgmii_rxd             (rgmii_3_rxd),
	.rgmii_rx_ctl          (rgmii_3_rx_ctl),
	.rgmii_rx_clk          (~rgmii_3_rxc),
	.gmii_txd              (gmii_3_txd),
	.gmii_tx_en            (gmii_3_tx_en),
	.gmii_tx_er            (gmii_3_tx_er),
	.gmii_rxd              (gmii_3_rxd),
	.gmii_rx_dv            (gmii_3_rx_dv),
	.gmii_rx_er            (gmii_3_rx_er),
	.link                  (gmii_3_link),
	.speed                 (gmii_3_speed),
	.duplex                (gmii_3_duplex),
	.reset                 (reset)
);
`else
assign rgmii_3_txd     = 4'hz;
assign rgmii_3_tx_ctl  = 1'h0;
assign rgmii_3_txc     = 1'hz;
`endif

assign gmii_0_tx_er = 1'b0;
assign gmii_1_tx_er = 1'b0;
assign gmii_2_tx_er = 1'b0;
assign gmii_3_tx_er = 1'b0;

system system_inst (
	.sys_rst(reset),
	.sys_clk(rgmii_tx_clk),

	.gmii_tx_clk(rgmii_tx_clk),

	.gmii_0_txd(gmii_0_txd),
	.gmii_0_tx_en(gmii_0_tx_en),
	.gmii_0_rxd(gmii_0_rxd),
	.gmii_0_rx_dv(gmii_0_rx_dv),
	.gmii_0_rx_clk(rgmii_0_rxc),

	.gmii_1_txd(gmii_1_txd),
	.gmii_1_tx_en(gmii_1_tx_en),
	.gmii_1_rxd(gmii_1_rxd),
	.gmii_1_rx_dv(gmii_1_rx_dv),
	.gmii_1_rx_clk(rgmii_1_rxc)

);

assign gmii_0_tx_er = 1'b0;
assign gmii_1_tx_er = 1'b0;

//assign rgmii_0_tx_ctl = rgmii0_tx_ctl;
//assign DEBUG_PIN0     = gmii_0_tx_en; //rgmii0_tx_ctl;
//assign DEBUG_PIN1     = gmii_1_rx_dv; // 1'b0; //rgmii_1_rx_ctl;
//assign DEBUG_PIN0     = rgmii0_tx_ctl;
//assign DEBUG_PIN1     = rgmii_1_rx_ctl;
endmodule
