module MEMWB(
    clk,rst,en,
    MD_Out,//output of memory reading
	ALU_Out,//output of alu
    read_data_1_M,read_data_2_M,
    read_data_1_WB,read_data_2_WB,
    WALU_Out,
	WD_Out,
    instr_M,
    instr_W,
    MemToRegd, RegWrited, RegAddrd,MemToRegq, RegWriteq, RegAddrq//WB signals
    ,llbd,llbq,lhbd,lhbq,
    PC_M,PC_W
);
    input clk,rst,en;

    input MemToRegd, RegWrited;
    input[3:0] RegAddrd;
    input[15:0]MD_Out,ALU_Out;
    input [15:0] read_data_1_M,read_data_2_M;
	output[15:0] read_data_1_WB,read_data_2_WB;
    output[15:0]WALU_Out,WD_Out;
    output MemToRegq, RegWriteq;
    output[3:0] RegAddrq;
    input llbd,lhbd;
    output llbq,lhbq;
    input [15:0] instr_M;
    output[15:0] instr_W;
    input[15:0] PC_M;
    output[15:0] PC_W;
 

    dff ffinstr[15:0](.d(instr_M),.q(instr_W),.wen(en),.clk(clk),.rst(rst));

    dff dff1[15:0](.d(ALU_Out),.q(WALU_Out),.wen(en),.clk(clk),.rst(rst));
    dff dff2[15:0](.d(MD_Out),.q(WD_Out),.wen(en),.clk(clk),.rst(rst));
    dff dff3[15:0](.d(read_data_1_M),.q(read_data_1_WB),.clk(clk),.rst(rst),.wen(en));
    dff dff4[15:0](.d(read_data_2_M),.q(read_data_2_WB),.clk(clk),.rst(rst),.wen(en));
    dff dff_pc[15:0](.d(PC_M),.q(PC_W),.clk(clk),.wen(en),.rst(rst));

    //control signals to be sent to the respective frames 
    WB iWB(.MemToRegd(MemToRegd), .RegWrited(RegWrited), .RegAddrd(RegAddrd),.MemToRegq(MemToRegq), .RegWriteq(RegWriteq), .RegAddrq(RegAddrq),
    .llbd(llbd),.llbq(llbq),.lhbd(lhbd),.lhbq(lhbq),.clk(clk),.rst(rst),.en(en));
endmodule