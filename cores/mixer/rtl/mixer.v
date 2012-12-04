module mixer (
    input         sys_rst
  , input         sys_clk
    // in FIFO
  , input [8:0]   port0_dout
  , input         port0_empty
  , output reg    port0_rd_en
  , input [8:0]   port1_dout
  , input         port1_empty
  , output reg    port1_rd_en
  , input [8:0]   port2_dout
  , input         port2_empty
  , output reg    port2_rd_en
  , input [8:0]   port3_dout
  , input         port3_empty
  , output reg    port3_rd_en
  , input [8:0]   arp_dout
  , input         arp_empty
  , output reg    arp_rd_en
  , input [8:0]   nic_dout
  , input         nic_empty
  , output reg    nic_rd_en
    // out FIFO
  , output reg [8:0] din
  , input         full
  , output reg    wr_en
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
    .DATA_WIDTH(9)
  , .ADDR_WIDTH(12)
) tx0_mixq (
    .clk(sys_clk)
  , .rst(sys_rst)

  , .din(txmixq_din)
  , .full(txmixq_full)
  , .wr_cs(txmixq_wr_en)
  , .wr_en(txmixq_wr_en)

  , .dout(txmixq_dout)
  , .empty(txmixq_empty)
  , .rd_cs(txmixq_rd_en)
  , .rd_en(txmixq_rd_en)

  , .data_count(txmixq_data_count)
);
`else
sfifo9_12 tx0_mixq (
    .clk(sys_clk)
  , .rst(sys_rst)

  , .din(txmixq_din)
  , .full(txmixq_full)
  , .wr_en(txmixq_wr_en)

  , .dout(txmixq_dout)
  , .empty(txmixq_empty)
  , .rd_en(txmixq_rd_en)

  , .data_count(txmixq_data_count)
);
`endif

wire txmixq_half = txmixq_data_count[11];

reg [2:0] mixer_state;
parameter [2:0] STATE_IDLE  = 3'h0
              , STATE_PORT0 = 3'h1
              , STATE_PORT1 = 3'h2
              , STATE_PORT2 = 3'h3
              , STATE_PORT3 = 3'h4
              , STATE_ARP   = 3'h5
              , STATE_NIC   = 3'h6;

//-----------------------------------
// Check multi pot FIFOs
//-----------------------------------
always @(posedge sys_clk) begin
  if (sys_rst) begin
    mixer_state <= STATE_IDLE;
    port0_rd_en <= 1'b0;
    port1_rd_en <= 1'b0;
    port2_rd_en <= 1'b0;
    port3_rd_en <= 1'b0;
    arp_rd_en <= 1'b0;
    nic_rd_en <= 1'b0;
    txmixq_wr_en <= 1'b0;
  end else begin
    port0_rd_en <= 1'b0;
    port1_rd_en <= 1'b0;
    port2_rd_en <= 1'b0;
    port3_rd_en <= 1'b0;
    arp_rd_en <= 1'b0;
    nic_rd_en <= 1'b0;
    txmixq_wr_en <= 1'b0;
    case (mixer_state)
      STATE_IDLE: begin
        if (port0_empty == 1'b0) begin
          port0_rd_en <= 1'b1;
          mixer_state <= STATE_PORT0;
        end else if (port1_empty == 1'b0) begin
          port1_rd_en <= 1'b1;
          mixer_state <= STATE_PORT1;
        end else if (port2_empty == 1'b0) begin
          port2_rd_en <= 1'b1;
          mixer_state <= STATE_PORT2;
        end else if (port3_empty == 1'b0) begin
          port3_rd_en <= 1'b1;
          mixer_state <= STATE_PORT3;
        end else if (arp_empty == 1'b0) begin
          arp_rd_en <= 1'b1;
          mixer_state <= STATE_ARP;
        end else if (nic_empty == 1'b0) begin
          nic_rd_en <= 1'b1;
          mixer_state <= STATE_NIC;
        end
      end
      STATE_PORT0: begin
        if (port0_rd_en == 1'b1) begin
          txmixq_din <= port0_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (port0_empty == 1'b0)
          port0_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
      STATE_PORT1: begin
        if (port1_rd_en == 1'b1) begin
          txmixq_din <= port1_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (port1_empty == 1'b0)
          port1_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
      STATE_PORT2: begin
        if (port2_rd_en == 1'b1) begin
          txmixq_din <= port2_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (port2_empty == 1'b0)
          port2_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
      STATE_PORT3: begin
        if (port3_rd_en == 1'b1) begin
          txmixq_din <= port3_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (port3_empty == 1'b0)
          port3_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
      STATE_ARP: begin
        if (arp_rd_en == 1'b1) begin
          txmixq_din <= arp_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (arp_empty == 1'b0)
          arp_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
      STATE_NIC: begin
        if (nic_rd_en == 1'b1) begin
          txmixq_din <= nic_dout[8:0];
          txmixq_wr_en <= 1'b1;
        end
        if (nic_empty == 1'b0)
          nic_rd_en <= 1'b1;
        else
          mixer_state <= STATE_IDLE;
      end
    endcase
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
