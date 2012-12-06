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
  , output reg [ 3:0]  fwd_port
  //
  , input      [ 3:0]  cmd_fwd_port
  // bonding test
  , input              cmd_mode
);

always @(posedge sys_clk) begin
  if (sys_rst) begin
    ack      <= 1'b0;
    fwd_port <= 4'b0;
  end else begin
    if (req == 1'b1) begin
      ack <= 1'b1;
      if (cmd_mode == 1'b1) begin
        // bonding test
        case (tuple[95:48])
          48'h000000_000003: fwd_port <= 4'b0001; // SERVER1
          48'h001e4f_498191: fwd_port <= 4'b0010; // SERVER2
          48'h0023df_85302a: fwd_port <= 4'b0100; // PC1
          48'h406c8f_39ba77: fwd_port <= 4'b1000; // PC2
          default:           fwd_port <= 4'b0000;
//          48'hffffff_ffffff: fwd_port <= BROADCAST;
        endcase
      end else begin
        fwd_port <= cmd_fwd_port[3:0];
      end
    end else begin
      ack <= 1'b0;
    end
  end
end

endmodule

