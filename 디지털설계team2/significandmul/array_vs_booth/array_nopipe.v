`timescale 1ns / 1ps

module array_mul(a, b,azero, bzero, s, CLK, RST);

	input [9:0] a,b;
	input CLK, RST;
	input azero, bzero;
	output reg [23:0] s;
	wire [11:0] aa, bb;
	
	assign aa = {1'b0,azero,a};
	assign bb = {1'b0,bzero,b};

	wire [23:0] partials[11:0];

	genvar i;
	assign partials[0] = aa[0] ? {{12{0}},bb} : 0;

	generate 	
		for(i=1; i<12; i=i+1) begin: genblk1
			assign partials[i] = (aa[i] ? {{12{0}},bb}<<i : 0)+partials[i-1];
		end
	endgenerate
	
	always @(posedge CLK or negedge RST) begin
		if (!RST) begin
		s <= 0;
	end else begin
		s <= partials[11];
			 
	end
	end

endmodule