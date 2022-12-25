`timescale 1ns / 1ps

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
		
		 Carry_Ripple_Adder a1 (.a({ap[24],ap[24:1]}), .b(ppp), .ci(1'b0), .Sum(pp), .Cout());
		 
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

module Carry_Ripple_Adder(a, b, ci, Sum, Cout);
	
	input 		[25:1] 	a;
	input 		[25:1] 	b;
	input 			ci;
	output 	[25:1] 	Sum;
	output  		Cout;
	
	
	
	wire [25:0] G;
	wire [25:0] P;
	wire [25:0] GG;
	wire [25:1] S;
	
	assign G[0] = ci;
	assign P[0] = 0;
	assign G[25:1] = a & b;
	assign P[25:1] = a ^ b;

	
	assign GG[0] = G[0];
	G_Cell U0(G[0], G[1], P[1], GG[1]);
	
	genvar i;
	generate
		for(i=1; i<25; i=i+1) begin: loop_1
					G_Cell U1(GG[i], G[i+1], P[i+1], GG[i+1]);
		end
	endgenerate
	
	genvar j;
	generate
		for(j=1; j<=25; j=j+1) begin: loop_2
			assign S[j] = P[j] ^ GG[j-1];
		end
	endgenerate
	
	assign Cout = GG[25];
	assign Sum = S;
	
endmodule

module G_Cell(G0, G1, P1, GG);
	input G0;
	input G1;
	input P1;
	output GG;
	
	assign GG = G1 | (P1 & G0);
endmodule


