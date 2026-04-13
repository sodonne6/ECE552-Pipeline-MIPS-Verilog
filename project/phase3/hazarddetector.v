module hazard_detection(
    // pipelie stage info
    input wire [3:0] id_opcode,        
    input wire [3:0] id_rs_addr,         
    input wire [3:0] id_rt_addr,        
    input wire id_uses_rs,               // wether instruction in ID uses Rs
    input wire id_uses_rt,               // whether instruction in ID uses Rt
    input wire id_is_branch,             // whether instruction in ID is a branch
    input wire id_is_br_reg,             // whethr instruction in ID is a BR 
    
    // ex instr info
    input wire [3:0] ex_opcode,          
    input wire [3:0] ex_rd_addr,         
    input wire ex_writes_reg,           
    input wire ex_is_load,              
    
    // mem instrinfo
    input wire [3:0] mem_opcode,         
    input wire [3:0] mem_rd_addr,       
    input wire mem_writes_reg,         
    input wire mem_is_load,             
    
    input wire branch_taken,            
    
    // forwarding availability
    input wire ex_mem_forward_available, // Whether EX-to-MEM forwarding is available
    input wire mem_ex_forward_available, // Whether MEM-to-EX forwarding is available
    input wire mem_mem_forward_available,// Whether MEM-to-MEM forwarding is available
    
    // ctrl outputs
    output wire stall_if,                // Stall instruction fetch
    output wire stall_id,                // Stall instruction decode
    output wire flush_if_id,             // Flush IF/ID pipeline register
    output wire flush_id_ex              // Flush ID/EX pipeline register
);

    // checlk load-use data hazards
    wire load_use_hazard_rs, load_use_hazard_rt;
    wire branch_data_hazard_rs, branch_data_hazard_rt;
    
    // load-use hazard on Rs => needs stall if EX stage has load that targets Rs in ID
    assign load_use_hazard_rs = id_uses_rs & ex_is_load & (ex_rd_addr == id_rs_addr) & (id_rs_addr != 4'b0000);
    
    // load-use hazard on Rt => needs stall if EX stage has load that targets Rt in ID
    assign load_use_hazard_rt = id_uses_rt & ex_is_load & (ex_rd_addr == id_rt_addr) & (id_rt_addr != 4'b0000);
    
    // branch data hazards => ID stage branch depends on result from EX or MEM stage
    assign branch_data_hazard_rs = id_is_branch & id_uses_rs & 
                ((ex_writes_reg & (ex_rd_addr == id_rs_addr) & (id_rs_addr != 4'b0000)) |
                 (mem_writes_reg & (mem_rd_addr == id_rs_addr) & (id_rs_addr != 4'b0000) & ex_is_load));
                 
    assign branch_data_hazard_rt = id_is_branch & id_uses_rt & 
                ((ex_writes_reg & (ex_rd_addr == id_rt_addr) & (id_rt_addr != 4'b0000)) |
                 (mem_writes_reg & (mem_rd_addr == id_rt_addr) & (id_rt_addr != 4'b0000) & ex_is_load));
    
    // BR instruction special case - cannt forward to BR instruction for address computation
    wire br_reg_hazard;
    assign br_reg_hazard = id_is_br_reg & 
                ((ex_writes_reg & (ex_rd_addr == id_rs_addr) & (id_rs_addr != 4'b0000)) |
                 (mem_writes_reg & (mem_rd_addr == id_rs_addr) & (id_rs_addr != 4'b0000)));
                 
    // stall sisg
    wire data_hazard_stall;
    assign data_hazard_stall = load_use_hazard_rs | load_use_hazard_rt | 
                               branch_data_hazard_rs | branch_data_hazard_rt | 
                               br_reg_hazard;
                               
    // ctrl hazard => branch taken signals
    wire control_hazard_flush;
    assign control_hazard_flush = branch_taken;
    
    // output ctrl sigs
    assign stall_if = data_hazard_stall;
    assign stall_id = data_hazard_stall;
    assign flush_if_id = control_hazard_flush;
    assign flush_id_ex = control_hazard_flush | data_hazard_stall;

endmodule
