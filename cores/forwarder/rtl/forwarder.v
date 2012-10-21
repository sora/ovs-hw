module forwarder (
	input         sys_rst,
	input         sys_clk,
	// in FIFO
	input [8:0]   port0rx_dout,
	input         port0rx_empty,
	output reg    port0rx_rd_en,
	input [8:0]   port1rx_dout,
	input         port1rx_empty,
	output reg    port1rx_rd_en,
	// out FIFO
	output reg [8:0] port0tx_din,
	input         port0tx_full,
	output reg    port0tx_wr_en,
	output reg [8:0] port1tx_din,
	input         port1tx_full,
	output reg    port1tx_wr_en
);

//-----------------------------------
// forwarding from port0 rx
//-----------------------------------
always @(posedge sys_clk) begin
	if (sys_rst) begin
       		port0rx_rd_en <= 1'b0;
		port1tx_wr_en <= 1'b0;
	end else begin
		port0rx_rd_en <= ~port0rx_empty;
		port1tx_wr_en <= 1'b0;
		if (port0rx_rd_en == 1'b1) begin
			port1tx_din <= port0rx_dout[8:0];
			port1tx_wr_en <= 1'b1;
		end
	end
end

//-----------------------------------
// forwarding from port1 rx
//-----------------------------------
always @(posedge sys_clk) begin
	if (sys_rst) begin
       		port1rx_rd_en <= 1'b0;
		port0tx_wr_en <= 1'b0;
	end else begin
		port1rx_rd_en <= ~port1rx_empty;
		port0tx_wr_en <= 1'b0;
		if (port1rx_rd_en == 1'b1) begin
			port0tx_din <= port1rx_dout[8:0];
			port0tx_wr_en <= 1'b1;
		end
	end
end

endmodule
