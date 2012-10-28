module forwarder #(
    parameter port_num = 4'b0
)(
  , input            sys_rst
  , input            sys_clk
// in FIFO
  , input      [8:0] rx_dout
  , input            rx_empty
  , output reg       rx_rd_en
// out FIFO
  , output reg [8:0] port0tx_din
  , input            port0tx_full
  , output reg       port0tx_wr_en
  , output reg [8:0] port1tx_din
  , input            port1tx_full
  , output reg       port1tx_wr_en
  , output reg [8:0] port2tx_din
  , input            port2tx_full
  , output reg       port2tx_wr_en
  , output reg [8:0] port3tx_din
  , input            port3tx_full
  , output reg       port3tx_wr_en
// flow entries for lookup
  , output reg        of_ingress_port_req
  , output reg [ 3:0] of_ingress_port
  , output reg        of_eth_src_req
  , output reg [47:0] of_eth_src
  , output reg        of_eth_dst_req
  , output reg [47:0] of_eth_dst
  , output reg        of_eth_type_req
  , output reg [15:0] of_eth_type
  , output reg        of_vlan_id_req
  , output reg [11:0] of_vlan_id
  , output reg        of_vlan_priority_req
  , output reg [ 2:0] of_vlan_priority
  , output reg        of_ip_src_req
  , output reg [31:0] of_ip_src
  , output reg        of_ip_dst_req
  , output reg [31:0] of_ip_dst
  , output reg        of_ip_proto_req
  , output reg [ 7:0] of_ip_proto
  , output reg        of_ip_tos_req
  , output reg [ 7:0] of_ip_tos
  , output reg        of_layer4_src_port_req
  , output reg [15:0] of_layer4_src_port
  , output reg        of_layer4_dst_port_req
  , output reg [15:0] of_layer4_dst_port
  , input             of_fwd_port_res
  , input             of_fwd_port_err
  , input      [ 3:0] of_fwd_port
);

//-----------------------------------
// data pipeline
// 50 byte: Ethernet(802.1q) 26 byte + IPv4 20 byte + TCP 4 byte
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
// RX FIFO read enable
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst)
    rx_rd_en <= 1'b0;
  else
    rx_rd_en <= ~rx_empty;
end

