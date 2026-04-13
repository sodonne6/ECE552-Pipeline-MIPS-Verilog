module PSA_16bit (Sum, Error, A, B);
	input [15:0] A, B; 	//inputs 16 bit	
	output [15:0] Sum; 	//output sum
	output Error; 	//overflow

	wire [3:0] sum3,sum2, sum1,sum0;
	wire ovf3,ovf2,ovf1,ovf0;
	//break input into 4 bit values and add using 4 bit ripple adder 
	addsub_4bit s0 (.A(A[3:0]), .B(B[3:0]), .sub(0), .Sum(sum0), .Ovfl(ovf0));
	addsub_4bit s1 (.A(A[7:4]), .B(B[7:4]), .sub(0), .Sum(sum1), .Ovfl(ovf1));
	addsub_4bit s2 (.A(A[11:8]), .B(B[11:8]), .sub(0),  .Sum(sum2), .Ovfl(ovf2));
	addsub_4bit s3 (.A(A[15:12]), .B(B[15:12]), .sub(0), .Sum(sum3), .Ovfl(ovf3));
	//concactenate all sums
	assign Sum = {sum3,sum2,sum1,sum0};
	//if any overflow flag is high error flagged
	assign Error = ovf3 | ovf2 | ovf1 | ovf0;



endmodule

