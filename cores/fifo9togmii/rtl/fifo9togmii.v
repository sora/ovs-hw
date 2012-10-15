//`define ADD_SFD

module fifo9togmii (
	// FIFO
	input         sys_rst,
	input [8:0]   dout,
	input         empty,
	output        rd_en,
	output        rd_clk,
	// GMII
	input         gmii_tx_clk,
	output        gmii_tx_en,
	output [7:0]  gmii_txd
);

assign rd_clk = gmii_tx_clk;

//-----------------------------------
// CRC generator
//-----------------------------------
wire crc_init;
wire [31:0] crc_out;
reg crc_rd;
reg [7:0] txd;
assign crc_data_en = ~crc_rd;
crc_gen crc_inst (
	.Reset(sys_rst),
	.Clk(gmii_tx_clk),
	.Init(crc_init),
	.Frame_data(txd),
	.Data_en(crc_data_en),
	.CRC_rd(crc_rd),
	.CRC_end(),
	.CRC_out(crc_out)
); 

`ifndef ADD_SFD
//-----------------------------------
// logic
//-----------------------------------
parameter STATE_IDLE = 2'h0;
parameter STATE_DATA = 2'h1;
parameter STATE_FCS  = 2'h2;

reg [1:0] state;
reg [12:0] count;
reg [1:0] fcs_count;
reg [7:0] txd1, txd2;
reg tx_en;

assign crc_init = (count == 12'd7);

always @(posedge gmii_tx_clk) begin
	if (sys_rst) begin
		state <= STATE_IDLE;
		txd <= 8'h0;
		tx_en <= 1'b0;
		count <= 12'h0;
		crc_rd <= 1'b0;
		fcs_count <= 2'h0;
	end else begin
		tx_en <= 1'b0;
		crc_rd <= 1'b0;
		case (state)
			STATE_IDLE: begin
				if (empty == 1'b0 && dout[8] == 1'b1) begin
					txd <= dout[ 7: 0];
					tx_en <= 1'b1;
					state <= STATE_DATA;
					count <= 12'h0;
				end 
			end
			STATE_DATA: begin
				count <= count + 12'h1;
				if (empty  == 1'b0) begin
					txd <= dout[ 7: 0];
					tx_en <= dout[8]; 
					if (dout[8] == 1'b0) begin
						crc_rd <= 1'b1;
						txd <= crc_out[31:24];	
						tx_en <= 1'b1;
						fcs_count <= 2'h0;
						state <= STATE_FCS;
					end
				end else
					state <= STATE_IDLE;
			end
			STATE_FCS: begin
				crc_rd <= 1'b1;
				fcs_count <= fcs_count + 2'h1;
				case (fcs_count)
					2'h0: txd <= crc_out[23:16];	
					2'h1: txd <= crc_out[15: 8];	
					2'h2: begin
					      txd <= crc_out[ 7: 0];	
					      state <= STATE_IDLE;
					end
				endcase
				tx_en <= 1'b1;
			end
		endcase
	end
end

assign rd_en = ~empty;
`else
//-----------------------------------
// logic
//-----------------------------------
parameter STATE_IDLE = 3'h0;
parameter STATE_PRE  = 3'h1;
parameter STATE_SFD  = 3'h2;
parameter STATE_DATA = 3'h3;
parameter STATE_FCS  = 3'h4;

reg [2:0] state;
reg [2:0] count;
reg [1:0] fcs_count;
reg [7:0] txd1, txd2;
reg tx_en;
reg crc_init_req;

assign crc_init = crc_init_req;

always @(posedge gmii_tx_clk) begin
	if (sys_rst) begin
		state <= STATE_IDLE;
		txd <= 8'h0;
		tx_en <= 1'b0;
		count <= 3'h0;
		crc_init_req <= 1'b0;
		crc_rd <= 1'b0;
		fcs_count <= 2'h0;
	end else begin
		tx_en <= 1'b0;
		crc_init_req <= 1'b0;
		crc_rd <= 1'b0;
		case (state)
			STATE_IDLE: begin
				if (empty == 1'b0 && dout[8] == 1'b1) begin
					txd <= 8'h55;
					tx_en <= 1'b1;
					txd1 <= dout;
					state <= STATE_PRE;
					count <= 3'h0;
				end 
			end
			STATE_PRE: begin
				tx_en <= 1'b1;
				count <= count + 3'h1;
				case (count)
					3'h0: begin
						txd <= 8'h55;	
						txd2 <= dout;
					end
					3'h6: begin
						txd <= 8'hd5;	
						crc_init_req <= 1'b1;
					end
					3'h7: begin
						txd <= txd1;	
						state <= STATE_SFD;
					end
					default: begin
						txd <= 8'h55;	
					end
				endcase
			end
			STATE_SFD: begin
				txd <= txd2;	
				tx_en <= 1'b1;
				state <= STATE_DATA;
			end
			STATE_DATA: begin
				if (empty  == 1'b0) begin
					txd <= dout[ 7: 0];
					tx_en <= dout[8]; 
					if (dout[8] == 1'b0) begin
						crc_rd <= 1'b1;
						txd <= crc_out[31:24];	
						tx_en <= 1'b1;
						fcs_count <= 2'h0;
						state <= STATE_FCS;
					end
				end else
					state <= STATE_IDLE;
			end
			STATE_FCS: begin
				crc_rd <= 1'b1;
				fcs_count <= fcs_count + 2'h1;
				case (fcs_count)
					2'h0: txd <= crc_out[23:16];	
					2'h1: txd <= crc_out[15: 8];	
					2'h2: begin
					      txd <= crc_out[ 7: 0];	
					      state <= STATE_IDLE;
					end
				endcase
				tx_en <= 1'b1;
			end
		endcase
	end
end

assign rd_en = ~empty && (state != STATE_PRE);
`endif

assign gmii_tx_en = tx_en;
assign gmii_txd   = txd;

endmodule
