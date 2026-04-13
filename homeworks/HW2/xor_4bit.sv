module xor_4bit(
input wire [3:0] x, y,
output wire [3:0] xor_4
    );
    //call 1 bit xor module for each bit seperately
    xor_1bit xor_0 (.a(x[0]), .b(y[0]), .xor_1(xor_4[0]));
    xor_1bit xor_1 (.a(x[1]), .b(y[1]), .xor_1(xor_4[1]));
    xor_1bit xor_2 (.a(x[2]), .b(y[2]), .xor_1(xor_4[2]));
    xor_1bit xor_3 (.a(x[3]), .b(y[3]), .xor_1(xor_4[3]));
    
    
endmodule

