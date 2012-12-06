module cmdrecv #(
    parameter MAGIC_CODE = 32'hC0C0C0CC
  , parameter NPORT      = 4'h4
  , parameter PORT_NUM   = 4'h3
)(
    input              sys_rst
  , input              sys_clk
  // recieve flow data from RX-FIFO
  , input      [ 8:0]  rx_dout
  , input              rx_empty
  , output reg         rx_rd_en
  // lookup
  , output     [15:0]  cmd_fwd_port
  // bonding test
  , output             cmd_mode
);

// rx_rd_en
always @(posedge sys_clk) begin
  if (sys_rst)
    rx_rd_en <= 1'b0;
  else
    rx_rd_en <= ~rx_empty;
end

// global counter
reg [10:0] counter;
always @(posedge sys_clk) begin
  if (sys_rst)
    counter <= 11'b0;
  else begin
    if (rx_rd_en == 1'b1) begin
      counter <= counter + 11'b1;
      if (rx_dout[8] == 1'b1)
        counter <= counter + 11'b1;
      else
        counter <= 11'b0;
    end
  end
end

// checking command packet header
reg [15:0] eth_type;
reg [15:0] tp_dst_port;
reg [15:0] ip_version;
reg [ 8:0] ipv4_proto;
reg [31:0] rx_magic;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    eth_type    <= 16'h0;
    ip_version  <= 16'h0;
    ipv4_proto  <= 8'h0;
    tp_dst_port <= 16'h0;
    rx_magic    <= 32'h0;
  end else begin
    if (rx_dout[8] == 1'b1 && rx_rd_en == 1'b1) begin
      case (counter)
        11'h0c: eth_type[15:8]    <= rx_dout[7:0];
        11'h0d: eth_type[ 7:0]    <= rx_dout[7:0];
        11'h0e: ip_version[15:8]  <= rx_dout[7:0];
        11'h0f: ip_version[ 7:0]  <= rx_dout[7:0];
        11'h17: ipv4_proto[ 7:0]  <= rx_dout[7:0];
        11'h24: tp_dst_port[15:8] <= rx_dout[7:0];
        11'h25: tp_dst_port[ 7:0] <= rx_dout[7:0];
        11'h2a: rx_magic[31:24]   <= rx_dout[7:0];
        11'h2b: rx_magic[23:16]   <= rx_dout[7:0];
        11'h2c: rx_magic[15: 8]   <= rx_dout[7:0];
        11'h2d: rx_magic[ 7: 0]   <= rx_dout[7:0];
      endcase
    end
  end
end

// payload parser
reg [7:0] p0out, p1out, p2out, p3out;
reg [7:0] mode;                         // bonding test
always @(posedge sys_clk) begin
  if (sys_rst) begin
    p0out <= 8'b0;
    p1out <= 8'b0;
    p2out <= 8'b0;
    p3out <= 8'b0;
  end else begin
    if (rx_dout[8] == 1'b1 && rx_rd_en == 1'b1) begin
      // if the packet is command packet
      if (eth_type[15:0]    == 16'h0800 && ip_version[15:0] == 16'h4500 &&
          tp_dst_port[15:0] == 16'd3776 && ipv4_proto[7:0]  == 8'h11    &&
          rx_magic[31:0]    == MAGIC_CODE) begin
        case (counter)
          11'h2e: p0out <= rx_dout[7:0];
          11'h2f: p1out <= rx_dout[7:0];
          11'h30: p2out <= rx_dout[7:0];
          11'h31: p3out <= rx_dout[7:0];
          11'h32: mode  <= rx_dout[7:0];
        endcase
      end
    end
  end
end
//assign cmd_fwd_port[15:0] = { p3out[3:0], p2out[3:0], p1out[3:0], p0out[3:0] };
// port3 is used for cmd port
assign cmd_fwd_port[15:0] = { p3out[3:0] | 4'b0111,
                              p2out[3:0] | 4'b1000,
                              p1out[3:0] | 4'b0000,
                              p0out[3:0] | 4'b0000 };

assign cmd_mode = mode[0];      // bonding test

endmodule

