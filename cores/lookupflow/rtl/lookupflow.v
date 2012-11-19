module lookupflow #(
    parameter NPORT    = 4'h4
  , parameter PORT_NUM = 4'h0
) (
    input                  sys_rst
  , input                  sys_clk
  , input                  of_lookup_req
  , input      [115:0]     of_lookup_data
  , output reg             of_lookup_ack
  , output reg             of_lookup_err
  , output reg [3:0]       of_lookup_fwd_port
);

//wire match = ( of_lookup_data[115:112] == 4'h0 &&
//               of_lookup_data[111: 64] == { 8'h40, 8'h6c, 8'h8f, 8'h37, 8'hf1, 8'hf8 } &&
//               of_lookup_data[ 63: 32] == { 8'd10, 8'd0, 8'd0, 8'd200 } );
wire match = 1'b1;
wire [3:0] fwd_ports = ~PORT_NUM;

function [3:0] ip2port;
  input [31:0] dstip;
  case (dstip)
    32'h0A000001: ip2port = 4'h1; // dst ip = 10.0.0.1
    32'h0A000002: ip2port = 4'h2; // dst ip = 10.0.0.2
    32'h0A000003: ip2port = 4'h3; // dst ip = 10.0.0.3
    32'h0A000004: ip2port = 4'h4; // dst ip = 10.0.0.4
    32'h0A000005: ip2port = 4'h5; // dst ip = 10.0.0.5
    default:      ip2port = 4'h0; // no match
  endcase
endfunction

// demo: 4(ingressport) + 48(srcmac) +  32(dstip) + 32(srcip) = 116
always @(posedge sys_clk) begin
  if (sys_rst) begin
    of_lookup_ack      <= 1'b0;
    of_lookup_err      <= 1'b0;
    of_lookup_fwd_port <= 4'b0;
  end else begin
    of_lookup_ack <= 1'b0;
    of_lookup_err <= 1'b0;
    if (of_lookup_req && match) begin
      case (ip2port(of_lookup_data[31:0]))
        /*
        4'h0: begin
          of_lookup_fwd_port <= 4'b0000;
          of_lookup_ack      <= 1'b1;
          of_lookup_err      <= 1'b1;
        end
        4'h1: begin
          of_lookup_fwd_port <= 4'b0001;
          of_lookup_ack      <= 1'b1;
        end
        4'h2: begin
          of_lookup_fwd_port <= 4'b0010;
          of_lookup_ack      <= 1'b1;
        end
        4'h3: begin
          of_lookup_fwd_port <= 4'b0100;
          of_lookup_ack      <= 1'b1;
        end
        4'h4: begin
          of_lookup_fwd_port <= 4'b1000;
          of_lookup_ack      <= 1'b1;
        end
        4'h5: begin
          of_lookup_fwd_port <= 4'b1111;
          of_lookup_ack      <= 1'b1;
        end
        default: begin
          of_lookup_fwd_port <= 4'b0000;
        end
        */
        default: begin
          of_lookup_fwd_port <= ~PORT_NUM;
          of_lookup_ack      <= 1'b1;
        end
      endcase
    end
  end
end

endmodule

