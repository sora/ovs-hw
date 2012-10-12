`default_nettype none

module filter (
    input           sys_clk
  , input           sys_rst
// PHY0
  , output          rd0_en
  , input  [8:0]    rd0_data
  , input           rd0_empty
  , output reg      wr0_en
  , output reg[8:0] wr0_data
  , input           wr0_full
// PHY1
  , output          rd1_en
  , input  [8:0]    rd1_data
  , input           rd1_empty
  , output reg      wr1_en
  , output reg[8:0] wr1_data
  , input           wr1_full
);

reg      port0_en;
reg[8:0] port0_data;
reg      port1_en;
reg[8:0] port1_data;

/* PHY0->PHY1 */
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port0_en   <= 1'b0;
    port0_data <= 9'b0;
  end else begin
    if (rd0_empty)
      port0_en <= 1'b0;
    else
      port0_en <= 1'b1;
    if (port0_en && rd0_data[8])
      port0_data <= rd0_data;
    else
      port0_data <= 9'b0;
  end
end
assign rd0_en = port0_en & ~rd0_empty;
always @* begin
  if (port0_en) begin
    wr1_en   <= 1'b1;
    wr1_data <= port0_data;
  end else begin
    wr1_en   <= 1'b0;
    wr1_data <= 9'b0;
  end
end


/* PHY1->PHY0 */
always @(posedge sys_clk) begin
  if (sys_rst) begin
    port1_en   <= 1'b0;
    port1_data <= 9'b0;
  end else begin
    if (rd1_empty)
      port1_en <= 1'b0;
    else
      port1_en <= 1'b1;
    if (port1_en && rd1_data[8])
      port1_data <= rd1_data;
    else
      port1_data <= 9'b0;
  end
end
assign rd1_en = port1_en & ~rd1_empty;
always @* begin
  if (port1_en) begin
    wr0_en   <= 1'b1;
    wr0_data <= port1_data;
  end else begin
    wr0_en   <= 1'b0;
    wr0_data <= 9'b0;
  end
end

endmodule

`default_nettype wire

