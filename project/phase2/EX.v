// the EX register on top of each register in between steps, i.e. in cpu there should be 1 of these
//contains control signols needed in the EX phase
//d means input, q means output signal
//feel free to add more signals 
module EX(ALUopd,ALUopq,ALUsrcd,ALUsrcq,clk,rst,en);
input clk,rst,en;
input [3:0]ALUopd;
input ALUsrcd;

output [3:0] ALUopq;
output ALUsrcq;

dff idff1[3:0](.q(ALUopq), .d(ALUopd), .wen(en), .clk(clk), .rst(rst));
dff idff21[3:0](.q(ALUsrcq), .d(ALUsrcd), .wen(en), .clk(clk), .rst(rst));
endmodule
