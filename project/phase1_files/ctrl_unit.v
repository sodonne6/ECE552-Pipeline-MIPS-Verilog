module control_unit (

    input [15:0] instr,        
    input z_flag,              
    input v_flag,              // overflow 
    input n_flag,              
    
	output c_z,
	output c_v,
	output c_n,//should you change the register for z,v,n
   
    output [3:0] srcReg1,      
    output [3:0] srcReg2,      
    output [3:0] dstReg,       
    output regWrite,           
    
    output [3:0] aluOp,        
    output aluSrc,             // 1 ===> Immediate value; 0 ===> Register 
    
    output memRead,            
    output memWrite,           
    
    output branch,          
    output branchReg,        
    output jumpAndLink,        
    output halt,               
    
    output [15:0] immediate,
    
    output llb,                // Load Lower Byte
    output lhb                 // Load Higher Byte
);

    // instruction field 
    wire [3:0] opcode;
    wire [3:0] rd;
    wire [3:0] rs;
    wire [3:0] rt;
    wire [3:0] imm4;
    wire [7:0] imm8;
    wire [2:0] cond;
    wire [8:0] offset9;
    wire [3:0] offset4;
    
    // opcodes
    wire isADD, isSUB, isXOR, isRED, isSLL, isSRA, isROR, isPADDSB;
    wire isLW, isSW, isLLB, isLHB, isB, isBR, isPCS, isHLT;
    
    // branch condition eval
    wire neq_cond, eq_cond, gt_cond, lt_cond, gte_cond, lte_cond, ovfl_cond, uncond_cond;
    wire branch_taken;
    
    // get instrcution fields
    assign opcode = instr[15:12];
    assign rd = instr[11:8];
    assign rs = instr[7:4];
    assign rt = instr[3:0];
    assign imm4 = instr[3:0];
    assign imm8 = instr[7:0];
    assign cond = instr[11:9];
    assign offset9 = instr[8:0];
    assign offset4 = instr[3:0];
    
    // Decode opcode
    assign isADD = (opcode == 4'b0000);
    assign isSUB = (opcode == 4'b0001);
    assign isXOR = (opcode == 4'b0010);
    assign isRED = (opcode == 4'b0011);
    assign isSLL = (opcode == 4'b0100);
    assign isSRA = (opcode == 4'b0101);
    assign isROR = (opcode == 4'b0110);
    assign isPADDSB = (opcode == 4'b0111);
    assign isLW = (opcode == 4'b1000);
    assign isSW = (opcode == 4'b1001);
    assign isLLB = (opcode == 4'b1010);
    assign isLHB = (opcode == 4'b1011);
    assign isB = (opcode == 4'b1100);
    assign isBR = (opcode == 4'b1101);
    assign isPCS = (opcode == 4'b1110);
    assign isHLT = (opcode == 4'b1111);
    
    // branch condition eval
    assign neq_cond = ~z_flag;
    assign eq_cond = z_flag;
    assign gt_cond = ~z_flag & ~n_flag;
    assign lt_cond = n_flag;
    assign gte_cond = z_flag | (~z_flag & ~n_flag);
    assign lte_cond = n_flag | z_flag;
    assign ovfl_cond = v_flag;
    assign uncond_cond = 1'b1;
    
	//Check to see what flags to set
	assign c_n = isADD|isSUB;
	assign c_v = isADD|isSUB;
	assign c_z = isADD|isSUB|isXOR|isSLL|isSRA|isROR;
	
	
    // branch condition multiplexer
    wire cond_result;
    assign cond_result = (cond == 3'b000) ? neq_cond :
                         (cond == 3'b001) ? eq_cond :
                         (cond == 3'b010) ? gt_cond :
                         (cond == 3'b011) ? lt_cond :
                         (cond == 3'b100) ? gte_cond :
                         (cond == 3'b101) ? lte_cond :
                         (cond == 3'b110) ? ovfl_cond :
                         uncond_cond;
    
    // set ctrl sigs for each instruction type
    // reg ctrl sigs
    assign srcReg1 = rs;
    assign srcReg2 = (isLLB | isLHB|isLW|isSW) ? rd : rt;
    assign dstReg = (0'b0) ? rt : rd;
    assign regWrite = isADD | isSUB | isXOR | isRED | isSLL | isSRA | 
                     isROR | isPADDSB | isLW | isLLB | isLHB | isPCS;
    
    // ALU ctrl sigs
    assign aluOp = opcode;
    assign aluSrc = isSLL | isSRA | isROR | isLW | isSW;
    
    // mem ctrl sigs
    assign memRead = isLW;
    assign memWrite = isSW;
    
    // branch ctrl signals
    assign branch = isB & cond_result;
    assign branchReg = isBR & cond_result;
    assign jumpAndLink = isPCS;
    assign halt = isHLT;
    
    // immediate gen
    wire [15:0] sll_imm, sra_imm, ror_imm;
    wire [15:0] lw_imm, sw_imm;
    wire [15:0] llb_imm, lhb_imm;
    wire [15:0] b_imm;
    
    // zero-extend shift imediate values
    assign sll_imm = {12'b0, imm4};
    assign sra_imm = {12'b0, imm4};
    assign ror_imm = {12'b0, imm4};
  
    // sign-extend and shift offset for mem ops
    // lw/sw ===> offset is sign-extended and shifted left by 1
    assign lw_imm = {{11{offset4[3]}}, offset4, 1'b0};
    assign sw_imm = {{11{offset4[3]}}, offset4, 1'b0};
    
    assign llb_imm = {8'b0, imm8};
    assign lhb_imm = {8'b0, imm8};
    
    // B instruction, 9-bit offset is sign-extended and shifted left by 1
    assign b_imm = {{6{offset9[8]}}, offset9, 1'b0};
     
    // immediate multiplexer
    assign immediate = (isSLL) ? sll_imm :
                       (isSRA) ? sra_imm :
                       (isROR) ? ror_imm :
                       (isLW) ? lw_imm :
                       (isSW) ? sw_imm :
                       (isLLB | isLHB) ? llb_imm :
                       (isB) ? b_imm :
                      16'h0000;
    
    assign llb = isLLB;
    assign lhb = isLHB;
	
   
endmodule
