`define SIMULATION
module tb_router();

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

wire req;
wire [31:0] search_ip;
wire ack;
wire [31:0] dest_ip;
wire [47:0] src_mac, dest_mac;
wire [3:0] forward_port;

lookupfib # (
	.MaxPort(4'h1)
) lookupfib_tb (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	.int_0_mac_addr(48'h00a0de1c07e2),
	.int_1_mac_addr(48'h00a0de1c07e8),
	.int_2_mac_addr(),
	.int_3_mac_addr(),

	.req(req),
	.search_ip(search_ip),

	.ack(ack),
	.dest_ip(dest_ip),
	.src_mac(src_mac),
	.dest_mac(dest_mac),
	.forward_port(forward_port)
);

reg [8:0] dout;
reg empty;
wire rd_en;
wire [8:0] port0_din, port1_din, port2_din, port3_din, nic_din;
reg port0_full, port1_full, port2_full, port3_full, nic_full;
reg port0_half, port1_half, port2_half, port3_half, nic_half;
wire port0_wr_en, port1_wr_en, port2_wr_en, port3_wr_en, nic_wr_en;

router # (
	.Port(2'h0),
	.MaxPort(2'h1)
) router_tb (
	.sys_rst(sys_rst),
	.sys_clk(sys_clk),

	.int_ipv4addr({8'd10,8'd0,8'd21,8'd1}),

	.dout(dout),
	.empty(empty),
	.rd_en(rd_en),

	.port0_din(port0_din),
	.port0_full(port0_full),
	.port0_half(port0_half),
	.port0_wr_en(port0_wr_en),

	.port1_din(port1_din),
	.port1_full(port1_full),
	.port1_half(port1_half),
	.port1_wr_en(port1_wr_en),

	.port2_din(port2_din),
	.port2_full(port2_full),
	.port2_half(port2_half),
	.port2_wr_en(port2_wr_en),

	.port3_din(port3_din),
	.port3_full(port3_full),
	.port3_half(port3_half),
	.port3_wr_en(port3_wr_en),

	.nic_din(nic_din),
	.nic_full(nic_full),
	.nic_half(nic_half),
	.nic_wr_en(nic_wr_en),

	.req(req),
	.search_ip(search_ip),
	.ack(ack),
	.dest_ip(dest_ip),
	.src_mac(src_mac),
	.dest_mac(dest_mac),
	.forward_port(forward_port)
);

task waitclock;
begin
	@(posedge sys_clk);
	#1;
end
endtask

always @(posedge sys_clk) begin
	if (rd_en == 1'b1)
		$display("empty: %x dout: %x", empty, dout);
end

reg [11:0] counter;
reg [8:0] rom [0:511];

always #1
	{empty,dout} <= rom[ counter ];

always @(posedge phy_tx_clk) begin
	if (rd_en == 1'b1)
		counter <= counter + 1;
end

initial begin
        $dumpfile("./test.vcd");
	$dumpvars(0, tb_router);
	$readmemh("./phy_test.hex", rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;
	counter = 0;

	waitclock;
	waitclock;

	sys_rst = 1'b0;

	waitclock;


	#10000;

	$finish;
end

endmodule
