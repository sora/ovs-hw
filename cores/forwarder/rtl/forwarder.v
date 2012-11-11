module forwarder #(
    parameter NPORT    = 4
  , parameter PORT_NUM = 4'd0
)(
    input            sys_rst
  , input            sys_clk
// in FIFO
  , input      [8:0] rx_dout
  , input            rx_empty
  , output reg       rx_rd_en
// out FIFO
  , output     [8:0] port0tx_din
  , input            port0tx_full
  , output reg       port0tx_wr_en
  , output     [8:0] port1tx_din
  , input            port1tx_full
  , output reg       port1tx_wr_en
  , output     [8:0] port2tx_din
  , input            port2tx_full
  , output reg       port2tx_wr_en
  , output     [8:0] port3tx_din
  , input            port3tx_full
  , output reg       port3tx_wr_en
  , output reg [8:0] nic_din
  , input            nic_full
  , output reg       nic_wr_en
// flow entries for lookup
  , output reg             of_lookup_req
  , output     [242:0]     of_lookup_data
  , input                  of_lookup_ack
  , input      [NPORT-1:0] of_lookup_fwd_port
);

/*
 * OpenFlow Match Fields (Spec 1.0.0)
 *   reg [ 3:0] of_ingress_port
 *   reg [47:0] of_eth_src
 *   reg [47:0] of_eth_dst
 *   reg [15:0] of_eth_type
 *   reg [11:0] of_vlan_id
 *   reg [ 2:0] of_vlan_priority
 *   reg [31:0] of_ip_src
 *   reg [31:0] of_ip_dst
 *   reg [ 7:0] of_ip_proto
 *   reg [ 7:0] of_ip_tos
 *   reg [15:0] of_tp_src_port
 *   reg [15:0] of_tp_dst_port
 */

/* 
 * Format of forwarding port
 * 1         :=> forwarding port
 * 0         :=> no forwarding port
 * bit width :=> number of ports
 * ex)
 *  fwd_port == 4'b1000 :=> forward to port 3
 *  fwd_port == 4'b0001 :=> forward to port 0
 *  fwd_port == 4'b1010 :=> forward to port 1 and 3
 *  fwd_port == 4'b0000 :=> drop packets
 *  fwd_port == 4'b1111 :=> forward to all ports
 */

//-----------------------------------
// RX FIFO read enable
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst)
    rx_rd_en <= 1'b0;
  else
    rx_rd_en <= ~rx_empty;
end

