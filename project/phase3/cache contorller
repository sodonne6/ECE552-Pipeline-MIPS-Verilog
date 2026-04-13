module cache_controller(
    // System signals
    input clk,
    input rst_n,
    
    // Processor interface
    input [15:0] addr,
    input rd_req,
    input wr_req,
    input [15:0] data_in,
    output [15:0] data_out,
    output stall,
    
    // Cache data array interface
    output [15:0] cache_addr,
    output cache_wr_en,
    output [15:0] cache_data_in,
    input [15:0] cache_data_out,
    
    // Cache meta-data array interface
    output [7:0] meta_idx,
    output meta_wr_en,
    output meta_wr_way,
    output [7:0] meta_tag_in,
    output meta_valid_in,
    input [7:0] meta_tag_out0,
    input meta_valid_out0,
    input [7:0] meta_tag_out1,
    input meta_valid_out1,
    output meta_lru_in,
    input meta_lru_out,
    
    // Memory interface signals
    output [15:0] mem_addr,
    output mem_rd_req,
    output mem_wr_req,
    output [15:0] mem_data_out,
    input [15:0] mem_data_in,
    input mem_data_valid,
    
    // Arbitration interface
    output mem_access_req,
    input mem_access_grant
);

    // State definitions
    parameter IDLE = 3'h0;
    parameter COMPARE_TAG = 3'h1;
    parameter ALLOCATE_INIT = 3'h2;
    parameter ALLOCATE_WAIT = 3'h3;
    parameter ALLOCATE_RECEIVE = 3'h4;
    parameter UPDATE_CACHE = 3'h5;
    parameter WRITE_META = 3'h6;
    parameter COMPLETE = 3'h7;
    
    // Current and next state registers
    reg [2:0] curr_state, next_state;
    
    // Address breakdown
    wire [7:0] addr_tag;
    wire [5:0] addr_idx;
    wire [1:0] addr_word_offset;
    wire [2:0] addr_byte_offset;
    
    // Tag comparison results
    wire tag_match_way0, tag_match_way1, cache_hit;
    wire victim_way;
    
    // Counters for block transfer
    reg [2:0] word_count;
    wire word_count_done;
    
    // Saved request information
    reg [15:0] saved_addr;
    reg [15:0] saved_data;
    reg saved_is_write;
    
    // Cache block buffer for allocation
    reg [15:0] block_buffer [0:7]; // 8 words per block (16 bytes)
    
    // Extract address components
    assign addr_tag = addr[15:8];
    assign addr_idx = addr[7:2];
    assign addr_word_offset = addr[1:0];
    assign addr_byte_offset = {addr[1:0], 1'b0}; // Align to 2-byte boundary
    
    // Tag comparison
    assign tag_match_way0 = (meta_valid_out0 & (meta_tag_out0 == saved_addr[15:8]));
    assign tag_match_way1 = (meta_valid_out1 & (meta_tag_out1 == saved_addr[15:8]));
    assign cache_hit = tag_match_way0 | tag_match_way1;
    
    // Victim way selection (based on LRU)
    assign victim_way = (meta_valid_out0 == 1'b0) ? 1'b0 :
                        (meta_valid_out1 == 1'b0) ? 1'b1 :
                        meta_lru_out;
    
    // Word counter control
    assign word_count_done = (word_count == 3'h7);
    
    // Meta-data array signals
    assign meta_idx = addr_idx;
    assign meta_tag_in = saved_addr[15:8];
    assign meta_valid_in = 1'b1;
    
    // Set the LRU bit to indicate the other way was used most recently
    assign meta_lru_in = tag_match_way0 ? 1'b1 : 1'b0;
    
    // Which way to write to during allocation
    assign meta_wr_way = victim_way;
    
    // Processor interface
    assign stall = (curr_state != IDLE) & (curr_state != COMPLETE);
    
    // Memory interface
    assign mem_access_req = (curr_state == ALLOCATE_INIT) | (curr_state == ALLOCATE_WAIT);
    
    // Memory write for write-through
    assign mem_wr_req = (curr_state == COMPARE_TAG) & saved_is_write & cache_hit;
    
    // Memory read for allocation
    assign mem_rd_req = (curr_state == ALLOCATE_WAIT) & mem_access_grant;
    
    // State transition logic
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    // Word counter logic
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n)
            word_count <= 3'h0;
        else if (curr_state == ALLOCATE_INIT)
            word_count <= 3'h0;
        else if (curr_state == ALLOCATE_RECEIVE & mem_data_valid)
            word_count <= word_count + 3'h1;
    end
    
    // Save request information
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            saved_addr <= 16'h0000;
            saved_data <= 16'h0000;
            saved_is_write <= 1'b0;
        end
        else if (curr_state == IDLE & (rd_req | wr_req)) begin
            saved_addr <= addr;
            saved_data <= data_in;
            saved_is_write <= wr_req;
        end
    end
    
    // Block buffer for receiving allocation data
    always @(posedge clk) begin
        if (curr_state == ALLOCATE_RECEIVE & mem_data_valid)
            block_buffer[word_count] <= mem_data_in;
    end
    
    // Memory address generation
    assign mem_addr = (curr_state == COMPARE_TAG) ? saved_addr :
                      (curr_state == ALLOCATE_WAIT | curr_state == ALLOCATE_RECEIVE) ? 
                      {saved_addr[15:4], word_count, 1'b0} : 16'h0000;
    
    // Memory data for write-through
    assign mem_data_out = saved_data;
    
    // Cache data array signals
    assign cache_addr = (curr_state == IDLE | curr_state == COMPARE_TAG) ? 
                        {addr_idx, addr_word_offset} :
                        (curr_state == UPDATE_CACHE) ? 
                        {saved_addr[7:2], word_count[1:0]} : 8'h00;
    
    assign cache_wr_en = (curr_state == COMPARE_TAG & saved_is_write & cache_hit) |
                         (curr_state == UPDATE_CACHE);
    
    assign cache_data_in = (curr_state == COMPARE_TAG) ? saved_data :
                           (curr_state == UPDATE_CACHE) ? block_buffer[word_count[1:0]] : 16'h0000;
    
    // Output data mux
    assign data_out = cache_data_out;
    
    // Main state machine
    always @(*) begin
        // Default next state
        next_state = curr_state;
        
        // Default control signals
        meta_wr_en = 1'b0;
        
        case (curr_state)
            IDLE: begin
                if (rd_req | wr_req)
                    next_state = COMPARE_TAG;
            end
            
            COMPARE_TAG: begin
                if (cache_hit) begin
                    // Write-through happens in this state directly
                    // Update LRU on hit
                    meta_wr_en = 1'b1;
                    next_state = COMPLETE;
                end
                else begin
                    // Start allocation on miss
                    next_state = ALLOCATE_INIT;
                end
            end
            
            ALLOCATE_INIT: begin
                // Request memory access from arbiter
                if (mem_access_grant)
                    next_state = ALLOCATE_WAIT;
            end
            
            ALLOCATE_WAIT: begin
                // Wait for first data to arrive
                if (mem_data_valid)
                    next_state = ALLOCATE_RECEIVE;
            end
            
            ALLOCATE_RECEIVE: begin
                // Receive data from memory (8 words, 16 bytes)
                if (word_count_done & mem_data_valid)
                    next_state = UPDATE_CACHE;
            end
            
            UPDATE_CACHE: begin
                // Write the received block to cache
                if (word_count_done)
                    next_state = WRITE_META;
                else begin
                    word_count <= word_count + 3'h1;
                end
            end
            
            WRITE_META: begin
                // Update metadata (tag, valid, LRU)
                meta_wr_en = 1'b1;
                next_state = COMPARE_TAG; // Retry the original request
            end
            
            COMPLETE: begin
                next_state = IDLE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
