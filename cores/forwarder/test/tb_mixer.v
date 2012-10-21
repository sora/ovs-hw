`define SIMULATION
module tb_mixer();

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

reg [8:0] port0_dout, port1_dout, port2_dout, port3_dout, nic_dout;
reg port0_empty, port1_empty, port2_empty, port3_empty, nic_empty;
wire port0_rd_en, port1_rd_en, port2_rd_en, port3_rd_en, nic_rd_en;
wire [8:0] din;
reg full;
wire wr_en;

mixer # (
	.Port(2'h0),
	.MaxPort(2'h1)
) mixer_tb (
	.sys_rst(sys_rst),
	.sys_clk(sys_clk),

	.port0_dout(port0_dout),
	.port0_empty(port0_empty),
	.port0_rd_en(port0_rd_en),

	.port1_dout(port1_dout),
	.port1_empty(port1_empty),
	.port1_rd_en(port1_rd_en),

	.port2_dout(port2_dout),
	.port2_empty(port2_empty),
	.port2_rd_en(port2_rd_en),

	.port3_dout(port3_dout),
	.port3_empty(port3_empty),
	.port3_rd_en(port3_rd_en),

	.nic_dout(nic_dout),
	.nic_empty(nic_empty),
	.nic_rd_en(nic_rd_en),

	.din(din),
	.full(full),
	.wr_en(wr_en)
);

task waitclock;
begin
	@(posedge sys_clk);
	#1;
end
endtask

always @(posedge sys_clk) begin
	if (wr_en == 1'b1)
		$display("din: %x", din);
end

reg [11:0] counter;
reg [8:0] rom [0:511];

//always #1
//	{empty,dout} <= rom[ counter ];

always @(posedge sys_clk) begin
	if (wr_en == 1'b1)
		counter <= counter + 1;
end

initial begin
        $dumpfile("./test.vcd");
	$dumpvars(0, tb_mixer);
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
