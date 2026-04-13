module addsub_4bit (
    input [3:0] A, B,   // 4-bit Inputs
    input sub,          // 0 = Add, 1 = Subtract
    output [3:0] Sum,   // 4-bit Sum Output
    output Ovfl         // Overflow Flag
);

    wire [3:0] B_xor;   // XOR version of B
    wire [3:0] carry;   //carry signals

    //XOR each bit of B with 'sub' for subtraction
    assign B_xor = B ^ {4{sub}};  

    //instantiate Full Adders 
    fulladder_1bit FA0 (A[0], B_xor[0], sub,      Sum[0], carry[0]);
    fulladder_1bit FA1 (A[1], B_xor[1], carry[0], Sum[1], carry[1]);
    fulladder_1bit FA2 (A[2], B_xor[2], carry[1], Sum[2], carry[2]);
    fulladder_1bit FA3 (A[3], B_xor[3], carry[2], Sum[3], carry[3]);

    //Overflow Detection
    assign Ovfl = (~(A[3] ^ B_xor[3])) & (A[3] ^ Sum[3]);

endmodule

