`timescale 1ns / 1ps


module tb_fpmac;

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg [15:0] c;
	reg CLK;
	reg RST;
	reg [15:0] e;
	// Outputs
	wire [15:0] out;
	wire overflow, sub;
	wire eover, check;
	
	assign eover = (e[14:10] == 5'b11111) ? 1 : 0;
	assign check = ((out[15:0] == e[15:0]) || (out[15:0] == (e[15:0] + 1)) || (overflow==1 && eover==1)) ? 1 : 0;
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
#20
a = 16'h9f1a;
b = 16'hc27a;
c = 16'hcde9;
#20
a = 16'h92ce;
b = 16'h9d54;
c = 16'h2de ;
#20
a = 16'hc858;
b = 16'he5b9;
c = 16'h94a7;
#20
a = 16'hc593;
b = 16'hdb90;
c = 16'h6aea;
#20
a = 16'h21db;
b = 16'hd171;
c = 16'h4c43;
#20
a = 16'h53cf;
b = 16'hc032;
c = 16'he2bc;
#20
a = 16'hb187;
b = 16'h7827;
c = 16'h617d;
#20
a = 16'hc623;
b = 16'heee1;
c = 16'h58a7;
#20
a = 16'h4bc9;
b = 16'h9757;
c = 16'hbd51;
#20
a = 16'h32dd;
b = 16'hd318;
c = 16'h786f;
#20
a = 16'h2da5;
b = 16'hb8a0;
c = 16'h3cae;
#20
a = 16'hc52 ;
b = 16'hcb14;
c = 16'h1ddb;
#20
a = 16'hf02f;
b = 16'h4555;
c = 16'h1cd7;
#20
a = 16'hef67;
b = 16'h3257;
c = 16'ha705;
#20
a = 16'h88c8;
b = 16'hf4b4;
c = 16'h3a1 ;
#20
a = 16'h31c6;
b = 16'h3697;
c = 16'h77bf;
#20
a = 16'h88a ;
b = 16'h9216;
c = 16'h58f8;
#20
a = 16'h548a;
b = 16'h75a5;
c = 16'h9ace;
#20
a = 16'ha8bf;
b = 16'hc1a3;
c = 16'h99a2;
#20
a = 16'h4d73;
b = 16'h9eda;
c = 16'h8b1d;
#20
a = 16'h9f8e;
b = 16'h356a;
c = 16'ha809;
#20
a = 16'h396b;
b = 16'hb028;
c = 16'hde44;
#20
a = 16'h40cd;
b = 16'hacb ;
c = 16'hcc12;
#20
a = 16'h8c6 ;
b = 16'hd5a5;
c = 16'h9eb7;
#20
a = 16'h1c04;
b = 16'hd67 ;
c = 16'hf73d;
#20
a = 16'hab02;
b = 16'h92a ;
c = 16'h2274;
#20
a = 16'h7a2a;
b = 16'he005;
c = 16'hb396;
#20
a = 16'ha126;
b = 16'h828 ;
c = 16'hcebc;
#20
a = 16'hf282;
b = 16'h67fc;
c = 16'hbcb2;
#20
a = 16'haf82;
b = 16'h4a37;
c = 16'h4cba;
#20
a = 16'h18ea;
b = 16'h40f5;
c = 16'hd09 ;
#20
a = 16'hd8ba;
b = 16'h6a0c;
c = 16'hc7ed;
#20
a = 16'h9b5c;
b = 16'h6894;
c = 16'hbeb7;
#20
a = 16'h437b;
b = 16'h680d;
c = 16'ha965;
#20
a = 16'h9fe ;
b = 16'h93fd;
c = 16'h72c6;
#20
a = 16'hdfaf;
b = 16'h337e;
c = 16'h325a;
#20
a = 16'hc235;
b = 16'h3943;
c = 16'h2abf;
#20
a = 16'hdcf7;
b = 16'he488;
c = 16'h3fba;
#20
a = 16'h1a85;
b = 16'h73de;
c = 16'hfa38;
#20
a = 16'hdb6b;
b = 16'hb1df;
c = 16'h8cd3;
#20
a = 16'hee5f;
b = 16'h86c0;
c = 16'h45a8;
#20
a = 16'h499e;
b = 16'h8ddf;
c = 16'he520;
#20
a = 16'h1a86;
b = 16'h7da5;
c = 16'h8311;
#20
a = 16'hdcf8;
b = 16'h3427;
c = 16'h4448;
#20
a = 16'h7444;
b = 16'hcfde;
c = 16'h83bd;
#20
a = 16'h531b;
b = 16'hd6f6;
c = 16'h765b;
#20
a = 16'hacb ;
b = 16'h5bb6;
c = 16'hd3c8;
#20
a = 16'h6b94;
b = 16'ha2d1;
c = 16'ha254;
#20
a = 16'hd710;
b = 16'hbc75;
c = 16'hdeaa;
#20
a = 16'h169b;
b = 16'hccde;
c = 16'h1c27;

end
	initial begin
	#230
	e = 16'h6977;
#20
e = 16'hfc00;
#20
e = 16'h40ff;
#20
e = 16'h7c00;
#20
e = 16'hfc00;
#20
e = 16'h6fdf;
#20
e = 16'h7fff;
#20
e = 16'hf597;
#20
e = 16'h78c0;
#20
e = 16'h6156;
#20
e = 16'hcde8;
#20
e = 16'h326 ;
#20
e = 16'h7236;
#20
e = 16'h6cc6;
#20
e = 16'h4c23;
#20
e = 16'he3c2;
#20
e = 16'hed0c;
#20
e = 16'h794a;
#20
e = 16'hbd6d;
#20
e = 16'h786f;
#20
e = 16'h3c7a;
#20
e = 16'h1811;
#20
e = 16'hf993;
#20
e = 16'he5dd;
#20
e = 16'h419f;
#20
e = 16'h77bf;
#20
e = 16'h58f8;
#20
e = 16'h7c00;
#20
e = 16'h2e83;
#20
e = 16'hb0ad;
#20
e = 16'ha85a;
#20
e = 16'hde44;
#20
e = 16'hcc12;
#20
e = 16'ha50b;
#20
e = 16'hf73d;
#20
e = 16'h2273;
#20
e = 16'hfc00;
#20
e = 16'hcebc;
#20
e = 16'hfc00;
#20
e = 16'h4c5d;
#20
e = 16'h1e66;
#20
e = 16'hfc00;
#20
e = 16'hc90c;
#20
e = 16'h6f93;
#20
e = 16'h72c6;
#20
e = 16'hd72f;
#20
e = 16'hbff5;
#20
e = 16'h7c00;
#20
e = 16'hfa36;
#20
e = 16'h5171;
#20
e = 16'h4654;
#20
e = 16'he520;
#20
e = 16'h7fff;
#20
e = 16'hd4e3;
#20
e = 16'hfc00;
#20
e = 16'h74cf;
#20
e = 16'hd3c6;
#20
e = 16'hd274;
#20
e = 16'hdcb2;
#20
e = 16'ha701;
#20
$finish;
end
       
	initial begin
		CLK = 0;
		RST = 1;
		forever #10 CLK = ~CLK;
	end
      
endmodule

