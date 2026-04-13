module nand_4bit(
input wire [3:0] x, y,
output wire [3:0] nand_4
    );
    //call 1 bit nand module for each bit seperately
    nand_1bit nand_0 (.a(x[0]), .b(y[0]), .nand_1(nand_4[0]));
    nand_1bit nand_1 (.a(x[1]), .b(y[1]), .nand_1(nand_4[1]));
    nand_1bit nand_2 (.a(x[2]), .b(y[2]), .nand_1(nand_4[2]));
    nand_1bit nand_3 (.a(x[3]), .b(y[3]), .nand_1(nand_4[3]));
    
    
endmodule
