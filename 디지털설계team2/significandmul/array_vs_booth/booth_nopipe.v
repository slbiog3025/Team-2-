`timescale 1ns / 1ps

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
		 
		 output reg [24:0] out;
		 output reg [23:0] aao;
		 output reg [23:0] aso;
		 
		 
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

