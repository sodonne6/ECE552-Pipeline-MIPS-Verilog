module add_sub_16(
    input signed [15:0] A, B,
    input sub, // 1 for subtraction, 0 for addition
    output signed [15:0] Sum,
    output Ovfl
);
    wire [15:0] B_xor; 
    wire [15:0] s;
    wire Cin;
    wire [3:0] C, PG, GG;

    assign B_xor = B ^ {16{sub}}; // negate if subtraction
    assign Cin = sub; // add 1 if negated
/*
module add_sub_4(
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Ovfl,
    output Cout, PG, GG
);*/
    add_sub_4 a1(.A(A[3:0]), .B(B_xor[3:0]), .Cin(Cin), .Sum(s[3:0]),.Ovfl(), .Cout(C[0]), .PG(PG[0]), .GG(GG[0]));
	add_sub_4 a2(.A(A[7:4]), .B(B_xor[7:4]), .Cin(C[0]), .Sum(s[7:4]),.Ovfl(), .Cout(C[1]), .PG(PG[1]), .GG(GG[1]));
	add_sub_4 a3(.A(A[11:8]), .B(B_xor[11:8]), .Cin(C[1]), .Sum(s[11:8]),.Ovfl(), .Cout(C[2]), .PG(PG[2]), .GG(GG[2]));
    add_sub_4 a4(.A(A[15:12]), .B(B_xor[15:12]), .Cin(C[2]), .Sum(s[15:12]),.Ovfl(), .Cout(C[3]), .PG(PG[3]), .GG(GG[3]));
	
    //add_sub_4 a2(A[7:4], B_xor[7:4], C[0], s[7:4],.Ovfl(), C[1], PG[1], GG[1]);
    //add_sub_4 a3(A[11:8], B_xor[11:8], C[1], s[11:8],.Ovfl() ,C[2], PG[2], GG[2]);
    //add_sub_4 a4(A[15:12], B_xor[15:12], C[2], s[15:12], .Ovfl(),C[3], PG[3], GG[3]);

    assign Ovfl = (~A[15] & ~B_xor[15] & s[15]) | (A[15] & B_xor[15] & ~s[15]);
    assign Sum = Ovfl ? (A[15] ? 16'h8000 : 16'h7FFF) : s; // saturation
endmodule
