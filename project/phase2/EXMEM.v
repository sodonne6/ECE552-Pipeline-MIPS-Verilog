module EXMEM(
        clk,
    	rst,
    	en, 
		ALU_Out,
		ALU_In2,
		read_data_1_EX,
		read_data_1_M,
		read_data_2_EX,
		read_data_2_M,
		MALU_Out,
		MALU_In2,
		instr_EX,
		instr_M,
        MemWrited,MemWriteq,// M signals
		MemToRegd, RegWrited, RegAddrd,MemToRegq, RegWriteq, RegAddrq//WB signals
		,llbd,llbq,lhbd,lhbq
		,PC_EX,PC_M//pc+2
        );
		//input and output signals for control signals

		input clk,rst,en;

		input MemWrited,MemToRegd, RegWrited;
		input[3:0] RegAddrd;
		input[15:0] ALU_Out,ALU_In2;
		input[15:0] read_data_1_EX,read_data_2_EX;
		output[15:0] read_data_1_M,read_data_2_M;
		output[15:0] MALU_Out;
		output[15:0] MALU_In2;
		output MemWriteq,MemToRegq, RegWriteq;
		output[3:0] RegAddrq;
		input llbd,lhbd;
		output llbq,lhbq;
		input [15:0] instr_EX;
		output[15:0] instr_M;
		input[15:0] PC_EX;
		output[15:0] PC_M;


    dff ffinstr[15:0](.d(instr_EX),.q(instr_M),.wen(en),.clk(clk),.rst(rst));
	//control signals to be sent to the respective frames 
	dff dff1[15:0](.d(ALU_Out),.q(MALU_Out),.wen(en),.clk(clk),.rst(rst));
	dff dff2[15:0](.d(ALU_In2),.q(MALU_In2),.wen(en),.clk(clk),.rst(rst));
	dff dff3[15:0](.d(read_data_1_EX),.q(read_data_1_M),.clk(clk),.rst(rst),.wen(en));
	dff dff4[15:0](.d(read_data_2_EX),.q(read_data_2_M),.clk(clk),.rst(rst),.wen(en));
	dff dff_pc[15:0](.d(PC_EX),.q(PC_M),.clk(clk),.rst(rst),.wen(en));
	M iM(.MemWrited(MemWrited),.MemWriteq(MemWriteq),.clk(clk),.rst(rst),.en(en));
	WB iWB(.MemToRegd(MemToRegd), .RegWrited(RegWrited), .RegAddrd(RegAddrd),.MemToRegq(MemToRegq), .RegWriteq(RegWriteq),
	.llbd(llbd),.llbq(llbq),.lhbd(lhbd),.lhbq(lhbq) ,.RegAddrq(RegAddrq),.clk(clk),.rst(rst),.en(en));


endmodule