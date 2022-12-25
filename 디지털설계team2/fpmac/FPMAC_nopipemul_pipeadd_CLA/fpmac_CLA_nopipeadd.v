`timescale 1ns / 1ps

module fpmac(in, weight, acc, out, overflow, sub, CLK, RST);
	    input [15:0] in;
		 input [15:0] weight;
		 input [15:0] acc;
		 input CLK,RST;
		 output reg [15:0] out;
		 output reg overflow, sub;
		 
		 wire [15:0] addout;
		 wire [15:0] mulres; 
		 wire muloverflow, addoverflow;
		 wire mulsub, addsub;
		 reg [15:0] accreg[8:0];
		 
		 
		 fpmul a0 (
		.a(in), 
		.b(weight), 
		.out(mulres), 
		.overflow(muloverflow),
		.sub(mulsub),
		.CLK(CLK), 
		.RST(RST));
		
		fpadd a1 (
		.a(accreg[8]), 
		.b(mulres), 
		.out(addout), 
		.overflow(addoverflow),
		.sub(addsub),
		.CLK(CLK), 
		.RST(RST));
		
		
		
		always@(posedge CLK, negedge RST) begin
		if(!RST) begin
			accreg[0] <= 0;
			accreg[1] <= 0;
			accreg[2] <= 0;
			accreg[3] <= 0;
			accreg[4] <= 0;
			accreg[5] <= 0;
			accreg[6] <= 0;
			accreg[7] <= 0;
			accreg[8] <= 0;
			out <= 0;
		end else begin
			accreg[0] <= acc;
			accreg[1] <= accreg[0];
			accreg[2] <= accreg[1];
			accreg[3] <= accreg[2];
			accreg[4] <= accreg[3];
			accreg[5] <= accreg[4];
			accreg[6] <= accreg[5];
			accreg[7] <= accreg[6];
			accreg[8] <= accreg[7];
			out <= addout;
			overflow <= addoverflow;
			sub <= addsub;
		end
	end

endmodule



module fpmul(a,b,out,overflow,sub,CLK,RST
    );
	 input [15:0] a;
	 input [15:0] b;
	 input CLK, RST;
	 
	 output reg [15:0] out;
	 output reg overflow, sub;
	 
	 wire sign;
	 wire [5:0] exp;
	 wire signed  [6:0] exad;
	 wire [9:0] fra;
	 wire azero, bzero;
	 wire [23:0] win;
	 wire [23:0] subwin;
	 wire [5:0] fo;
	 wire [23:0] s;
	 wire signed [6:0] carry;
	 wire signed [6:0] exx;
	 
	 reg signed [6:0] ex[14:0];
	 wire signdelay[14:0];
	 
	 
	 assign sign = a[15] ^ b[15];
	 assign azero = (a[14:10] == 5'b00000) ? 0 : 1;
	 assign bzero = (b[14:10] == 5'b00000) ? 0 : 1;
	 assign exad = ((a[14:10] == 5'b11111) || (b[14:10] == 5'b11111))? (5'b11111) :((a[14:10] == 0) || (b[14:10] == 0)) ?
						(a[14:10] + b[14:10] -5'b01110) : (a[14:10] + b[14:10] -5'b01111);
	 booth_multiplier a1 (.a(a[9:0]),.b(b[9:0]), .azero(azero), .bzero(bzero), .CLK(CLK) , .RST(RST), .s(s));
	 
	 assign fo =    s[23] ? 23 : s[22] ? 22 : s[21] ? 21 :
						 s[20] ? 20 : s[19] ? 19 : s[18] ? 18 :
						 s[17] ? 17 : s[16] ? 16 : s[15] ? 15 :
						 s[14] ? 14 : s[13] ? 13 : s[12] ? 12 :
						 s[11] ? 11 : s[10] ? 10 : s[9] ? 9 :
						 s[8] ? 8 : s[7] ? 7 : s[6] ? 6 :
					    s[5] ? 5 : s[4] ? 4 : s[3] ? 3 :
				   	 s[2] ? 2 : s[1] ? 1 : 0;
	 assign carry = fo-20;
	 assign exx = ex[7] + carry;
	 assign exp = (0 >= exx) ? 5'b00000 : 
					  (exx >= 5'b11111) ? 5'b11111 : exx;
	 assign win = (carry>0) ? s >> carry : s << -(carry);
	 assign subwin = win >> -(exx); 
	 
	 assign fra = (exp == 5'b11111) ? 10'b1111111111:
					  (exp == 5'b00000) ? (subwin[20:11] + ((subwin[10]&&subwin[9])||(subwin[10]&&(subwin[8:0]!=0)))) : 
												 (win[19:10] + ((win[9]&&win[8])||(win[9]&&(win[7:0]!=0))));
	 
	 delay_buffer d1 (sign, signdelay[0], CLK, RST);
	 delay_buffer d15 (signdelay[0], signdelay[1], CLK, RST);
	 delay_buffer d2 (signdelay[1], signdelay[2], CLK, RST);
	 delay_buffer d3 (signdelay[2], signdelay[3], CLK, RST);
	 delay_buffer d4 (signdelay[3], signdelay[4], CLK, RST);
	 delay_buffer d5 (signdelay[4], signdelay[5], CLK, RST);
	 delay_buffer d6(signdelay[5], signdelay[6], CLK, RST);
	 delay_buffer d7 (signdelay[6], signdelay[7], CLK, RST);
	 
	 
	 
	 always @(posedge CLK or negedge RST) begin
		if (!RST) begin
		out <= 0;
		overflow <=0;
		sub <= 0;
		ex[0] <= 0;
		ex[1] <= 0;
		ex[2] <= 0;
		ex[3] <= 0;
		ex[4] <= 0;
		ex[5] <= 0;
		ex[6] <= 0;
		ex[7] <= 0;
		
	end else begin
		out <= {signdelay[7],exp[4:0],fra[9:0]};
		overflow <= (exp == 5'b11111) ? 1 : 0;
		sub <= (exp == 5'b00000) ? 1 :0;	
		ex[0] <= exad;
		ex[1] <= ex[0];
		ex[2] <= ex[1];
		ex[3] <= ex[2];
		ex[4] <= ex[3];
		ex[5] <= ex[4];
		ex[6] <= ex[5];
		ex[7] <= ex[6];
	end
	end

endmodule


module delay_buffer (a, b, CLK, RST);
input a, CLK, RST;
wire a1, a2, a3, a4, a5, a6;

output reg b;

assign a1 = !a;
assign a2 = !a1;
assign a3 = !a2;
assign a4 = !a3;
assign a5 = !a4;
assign a6 = !a5;

always@(posedge CLK, negedge RST) begin
		if(!RST) begin
			b <= 0;
		end else begin
			b <= a6;
		end
	end
	

endmodule
		

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

module fpadd(a,b,out,overflow,sub,CLK,RST);
	 input [15:0] a;
	 input [15:0] b;
	 input CLK, RST;
	 
	 wire [13:0] shiftedA;
	 wire [13:0] shiftedB;
	 wire [13:0] shiftedAA;
	 wire [13:0] shiftedBB;
	 wire [13:0] signedA;
	 wire [13:0] signedB;
	 wire [13:0] Sum;
	 wire [9:0] fra1;
	 wire [9:0] fra2;
	 wire [4:0] exp;
	 wire [4:0] shift;
	 wire sign;
	 wire subt;
	 wire [3:0] sumshift; 
	 
	 output reg [15:0] out;
	 output reg overflow, sub;
	 
	 assign sign = ((a[15] == 1) && (b[15] ==1)) ? 1 :
						((a[15] == 0) && (b[15] ==0))	? 0 :
						(a[14:10] > b[14:10]) ? a[15] :
						(b[14:10] > a[14:10]) ? b[15] :
						(a[9:0] > b[9:0]) ? a[15] :
						(b[9:0] > a[9:0]) ? b[15] : 0;
	 assign subt = a[15] ^ b[15];
	 assign shift[4:0] = (a[14:10] > b[14:10]) ? (a[14:10] - (b[14:10]==5'b00000 ? 5'b00001 :b[14:10])) : 
								(b[14:10] - (a[14:10]==5'b00000 ? 5'b00001 :a[14:10]));
	 assign shiftedA[13:12] = (a[14:10] == 5'b0) ? 2'b00 : 2'b01;
	 assign shiftedB[13:12] = (b[14:10] == 5'b0) ? 2'b00 : 2'b01;
	 assign shiftedA[11:2] = a[9:0];
	 assign shiftedB[11:2] = b[9:0];
	 assign shiftedA[1:0] = 2'b00;
	 assign shiftedB[1:0] = 2'b00;
	 assign shiftedAA[13:0] = (a[14:10] < b[14:10]) ? (shiftedA >> shift) : shiftedA;
	 assign shiftedBB[13:0] = (a[14:10] > b[14:10]) ? (shiftedB >> shift) : shiftedB;
	 
	 assign Sum = subt ? ((shiftedAA > shiftedBB) ? (shiftedAA - shiftedBB) : (shiftedBB-shiftedAA)) : (shiftedAA+shiftedBB); 
	 
	 assign sumshift = Sum[13] ? 13 : 
							 Sum[12] ? 12 :
							 Sum[11] ? 11 :
							 Sum[10] ?  10 :
							 Sum[9] ? 9 :
							 Sum[8] ? 8 :
							 Sum[7] ? 7 :
							 Sum[6] ? 6 :
							 Sum[5] ? 5 :
							 Sum[4] ? 4 :
							 Sum[3] ? 3 :
							 Sum[2] ? 2 :
							 Sum[1] ? 1 : 0;
	 
	 assign fra1[9:0] = sumshift == 13 ? (Sum[12:3] + (Sum[2]&&Sum[1])) : 
							 sumshift == 12 ? (Sum[11:2] + (Sum[1]&&Sum[0])) :
							 sumshift == 11 ? (Sum[10:1] + Sum[0]) :
							 sumshift == 10 ?  Sum[9:0] :
							 sumshift == 9 ? {Sum[8:0],1'b0} :
							 sumshift == 8 ? {Sum[7:0],2'b00} :
							 sumshift == 7 ? {Sum[6:0],3'b000} :
							 sumshift == 6 ? {Sum[5:0],4'b0000} :
							 sumshift == 5 ? {Sum[4:0],5'b00000} :
							 sumshift == 4 ? {Sum[3:0],6'b000000} :
							 sumshift == 3 ? {Sum[2:0],7'b0000000} :
							 sumshift == 2 ? {Sum[1:0],8'b00000000} :
							 sumshift == 1 ? {Sum[0],  9'b000000000} : 10'b0000000000;
							 
	 assign exp = (a[14:10] >= b[14:10]) ? (((a[14:10] + sumshift -12) > 5'b00000)? (a[14:10] + sumshift -12) : 5'b00000): 
						(((b[14:10] + sumshift -12) > 5'b00000)? (b[14:10] + sumshift -12) : 5'b00000);
						
						
	 assign fra2[9:0] = (a[14:10] >= b[14:10]) ? (((a[14:10] + sumshift -12) < 5'b00000)? 
	                    (fra1 >> (12-sumshift -a[14:10])): fra1) : (((b[14:10] + sumshift -12) < 5'b00000)? 
	                    (fra1 >> (12-sumshift -b[14:10])): fra1);
	 
	 
	 always @(posedge CLK or negedge RST) begin
		if (!RST) begin
		out <= 0;
		sub <= 0;
		overflow <=0;
	end else begin
		out <= ((a[14:10] == 5'b11111) || (b[14:10] == 5'b11111)) ? 16'b1111110000000000 :(exp == 5'b11111) ? 16'b1111110000000000 : {sign,exp[4:0],fra2[9:0]};
		overflow <= ((a[14:10] == 5'b11111) || (b[14:10] == 5'b11111)) ? 1 :(exp == 5'b11111) ? 1 : 0;
		sub <= ((a[14:10] == 5'b11111) || (b[14:10] == 5'b11111)) ? 0 :(exp == 5'b11111) ? 0 :(exp == 5'b00000) ? 1 :0;	 
	end
	end


endmodule



		