//-----------------------------------
// data pipeline
// 50 byte: Ethernet(802.1q) 24 byte + IPv4 20 byte + TCP 4 byte
//-----------------------------------
reg [9:0] dout [0:57];
always @(posedge sys_clk) begin
  if (sys_rst) begin
    dout[ 0] <= 10'b0; dout[ 1] <= 10'b0; dout[ 2] <= 10'b0; dout[ 3] <= 10'b0;
    dout[ 4] <= 10'b0; dout[ 5] <= 10'b0; dout[ 6] <= 10'b0; dout[ 7] <= 10'b0;
    dout[ 8] <= 10'b0; dout[ 9] <= 10'b0; dout[10] <= 10'b0; dout[11] <= 10'b0;
    dout[12] <= 10'b0; dout[13] <= 10'b0; dout[14] <= 10'b0; dout[15] <= 10'b0;
    dout[16] <= 10'b0; dout[17] <= 10'b0; dout[18] <= 10'b0; dout[19] <= 10'b0;
    dout[20] <= 10'b0; dout[21] <= 10'b0; dout[22] <= 10'b0; dout[23] <= 10'b0;
    dout[24] <= 10'b0; dout[25] <= 10'b0; dout[26] <= 10'b0; dout[27] <= 10'b0;
    dout[28] <= 10'b0; dout[29] <= 10'b0; dout[30] <= 10'b0; dout[31] <= 10'b0;
    dout[32] <= 10'b0; dout[33] <= 10'b0; dout[34] <= 10'b0; dout[35] <= 10'b0;
    dout[36] <= 10'b0; dout[37] <= 10'b0; dout[38] <= 10'b0; dout[39] <= 10'b0;
    dout[40] <= 10'b0; dout[41] <= 10'b0; dout[42] <= 10'b0; dout[43] <= 10'b0;
    dout[44] <= 10'b0; dout[45] <= 10'b0; dout[46] <= 10'b0; dout[47] <= 10'b0;
    dout[48] <= 10'b0; dout[49] <= 10'b0; dout[50] <= 10'b0; dout[51] <= 10'b0;
    dout[52] <= 10'b0; dout[53] <= 10'b0; dout[54] <= 10'b0; dout[55] <= 10'b0;
    dout[56] <= 10'b0; dout[57] <= 10'b0;
  end else begin
    if (rx_rd_en) begin
      dout[ 0] <= { rx_rd_en, rx_dout };
      dout[ 1] <= dout[ 0]; dout[ 2] <= dout[ 1]; dout[ 3] <= dout[ 2]; dout[ 4] <= dout[ 3];
      dout[ 5] <= dout[ 4]; dout[ 6] <= dout[ 5]; dout[ 7] <= dout[ 6]; dout[ 8] <= dout[ 7];
      dout[ 9] <= dout[ 8]; dout[10] <= dout[ 9]; dout[11] <= dout[10]; dout[12] <= dout[11];
      dout[13] <= dout[12]; dout[14] <= dout[13]; dout[15] <= dout[14]; dout[16] <= dout[15];
      dout[17] <= dout[16]; dout[18] <= dout[17]; dout[19] <= dout[18]; dout[20] <= dout[19];
      dout[21] <= dout[20]; dout[22] <= dout[21]; dout[23] <= dout[22]; dout[24] <= dout[23];
      dout[25] <= dout[24]; dout[26] <= dout[25]; dout[27] <= dout[26]; dout[28] <= dout[27];
      dout[29] <= dout[28]; dout[30] <= dout[29]; dout[31] <= dout[30]; dout[32] <= dout[31];
      dout[33] <= dout[32]; dout[34] <= dout[33]; dout[35] <= dout[34]; dout[36] <= dout[35];
      dout[37] <= dout[36]; dout[38] <= dout[37]; dout[39] <= dout[38]; dout[40] <= dout[39];
      dout[41] <= dout[40]; dout[42] <= dout[41]; dout[43] <= dout[42]; dout[44] <= dout[43];
      dout[45] <= dout[44]; dout[46] <= dout[45]; dout[47] <= dout[46]; dout[48] <= dout[47];
      dout[49] <= dout[48]; dout[50] <= dout[49]; dout[51] <= dout[50]; dout[52] <= dout[51];
      dout[53] <= dout[52]; dout[54] <= dout[53]; dout[55] <= dout[54]; dout[56] <= dout[55];
      dout[57] <= dout[56];
    end
  end
end

//-----------------------------------
// in_frame
//-----------------------------------
reg in_frame;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    in_frame <= 1'b0;
  end else begin
    if (rx_rd_en)
      in_frame <= dout[42][8];
  end
end

//-----------------------------------
// counter
//-----------------------------------
reg [11:0] counter;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    counter <= 12'b0;
  end else begin
    if (rx_rd_en)
      counter <= counter + 12'h1;
    else
      counter <= 12'h0;
  end
end

//-----------------------------------
// TX counter
//-----------------------------------
reg [11:0] counter42;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    counter42 <= 12'b0;
  end else begin
    if (rx_rd_en || in_frame) begin
      if (dout[42][8])
        counter42 <= counter42 + 12'b1;
      else
        counter42 <= 12'b0;
    end
  end
end

