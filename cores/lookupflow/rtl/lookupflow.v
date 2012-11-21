`define MAGIC_CODE    32'hC0C0C0CC

module lookupflow #(
    parameter NPORT    = 4'h4
  , parameter PORT_NUM = 4'h0
) (
    input              sys_rst
  , input              sys_clk
  // recieve flow data from RX-FIFO
  , input      [8:0]   rx_dout
  , input              rx_empty
  , output reg         rx_rd_en
  // lookup
  , output     [15:0]  of_lookup_fwd_port
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

// packet parser
reg [15:0] rx_tp_dst_port;
reg [15:0] rx_type;
reg [15:0] rx_ip_version;
reg [ 8:0] rx_ipv4_proto;
reg [31:0] rx_magic;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    rx_type        <= 16'h0;
    rx_ip_version  <= 16'h0;
    rx_ipv4_proto  <= 8'h0;
    rx_tp_dst_port <= 16'h0;
    rx_magic       <= 32'h0;
  end else begin
    if (rx_dout[8] == 1'b1 && rx_rd_en == 1'b1) begin
      case (counter)
        14'h0c: rx_type[15:8]        <= rx_dout[7:0];
        14'h0d: rx_type[ 7:0]        <= rx_dout[7:0];
        14'h0e: rx_ip_version[15:8]  <= rx_dout[7:0];
        14'h0f: rx_ip_version[ 7:0]  <= rx_dout[7:0];
        14'h17: rx_ipv4_proto[ 7:0]  <= rx_dout[7:0];
        11'h24: rx_tp_dst_port[15:8] <= rx_dout[7:0];
        11'h25: rx_tp_dst_port[ 7:0] <= rx_dout[7:0];
        11'h2a: rx_magic[31:24]      <= rx_dout[7:0];
        11'h2b: rx_magic[23:16]      <= rx_dout[7:0];
        11'h2c: rx_magic[15: 8]      <= rx_dout[7:0];
        11'h2d: rx_magic[ 7: 0]      <= rx_dout[7:0];
      endcase
    end
  end
end
//wire is_cmd_pkt = (rx_type[15:0]        == 16'h0800) & 
//                  (rx_tp_dst_port[15:0] == 16'd3776) &
//                  (rx_opcode[15:0]      == 16'd17  ) &
//                  (rx_magic[31:0]       == `MAGIC_CODE);

reg [7:0] p0out, p1out, p2out, p3out;
always @(posedge sys_clk) begin
  if (sys_rst) begin
    p0out <= 8'b0;
    p1out <= 8'b0;
    p2out <= 8'b0;
    p3out <= 8'b0;
  end else begin
    if (rx_dout[8] == 1'b1 && rx_rd_en == 1'b1) begin
//      if (rx_type[15:0]        == 16'h0800 && rx_ip_version[15:0] == 16'h4500 &&
//          rx_tp_dst_port[15:0] == 16'd3776 && rx_ipv4_proto[7:0]  == 8'h11    &&
//          rx_magic[31:0]       == `MAGIC_CODE) begin
        case (counter)
          11'h2e: p0out <= rx_dout[7:0];
          11'h2f: p1out <= rx_dout[7:0];
          11'h30: p2out <= rx_dout[7:0];
          11'h31: p3out <= rx_dout[7:0];
        endcase
//      end
    end
  end
end
assign of_lookup_fwd_port[15:0] = { p3out[3:0] | 4'b0111,
                                    p2out[3:0] | 4'b1000,
                                    p1out[3:0] | 4'b1000,
                                    p0out[3:0] | 4'b1000 };

/*
// lookup from flows
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_ack      <= 1'b0;
    of_lookup_err      <= 1'b0;
    of_lookup_fwd_port <= 4'b0;
  end else begin
    of_lookup_ack <= 1'b0;
    of_lookup_err <= 1'b0;
    if (of_lookup_req == 1'b1) begin
      case (PORT_NUM) // port0
        4'h0: begin
          of_lookup_ack      <= 1'b1;
          of_lookup_fwd_port[3:0] <= p0out[3:0];
        end
        4'h1: begin // port1
          of_lookup_ack           <= 1'b1;
          of_lookup_fwd_port[3:0] <= p1out[3:0];
        end
        4'h2: begin // port2
          of_lookup_ack           <= 1'b1;
          of_lookup_fwd_port[3:0] <= p2out[3:0];
        end
        4'h3: begin // port3
          of_lookup_ack           <= 1'b1;
          of_lookup_fwd_port[3:0] <= p3out[3:0];
        end
      endcase
    end
  end
end
*/

endmodule

