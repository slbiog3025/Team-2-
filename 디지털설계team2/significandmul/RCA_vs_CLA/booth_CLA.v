`timescale 1ns / 1ps

module booth_multiplier(a,b, azero, bzero, CLK,RST,s 
    );
	 input [9:0] a;
	 input [9:0] b;
	 input azero, bzero;
	 input CLK, RST;
	 output reg [23:0] s;
	 
	 wire [23:0] aa[6:0];
	 wire [23:0] as[6:0];
	 
	 wire [24:0] partials[6:0];
	 
	 EE a1 (a, b, azero, bzero,CLK, RST, aa[0], as[0], partials[0]);
	 
	 genvar i;
	 generate 	 
		for(i=0; i<6; i=i+1) begin: genblk1
			MM u1 (aa[i], as[i], partials[i], partials[i+1], aa[i+1], as[i+1], CLK, RST);
		end
	endgenerate
	 
		 always@(posedge CLK, negedge RST) begin
		 if(!RST) begin
				s <= 0;
		 end else begin
				s <= (partials[6][24:1]);
		 end
		 end
	endmodule

module MM (aa, as, ap, out, aao, aso, CLK, RST);
		 input [23:0] aa;
		 input [23:0] as;
		 input [24:0] ap;
		 input CLK, RST;
		 
		 reg [24:0] ppp;
		 wire [2:0] CC = ap[2:0];
		 wire [24:0] pp;
		 
		 output reg [24:0] out;
		 output reg [23:0] aao;
		 output reg [23:0] aso;
		 
		 reg [23:0] aa1;
	 
		 reg [23:0] as1;
		 

	
		 always@(*) begin
		 case(CC)
			3'b001:   ppp = {1'b0,aa[23:0]};
			3'b010:   ppp = {1'b0,aa[23:0]};
			3'b011:   ppp = {1'b0,aa[22:0],1'b0};
			3'b100:   ppp = {1'b1,as[22:0],1'b0};
			3'b101:   ppp = {1'b1,as[23:0]};
			3'b110:   ppp = {1'b1,as[23:0]};
			default : ppp = 0;
		 endcase
		 end
		
		 CLA_25bit a1 (.a({ap[24],ap[24:1]}), .b(ppp), .ci(1'b0), .Sum(pp), .Cout());
		 
		 always@(posedge CLK, negedge RST) begin
		 if(!RST) begin
				out <= 0;
				aao <= 0;
				aso <= 0;
				
				
		 end else begin
				out[24] <= pp[24];
				out[23:0] <= pp[24:1];
				
				aao <= aa;
				aso <= as;
				
		 end
		 end
		 
endmodule



module EE (a, b, azero, bzero, CLK, RST,  aa, as, ap);
		 input [9:0] a;
    	 input [9:0] b;
		 input azero, bzero;
		 input CLK, RST;
		 
		 wire [23:0] aaa; 
		 wire [23:0] aas;
		 wire [24:0] aap;
		 
		 assign aaa[23] = 1'b0;
		 assign aaa[22] = azero;
		 assign aaa[21:12] = a[9:0];
		 assign aaa[11: 0] = 12'b0;
		 
		 assign aas[23:12] = (~{1'b0,azero,a[9:0]}+1);
		 assign aas[11: 0] = 12'b0;
		 
    	 assign aap[24:12] = 12'b0;
		 assign aap[11] = bzero;
		 assign aap[10: 1] = b[9:0];
		 assign aap[0] = 0;
		 
		 output reg [23:0] aa;
		 output reg [23:0] as;
		 output reg [24:0] ap;

		 
		 always@(posedge CLK, negedge RST) begin
				if(!RST) begin
							aa <= 0;
							as <= 0;
							ap <= 0;
				end
		 else begin
							aa <= aaa;
							as <= aas;
							ap <= aap;
				end
		 end
		 
endmodule

module CLA_25bit(a, b, ci, Sum, Cout);

	input [24:0] a;
	input [24:0] b;
	input ci;
	output [24:0] Sum;
	output Cout;
	

	wire [24:0] G;
	wire [24:0] P;
	wire [5:0] GG;
	wire [5:0] PP;
	wire [24:0] C;
	wire [24:0] S;
	
	
	assign G[24:0] = a & b;
	assign P[24:0] = a ^ b;
	
	GGPP4 u1 (G[3:0], P[3:0], GG[0], PP[0]);
	GGPP4 u2 (G[7:4], P[7:4], GG[1], PP[1]);
	GGPP4 u3 (G[11:8], P[11:8], GG[2], PP[2]);
	GGPP4 u4 (G[15:12], P[15:12], GG[3], PP[3]);
	GGPP4 u5 (G[19:16], P[19:16], GG[4], PP[4]);
	GGPP4 u6 (G[23:20], P[23:20], GG[5], PP[5]);
	
	Cgenerate1 a1(GG[0], PP[0], ci, C[3]);
	Cgenerate1 a2(GG[1], PP[1], C[3], C[7]);
	Cgenerate1 a3(GG[2], PP[2], C[7], C[11]);
	Cgenerate1 a4(GG[3], PP[3], C[11], C[15]);
	Cgenerate1 a5(GG[4], PP[4], C[15], C[19]);
	Cgenerate1 a6(GG[5], PP[5], C[19], C[23]);
	
				Cgenerate1 a12(G[0], P[0], ci, C[0]);
				Cgenerate1 a13(G[1], P[1], C[0], C[1]);
				Cgenerate1 a14(G[2], P[2], C[1], C[2]);
	genvar q;
	generate
		for(q=1; q<=5; q=q+1) begin: genblk1
			   Cgenerate1 a9 (G[4*q], P[4*q], C[4*q-1], C[4*q]);
				Cgenerate1 a10 (G[4*q+1], P[4*q+1], C[4*q], C[4*q+1]);
				Cgenerate1 a11 (G[4*q+2], P[4*q+2], C[4*q+1], C[4*q+2]);
	   end
	endgenerate
				Cgenerate1 a15(G[24], P[24], C[23], C[24]);
	
	
	assign S[0] = P[0] ^ ci;
	genvar w;
	generate
		for(w=1; w<=24; w=w+1) begin: genblk2
					Sumgenerate1 c1(P[w], C[w-1], S[w]);
	   end
	endgenerate
	
	assign Cout = C[24];
	assign Sum = S;

endmodule


module Cgenerate1(G, P, Cin, Cout);
	input G;
	input P;
	input Cin;
	output Cout;
	assign Cout = G | P&Cin;
endmodule

module Sumgenerate1(P, Cin, Sum);
	input P;
	input Cin;
	output Sum;
	assign Sum = P^Cin;
endmodule


module GGPP4 (G, P, GG, PP);
	input [3:0] G;
	input [3:0] P;
	output PP;
	output GG;

	assign PP= P[3] & P[2] &P[1] & P[0];
	assign GG = G [3] |
		    (P[3] & G[2]) |
		    (P[3] & P[2] & G[1]) |
		    (P[3] & P[2] & P[1] & G[0]);
endmodule