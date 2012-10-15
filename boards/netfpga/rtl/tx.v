`default_nettype none

module tx (
    input        sys_rst
  , input        wr_clk
  , input        wr_en
  , input  [8:0] wr_data
  , input        phy_gtx_clk
  , output       phy_tx_en
  , output [7:0] phy_txd
);

reg[12:0] count = 13'b0;

/* --------------------------------------- */
/* MAC layer: send frame state */
parameter PREAM = 8'h55;   // preamble (8'b0101_0101)
parameter SFD   = 8'hd5;   // Start Frame Delimiter (8'b1101_0101)

parameter[1:0]
    SEND_IDLE = 2'b00
  , PREAMBLE  = 2'b01
  , SEND_DATA = 2'b10
  , SEND_FCS  = 2'b11;
/* send FIFO */
reg[1:0]  state     = 2'b0;
wire[8:0] fifo_dout;
wire      fifo_empty;
wire      fifo_full;
wire      rd_en = ~fifo_empty && (state != PREAMBLE);
`ifdef SIMULATION
//`ifdef ECP3VERSA
asfifo9_12 txq (
    .wr_clk(wr_clk)
  , .wr_en(wr_en)
  , .din(wr_data)
  , .rd_clk(phy_gtx_clk)
  , .rd_en(rd_en)
  , .rst(sys_rst)
  , .dout(fifo_dout)
  , .empty(fifo_empty)
  , .full(fifo_full)
);
//`endif
`else
asfifo # (
    .DATA_WIDTH(9)
  , .ADDRESS_WIDTH(4)
) txq (
    .din(wr_data)
  , .full(fifo_full)
  , .wr_en(wr_en)
  , .wr_clk(wr_clk)
  , .dout(fifo_dout)
  , .empty(fifo_empty)
  , .rd_en(rd_en)
  , .rd_clk(phy_gtx_clk)
  , .rst(sys_rst)
);
`endif


reg[1:0]  fcs_count = 2'b0;
reg       tx_en     = 1'b0;
reg[7:0]  txd       = 8'h0;
//reg[7:0]  txd_tmp1  = 8'h0;
//reg[7:0]  txd_tmp2  = 8'h0;

/* --------------------------------------- */
/* generate frame's CRC (FCS) */
reg        crc_init;
reg        crc_rd;
wire[31:0] crc_out;
wire       crc_data_en = ~crc_rd;
crc_gen crc_inst (
    .Reset(sys_rst)
  , .Clk(wr_clk)
  , .Init(crc_init)
  , .Frame_data(txd)
  , .Data_en(crc_data_en)
  , .CRC_rd(crc_rd)
  , .CRC_end()
  , .CRC_out(crc_out)
);

/* --------------------------------------- */
/* tx */
always @(posedge phy_gtx_clk) begin
  if (sys_rst) begin
    state     <= SEND_IDLE;
    crc_init  <= 1'b0;
    crc_rd    <= 1'b0;
    count     <= 13'b0;
    tx_en     <= 1'b0;
    txd       <= 8'b0;
    fcs_count <= 2'b0;
  end else begin
    case (state)
      SEND_IDLE: begin
        if (!fifo_empty && fifo_dout[8]) begin
          state <= PREAMBLE;
          txd   <= PREAM;
          tx_en <= 1'b1;
          count <= 13'b0;
        end else begin
          tx_en <= 1'b0;
          txd   <= 8'b0;
        end
      end
      PREAMBLE: begin   // drop preamble data
        tx_en <= 1'b1;
        count <= count + 13'b1;
        case (count)
          13'h6: begin
            txd      <= SFD;
            crc_init <= 1'b1;
            state    <= SEND_DATA;
          end
          default: txd <= PREAM;
        endcase
      end
      SEND_DATA: begin
        if (!fifo_empty) begin
          if (fifo_dout[8]) begin
            tx_en <= fifo_dout[8];
            txd   <= fifo_dout[7:0];
          end else begin
            crc_rd    <= 1'b1;
//            txd       <= crc_out[31:24];
            tx_en     <= 8'b0;
            txd       <= 8'b0;
            fcs_count <= 2'b0;
//            state     <= SEND_FCS;
            state     <= SEND_IDLE;
          end
        end else begin
          state <= SEND_IDLE;
          tx_en <= 8'b0;
          txd   <= 8'b0;
        end
      end
      SEND_FCS: begin
        tx_en     <= 1'b1;
        crc_rd    <= 1'b1;
        fcs_count <= fcs_count + 2'b1;
        case (fcs_count)
          2'h0: txd <= crc_out[23:16];
          2'h1: txd <= crc_out[15:8];
          2'h2: begin
            txd   <= crc_out[7:0];
            state <= SEND_IDLE;
          end
        endcase
      end
    endcase
  end
end

assign phy_txd   = txd;
assign phy_tx_en = tx_en;

endmodule

`default_nettype wire