//-----------------------------------
// target headers
//-----------------------------------
reg [47:0] eth_dst;
reg [47:0] eth_src;
reg [15:0] eth_type;
reg [11:0] vlan_id;
reg [ 2:0] vlan_priority;
reg [ 3:0] ip_hdrlen;
reg [ 7:0] ipv4_tos;
reg [ 7:0] ipv4_ttl;
reg [ 7:0] ipv4_proto;
reg [31:0] ipv4_src_ip;
reg [31:0] ipv4_dst_ip;
reg [15:0] tp_src_port;
reg [15:0] tp_dst_port;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    eth_dst     <= 48'b0;
    eth_src     <= 48'b0;
    eth_type    <= 16'b0;
    ip_hdrlen   <= 4'b0;
    ipv4_tos    <= 8'b0;
    ipv4_ttl    <= 8'b0;
    ipv4_proto  <= 8'b0;
    ipv4_src_ip <= 32'b0;
    ipv4_dst_ip <= 32'b0;
    tp_src_port <= 16'b0;
    tp_dst_port <= 16'b0;
  end else begin
    if (rx_rd_en && rx_dout[8]) begin
      case (counter)
        // ethernet dst MAC Address
        12'h00: eth_dst[47:40] <= rx_dout[7:0];
        12'h01: eth_dst[39:32] <= rx_dout[7:0];
        12'h02: eth_dst[31:24] <= rx_dout[7:0];
        12'h03: eth_dst[23:16] <= rx_dout[7:0];
        12'h04: eth_dst[15: 8] <= rx_dout[7:0];
        12'h05: eth_dst[ 7: 0] <= rx_dout[7:0];
        // ethernet src MAC Address
        12'h06: eth_src[47:40] <= rx_dout[7:0];
        12'h07: eth_src[39:32] <= rx_dout[7:0];
        12'h08: eth_src[31:24] <= rx_dout[7:0];
        12'h09: eth_src[23:16] <= rx_dout[7:0];
        12'h0a: eth_src[15: 8] <= rx_dout[7:0];
        12'h0b: eth_src[ 7: 0] <= rx_dout[7:0];
        // ethernet type
        12'h0c: eth_type[15: 8] <= rx_dout[7:0];
        12'h0d: eth_type[ 7: 0] <= rx_dout[7:0];
        // IPv4 header length
        12'h0e: ip_hdrlen[3:0] <= rx_dout[3:0];
        // IPv4 ToS
        12'h0f: ipv4_tos[7:0] <= rx_dout[7:0];
        // IPv4 TTL
        12'h16: ipv4_ttl[7:0] <= rx_dout[7:0];
        // IPv4 protocol
        12'h17: ipv4_proto[7:0] <= rx_dout[7:0];
        // IPv4 src IP address
        12'h1a: ipv4_src_ip[31:24] <= rx_dout[7:0];
        12'h1b: ipv4_src_ip[23:16] <= rx_dout[7:0];
        12'h1c: ipv4_src_ip[15: 8] <= rx_dout[7:0];
        12'h1d: ipv4_src_ip[ 7: 0] <= rx_dout[7:0];
        // IPv4 dst IP address
        12'h1e: ipv4_dst_ip[31:24] <= rx_dout[7:0];
        12'h1f: ipv4_dst_ip[23:16] <= rx_dout[7:0];
        12'h20: ipv4_dst_ip[15: 8] <= rx_dout[7:0];
        12'h21: ipv4_dst_ip[ 7: 0] <= rx_dout[7:0];
        // transport layer src port
        12'h22: tp_src_port[15: 8] <= rx_dout[7:0];
        12'h23: tp_src_port[ 7: 0] <= rx_dout[7:0];
        // transport layer dst port
        12'h24: tp_dst_port[15: 8] <= rx_dout[7:0];
        12'h25: tp_dst_port[ 7: 0] <= rx_dout[7:0];
      endcase
    end
  end
end