//-----------------------------------
// target headers
//-----------------------------------
reg [47:0] eth_dst;
reg [47:0] eth_src;
reg [15:0] eth_type;
reg [ 3:0] ipv4_hdrlen;
reg [ 7:0] ipv4_tos;
reg [ 7:0] ipv4_ttl;
reg [ 7:0] ipv4_proto;
reg [31:0] ipv4_src_ip;
reg [31:0] ipv4_dst_ip;
reg [15:0] layer4_src_port;
reg [15:0] layer4_dst_port;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    eth_dst         <= 48'b0;
    eth_src         <= 48'b0;
    eth_type        <= 16'b0;
    ipv4_hdrlen     <= 4'b0;
    ipv4_tos        <= 8'b0;
    ipv4_ttl        <= 8'b0;
    ipv4_proto      <= 8'b0;
    ipv4_src_ip     <= 32'b0;
    ipv4_dst_ip     <= 32'b0;
    layer4_src_port <= 16'b0;
    layer4_dst_port <= 16'b0;
  end else begin
    if (rx_rd_en && dout[8]) begin
      case (counter)
        // ethernet dst MAC Address
        12'h00: eth_dst[47:40] <= dout[7:0];
        12'h01: eth_dst[39:32] <= dout[7:0];
        12'h02: eth_dst[31:24] <= dout[7:0];
        12'h03: eth_dst[23:16] <= dout[7:0];
        12'h04: eth_dst[15: 8] <= dout[7:0];
        12'h05: eth_dst[ 7: 0] <= dout[7:0];
        // ethernet src MAC Address
        12'h06: eth_src[47:40] <= dout[7:0];
        12'h07: eth_src[39:32] <= dout[7:0];
        12'h08: eth_src[31:24] <= dout[7:0];
        12'h09: eth_src[23:16] <= dout[7:0];
        12'h0a: eth_src[15: 8] <= dout[7:0];
        12'h0b: eth_src[ 7: 0] <= dout[7:0];
        // ethernet type
        12'h0c: eth_type[15: 8] <= dout[7:0];
        12'h0d: eth_type[ 7: 0] <= dout[7:0];
        // IPv4 header length
        12'h0e: ipv4_hdrlen[3:0] <= dout[3:0];
        // IPv4 ToS
        12'h0f: ipv4_tos[7:0] <= dout[7:0];
        // IPv4 TTL
        12'h16: ipv4_ttl[7:0] <= dout[7:0];
        // IPv4 protocol
        12'h17: ipv4_proto[7:0] <= dout[7:0];
        // IPv4 src IP address
        12'h1a: ipv4_src_ip[31:24] <= dout[7:0];
        12'h1b: ipv4_src_ip[23:16] <= dout[7:0];
        12'h1c: ipv4_src_ip[15: 8] <= dout[7:0];
        12'h1d: ipv4_src_ip[ 7: 0] <= dout[7:0];
        // IPv4 dst IP address
        12'h1e: ipv4_dst_ip[31:24] <= dout[7:0];
        12'h1f: ipv4_dst_ip[23:16] <= dout[7:0];
        12'h20: ipv4_dst_ip[15: 8] <= dout[7:0];
        12'h21: ipv4_dst_ip[ 7: 0] <= dout[7:0];
        // Layer4 src port
        12'h22: layer4_src_port[16: 8] <= dout[7:0];
        12'h23: layer4_src_port[ 7: 0] <= dout[7:0];
        // Layer4 dst port
        12'h24: layer4_dst_port[16: 8] <= dout[7:0];
        12'h25: layer4_dst_port[ 7: 0] <= dout[7:0];
      endcase
    end
  end
end

//-----------------------------------
// lookup requests
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_ingress_port_req    <= 1'b0;
    of_eth_src_req         <= 1'b0;
    of_eth_dst_req         <= 1'b0;
    of_eth_type_req        <= 1'b0;
    of_vlan_id_req         <= 1'b0;
    of_vlan_priority_req   <= 1'b0;
    of_ip_src_req          <= 1'b0;
    of_ip_dst_req          <= 1'b0;
    of_ip_proto_req        <= 1'b0;
    of_ip_tos_req          <= 1'b0;
    of_layer4_src_port_req <= 1'b0;
    of_layer4_dst_port_req <= 1'b0;
    of_ingress_port        <= 4'b0;
    of_eth_src             <= 48'b0;
    of_eth_dst             <= 48'b0;
    of_eth_type            <= 16'b0;
    of_vlan_id             <= 16'b0;
    of_vlan_priority       <= 3'b0;
    of_ip_src              <= 32'b0;
    of_ip_dst              <= 32'b0;
    of_ip_proto            <= 8'b0;
    of_ip_tos              <= 8'b0;
    of_layer4_src_port     <= 16'b0;
    of_layer4_dst_port     <= 16'b0;
  end else begin
    if (rx_rd_en && dout[8]) begin
      case (counter)
        12'h00: begin // ingress port
          of_ingress_port_req  <= 1'b1;
          of_ingress_port[3:0] <= port_num;
        end
        12'h05: begin // etherent dst MAC address
          of_eth_dst_req   <= 1'b1;
          of_eth_dst[47:0] <= { of_eth_dst[47:8], dout[7:0] };
        end
        12'h0b: begin // etherent src MAC address
          of_eth_src_req   <= 1'b1;
          of_eth_src[47:0] <= { of_eth_src[47:8], dout[7:0] };
        end
        12'h0d: begin // etherent type
          of_eth_type_req   <= 1'b1;
          of_eth_type[15:0] <= { of_eth_type[15:8], dout[7:0] };
        end
        12'h0f: begin // IPv4 ToS
          of_ip_tos_req  <= 1'b1;
          of_ip_tos[7:0] <= dout[7:0];
        end
        12'h17: begin // IPv4 protocol
          of_ip_proto_req  <= 1'b1;
          of_ip_proto[7:0] <= dout[7:0];
        end
        12'h1d: begin // IPv4 src IP address
          of_ip_src_req   <= 1'b1;
          of_ip_src[31:0] <= { ipv4_src_ip[31:8], dout[7:0] };
        end
        12'h21: begin // IPv4 dst IP address
          of_ip_dst_req   <= 1'b1;
          of_ip_dst[31:0] <= { ipv4_dst_ip[31:8], dout[7:0] };
        end
        12'h23: begin // Layer4 src port
          of_layer4_src_port_req   <= 1'b1;
          of_layer4_src_port[15:0] <= { of_layer4_src_port[15:8], dout[7:0] };
        end
        12'h25: begin // Layer4 dst port
          of_layer4_dst_port_req   <= 1'b1;
          of_layer4_dst_port[15:0] <= { of_layer4_dst_port[15:8], dout[7:0] };
        end
      endcase
    end else begin
      of_ingress_port_req    <= 1'b0;
      of_eth_src_req         <= 1'b0;
      of_eth_dst_req         <= 1'b0;
      of_eth_type_req        <= 1'b0;
      of_vlan_id_req         <= 1'b0;
      of_vlan_priority_req   <= 1'b0;
      of_ip_src_req          <= 1'b0;
      of_ip_dst_req          <= 1'b0;
      of_ip_proto_req        <= 1'b0;
      of_ip_tos_req          <= 1'b0;
      of_layer4_src_port_req <= 1'b0;
      of_layer4_dst_port_req <= 1'b0;
    end
  end
