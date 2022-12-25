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
		.a(accreg[1]), 
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
			out <= 0;
		end else begin
			accreg[0] <= acc;
			accreg[1] <= accreg[0];
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
	 
	 reg signed [6:0] ex;
	 wire signdelay;
	 
	 
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
	 assign exx = ex + carry;
	 assign exp = (0 >= exx) ? 5'b00000 : 
					  (exx >= 5'b11111) ? 5'b11111 : exx;
	 assign win = (carry>0) ? s >> carry : s << -(carry);
	 assign subwin = win >> -(exx); 
	 
	 assign fra = (exp == 5'b11111) ? 10'b1111111111:
					  (exp == 5'b00000) ? (subwin[20:11] + ((subwin[10]&&subwin[9])||(subwin[10]&&(subwin[8:0]!=0)))) : 
												 (win[19:10] + ((win[9]&&win[8])||(win[9]&&(win[7:0]!=0))));
	 
	 delay_buffer d1 (sign, signdelay, CLK, RST);
	 
	 
	 
	 always @(posedge CLK or negedge RST) begin
		if (!RST) begin
		out <= 0;
		overflow <=0;
		sub <= 0;
		ex <= 0;
		
	end else begin
		out <= {signdelay,exp[4:0],fra[9:0]};
		overflow <= (exp == 5'b11111) ? 1 : 0;
		sub <= (exp == 5'b00000) ? 1 :0;	
		ex <= exad;
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
	 
	 wire [23:0] aa;
	 wire [23:0] as;
	 
	 wire [24:0] partials[6:0];
	 
	 EE a1 (a, b, azero, bzero, aa, as, partials[0]);
	 
	 genvar i;
	 generate 	 
		for(i=0; i<6; i=i+1) begin: genblk1
			MM u1 (aa, as, partials[i], partials[i+1]);
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

module MM (aa, as, ap, out);
		 input [23:0] aa;
		 input [23:0] as;
		 input [24:0] ap;
		 
		 wire [24:0] ppp;
		 wire [2:0] CC = ap[2:0];
		 wire [24:0] pp;
		 
		 output [24:0] out;
		 
		 
		 assign ppp = (CC == 3'b001) ? {1'b0,aa[23:0]} :
					  (CC == 3'b010) ? {1'b0,aa[23:0]} :
					  (CC == 3'b011) ? {1'b0,aa[22:0],1'b0} :
					  (CC == 3'b100) ? {1'b1,as[22:0],1'b0} :
					  (CC == 3'b101) ? {1'b1,as[23:0]} :
					  (CC == 3'b110) ? {1'b1,as[23:0]} : 0;

		
		 assign pp = {ap[24],ap[24:1]} + ppp;

		 
		assign out[24:0] = {pp[24],pp[24:1]};		
		 
endmodule

module EE (a, b, azero, bzero, aa, as, ap);
		 input [9:0] a;
    	 input [9:0] b;
		 input azero, bzero;
		 
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
		 
		 output  [23:0] aa;
		 output  [23:0] as;
		 output  [24:0] ap;

		 
		 assign aa = aaa;
		 assign as = aas;
		 assign ap = aap;
		 
		 
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
	 
	 reg [13:0] aareg;
	 reg [13:0] bbreg;
	 reg [4:0] exa, exb;
	 reg subt2;
	 reg sign2;
	 
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
	 
	 assign Sum = subt2 ? ((aareg > bbreg) ? (aareg - bbreg) : (bbreg-aareg)) : (aareg+bbreg); 
	 
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
							 
	 assign exp = (exa >= exb) ? (((exa + sumshift -12) > 5'b00000)? (exa + sumshift -12) : 5'b00000): 
						(((exb + sumshift -12) > 5'b00000)? (exb + sumshift -12) : 5'b00000);
						
						
	 assign fra2[9:0] = (exa >= exb) ? (((exa + sumshift -12) < 5'b00000)? 
	                    (fra1 >> (12-sumshift -exa)): fra1) : (((exb + sumshift -12) < 5'b00000)? 
	                    (fra1 >> (12-sumshift -exb)): fra1);
	 
	 
	 always @(posedge CLK or negedge RST) begin
		if (!RST) begin
		out <= 0;
		sub <= 0;
		overflow <=0;
	end else begin
		out <= ((exa == 5'b11111) || (exb == 5'b11111)) ? 16'b1111110000000000 :(exp == 5'b11111) ? 16'b1111110000000000 : {sign2,exp[4:0],fra2[9:0]};
		overflow <= ((exa == 5'b11111) || (exb == 5'b11111)) ? 1 :(exp == 5'b11111) ? 1 : 0;
		sub <= ((exa == 5'b11111) || (exb == 5'b11111)) ? 0 :(exp == 5'b11111) ? 0 :(exp == 5'b00000) ? 1 :0;	 
		subt2 <= subt;
		sign2 <= sign;
		exa <= a[14:10];		
		exb <= b[14:10];
		aareg <= shiftedAA;
		bbreg <= shiftedBB;
	end
	end


endmodule



		