//-----------------------------------
// lookup requests
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_req <= 1'b0;
  end else begin
    if (counter == 12'h26)
      of_lookup_req <= 1'b1;
    else
      of_lookup_req <= 1'b0;
  end
end

//-----------------------------------
// lookup data
//-----------------------------------
assign of_lookup_data = { PORT_NUM, eth_src, eth_dst, eth_type, vlan_id, vlan_priority,
                          ipv4_src_ip, ipv4_dst_ip, ipv4_proto, ipv4_tos,
                          tp_src_port, tp_dst_port };

//-----------------------------------
// lookup response (forwarding port)
//-----------------------------------
reg [3:0] fwd_port;
reg       fwd_nic;
wire      forward_nic = 1'b0;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    fwd_port <= 4'b0;
    fwd_nic  <= 1'b0;
  end else begin
    if (rx_rd_en && of_lookup_ack) begin
      fwd_port <= of_lookup_fwd_port[3:0];
      fwd_nic  <= forward_nic;
    end
  end
end

//-----------------------------------
// TX write enable
//-----------------------------------
reg [8:0] port_din;
reg [3:0] fwd_port2;
reg       fwd_nic2;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port0tx_wr_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
    port2tx_wr_en <= 1'b0;
    port3tx_wr_en <= 1'b0;
    nic_wr_en     <= 1'b0;
  end else begin
    port0tx_wr_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
    port2tx_wr_en <= 1'b0;
    port3tx_wr_en <= 1'b0;
    nic_wr_en     <= 1'b0;
    if (rx_rd_en || in_frame) begin
      if (dout[42][9] && dout[42][8]) begin
        case (counter42)
          12'h00: begin
            port_din <= { 1'b1, eth_dst[47:40] };
            port0tx_wr_en <= fwd_port[0];
            port1tx_wr_en <= fwd_port[1];
            port2tx_wr_en <= fwd_port[2];
            port3tx_wr_en <= fwd_port[3];
            nic_wr_en     <= fwd_nic;
            fwd_port2     <= fwd_port;
            fwd_nic2      <= fwd_nic;
          end
          12'h01: port_din <= { 1'b1, eth_dst[39:32] };
          12'h02: port_din <= { 1'b1, eth_dst[31:24] };
          12'h03: port_din <= { 1'b1, eth_dst[23:16] };
          12'h04: port_din <= { 1'b1, eth_dst[15: 8] };
          12'h05: port_din <= { 1'b1, eth_dst[ 7: 0] };
          12'h06: port_din <= { 1'b1, eth_src[47:40] };
          12'h07: port_din <= { 1'b1, eth_src[39:32] };
          12'h08: port_din <= { 1'b1, eth_src[31:24] };
          12'h09: port_din <= { 1'b1, eth_src[23:16] };
          12'h0a: port_din <= { 1'b1, eth_src[15: 8] };
          12'h0b: port_din <= { 1'b1, eth_src[ 7: 0] };
          12'h0c: port_din <= { 1'b1, eth_type[15: 8] };
          12'h0d: port_din <= { 1'b1, eth_type[ 7: 0] };
          12'h17: port_din <= { 1'b1, ipv4_proto[ 7: 0] };
          12'h1a: port_din <= { 1'b1, ipv4_src_ip[31:24] };
          12'h1b: port_din <= { 1'b1, ipv4_src_ip[23:16] };
          12'h1c: port_din <= { 1'b1, ipv4_src_ip[15: 8] };
          12'h1d: port_din <= { 1'b1, ipv4_src_ip[ 7: 0] };
          12'h1e: port_din <= { 1'b1, ipv4_dst_ip[31:24] };
          12'h1f: port_din <= { 1'b1, ipv4_dst_ip[23:16] };
          12'h20: port_din <= { 1'b1, ipv4_dst_ip[15: 8] };
          12'h21: port_din <= { 1'b1, ipv4_dst_ip[ 7: 0] };
          12'h22: port_din <= { 1'b1, tp_src_port[15: 8] };
          12'h23: port_din <= { 1'b1, tp_src_port[ 7: 0] };
          12'h24: port_din <= { 1'b1, tp_dst_port[15: 8] };
          12'h25: port_din <= { 1'b1, tp_dst_port[ 7: 0] };
          default: port_din <= dout[42][8:0];
        endcase
        nic_din <= dout[42][8:0];
      end else begin
        port_din <= 9'h0;
        nic_din  <= 9'h0;
      end
      port0tx_wr_en <= fwd_port2[0];
      port1tx_wr_en <= fwd_port2[1];
      port2tx_wr_en <= fwd_port2[2];
      port3tx_wr_en <= fwd_port2[3];
      nic_wr_en     <= fwd_nic2;
    end
  end
end

//-----------------------------------
// TX write data
//-----------------------------------
assign port0tx_din = port_din;
assign port1tx_din = port_din;
assign port2tx_din = port_din;
assign port3tx_din = port_din;

//-----------------------------------
// forwarding from port0 rx
//-----------------------------------
//always @(posedge sys_clk) begin
//  if (sys_rst) begin
//    port0rx_rd_en <= 1'b0;
//    port1tx_wr_en <= 1'b0;
//  end else begin
//    port0rx_rd_en <= ~port0rx_empty;
//    port1tx_wr_en <= 1'b0;
//    if (port0rx_rd_en == 1'b1) begin
//      port1tx_din   <= port0rx_dout[8:0];
//      port1tx_wr_en <= 1'b1;
//    end
//  end
//end

endmodule

