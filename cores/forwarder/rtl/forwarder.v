module forwarder #(
    parameter NPORT    = 4'h4
  , parameter PORT_NUM = 4'h0
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
  , output reg [115:0]     of_lookup_data
  , input                  of_lookup_ack
  , input                  of_lookup_err
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
// on data processing
//-----------------------------------
reg in_frame;
wire in_process = (in_frame == 1'b1 || rx_rd_en == 1'b1);

//-----------------------------------
// data pipeline
// 50 byte: Ethernet(802.1q) 24 byte + IPv4 20 byte + TCP 4 byte
//-----------------------------------
reg [9:0]          dout1,  dout2,  dout3,  dout4,  dout5,  dout6,  dout7,  dout8,  dout9,
          dout10, dout11, dout12, dout13, dout14, dout15, dout16, dout17, dout18, dout19,
          dout20, dout21, dout22, dout23, dout24, dout25, dout26, dout27, dout28, dout29,
          dout30, dout31, dout32, dout33, dout34, dout35, dout36, dout37, dout38, dout39,
          dout40, dout41, dout42, dout43, dout44, dout45, dout46, dout47, dout48, dout49,
          dout50, dout51, dout52, dout53, dout54, dout55, dout56, dout57, dout58, dout59,
          dout60, dout61, dout62, dout63, dout64, dout65, dout66, dout67, dout68, dout69;

always @(posedge sys_clk) begin
  if (sys_rst) begin
                       dout1 <= 10'b0;  dout2 <= 10'b0;  dout3 <= 10'b0;  dout4 <= 10'b0;
      dout5 <= 10'b0;  dout6 <= 10'b0;  dout7 <= 10'b0;  dout8 <= 10'b0;  dout9 <= 10'b0;
     dout10 <= 10'b0; dout11 <= 10'b0; dout12 <= 10'b0; dout13 <= 10'b0; dout14 <= 10'b0;
     dout15 <= 10'b0; dout16 <= 10'b0; dout17 <= 10'b0; dout18 <= 10'b0; dout19 <= 10'b0;
     dout20 <= 10'b0; dout21 <= 10'b0; dout22 <= 10'b0; dout23 <= 10'b0; dout24 <= 10'b0;
     dout25 <= 10'b0; dout26 <= 10'b0; dout27 <= 10'b0; dout28 <= 10'b0; dout29 <= 10'b0;
     dout30 <= 10'b0; dout31 <= 10'b0; dout32 <= 10'b0; dout33 <= 10'b0; dout34 <= 10'b0;
     dout35 <= 10'b0; dout36 <= 10'b0; dout37 <= 10'b0; dout38 <= 10'b0; dout39 <= 10'b0;
     dout40 <= 10'b0; dout41 <= 10'b0; dout42 <= 10'b0; dout43 <= 10'b0; dout44 <= 10'b0;
     dout45 <= 10'b0; dout46 <= 10'b0; dout47 <= 10'b0; dout48 <= 10'b0; dout49 <= 10'b0;
     dout50 <= 10'b0; dout51 <= 10'b0; dout52 <= 10'b0; dout53 <= 10'b0; dout54 <= 10'b0;
     dout55 <= 10'b0; dout56 <= 10'b0; dout57 <= 10'b0; dout58 <= 10'b0; dout59 <= 10'b0;
     dout60 <= 10'b0; dout61 <= 10'b0; dout62 <= 10'b0; dout63 <= 10'b0; dout64 <= 10'b0;
     dout65 <= 10'b0; dout66 <= 10'b0; dout67 <= 10'b0; dout68 <= 10'b0; dout69 <= 10'b0;
  end else begin
    if (in_process) begin
       dout1 <= { rx_rd_en, rx_dout };
                         dout2 <=  dout1;  dout3 <=  dout2;  dout4 <=  dout3;  dout5 <=  dout4;
       dout6 <= dout5;   dout7 <=  dout6;  dout8 <=  dout7;  dout9 <=  dout8; dout10 <=  dout9;
      dout11 <= dout10; dout12 <= dout11; dout13 <= dout12; dout14 <= dout13; dout15 <= dout14;
      dout16 <= dout15; dout17 <= dout16; dout18 <= dout17; dout19 <= dout18; dout20 <= dout19;
      dout21 <= dout20; dout22 <= dout21; dout23 <= dout22; dout24 <= dout23; dout25 <= dout24;
      dout26 <= dout25; dout27 <= dout26; dout28 <= dout27; dout29 <= dout28; dout30 <= dout29;
      dout31 <= dout30; dout32 <= dout31; dout33 <= dout32; dout34 <= dout33; dout35 <= dout34;
      dout36 <= dout35; dout37 <= dout36; dout38 <= dout37; dout39 <= dout38; dout40 <= dout39;
      dout41 <= dout40; dout42 <= dout41; dout43 <= dout42; dout44 <= dout43; dout45 <= dout44;
      dout46 <= dout45; dout47 <= dout46; dout48 <= dout47; dout49 <= dout48; dout50 <= dout49;
      dout51 <= dout50; dout52 <= dout51; dout53 <= dout52; dout54 <= dout53; dout55 <= dout54;
      dout56 <= dout55; dout57 <= dout56; dout58 <= dout57; dout59 <= dout58; dout60 <= dout59;
      dout61 <= dout60; dout62 <= dout61; dout63 <= dout62; dout64 <= dout63; dout65 <= dout64;
      dout66 <= dout65; dout67 <= dout66; dout68 <= dout67; dout69 <= dout68;
    end
  end
end

