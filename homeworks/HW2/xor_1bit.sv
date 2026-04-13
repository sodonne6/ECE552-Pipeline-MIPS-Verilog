module xor_1bit(
    input wire a,b,
    output wire xor_1
    );
    
    assign xor_1 = (a ^ b); 
endmodule

// a     b     nxor
// 0     0      0
// 0     1      1
// 1     0      1
// 1     1      0
