`define DROP_SFD

module gmii2fifo9 # (
    parameter Gap = 4'h2
) (
    input         sys_rst
  , input         gmii_rx_clk
  , input         gmii_rx_dv
  , input  [7:0]  gmii_rxd
    // FIFO
  , output [8:0]  din
  , input         full
  , output reg    wr_en
  , output        wr_clk
);

assign wr_clk = gmii_rx_clk;

parameter STATE_IDLE = 1'b0;
parameter STATE_DATA = 1'b1;

//-----------------------------------
// logic
//-----------------------------------
`ifndef DROP_SFD
reg [7:0] rxd       = 8'h0;
reg       rxc       = 1'b0;
reg [3:0] gap_count = 4'h0;
always @(posedge gmii_rx_clk) begin
  if (sys_rst) begin
    gap_count <= 4'h0;
    wr_en     <= 1'b0;
  end else begin
    wr_en <= 1'b0;
    if (gmii_rx_dv == 1'b1) begin
      gap_count <= Gap;
      rxd[7:0]  <= gmii_rxd[7:0];
      rxc       <= 1'b1;
      wr_en     <= 1'b1;
    end else begin
      if (gap_count != 4'h0) begin
        rxd[7:0]  <= 8'h0;
        rxc       <= 1'b0;
        wr_en     <= 1'b1;
        gap_count <= gap_count - 4'h1;
      end
    end
  end
end
`else
reg [7:0] rxd       = 8'h0;
reg       rxc       = 1'b0;
reg [3:0] gap_count = 4'h0;
reg [1:0] state;
always @(posedge gmii_rx_clk) begin
  if (sys_rst) begin
    state     <= STATE_IDLE;
    gap_count <= 4'h0;
    wr_en     <= 1'b0;
  end else begin
    wr_en <= 1'b0;
    if (gmii_rx_dv == 1'b1) begin
      case (state)
        STATE_IDLE: begin
          if (gmii_rxd[7:0] == 8'hd5)
            state <= STATE_DATA;
        end
        STATE_DATA: begin
          gap_count <= Gap;
          rxd[7:0]  <= gmii_rxd[7:0];
          rxc       <= 1'b1;
          wr_en     <= 1'b1;
        end
      endcase
    end else begin
      state <= STATE_IDLE;
      if (gap_count != 4'h0) begin
        rxd[7:0]  <= 8'h0;
        rxc       <= 1'b0;
        wr_en     <= 1'b1;
        gap_count <= gap_count - 4'h1;
      end
    end
  end
end
`endif
assign din[8:0] = {rxc, rxd[7:0]};

endmodule

