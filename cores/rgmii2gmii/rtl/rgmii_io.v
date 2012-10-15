`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Murai Lab
// Engineer: Takeshi Matsuya
// 
// Create Date:    21:31:35 10/29/2011 
// Design Name: 
// Module Name:    rgmii_io.v
// Project Name:
// Target Devices: 
// Tool versions: 
// Description: RGMII to GMII bridge
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: See XAPP692
//
//////////////////////////////////////////////////////////////////////////////////

module rgmii_io
(
     //-----------------------------------------------------------------------
     //-- Pad side signals
     //-----------------------------------------------------------------------

	output [3:0] rgmii_txd,
	output       rgmii_tx_ctl,
	input        rgmii_tx_clk_int,
	input        not_rgmii_tx_clk,

	input  [3:0] rgmii_rxd,
	input        rgmii_rx_ctl,
	input        rgmii_rx_clk,

     //-----------------------------------------------------------------------
     //-- Core side signals
     //-----------------------------------------------------------------------

	input  [7:0] gmii_txd,      // Internal gmii_txd signal.
	input        gmii_tx_en,
	input        gmii_tx_er,

	output [7:0] gmii_rxd,
	output       gmii_rx_dv,
	output       gmii_rx_er,

	output       link,
	output [1:0] speed,
	output       duplex,

	input reset
);

//-----------------------------------------------------------------------
//-- RGMII_TXD[3:0]
//-----------------------------------------------------------------------
FDCE fdce_txd0 (
      .Q(fdce_txd0_1),
      .D (gmii_txd[0]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_txd1 (
      .Q(fdce_txd1_1),
      .D (gmii_txd[1]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_txd2 (
      .Q(fdce_txd2_1),
      .D (gmii_txd[2]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_txd3 (
      .Q(fdce_txd3_1),
      .D (gmii_txd[3]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_txd4 (
      .Q(fdce_txd4_1),
      .D (gmii_txd[4]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_txd5 (
      .Q(fdce_txd5_1),
      .D (gmii_txd[5]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_txd6 (
      .Q(fdce_txd6_1),
      .D (gmii_txd[6]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_txd7 (
      .Q(fdce_txd7_1),
      .D (gmii_txd[7]),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);

wire [3:0] rgmii_txd_obuf;

FDDRRSE fddrse_txd0 (
   .Q (rgmii_txd_obuf[0]),
   .D0(fdce_txd0_1),
   .D1(fdce_txd4_1),
   .C0(rgmii_tx_clk_int),
   .C1(not_rgmii_tx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
FDDRRSE fddrse_txd1 (
   .Q (rgmii_txd_obuf[1]),
   .D0(fdce_txd1_1),
   .D1(fdce_txd5_1),
   .C0(rgmii_tx_clk_int),
   .C1(not_rgmii_tx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
FDDRRSE fddrse_txd2 (
   .Q (rgmii_txd_obuf[2]),
   .D0(fdce_txd2_1),
   .D1(fdce_txd6_1),
   .C0(rgmii_tx_clk_int),
   .C1(not_rgmii_tx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
FDDRRSE fddrse_txd3 (
   .Q (rgmii_txd_obuf[3]),
   .D0(fdce_txd3_1),
   .D1(fdce_txd7_1),
   .C0(rgmii_tx_clk_int),
   .C1(not_rgmii_tx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
OBUF drive_rgmii_txd0 (.I(rgmii_txd_obuf[0]), .O(rgmii_txd[0]));
OBUF drive_rgmii_txd1 (.I(rgmii_txd_obuf[1]), .O(rgmii_txd[1]));
OBUF drive_rgmii_txd2 (.I(rgmii_txd_obuf[2]), .O(rgmii_txd[2]));
OBUF drive_rgmii_txd3 (.I(rgmii_txd_obuf[3]), .O(rgmii_txd[3]));

//-----------------------------------------------------------------------
//-- RGMII_TX_CTL
//-----------------------------------------------------------------------
assign tx_en_xor_tx_er = gmii_tx_en ^ gmii_tx_er;
FDCE fdce_txen (
      .Q(fdce_txen_1),
      .D (gmii_tx_en),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_txer (
      .Q(fdce_txer_1),
      .D (tx_en_xor_tx_er),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce1_txer (
      .Q(fdce1_txer_1),
      .D (fdce_txer_1),
      .C (rgmii_tx_clk_int),
      .CE(1'b1),
      .CLR(reset)
);
wire rgmii_tx_ctl_obuf;
FDDRRSE fddrse_txctl (
   .Q (rgmii_tx_ctl_obuf),
   .D0(fdce_txen_1),
   .D1(fdce1_txer_1),
   .C0(rgmii_tx_clk_int),
   .C1(not_rgmii_tx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
OBUF drive_rgmii_txctl (.I(rgmii_tx_ctl_obuf), .O(rgmii_tx_ctl));

assign not_rgmii_rx_clk   = ~rgmii_rx_clk;

//-----------------------------------------------------------------------
//-- RGMII_RXD[3:0]
//-----------------------------------------------------------------------
IFDDRRSE ifddrse_rxd0 (
   .Q0(ifddrse_rxd0_1),
   .Q1(ifddrse_rxd0_2),
   .D (rgmii_rxd[0]),
   .C0(rgmii_rx_clk),
   .C1(not_rgmii_rx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
IFDDRRSE ifddrse_rxd1 (
   .Q0(ifddrse_rxd1_1),
   .Q1(ifddrse_rxd1_2),
   .D (rgmii_rxd[1]),
   .C0(rgmii_rx_clk),
   .C1(not_rgmii_rx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
IFDDRRSE ifddrse_rxd2 (
   .Q0(ifddrse_rxd2_1),
   .Q1(ifddrse_rxd2_2),
   .D (rgmii_rxd[2]),
   .C0(rgmii_rx_clk),
   .C1(not_rgmii_rx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
IFDDRRSE ifddrse_rxd3 (
   .Q0(ifddrse_rxd3_1),
   .Q1(ifddrse_rxd3_2),
   .D (rgmii_rxd[3]),
   .C0(rgmii_rx_clk),
   .C1(not_rgmii_rx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
FDCE fdce_rxd0 (
      .Q(fdce_rxd0_1),
      .D (ifddrse_rxd0_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_rxd1 (
      .Q(fdce_rxd1_1),
      .D (ifddrse_rxd1_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_rxd2 (
      .Q(fdce_rxd2_1),
      .D (ifddrse_rxd2_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce_rxd3 (
      .Q(fdce_rxd3_1),
      .D (ifddrse_rxd3_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_rxd4 (
      .Q(fdce_rxd4_1),
      .D (ifddrse_rxd0_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_rxd5 (
      .Q(fdce_rxd5_1),
      .D (ifddrse_rxd1_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_rxd6 (
      .Q(fdce_rxd6_1),
      .D (ifddrse_rxd2_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_rxd7 (
      .Q(fdce_rxd7_1),
      .D (ifddrse_rxd3_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd0 (
      .Q(fdce_rxd0_2),
      .D (fdce_rxd0_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd1 (
      .Q(fdce_rxd1_2),
      .D (fdce_rxd1_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd2 (
      .Q(fdce_rxd2_2),
      .D (fdce_rxd2_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd3 (
      .Q(fdce_rxd3_2),
      .D (fdce_rxd3_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd4 (
      .Q(fdce_rxd4_2),
      .D (fdce_rxd4_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd5 (
      .Q(fdce_rxd5_2),
      .D (fdce_rxd5_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd6 (
      .Q(fdce_rxd6_2),
      .D (fdce_rxd6_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxd7 (
      .Q(fdce_rxd7_2),
      .D (fdce_rxd7_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd0 (
      .Q (gmii_rxd[0]),
      .D (fdce_rxd0_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd1 (
      .Q (gmii_rxd[1]),
      .D (fdce_rxd1_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd2 (
      .Q (gmii_rxd[2]),
      .D (fdce_rxd2_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd3 (
      .Q (gmii_rxd[3]),
      .D (fdce_rxd3_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd4 (
      .Q (gmii_rxd[4]),
      .D (fdce_rxd4_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd5 (
      .Q (gmii_rxd[5]),
      .D (fdce_rxd5_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd6 (
      .Q (gmii_rxd[6]),
      .D (fdce_rxd6_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxd7 (
      .Q (gmii_rxd[7]),
      .D (fdce_rxd7_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);

//-----------------------------------------------------------------------
//-- RGMII_RX_CTL
//-----------------------------------------------------------------------
IFDDRRSE ifddrse_rxctl (
   .Q0(ifddrse_rxctl_1),
   .Q1(ifddrse_rxctl_2),
   .D (rgmii_rx_ctl),
   .C0(rgmii_rx_clk),
   .C1(not_rgmii_rx_clk),
   .CE(1'b1),
   .R (reset),
   .S (1'b0)
);
FDCE fdce_rxctl1 (
      .Q (fdce_rxctl1_1),
      .D (ifddrse_rxctl_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE_1 fdce_rxctl2 (
      .Q (fdce_rxctl2_1),
      .D (ifddrse_rxctl_2),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxctl1 (
      .Q (fdce2_rxctl1_1),
      .D (fdce_rxctl1_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce2_rxctl2 (
      .Q (fdce2_rxctl2_1),
      .D (fdce_rxctl2_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
FDCE fdce3_rxctl1 (
      .Q (gmii_rx_dv),
      .D (fdce2_rxctl1_1),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);
assign fdce_xor = fdce_rxctl1_1 ^ fdce_rxctl2_1;
FDCE fdce3_rxctl2 (
      .Q (gmii_rx_er),
      .D (fdce_xor),
      .C (rgmii_rx_clk),
      .CE(1'b1),
      .CLR(reset)
);

//-----------------------------------------------------------------------
//-- RGMII_STATUS
//-----------------------------------------------------------------------
assign ce = ~(gmii_rx_dv | gmii_rx_er);
FDRSE fdrse_link (
      .Q (link),
      .D (gmii_rxd[0]),
      .C (rgmii_rx_clk),
      .CE(ce),
      .R (RESET),
      .S (1'b0)
);
FDRSE fdrse_speed0 (
      .Q (speed[0]),
      .D (gmii_rxd[0]),
      .C (rgmii_rx_clk),
      .CE(ce),
      .R (RESET),
      .S (1'b0)
);
FDRSE fdrse_speed1 (
      .Q (speed[1]),
      .D (gmii_rxd[0]),
      .C (rgmii_rx_clk),
      .CE(ce),
      .R (RESET),
      .S (1'b0)
);
FDRSE fdrse_duplex (
      .Q (duplex),
      .D (gmii_rxd[0]),
      .C (rgmii_rx_clk),
      .CE(ce),
      .R (RESET),
      .S (1'b0)
);

endmodule // rgmii_io
