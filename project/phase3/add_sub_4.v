module add_sub_4(
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Ovfl,
    output Cout, PG, GG
);
    wire [3:0] P, G;
    wire [3:1] C;
    
    assign P = A ^ B; // propagate
    assign G = A & B; // generate
    
    assign C[1] = G[0] | (P[0] & Cin);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign Cout = G[3] | (P[3] & C[3]);
    
    assign Sum[0] = P[0] ^ Cin;
    assign Sum[1] = P[1] ^ C[1];
    assign Sum[2] = P[2] ^ C[2];
    assign Sum[3] = P[3] ^ C[3];
    
    assign PG = &P; // group propagate
    assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]); // group generate
    
    //Overflow Detection - this does not have be detected if not needed
    //necessary for saturation detection in PADDSB
    //if overflow detection not necessary just keep this connection without a partner (for example .Ovfl() ) 
    assign Ovfl = (A[3] ~^ B[3]) & (A[3] ^ Sum[3]); 

endmodule
