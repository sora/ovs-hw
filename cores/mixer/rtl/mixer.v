module mixer (
	input         sys_rst,
	input         sys_clk,
	// in FIFO
	input [8:0]   port0_dout,
	input         port0_empty,
	output reg    port0_rd_en,
	input [8:0]   port1_dout,
	input         port1_empty,
	output reg    port1_rd_en,
	input [8:0]   port2_dout,
	input         port2_empty,
	output reg    port2_rd_en,
	input [8:0]   port3_dout,
	input         port3_empty,
	output reg    port3_rd_en,
	input [8:0]   arp_dout,
	input         arp_empty,
	output reg    arp_rd_en,
	input [8:0]   nic_dout,
	input         nic_empty,
	output reg    nic_rd_en,
	// out FIFO
	output reg [8:0] din,
	input         full,
	output reg    wr_en
);

reg [8:0] txmixq_din;
reg txmixq_wr_en;
wire txmixq_full;
wire [8:0] txmixq_dout;
wire txmixq_empty;
reg txmixq_rd_en;
wire [11:0] txmixq_data_count;

//-----------------------------------
// TX_MIXERQ FIFO
//-----------------------------------
`ifdef SIMULATION
sfifo # (
	.DATA_WIDTH(9),
	.ADDR_WIDTH(12)
) tx0_mixq (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(txmixq_din),
	.full(txmixq_full),
	.wr_cs(txmixq_wr_en),
	.wr_en(txmixq_wr_en),

	.dout(txmixq_dout),
	.empty(txmixq_empty),
	.rd_cs(txmixq_rd_en),
	.rd_en(txmixq_rd_en),

	.data_count(txmixq_data_count)
);
`else
sfifo9_12 tx0_mixq (
	.clk(sys_clk),
	.rst(sys_rst),

	.din(txmixq_din),
	.full(txmixq_full),
	.wr_en(txmixq_wr_en),

	.dout(txmixq_dout),
	.empty(txmixq_empty),
	.rd_en(txmixq_rd_en),

	.data_count(txmixq_data_count)
);
`endif

wire txmixq_half = txmixq_data_count[11];

//-----------------------------------
// Check multi pot FIFOs
//-----------------------------------
always @(posedge sys_clk) begin
	if (sys_rst) begin
		port0_rd_en <= 1'b0;
		port1_rd_en <= 1'b0;
		port2_rd_en <= 1'b0;
		port3_rd_en <= 1'b0;
		arp_rd_en <= 1'b0;
		nic_rd_en <= 1'b0;
		txmixq_wr_en <= 1'b0;
	end else begin
		port0_rd_en <= ~port0_empty;
		port1_rd_en <= ~port1_empty;
		port2_rd_en <= ~port2_empty;
		port3_rd_en <= ~port3_empty;
		arp_rd_en   <= ~arp_empty;
		nic_rd_en   <= ~nic_empty;
		txmixq_wr_en <= 1'b0;
		if (port0_rd_en == 1'b1) begin
			txmixq_din <= port0_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end else if (port1_rd_en == 1'b1) begin
			txmixq_din <= port1_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end else if (port2_rd_en == 1'b1) begin
			txmixq_din <= port2_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end else if (port3_rd_en == 1'b1) begin
			txmixq_din <= port3_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end else if (arp_rd_en == 1'b1) begin
			txmixq_din <= arp_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end else if (nic_rd_en == 1'b1) begin
			txmixq_din <= nic_dout[8:0];
			txmixq_wr_en <= 1'b1;
		end
	end
end

//-----------------------------------
// Distribute to multi port FIFO
//-----------------------------------
always @(posedge sys_clk) begin
	if (sys_rst) begin
       		txmixq_rd_en <= 1'b0;
		wr_en <= 1'b0;
	end else begin
		txmixq_rd_en <= ~txmixq_empty;
		wr_en <= 1'b0;
		if (txmixq_rd_en == 1'b1) begin
			din <= txmixq_dout[8:0];
			wr_en <= 1'b1;
		end
	end
end

endmodule
