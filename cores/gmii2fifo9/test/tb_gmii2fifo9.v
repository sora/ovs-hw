module tb_gmii2fifo9();

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
reg phy_rx_dv;
reg [7:0] phy_rxd;
wire [8:0] din;
reg full;
wire wr_en;
wire wr_clk;

gmii2fifo9 # (
        .Gap(4'h2)
) gmii2fifo9_tb (
        .sys_rst(sys_rst),

        .gmii_rx_clk(phy_rx_clk),
        .gmii_rx_dv(phy_rx_dv),
        .gmii_rxd(phy_rxd),

        .din(din),
        .full(full),
        .wr_en(wr_en),
        .wr_clk(wr_clk)
);

task waitclock;
begin
	@(posedge sys_clk);
	#1;
end
endtask

always @(posedge wr_clk) begin
	if (wr_en == 1'b1)
		$display("din: %x", din);
end

reg [8:0] rom [0:199];
reg [11:0] counter;

always @(posedge phy_rx_clk) begin
	{phy_rx_dv,phy_rxd} <= rom[ counter ];
	counter <= counter + 1;
end

initial begin
        $dumpfile("./test.vcd");
	$dumpvars(0, tb_gmii2fifo9); 
	$readmemh("./phy_rx.hex", rom);
	/* Reset / Initialize our logic */
	sys_rst = 1'b1;
	full = 1'b0;
	counter = 0;

	waitclock;
	waitclock;

	sys_rst = 1'b0;

	waitclock;


	#30000;

	$finish;
end

endmodule
