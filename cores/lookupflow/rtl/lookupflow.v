module lookupflow #(
    parameter NPORT     = 4'h4
  , parameter PORT_NUM  = 4'h0
  , parameter BROADCAST = ~(4'b1 << PORT_NUM)
) (
    input              sys_rst
  , input              sys_clk
  , input              req
  // recieve tuple from system
  , input      [95:0]  tuple
  , output reg         ack
  // lookup
  , output reg [3:0]   fwd_port
);

always @(posedge sys_clk) begin
  if (sys_rst) begin
  end else begin
    if (req == 1'b1) begin
      case (tuple[95:48])
        48'h000000_000000: fwd_port <= 4'b0001;
        48'h000000_000001: fwd_port <= 4'b0010;
        48'h000000_000002: fwd_port <= 4'b0100;
        48'h000000_000003: fwd_port <= 4'b1000;
        48'hffffff_ffffff: fwd_port <= BROADCAST;
      endcase
      ack <= 1'b1;
    end else begin
      ack <= 1'b0;
    end
  end
end

endmodule