//-----------------------------------
// in_frame
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    in_frame <= 1'b0;
  end else begin
    if (in_process) begin
      if (dout42[9] == 1'b1)
        in_frame <= dout42[8];
    end
  end
end

//-----------------------------------
// global counter
//-----------------------------------
reg [11:0] counter;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    counter <= 12'b0;
  end else begin
    if (rx_rd_en) begin
      counter <= counter + 12'h1;
      if (rx_dout[8] == 1'b0)
        counter <= 12'h0;
    end
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
    if (in_process) begin
      if (dout42[9] == 1'b1) begin
        counter42 <= 12'b0;
        if (dout42[8] == 1'b1)
          counter42 <= counter42 + 12'b1;
      end
    end
  end
end

//-----------------------------------
// target headers of process
//-----------------------------------
reg [47:0] eth_dst;
reg [47:0] eth_src;
reg [15:0] eth_type;
//reg [11:0] vlan_id;
//reg [ 2:0] vlan_priority;
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
    if (rx_rd_en) begin
      if (rx_dout[8] == 1'b1 && rx_rd_en == 1'b1) begin
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
end

//-----------------------------------
// lookup requests
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_req <= 1'b0;
  end else begin
    of_lookup_req <= 1'b0;
    if (counter == 12'h26)
      of_lookup_req <= 1'b1;
  end
end

//-----------------------------------
// lookup data
// demo: 4(ingressport) + 48(srcmac) +  32(dstip) + 32(srcip) = 116
//-----------------------------------
wire [11:0] vlan_id       = 12'b0;
wire [2:0]  vlan_priority = 3'b0;
/*
assign of_lookup_data[242:0] = { 4'h0, eth_src, eth_dst, eth_type, vlan_id, vlan_priority,
                          ipv4_src_ip, ipv4_dst_ip, ipv4_proto, ipv4_tos,
                          tp_src_port, tp_dst_port };
*/
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_data <= 116'b0;
  end else begin
    case (counter)
      12'h01: of_lookup_data[115:112] <= 4'h0;
      12'h0c: of_lookup_data[111: 64] <= eth_src[47:0];
      12'h1e: of_lookup_data[ 63: 32] <= ipv4_src_ip[31:0];
      12'h22: of_lookup_data[ 31:  0] <= ipv4_dst_ip[31:0];
    endcase
  end
end

/*
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_data <= 243'b0;
  end else begin
    if (rx_rd_en && rx_dout[8]) begin
      case (counter)
        12'h00: of_lookup_data[242:239] <= PORT_NUM;
        12'h05: of_lookup_data[238:191] <= { eth_src[47:8], rx_dout[7:0] };
        12'h0b: of_lookup_data[190:143] <= { eth_dst[47:8], rx_dout[7:0] };
        12'h0d: begin
          of_lookup_data[142:127] <= { eth_type[15:8], rx_dout[7:0] };
          of_lookup_data[126:115] <= 12'h0;
          of_lookup_data[114:112] <= 3'h0;
        end
        12'h0f: of_lookup_data[ 39:32] <= rx_dout[7:0]; // ipv4_tos
        12'h17: of_lookup_data[ 47:40] <= rx_dout[7:0]; // ipv4_proto
        12'h1d: of_lookup_data[111:80] <= { ipv4_src_ip[31:8], rx_dout[7:0] };
        12'h21: of_lookup_data[ 79:48] <= { ipv4_dst_ip[31:8], rx_dout[7:0] };
        12'h23: of_lookup_data[ 31:16] <= { tp_src_port[31:8], rx_dout[7:0] };
        12'h25: of_lookup_data[ 15: 0] <= { tp_dst_port[31:8], rx_dout[7:0] };
      endcase
    end
  end
end
*/

//-----------------------------------
// lookup response (return forwarding ports)
//-----------------------------------
reg [3:0] fwd_port;
reg       fwd_nic;
wire      forward_nic = 1'b0;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    fwd_port <= 4'b0;
    fwd_nic  <= 1'b0;
  end else begin
    if (rx_rd_en) begin
      if (rx_dout[8] == 1'b1 && of_lookup_ack == 1'b1) begin
        fwd_port <= of_lookup_fwd_port[3:0];
        fwd_nic  <= forward_nic;
      end
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
    port_din      <= 9'b0;
    nic_din       <= 9'b0;
    fwd_port2     <= 4'b0;
    fwd_nic2      <= 1'b0;
  end else begin
    port0tx_wr_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
    port2tx_wr_en <= 1'b0;
    port3tx_wr_en <= 1'b0;
    nic_wr_en     <= 1'b0;
    if (in_process) begin
      if (dout42[9] == 1'b1) begin 
        port0tx_wr_en <= fwd_port2[0];
        port1tx_wr_en <= fwd_port2[1];
        port2tx_wr_en <= fwd_port2[2];
        port3tx_wr_en <= fwd_port2[3];
        nic_wr_en     <= fwd_nic;
        if (dout38[8] == 1'b1 && dout42[8] == 1'b1) begin
          nic_din <= dout42[8:0];
          case (counter42)
            12'h00: begin
              port_din      <= { 1'b1, eth_dst[47:40] };
              port0tx_wr_en <= fwd_port[0];
              port1tx_wr_en <= fwd_port[1];
              port2tx_wr_en <= fwd_port[2];
              port3tx_wr_en <= fwd_port[3];
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
            default: port_din <= dout42[8:0];
          endcase
        end else begin
          port_din <= 9'h0;
          nic_din  <= 9'h0;
        end
      end
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

endmodule

