`timescale 1ns / 1ps

module tb_multii;
	// Inpu
	reg [9:0] A;
	reg [9:0] B;
	reg azero, bzero;
	reg CLK, RST;
	
	// Outputs
	wire [23:0] s;

	// Instantiate the Unit Under Test (UUT)
	array_mul uut (
		.a(A), 
		.b(B),
		.azero(azero),
		.bzero(bzero),
		.CLK(CLK), 
		.RST(RST), 
		.s(s)
	);
	
	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		azero = 1;
		bzero = 1;
		#40
		
		// Wait 100 ns for global reset to finish
		#10000;
		$finish;
	end
      	always #20 A = A + 1;
	      always #20 B = B + 2;
			
	initial begin
		CLK = 1;
		RST = 1;
		forever #10 CLK = ~CLK;
	end
endmodule