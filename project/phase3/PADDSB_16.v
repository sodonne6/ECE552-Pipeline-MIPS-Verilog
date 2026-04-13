module PSA_16bit (Sum, Error, A, B);
	input [15:0] A, B; 	//inputs 16 bit	
	output [15:0] Sum; 	//output sum
	output Error; 	//overflow

	wire [3:0] sum3,sum2, sum1,sum0;
	wire [3:0] sum3_sat, sum2_sat, sum1_sat,sum0_sat;
	wire ovf3,ovf2,ovf1,ovf0;


	add_sub_4 s0 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(sum0), .Ovfl(ovf0), .Cout(),.PG(), .GG());
	add_sub_4 s1 (.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Sum(sum1), .Ovfl(ovf1), .Cout(), .PG(), .GG());
	add_sub_4 s2 (.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Sum(sum2), .Ovfl(ovf2), .Cout(), .PG(), .GG());
	add_sub_4 s3 (.A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Sum(sum3), .Ovfl(ovf3), .Cout(), .PG(), .GG());

	//if any overflow flag is high error flagged
	assign Error = ovf3 | ovf2 | ovf1 | ovf0;

	//check ovf flag if it is high then go to next mux and && both MSB's
	//can only overflow if both pos or both neg so check the MSB's of the inputs A and B 
	//if the overflow is flagged and both MSB's are 1 -> saturate to biggest neg number
	//if the overflow is flagged and both MSB's are 0 -> saturate to biggest pos number
	assign sum0_sat = ovf0 ? ((A[3]& B[3]) ? (4'b1000):(4'b0111) ):(sum0);
	assign sum1_sat = ovf1 ? ((A[7]& B[7]) ? (4'b1000):(4'b0111) ):(sum1);
	assign sum2_sat = ovf2 ? ((A[11]& B[11]) ? (4'b1000):(4'b0111) ):(sum2);
	assign sum3_sat = ovf3 ? ((A[15]& B[15]) ? (4'b1000):(4'b0111) ):(sum3);

	//concactenate all sums
	assign Sum = {sum3_sat,sum2_sat,sum1_sat,sum0_sat};

endmodule
