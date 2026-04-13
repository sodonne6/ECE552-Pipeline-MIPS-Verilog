module memory_arbitration(
    // System signals
    input clk,
    input rst_n,
    
    // I-cache request interface
    input icache_req,
    output icache_grant,
    
    // D-cache request interface
    input dcache_req,
    output dcache_grant
);

    // Arbitration state register
    reg state;
    
    // State definitions
    parameter IDLE = 1'b0;
    parameter BUSY = 1'b1;
    
    // Internal tracking registers
    reg current_grant_to_icache;
    
    // Grant signals
    assign icache_grant = icache_req & ((state == IDLE&(~dcache_req)) | (state == BUSY & current_grant_to_icache));
    assign dcache_grant = dcache_req & (state == IDLE | (state == BUSY & ~current_grant_to_icache));
    
    // Arbitration FSM
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            current_grant_to_icache <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    // Priority to D-cache over I-cache
                    if (dcache_req) begin
                        state <= BUSY;
                        current_grant_to_icache <= 1'b0;
                    end
                    else if (icache_req) begin
                        state <= BUSY;
                        current_grant_to_icache <= 1'b1;
                    end
                end
                
                BUSY: begin
                    // Stay busy as long as the current requester still wants access
                    if ((current_grant_to_icache & ~icache_req) | 
                        (~current_grant_to_icache & ~dcache_req)) begin
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
