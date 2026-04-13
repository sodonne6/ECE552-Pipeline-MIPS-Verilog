// the M register on top of each register in between steps, i.e. in cpu there should be 1 of these
//contains control signols needed in the M phase
//d means input, q means output signal
//feel free to add more signals 
module M(MemWrited,MemWriteq,clk,rst,en);
input clk,rst,en;
input MemWrited;

output MemWriteq;

dff idff1(.q(MemWriteq), .d(MemWrited), .wen(en), .clk(clk), .rst(rst));

endmodule
