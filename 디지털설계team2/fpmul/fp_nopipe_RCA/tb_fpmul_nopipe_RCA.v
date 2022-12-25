`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:28:42 12/12/2022
// Design Name:   fpmul
// Module Name:   C:/Xilinx/14.7/booth_multiplier/tb_fpmul.v
// Project Name:  booth_multiplier
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fpmul
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_fpmul;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg CLK;
	reg RST;
	
	reg [15:0] c;
	// Outputs
	wire [15:0] out;
	wire overflow, sub;
	wire cover, check;
	
	assign cover = (c[14:10] == 5'b11111) ? 1 : 0;
	assign check = ((out[15:0] == c[15:0]) || (out[15:0] == (c[15:0] + 1)) || (overflow==1 && cover==1)) ? 1 : 0;
	// Instantiate the Unit Under Test (UUT)
	fpmul uut (
		.a(a), 
		.b(b), 
		.out(out), 
		.overflow(overflow),
		.sub(sub),
		.CLK(CLK), 
		.RST(RST)
	);

	initial begin
		// Initialize Inputs
		a = 16'h5285;
b = 16'h9f1a;
#20
a = 16'hf197;
b = 16'h92ce;
#20
a = 16'h5494;
b = 16'hc858;
#20
a = 16'h7a25;
b = 16'hc593;
#20
a = 16'h648c;
b = 16'h21db;
#20
a = 16'h37df;
b = 16'h53cf;
#20
a = 16'hea1e;
b = 16'hb187;
#20
a = 16'h5840;
b = 16'hc623;
#20
a = 16'hc220;
b = 16'h4bc9;
#20
a = 16'hef04;
b = 16'h32dd;
#20
a = 16'h2da5;
b = 16'h9f8e;
#20
a = 16'hc52;
b = 16'h396b;
#20
a = 16'hf02f;
b = 16'h40cd;
#20
a = 16'hef67;
b = 16'h8c6;
#20
a = 16'h88c8;
b = 16'h1c04;
#20
a = 16'h31c6;
b = 16'hab02;
#20
a = 16'h88a;
b = 16'h7a2a;
#20
a = 16'h548a;
b = 16'ha126;
#20
a = 16'ha8bf;
b = 16'hf282;
#20
a = 16'h4d73;
b = 16'haf82;
#20
a = 16'h18ea;
b = 16'hee5f;
#20
a = 16'hd8ba;
b = 16'h499e;
#20
a = 16'h9b5c;
b = 16'h1a86;
#20
a = 16'h437b;
b = 16'hdcf8;
#20
a = 16'h9fe;
b = 16'h7444;
#20
a = 16'hdfaf;
b = 16'h531b;
#20
a = 16'hc235;
b = 16'hacb;
#20
a = 16'hdcf7;
b = 16'h6b94;
#20
a = 16'h1a85;
b = 16'hd710;
#20
a = 16'hdb6b;
b = 16'h169b;
#20
a = 16'he4bb;
b = 16'h6af4;
#20
a = 16'h99b6;
b = 16'hcdd7;
#20
a = 16'h16d6;
b = 16'h1be0;
#20
a = 16'h39a8;
b = 16'h269f;
#20
a = 16'h6ad4;
b = 16'h9362;
#20
a = 16'h92de;
b = 16'hfa95;
#20
a = 16'hd75f;
b = 16'hd1f3;
#20
a = 16'hf6b0;
b = 16'ha949;
#20
a = 16'hf85c;
b = 16'h6513;
#20
a = 16'hfc64;
b = 16'h6cd5;
#20
a = 16'h53d7;
b = 16'he289;
#20
a = 16'h374d;
b = 16'h16df;
#20
a = 16'h417f;
b = 16'h74f8;
#20
a = 16'h7435;
b = 16'hd3fe;
#20
a = 16'h526b;
b = 16'hc923;
#20
a = 16'hc538;
b = 16'h3221;
#20
a = 16'h148a;
b = 16'h7c43;
#20
a = 16'h888d;
b = 16'he18d;
#20
a = 16'h98c9;
b = 16'h7235;
#20
a = 16'h85ba;
b = 16'h6524;

			end
	initial begin
	#290
	c = 16'hb5c9;
#20
c = 16'h48c1;
#20
c = 16'he0f8;
#20
c = 16'hfc00;
#20
c = 16'h4aa7;
#20
c = 16'h4fae;
#20
c = 16'h6039;
#20
c = 16'he285;
#20
c = 16'hd1f5;
#20
c = 16'he604;
#20
c = 16'h9154;
#20
c = 16'h9da;
#20
c = 16'hf505;
#20
c = 16'hbc6a;
#20
c = 16'h8009;
#20
c = 16'ha10e;
#20
c = 16'h46fe;
#20
c = 16'hb9d7;
#20
c = 16'h5fb8;
#20
c = 16'hc11d;
#20
c = 16'hcbd3;
#20
c = 16'he6a3;
#20
c = 16'h80c0;
#20
c = 16'he4a5;
#20
c = 16'h4263;
#20
c = 16'hf6d3;
#20
c = 16'h9145;
#20
c = 16'hfc00;
#20
c = 16'hb5c1;
#20
c = 16'hb61f;
#20
c = 16'hfc00;
#20
c = 16'h2c2b;
#20
c = 16'h6b;
#20
c = 16'h24ae;
#20
c = 16'hc24d;
#20
c = 16'h51a6;
#20
c = 16'h6d7b;
#20
c = 16'h646b;
#20
c = 16'hfc00;
#20
c = 16'h7fff;
#20
c = 16'hfa67;
#20
c = 16'h1245;
#20
c = 16'h7ad3;
#20
c = 16'hfc00;
#20
c = 16'he01e;
#20
c = 16'hbbff;
#20
c = 16'h7fff;
#20
c = 16'h2e50;
#20
c = 16'hcf6c;
#20
c = 16'haf5c;
	end
	
	initial begin
		CLK = 0;
		RST = 1;
		forever #10 CLK = ~CLK;
	end
      
endmodule