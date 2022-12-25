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
		out <= {sign,exp[4:0],fra2[9:0]};
		overflow <= (exp == 5'b11111) ? 1 : 0;
		sub <= (exp == 5'b00000) ? 1 :0;	 
	end
	end


endmodule
