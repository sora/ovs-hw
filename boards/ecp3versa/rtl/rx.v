`default_nettype none

module rx (
    input        sys_rst
  , input        phy_rx_clk
  , input        phy_rx_dv
  , input  [7:0] phy_rxd
  , input        rd_clk
  , input        rd_en
  , output [8:0] rd_data
  , output       rd_empty
);

reg      wr_en;
wire     wr_full;
reg[8:0] wr_data;

/* --------------------------------------- */
/* generate frame's CRC */
reg        crc_init;
wire[31:0] crc_out;
wire       crc_data_en = ~crc_rd;
reg        crc_rd;
crc_gen crc_inst (
    .Reset(sys_rst)
  , .Clk(phy_rx_clk)
  , .Init(crc_init)
  , .Frame_data(wr_data[7:0])
  , .Data_en(crc_data_en)
  , .CRC_rd(crc_rd)
  , .CRC_end()
  , .CRC_out(crc_out)
);

/* --------------------------------------- */
/* MAC layer recieve state */
parameter SFD = 8'hd5;   // Start Frame Delimiter

parameter[1:0]
    RECV_IDLE = 2'b00
  , SFD_WAIT  = 2'b01
  , RECV_DATA = 2'b10;

reg[1:0] state = 2'b0;

always @(posedge phy_rx_clk) begin
  if (sys_rst) begin
    state    <= RECV_IDLE;
    wr_en    <= 1'b0;
    wr_data  <= 9'b0;
    crc_init <= 1'b0;
    crc_rd   <= 1'b0;
  end else begin
    case (state)
      RECV_IDLE: begin
        if (phy_rx_dv) begin
          state <= SFD_WAIT;
          wr_en <= 1'b0;
        end
      end
      SFD_WAIT: begin   // drop preamble data
        if (phy_rx_dv) begin
          wr_en <= 1'b0;
          if (phy_rxd == SFD) begin
            state    <= RECV_DATA;
            crc_init <= 1'b1;
          end
        end else begin
          state <= RECV_IDLE;
        end
      end
      RECV_DATA: begin
        if (phy_rx_dv) begin
          wr_en   <= 1'b1;
          wr_data <= { 1'b1, phy_rxd };
        end else begin
          state   <= RECV_IDLE;
          wr_en   <= 1'b0;
          wr_data <= 9'b0;
        end
      end
      default: state <= RECV_IDLE;
    endcase
  end
end

/* --------------------------------------- */
/* recieve FIFO */
`ifndef SIMULATION
//`ifdef ECP3VERSA
asfifo9 rxq (
    .WrClock(phy_rx_clk)
  , .WrEn(wr_en)
  , .Data(wr_data)
  , .RdClock(rd_clk)
  , .RdEn(rd_en)
  , .Reset(sys_rst)
  , .RPReset()
  , .Q(rd_data)
  , .Empty(rd_empty)
  , .Full(wr_full)
);
//`endif
`else
asfifo # (
    .DATA_WIDTH(9)
  , .ADDRESS_WIDTH(10)
) rxq (
    .din(wr_data)
  , .full(wr_full)
  , .wr_en(wr_en)
  , .wr_clk(phy_rx_clk)
  , .dout(rd_data)
  , .empty(rd_empty)
  , .rd_en(rd_en)
  , .rd_clk(rd_clk)
  , .rst(sys_rst)
);
`endif

endmodule

`default_nettype wire
