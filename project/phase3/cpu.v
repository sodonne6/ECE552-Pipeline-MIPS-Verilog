module cpu(input clk, input rst_n, output hlt,output [15:0]pc);
	
	wire Branch,MemtoReg, MemWrite,ALUSrc,RegWrite;//control signals for there final phase
	wire DMemRead,DMemtoReg, DMemWrite,DALUSrc,DRegWrite;//control signals for D phase
	wire XMemtoReg, XMemWrite,XRegWrite;//control signals for ex phase
	wire MMemtoReg;
	wire [3:0] DALUOp,ALUOp;
	wire [15:0] DRReadData1,DRReadData2,XRReadData1,XRReadData2,MReadData,WMReadData,ALUin2,ALUin1,MALUIn2;// register outputs, data mem outputs, and intermediate signal for ALU input
	wire [15:0] XRReadData1pref,XRReadData2pref;//the data in the X phase pre the forwarding step
	wire [15:0] WRReadData1,WRReadData2;
	wire[15:0] ALU_Out,MALU_Out,WALU_Out;//output of central ALU
	wire[15:0] instruction,nxt_instr;//Current instruction
	wire[15:0] Xinstr, Minstr, Winstr;//instruction of the respective phase
	wire [15:0] DSEImm,XSEImm;//sign extended immediate
	wire dataMemEn;//enable data Mem?
	wire [15:0] RegWriteData;
	wire [3:0] Opcode, rd,rs,rt;//where rt could be immediate
	wire[3:0] WriteReg,DWriteReg, XWriteReg, MWriteReg;//what register to write to
	wire z,n,v,z_q,n_q,v_q;//ALU flags
	wire [15:0] pcp4, pcInput, branchALUresult,pc_next;//pc +4, pc Input for pc flip flop, result after branch
	wire ovflpc,ovflpc2;
	wire llb, lhb;
	wire [3:0] cusrcReg1,cusrcReg2;//control unit signals for register file inputs
	wire jumpAndLink, BranchReg;
	wire rst,cycle,cycle2;//assert reset when resetting, cycle is true when rst_n is low for at least one cycle
	wire [15:0] highByteLoad,lowByteLoad,mhighByteLoad,mlowByteLoad,mByteload;//intermediate signals for hbl, lbu
	wire[15:0]MRReadData1,MRReadData2;
	wire c_n,c_v,c_z;//change n,v,z?
	wire n_cur,v_cur, z_cur;//flag bits for this exact cycle, will be based on flag bits+ flag bits stored in register
	wire noopd, noopq;//input and output of the IDEX noop wire
	wire Dllb, Dlhb,Xllb,Xlhb,Mllb,Mlhb;
	wire [15:0] pcp4_id,pcp4_ex,pcp4_m,pcp4_w;//incremented pc for id phase
	wire halting;//are we in a state of halting?
	wire [3:0] shamtd,shamtq;//shift amount for shift operations
	wire stall_if_id,pc_write,if_id_stall;
	wire instructionValid,memvalid;//assert true if nxt_instruction is valid (fetching from mem)
	wire cache_stall_f, cache_stall_d, cache_stall_x, cache_stall_m;//stall inputs for cache stalls
	assign stall_if_id = if_id_stall;
	//If I halt then the pc will keep loading the same halt operation untill finally the program stops
	wire fALUin1,fALUin2;//assert 1 if ALU needs forwarding input
	wire[15:0] fALUin1_reg,fALUin2_reg;//register values from the forwarding unit
	wire[3:0] XALUin1addr,XALUin2addr;//what were the register input addresses?
	wire fMEMin;//am I forwarding mem to mem
	wire [15:0]fMEMin_reg, write_data;//the value forwarded, the register write data
	wire dusesReg1,dusesReg2;
	wire c_zq,c_vq,c_nq;
	wire DjumpAndLink, XjumpAndLink, MjumpAndLink;
	wire ireq;//are we requesting an instruction
	wire i_good,n_i_good;//have unused instruction
	wire [15:0]held_instruction;//holds instruction fetched untill next instruction fetched
	wire [15:0]got_instruction;//instruction received from cache
	wire corrupted;//nxt_instr is bad, keep sending garbage

	assign ireq = (~i_good)|(~n_i_good);
	assign write_data = fMEMin? fMEMin_reg: MRReadData2;
	dff df3233(.d(c_z),.q(c_zq),.wen(1'b1),.rst(rst),.clk(clk));
	dff df3gf233(.d(c_n),.q(c_nq),.wen(1'b1),.rst(rst),.clk(clk));
	dff df323fdfs3(.d(c_v),.q(c_vq),.wen(1'b1),.rst(rst),.clk(clk));
	assign {Opcode,rd,rs,rt }= instruction;//seperate the parts of the instruction
	assign shamtd = rt;
	assign dusesReg1 = ~((Opcode != 4'b1101)&(&Opcode));//all opcodes that don't read from a register
	assign dusesReg2= dusesReg1 &(~DALUSrc)&(~Dlhb)&(~Dllb);//operation uses regesters, and also isn't using immediate

	assign cache_stall_f = (~instructionValid)|((~memvalid)&(MemWrite|MMemtoReg));
	assign cache_stall_d = (~memvalid)&(MemWrite|MMemtoReg);
	assign cache_stall_x = (~memvalid)&(MemWrite|MMemtoReg);
	assign cache_stall_m = (~memvalid)&(MemWrite|MMemtoReg);
	dff  cache_instff[15:0](.d(got_instruction),.q(held_instruction),.clk(clk),.wen(instructionValid),.rst(rst));
	dff corrupt_ff(.d((Branch|BranchReg)),.q(corrupted),.clk(clk),.wen(1'b1),.rst(rst|n_i_good));
	assign n_i_good=(~(Branch|BranchReg))&((instructionValid)|(i_good&(~(cache_stall_f|stall_if_id))));
	dff igood_ff(.d(n_i_good),.q(i_good),.wen(1'b1),.rst(rst|corrupted),.clk(clk));//is the current instruction applicable
	hazard_detection_u hazard_detector(.MMRead(XMemtoReg),.Moutaddr(MWriteReg),.Dreg1((Dllb|Dlhb)?rd:rs),.Dreg2(rt),.reg1en(dusesReg1),
		.reg2en(dusesReg2),.pc_write(pc_write),.if_id_stall(if_id_stall),.Xoutaddr(XWriteReg)
		,.XWriteReg(XRegWrite),.BR(Opcode==4'b1101),.MWriteReg(MRegWrite));	
	IFID iIFID(
    	.clk(clk),
    	.rst(rst|(Branch|BranchReg)|(cache_stall_f&~cache_stall_d)),//reset if resetting or a branch operation
    	.nxt_instr(nxt_instr),  
    	.nxt_PC(pcp4),    
    	.en(~stall_if_id&(~cache_stall_d)),         //assert to let pipeline know to keep going -> when low the pipeline stalls 
    	.instr_ID(instruction),   
    	.PC_ID(pcp4_id)       
	);
	assign noopd = Branch|BranchReg;
	IDEX iIDEX(
    	.clk(clk),.rst(rst|stall_if_id|(cache_stall_d&~cache_stall_x)),.en(~stall_if_id&(~cache_stall_x)),         	//when low the pipeline stalls 
    	//inputs from the ID stage
		.read_data_1_ID(DRReadData1),     //read data 1
    	.read_data_2_ID(DRReadData2),     //read data 2
    	.imm_ID(DSEImm),     	//sign extended immediate
    	.PC_ID(pcp4_id),      	//PC value from ID
		.instr_ID(instruction),
		.instr_EX(Xinstr),
		.noopd(noopd),
		.noopq(noopq),
		.shamtd(shamtd),
		.shamtq(shamtq),

		.ALUin1addrd(cusrcReg1),
		.ALUin1addrq(XALUin1addr),
		.ALUin2addrd(cusrcReg2),
		.ALUin2addrq(XALUin2addr),

    	//outputs to the EX stage
    	.read_data_1_EX(XRReadData1pref), 	//read data 1 value going to ex
    	.read_data_2_EX(XRReadData2pref),	//read data 2 going to ex
    	.imm_EX(XSEImm),		//immidiate going to ex 
    	.PC_EX(pcp4_ex),		//pc value going to ex
		.ALUopd(DALUOp),.ALUopq(ALUOp),.ALUsrcd(DALUSrc),.ALUsrcq(ALUSrc),//EX signals 
		.MemWrited(DMemWrite),.MemWriteq(XMemWrite),// M signals
		.MemToRegd(DMemtoReg), .RegWrited(DRegWrite), .RegAddrd(DWriteReg),.MemToRegq(XMemtoReg), .RegWriteq(XRegWrite), .RegAddrq(XWriteReg),//WB signals
		.llbd(Dllb),.llbq(Xllb),.lhbd(Dlhb),.lhbq(Xlhb)//more WB signals
		);

	EXMEM iEXMEM(
        .clk(clk),.rst(rst|(cache_stall_x&~cache_stall_m)),.en(~cache_stall_m), 
		.ALU_Out(ALU_Out),//output of EX ALU
		.ALU_In2(ALUin2),
		.instr_EX(Xinstr),
		.instr_M(Minstr),

		.read_data_1_EX(XRReadData1),     //read data 1
    	.read_data_2_EX(XRReadData2),     //read data 2
		.read_data_1_M(MRReadData1), 	//read data 1 value going to ex
		.read_data_2_M(MRReadData2), 	//read data 1 value going to ex

		.PC_EX(pcp4_ex),
		.PC_M(pcp4_m),

		.MALU_Out(MALU_Out),
		.MALU_In2(MALUIn2),

        .MemWrited(XMemWrite),.MemWriteq(MemWrite),// M signals
		.MemToRegd(XMemtoReg), .RegWrited(XRegWrite), .RegAddrd(XWriteReg),.MemToRegq(MMemtoReg), .RegWriteq(MRegWrite), .RegAddrq(MWriteReg),//WB signals
		.llbd(Xllb),.llbq(Mllb),.lhbd(Xlhb),.lhbq(Mlhb)//more WB signals
        );
	MEMWB	iMEMWB(
    .clk(clk),.rst(rst|(cache_stall_m)),.en(1'b1),
	.MD_Out(MReadData),//output of memory reading
	.ALU_Out(MALU_Out),//output of alu

	.instr_M(Minstr),
	.instr_W(Winstr),
	.read_data_1_M(MRReadData1),     //read data 1
    .read_data_2_M(MRReadData2),     //read data 2
	.read_data_1_WB(WRReadData1), 	//read data 1 value going to ex
    .read_data_2_WB(WRReadData2),	//read data 2 going to ex

	
	.PC_M(pcp4_m),
	.PC_W(pcp4_w),

	.WALU_Out(WALU_Out),
	.WD_Out(WMReadData),

	.MemToRegd(MMemtoReg), .RegWrited(MRegWrite), .RegAddrd(MWriteReg),.MemToRegq(MemtoReg), .RegWriteq(RegWrite), .RegAddrq(WriteReg),//WB signals
	.llbd(Mllb),.llbq(llb),.lhbd(Mlhb),.lhbq(lhb)//more WB signals
	);


	fu forwarding_unit(.fALUin1(fALUin1),.fALUin1_reg(fALUin1_reg),.fALUin2(fALUin2),.fALUin2_reg(fALUin2_reg),
	.xaddr1(XALUin1addr), .xaddr2(XALUin2addr), 
	.maddr(MWriteReg),.waddr(WriteReg),
	.mwen(MRegWrite), .wwen(RegWrite),
	.reg1en(1'b1), .reg2en(1'b1),.mALU_out(MALU_Out),.wout(RegWriteData),
	.mlb(Mlhb|Mllb),.xlb(Xlhb|Xllb),.mByteload(mByteload),.xrd(XWriteReg)
	,.msw(MemWrite), .mrtaddr(Minstr[11:8]),.fMEMin(fMEMin),.fMEMin_reg(fMEMin_reg) );


	//so I should put this in the registers between steps , but I don't feel like it
	dff djl(.q(XjumpAndLink), .d(DjumpAndLink), .wen(pc_write&~stall_if_id&(~cache_stall_x)), .clk(clk), .rst(rst|stall_if_id|(cache_stall_d&~cache_stall_x)));
	dff xjl(.q(MjumpAndLink), .d(XjumpAndLink), .wen(pc_write&(~cache_stall_m)), .clk(clk), .rst(rst|(cache_stall_x&~cache_stall_m)));
	dff mjl(.q(jumpAndLink), .d(MjumpAndLink), .wen(pc_write), .clk(clk), .rst(rst|cache_stall_m));

	//pc flip flop
	dff pcnext[15:0](.q(pc_next),.d(pcInput),.clk(clk),.rst(rst),.wen(((~cache_stall_f)&(~corrupted))|(Branch|BranchReg)));
	dff pcReg[15:0](.q(pc), .d(pc_next), .wen(pc_write|(Branch|BranchReg)), .clk(clk), .rst(rst));
	
	dff cycleff(.q(cycle),.d(1'b1),.clk(clk),.wen(1'b1),.rst(~rst_n));
	dff rstff(.q(cycle2),.d(cycle|rst_n),.rst(1'b0),.wen(1'b1),.clk(clk));
	assign rst = ~cycle2&(~rst_n);
	
	//keep flags in flip flop to check branch potentially
	dff nff(.q(n_q),.d(n),.wen(c_nq&(~noopq)),.clk(clk),.rst(rst));//only store when alu operation
	dff vff(.q(v_q),.d(v),.wen(c_vq&(~noopq)),.clk(clk),.rst(rst));//only store when alu operation
	dff zff(.q(z_q),.d(z),.wen(c_zq&(~noopq)),.clk(clk),.rst(rst));//only store when alu operation

	//are we looking at this cycles or last cycles?	
	assign n_cur = (n_q & (~c_nq))|(n & c_n);
	assign v_cur = (v_q & (~c_vq))|(v & c_v);
	assign z_cur = (z_q & (~c_zq))|(z & c_z);
	
	add_sub_16 pcp4adder(//add 2 to pc
		.A(pc), .B(16'h0002),
		.sub(1'b0), // 1 for subtraction, 0 for addition
		.Sum(pcp4),
		.Ovfl(ovflpc)//don't care);
		);
		
	add_sub_16 branchAdder(//compute pc+2 + offset
		.A(pcp4_id), .B({DSEImm[15:0]}),
		.sub(1'b0), // 1 for subtraction, 0 for addition
		.Sum(branchALUresult),
		.Ovfl(ovflpc2)//don't care);
		);
	
	assign pcInput = rst? 16'h0000:
					//cache_stall_f?pc:
					Branch ? branchALUresult:
					BranchReg? DRReadData1://is it a branch?
					halting? pc//is the current F instruction a halt
					:pcp4;
	
	//memory1c_instr instructionMem(.data_out(nxt_instr), .data_in(16'hxxxx), .addr(pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));
	
	assign highByteLoad ={Winstr[7:0],WRReadData2[7:0]};
	assign lowByteLoad ={WRReadData2[15:8],Winstr[7:0]};

	assign mhighByteLoad ={Minstr[7:0],MRReadData2[7:0]};
	assign mlowByteLoad ={MRReadData2[15:8],Minstr[7:0]};
	assign mByteload = Mlhb? mhighByteLoad:mlowByteLoad;

	assign RegWriteData = lhb?highByteLoad
		:llb? lowByteLoad
		:MemtoReg? WMReadData//are we loading from memory?
		:jumpAndLink? pcp4_w//pcs?
		:WALU_Out;//default is just the result of whatever operation
	
	
	
	//assign WriteReg = RegDst? rt:rs;//for the instruction what is the destination register
	RegisterFile rf(
    .clk(clk),
    .rst(rst),
    .SrcReg1(cusrcReg1),
    .SrcReg2(cusrcReg2),
    .DstReg(WriteReg),
    .WriteReg(RegWrite),
    .DstData(RegWriteData),
    .SrcData1(DRReadData1),
    .SrcData2(DRReadData2)
);

	assign XRReadData1 = fALUin1? fALUin1_reg:
					XRReadData1pref;
	assign XRReadData2 = fALUin2? fALUin2_reg:
				XRReadData2pref;
	//are we forwarding?
	assign ALUin2 = ALUSrc? XSEImm:XRReadData2;
	assign ALUin1 = XRReadData1;
	ALU iALU(
    	.ALU_In1(ALUin1), .ALU_In2(ALUin2),  
    	.Opcode(ALUOp),            
    	.Shamt(shamtq),//TODO add an intermediate signal for this      
    	.ALU_Out(ALU_Out),     
    	 .Z(z), .N(n), .V(v));
		 
		 //control unit
	control_unit CU(
    .instr(instruction),        
    .z_flag(z_cur),              
    .v_flag(v_cur),              // overflow 
    .n_flag(n_cur),              
    
	.c_z(c_z),
	.c_v(c_v),
	.c_n(c_n),
	
    .srcReg1(cusrcReg1),      
    .srcReg2(cusrcReg2),      
	.dstReg(DWriteReg),       
	.regWrite(DRegWrite),           
    
	.aluOp(DALUOp),        
	.aluSrc(DALUSrc),             // 1 ===> Immediate value; 0 ===> Register 
    
    .memRead(DMemRead),            
    .memWrite(DMemWrite),           
    
    .branch(Branch),          
    .branchReg(BranchReg),        
    .jumpAndLink(DjumpAndLink),        
	.halt(),               
 
	.immediate(DSEImm),
    
    .llb(Dllb),                // Load Lower Byte
	.lhb(Dlhb)
);
	assign halting = &nxt_instr[15:12];//is a halt operation entering the pipeline
	assign hlt = &Winstr[15:12];//is a halt instruction at the end of the pipeline
	//if the halt was flushed, the instruction buffer would have been modified
	assign DMemtoReg = DMemRead;
	assign dataMemEn = MemWrite|MMemtoReg;
	
	//memory1c dataMem(.data_out(MReadData), .data_in(write_data), .addr(MALU_Out), .enable(dataMemEn), .wr(MemWrite), .clk(clk), .rst(rst));
	//MDCacheInterface MDCinterface(.addr(MALU_Out),.clk(clk),.rst(rst),.data_in(write_data),.data_out(MReadData), .data_ready(memvalid),.wen(MemWrite),.ren(DMemRead));
	//FICacheInterface FIcache(.addr(pc),.clk(clk),.rst(rst),.data(nxt_instr),.data_ready(instructionValid),.ren(1'b1));
	
	//fake_cache icache(.maddr(MALU_Out),.clk(clk),.rst(rst),.mdata_in(write_data),.mwen(MemWrite),.mren(MMemtoReg),.mdata_out(MReadData),.mdata_ready(memvalid),
		//.iaddr(pc),.iren(1'b1),.idata(nxt_instr),.idata_ready(instructionValid));
	assign nxt_instr = corrupted? 16'h0000
	:(instructionValid? got_instruction:held_instruction);
	//cache_container icache(maddr,clk,rst,mdata_in,mwen,mren,mdata_out,mdata_ready,iaddr,iren,idata,idata_ready);
	cache_container icache(.maddr(MALU_Out),.clk(clk),.rst(rst),.mdata_in(write_data),.mwen(MemWrite),.mren(MMemtoReg|MemWrite),.mdata_out(MReadData),.mdata_ready(memvalid),
		.iaddr(pc),.iren(ireq),.idata(got_instruction),.idata_ready(instructionValid));
endmodule
