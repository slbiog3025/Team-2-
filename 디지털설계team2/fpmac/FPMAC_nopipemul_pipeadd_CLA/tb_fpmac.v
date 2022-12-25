`timescale 1ns / 1ps


module tb_fpmac;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg [15:0] c;
	reg CLK;
	reg RST;

	// Outputs
	wire [15:0] out;
	wire overflow, sub;
	// Instantiate the Unit Under Test (UUT)
	fpmac mac0 (.in(a), .weight(b), .acc(c), .out(out), .overflow(overflow), .sub(sub),  .CLK(CLK), .RST(RST));
	
	initial begin
		// Initialize Inputs
		a = 16'h5285;
b = 16'ha579;
c = 16'h6978;
#20
a = 16'hf197;
b = 16'h6821;
c = 16'h1ff ;
#20
a = 16'h5494;
b = 16'ha97e;
c = 16'h45a4;
#20
a = 16'h7a25;
b = 16'h6278;
c = 16'h4e2f;
#20
a = 16'h648c;
b = 16'he136;
c = 16'h5c42;
#20
a = 16'h37df;
b = 16'hc41c;
c = 16'h6fe0;
#20
a = 16'hea1e;
b = 16'h7bff;
c = 16'hfd53;
#20
a = 16'h5840;
b = 16'h33de;
c = 16'hf599;
#20
a = 16'hc220;
b = 16'h54d8;
c = 16'h78c7;
#20
a = 16'hef04;
b = 16'ha5f4;
c = 16'h6008;
#300
$finish;
end
	initial begin
	
	end
       
	initial begin
		CLK = 0;
		RST = 1;
		forever #10 CLK = ~CLK;
	end
      
endmodule

