module lookupfib # (
	parameter MaxPort = 4'h3
) (
	input         sys_rst,
	input         sys_clk,
	input [47:0]  int_0_mac_addr,
	input [47:0]  int_1_mac_addr,
	input [47:0]  int_2_mac_addr,
	input [47:0]  int_3_mac_addr,
	input         ipv6,
	input         req,
	input [127:0]  search_ip,
	output reg    ack,
	output reg [127:0] dest_ip,
	output reg [47:0] src_mac,
	output reg [47:0] dest_mac,
	output reg [MaxPort:0] forward_port,

	// SRAM interface
	output reg    rd_req,
	output reg [19:0] rd_addr,
	input  [35:0] rd_data,
	input         rd_ack,
	input         rd_vld
);


//-----------------------------------
// logic
//-----------------------------------
`ifndef NO
function [1:0] fib2;
input [3:0] addr;
case (addr)
	4'h0: fib2 = rd_data[ 1: 0];
	4'h1: fib2 = rd_data[ 3: 2];
	4'h2: fib2 = rd_data[ 5: 4];
	4'h3: fib2 = rd_data[ 7: 6];
	4'h4: fib2 = rd_data[10: 9];
	4'h5: fib2 = rd_data[12:11];
	4'h6: fib2 = rd_data[14:13];
	4'h7: fib2 = rd_data[16:15];
	4'h8: fib2 = rd_data[19:18];
	4'h9: fib2 = rd_data[21:20];
	4'ha: fib2 = rd_data[23:22];
	4'hb: fib2 = rd_data[25:24];
	4'hc: fib2 = rd_data[28:27];
	4'hd: fib2 = rd_data[30:29];
	4'he: fib2 = rd_data[32:31];
	4'hf: fib2 = rd_data[34:33];
endcase
endfunction


always @(posedge sys_clk) begin
	if (sys_rst) begin
		dest_mac <= 48'h000000_000000;
		src_mac  <= 48'h000000_000000;
		forward_port <= 4'b0000;
	end else begin
		ack <= 1'b0;
		if (req == 1'b1) begin
			dest_ip <= search_ip;
			rd_addr <= search_ip[31:12];
			rd_req  <= req;
		end
		if (rd_ack == 1'b1) begin
			rd_req  <= 1'b0;
			case (fib2(dest_ip[11:8]))
				2'h0: begin
					dest_mac <= 48'h000000_000000;
					src_mac <= 48'h000000_000000;
					forward_port <= 4'b0000;
				end
				2'h1: begin
					dest_mac <= 48'h003776_000101;
					src_mac <= int_1_mac_addr;
					forward_port <= 4'b0010;
					ack <= 1'b1;
				end
				2'h2: begin
					dest_mac <= 48'h003776_000102;
					src_mac <= int_2_mac_addr;
					forward_port <= 4'b0100;
					ack <= 1'b1;
				end
				2'h3: begin
					dest_mac <= 48'h003776_000103;
					src_mac <= int_3_mac_addr;
					forward_port <= 4'b1000;
					ack <= 1'b1;
				end
			endcase
		end
	end
end
`else
reg req1, req2, req3, req4;
reg [31:0] search_ip1, search_ip2, search_ip3, search_ip4;
always @(posedge sys_clk) begin
	if (sys_rst) begin
		dest_mac <= 48'h000000_000000;
		src_mac <= 48'h000000_000000;
		forward_port <= 4'b0000;
		ack <= 1'b0;
		req1 <= 1'b0;
		req2 <= 1'b0;
		req3 <= 1'b0;
		req4 <= 1'b0;
		search_ip1 <= 32'h00000000;
		search_ip2 <= 32'h00000000;
		search_ip3 <= 32'h00000000;
		search_ip4 <= 32'h00000000;
	end else begin
		ack <= 1'b0;
		req1 <= req;
		req2 <= req1;
		req3 <= req2;
		req4 <= req3;
		search_ip1 <= search_ip;
		search_ip2 <= search_ip1;
		search_ip3 <= search_ip2;
		search_ip4 <= search_ip3;
		if (req4 == 1'b1) begin
			ack <= 1'b1;
			dest_ip <= search_ip4;
			casex (search_ip4)
				{8'd10,8'd0,8'd20,8'd10}: begin
					dest_mac <= 48'h00022a_dd1d94;
					src_mac <= int_0_mac_addr;
					forward_port <= 4'b0001;
				end
				{8'd10,8'd0,8'd20,8'd105}: begin
					dest_mac <= 48'h003776_000100;
					src_mac <= int_0_mac_addr;
					forward_port <= 4'b0001;
				end
`ifdef NO
				32'h0a_00_14_xx: begin
					dest_mac <= 48'hffffff_ffffff;
					src_mac <= int_0_mac_addr;
					forward_port <= 4'b0001;
				end
`endif
				{8'd10,8'd0,8'd21,8'd105}: begin
					dest_mac <= 48'h003776_000101;
					src_mac <= int_1_mac_addr;
					forward_port <= 4'b0010;
				end
`ifndef NO
				32'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
					dest_mac <= 48'h003776_000103;
					src_mac <= int_1_mac_addr;
					forward_port <= 4'b0010;
				end
				32'b10xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
					dest_mac <= 48'h003776_000103;
					src_mac <= int_2_mac_addr;
					forward_port <= 4'b0100;
				end
				32'b11xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
					dest_mac <= 48'h003776_000103;
					src_mac <= int_3_mac_addr;
					forward_port <= 4'b1000;
				end
`endif
				default: begin
					dest_mac <= 48'h000000_000000;
					src_mac <= 48'h000000_000000;
					forward_port <= 4'b0000;
				end
			endcase
		end
	end
end
`endif

endmodule
