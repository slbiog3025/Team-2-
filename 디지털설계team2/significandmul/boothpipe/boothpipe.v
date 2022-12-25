`timescale 1ns / 1ps

module booth_multiplier_pipeline(a,b, azero, bzero, CLK,RST,s 
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
		 assign pp = {ap[24],ap[24:1]} + ppp;
		 
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
