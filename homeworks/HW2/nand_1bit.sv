module nand_1bit(
    input wire a,b,
    output wire nand_1
    );
    
    assign nand_1 = ~(a & b); 
endmodule

// a     b     nxor
// 0     0      1
// 0     1      1
// 1     0      1
// 1     1      0
