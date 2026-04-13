module cpu(input clk, input rst_n, output hlt,output [15:0]pc);
	
	wire Branch,MemRead,MemtoReg, MemWrite,ALUSrc,RegWrite;//control signals
	wire [3:0] ALUOp;
	wire [15:0] RReadData1,RReadData2,MReadData,ALUin2;// register outputs, data mem outputs, and intermediate signal for ALU input
	wire[15:0] ALU_Out;//output of central ALU
	wire[15:0] instruction;//Current instruction
	wire [15:0] SEImm;//sign extended immediate
	wire dataMemEn;//enable data Mem?
	wire [15:0] RegWriteData;
	wire [3:0] Opcode, rd,rs,rt;//where rt could be immediate
	wire[3:0] WriteReg;//what register to write to
	wire z,n,v,z_q,n_q,v_q;//ALU flags
	wire [15:0] pcp4, pcInput, branchALUresult;//pc +4, pc Input for pc flip flop, result after branch
	wire ovflpc,ovflpc2;
	wire llb, lhb;
	wire [3:0] cusrcReg1,cusrcReg2,cudstReg;//control unit signals for register file inputs
	wire jumpAndLink, BranchReg;
	wire rst,cycle,cycle2;//assert reset when resetting, cycle is true when rst_n is low for at least one cycle
	wire [15:0] highByteLoad,lowByteLoad;//intermediate signals for hbl, lbu
	wire c_n,c_v,c_z;//change n,v,z?
	assign {Opcode,rd,rs,rt }= instruction;//seperate the parts of the instruction
	
	//TODO: look at rst_n mechanics,
	
	//assign rst = ~rst_n;
	//pc flip flop
	
	dff pcReg[15:0](.q(pc), .d(pcInput), .wen(1'b1), .clk(clk), .rst(rst));
	
	dff cycleff(.q(cycle),.d(1'b1),.clk(clk),.wen(1'b1),.rst(~rst_n));
	dff rstff(.q(cycle2),.d(cycle|rst_n),.rst(1'b0),.wen(1'b1),.clk(clk));
	assign rst = ~cycle2&(~rst_n);
	
	//keep flags in flip flop to check branch potentially
	dff nff(.q(n_q),.d(n),.wen(c_n),.clk(clk),.rst(rst));//only store when alu operation
	dff vff(.q(v_q),.d(v),.wen(c_v),.clk(clk),.rst(rst));//only store when alu operation
	dff zff(.q(z_q),.d(z),.wen(c_z),.clk(clk),.rst(rst));//only store when alu operation
	
	add_sub_16 pcp4adder(//add 2 to pc
		.A(pc), .B(16'h0002),
		.sub(1'b0), // 1 for subtraction, 0 for addition
		.Sum(pcp4),
		.Ovfl(ovflpc)//don't care);
		);
		
	add_sub_16 branchAdder(//compute pc+2 + offset
		.A(pcp4), .B({SEImm[15:0]}),
		.sub(1'b0), // 1 for subtraction, 0 for addition
		.Sum(branchALUresult),
		.Ovfl(ovflpc2)//don't care);
		);
	
	assign pcInput = rst? 16'h0000:
					Branch ? branchALUresult:
					BranchReg? RReadData1//is it a branch?
					:pcp4;
	
	memory1c_instr instructionMem(.data_out(instruction), .data_in(16'hxxxx), .addr(pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));
	
	assign highByteLoad ={instruction[7:0],RReadData2[7:0]} ;
	assign lowByteLoad ={RReadData2[15:8],instruction[7:0]};
	
	assign RegWriteData = lhb?highByteLoad
		:llb? lowByteLoad
		:MemtoReg? MReadData//are we loading from memory?
		:jumpAndLink? pcp4//pcs?
		:ALU_Out;//default is just the result of whatever operation
	
	
	
	//assign WriteReg = RegDst? rt:rs;//for the instruction what is the destination register
	RegisterFile rf(
    .clk(clk),
    .rst(rst),
    .SrcReg1(cusrcReg1),
    .SrcReg2(cusrcReg2),
    .DstReg(WriteReg),
    .WriteReg(RegWrite),
    .DstData(RegWriteData),
    .SrcData1(RReadData1),
    .SrcData2(RReadData2)
);
	
	assign ALUin2 = ALUSrc? SEImm:RReadData2;
	ALU iALU(
    	.ALU_In1(RReadData1), .ALU_In2(ALUin2),  
    	.Opcode(ALUOp),            
    	.Shamt(rt),             
    	.ALU_Out(ALU_Out),     
    	 .Z(z), .N(n), .V(v));
		 
		 //control unit
	control_unit CU(
    .instr(instruction),        
    .z_flag(z_q),              
    .v_flag(v_q),              // overflow 
    .n_flag(n_q),              
    
	.c_z(c_z),
	.c_v(c_v),
	.c_n(c_n),
	
    .srcReg1(cusrcReg1),      
    .srcReg2(cusrcReg2),      
	.dstReg(WriteReg),       
	.regWrite(RegWrite),           
    
	.aluOp(ALUOp),        
	.aluSrc(ALUSrc),             // 1 ===> Immediate value; 0 ===> Register 
    
    .memRead(MemRead),            
    .memWrite(MemWrite),           
    
    .branch(Branch),          
    .branchReg(BranchReg),        
    .jumpAndLink(jumpAndLink),        
	.halt(hlt),               
 
	.immediate(SEImm),
    
    .llb(llb),                // Load Lower Byte
	.lhb(lhb)
);
	assign MemtoReg = MemRead;
	assign dataMemEn = MemWrite|MemRead;
	
	memory1c dataMem(.data_out(MReadData), .data_in(RReadData2), .addr(ALU_Out), .enable(dataMemEn), .wr(MemWrite), .clk(clk), .rst(rst));

endmodule