end

//-----------------------------------
// lookup response
//-----------------------------------
reg [3:0] fwd_port;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    fwd_port <= 4'b0;
  end else begin
    if (rx_rd_en && dout[8] && of_fwd_port_res && !of_fwd_port_err) begin
      fwd_port <= of_fwd_port[3:0];
    end else begin
      fwd_port <= 4'b0;
    end
  end
end

//-----------------------------------
// forwarding
//-----------------------------------
reg [3:0] fwd_port;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port0tx_wr_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
    port2tx_wr_en <= 1'b0;
    port3tx_wr_en <= 1'b0;
    fwd_port      <= 4'b0;
  end else begin
    port0tx_wr_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
    port2tx_wr_en <= 1'b0;
    port3tx_wr_en <= 1'b0;
    if (rx_rd_en && dout[8] && of_fwd_port_res && !of_fwd_port_err) begin
      fwd_port <= of_fwd_port[3:0];
    end
  end
end

assign port0tx_din = port_din;
assign port1tx_din = port_din;
assign port2tx_din = port_din;
assign port3tx_din = port_din;

//-----------------------------------
// forwarding from port0 rx
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port0rx_rd_en <= 1'b0;
    port1tx_wr_en <= 1'b0;
  end else begin
    port0rx_rd_en <= ~port0rx_empty;
    port1tx_wr_en <= 1'b0;
    if (port0rx_rd_en == 1'b1) begin
      port1tx_din   <= port0rx_dout[8:0];
      port1tx_wr_en <= 1'b1;
    end
  end
end

//-----------------------------------
// forwarding from port1 rx
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port1rx_rd_en <= 1'b0;
    port0tx_wr_en <= 1'b0;
  end else begin
    port1rx_rd_en <= ~port1rx_empty;
    port0tx_wr_en <= 1'b0;
    if (port1rx_rd_en == 1'b1) begin
      port0tx_din   <= port1rx_dout[8:0];
      port0tx_wr_en <= 1'b1;
    end
  end
end

endmodule

