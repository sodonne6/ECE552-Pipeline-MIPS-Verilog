
module hazard_detection_u(MMRead,Moutaddr,Dreg1,Dreg2,reg1en,reg2en,pc_write,if_id_stall,Xoutaddr, XWriteReg,BR,MWriteReg);
    input MMRead;
    input [3:0]Moutaddr,Xoutaddr;
    input [3:0]Dreg1;// rt register of d
    input [3:0]Dreg2;//rs register of d
    input reg1en;
    input reg2en;
    input BR;
    input MWriteReg,XWriteReg;



    output pc_write,if_id_stall;
    assign if_id_stall = ((~BR)&reg1en &(Dreg1==Xoutaddr)&(Dreg1 != 0)&MMRead)|(reg2en &(Dreg2==Xoutaddr)&(Dreg2 != 0)&MMRead)
    |(BR & (Dreg1 !==0)&(((Dreg1 == Moutaddr) &MWriteReg )|((Dreg1 == Xoutaddr)&XWriteReg))) ;
    assign pc_write = ~if_id_stall;

endmodule

module hazard_detection_unit(
    //inputs ID/EX stage
    input  wire id_ex_memRead,   
    input  wire [3:0] id_ex_rd,        
    //inputs from IF/ID
    input  wire [3:0] if_id_rs,        
    input  wire [3:0] if_id_rt,       
    input  wire if_id_branch,
    //otuputs
    output wire pc_write,  //when high the pc can be updated      
    output wire if_id_write  //when zero.stall the pipeline so the instructiom in IF/Id can not be written to pipelime  
);
    

    //hazard is high when memory read ID/EX is high and either the IF/ID registers match the ID/EX registers 
    
    wire load_hazard, branch_hazard,hazard;
    assign load_hazard   = id_ex_memRead && ((id_ex_rd == if_id_rs) || (id_ex_rd == if_id_rt));
    //branch hazard is high when the insstruction currently in IF/ID is a branch command and the instruction in ID/EX is a load command
    //and the destination reg of the load is the same as either of the sources in the bramch 
    assign branch_hazard = if_id_branch && id_ex_memRead && ((id_ex_rd == if_id_rs) || (id_ex_rd == if_id_rt));
    //if either are high stall the pipeline 
    assign hazard = load_hazard || branch_hazard;

    //output logic - if hazard goes high at any point then the pipeline needs to be stalled
    //TO-DO: insert logic to commuicate the hazards with the rest of the system
    //need outputs to connect to the pipeline modules istantiated in cpu.v 
    //connect to the en inputs for pipeline modules??
   

endmodule