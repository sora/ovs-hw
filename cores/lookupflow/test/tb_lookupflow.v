module tb_lookupflow();

/* 125MHz system clock */
reg sys_clk;
initial sys_clk = 1'b0;
always #8 sys_clk = ~sys_clk;

/* 33MHz PCI clock */
reg pci_clk;
initial pci_clk = 1'b0;
always #30 pci_clk = ~pci_clk;

/* 62.5MHz CPCI clock */
reg cpci_clk;
initial cpci_clk = 1'b0;
always #16 cpci_clk = ~cpci_clk;

/* 125MHz RX clock */
reg phy_rx_clk;
initial phy_rx_clk = 1'b0;
always #8 phy_rx_clk = ~phy_rx_clk;

/* 125MHz TX clock */
reg phy_tx_clk;
initial phy_tx_clk = 1'b0;
always #8 phy_tx_clk = ~phy_tx_clk;


reg sys_rst;
reg of_lookup_req;
reg [242:0] of_lookup_data;
wire of_lookup_ack;
wire of_lookup_err;
wire [3:0] of_lookup_fwd_port;
lookupflow # (
    .NPORT(4'h4)
) lookupflow_tb (
    .sys_clk(sys_clk)
  , .sys_rst(sys_rst)
  , .of_lookup_req(of_lookup_req)
  , .of_lookup_data(of_lookup_data)
  , .of_lookup_ack(of_lookup_ack)
  , .of_lookup_err(of_lookup_err)
  , .of_lookup_fwd_port(of_lookup_fwd_port)
);

task waitclock;
begin
  @(posedge sys_clk);
  #1;
end
endtask

/*
always @(posedge sys_clk) begin
  if (of_lookup_ack)
    $display("dest_ip:%d.%d.%d.%d  src_mac:%x  dest_mac:%x  forward_port:%b",  dest_ip[31:24], dest_ip[23:16], dest_ip[15:8], dest_ip[7:0], src_mac, dest_mac, forward_port);
end
*/

initial begin
  $dumpfile("./test.vcd");
  $dumpvars(0, tb_lookupflow); 
  /* Reset / Initialize our logic */
  sys_rst = 1'b1;

  waitclock;
  waitclock;

  sys_rst = 1'b0;

  waitclock;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd1,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd2,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd3,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd4,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd5,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  of_lookup_req = 1'b1;
  of_lookup_data = { 4'h0, 48'h0, 48'h0, 16'h0, 12'h0, 3'h0, 32'h0,
                     8'd10, 8'd0, 8'd0, 8'd6,
                     8'h0, 8'h0, 16'h0, 16'h0 };
  waitclock;
  of_lookup_req = 1'b0;
  of_lookup_data = 243'h0;
  waitclock;
  waitclock;
  waitclock;

  waitclock;
  waitclock;
  waitclock;

  #300;

  $finish;
end

endmodule

