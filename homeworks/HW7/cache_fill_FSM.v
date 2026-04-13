module cache_fill_FSM(
    input clk,
    input rst_n,
    input miss_detected,
    input memory_data_valid,
    input [15:0] miss_address,
    output fsm_busy,
    output write_data_array,
    output write_tag_array,
    output [15:0] memory_address
);

    //state logic -> store curr state and next state in a flop in order to transition when needded 
    wire curr_state, next_state; //IDLE = 0 AND WAIT = 1
    dff state_ff(.clk(clk), .rst(~rst_n), .q(curr_state), .d(next_state), .wen(1'b1));

    //FSM busy logic
	// fsm_busy high when in WAIT STATE or if busy_out is high from pervious cycle
    wire busy_ff_out, busy_ff_in;
    dff busy_ff(.clk(clk), .rst(~rst_n), .q(busy_ff_out), .d(busy_ff_in), .wen(1'b1));
    assign fsm_busy = busy_ff_out | next_state;

    //keeps track of the number of words that have been read so far 
	//16 bytes in total
    wire [3:0] word_cnt, word_cnt_next;
    wire [3:0] word_cnt_inc;
	//store count value -> reset when rst_n is low or when counter reaches 8 -> meaning all bytes have been read
	//flip flop provided is 1 bit wide so by instantiating 4 you can store the entire count value 
    dff word_count_0(.clk(clk), .rst(~rst_n | (word_cnt == 4'b1000)), .q(word_cnt[0]), .d(word_cnt_next[0]), .wen(curr_state));
    dff word_count_1(.clk(clk), .rst(~rst_n | (word_cnt == 4'b1000)), .q(word_cnt[1]), .d(word_cnt_next[1]), .wen(curr_state));
    dff word_count_2(.clk(clk), .rst(~rst_n | (word_cnt == 4'b1000)), .q(word_cnt[2]), .d(word_cnt_next[2]), .wen(curr_state));
    dff word_count_3(.clk(clk), .rst(~rst_n | (word_cnt == 4'b1000)), .q(word_cnt[3]), .d(word_cnt_next[3]), .wen(curr_state));
	//resuse adder to increment the word counter
    add_sub_4 wordcnt_adder(
        .A(word_cnt),
        .B(4'b0000),
        .Cin(1'b1),
        .Sum(word_cnt_inc),
        .Ovfl(), .PG(), .GG() //unused outputs -> keep unconnected
    );

    //if in WAIT state and memory returns a word -> increment -> if not keep current count val
    assign word_cnt_next = (curr_state & memory_data_valid) ? word_cnt_inc : word_cnt;

    //calculate address for next 2 bytes in memory
    wire [3:0] byte_offset;
    wire [15:0] aligned_addr;
    assign byte_offset = word_cnt; ////offset is lower bits of the cuurent word count bit shifted left by 1 
    assign aligned_addr = {miss_address[15:4], byte_offset[2:0], 1'b0}; 
	//assign address to memory address output as lomg as reset isnt low
    assign memory_address = rst_n ? aligned_addr : 16'b0;

    
    wire done = (word_cnt == 4'b1000); //assert done when count is full
    wire chunks_left = curr_state & ~done;	//chunk left high when in WAIT state and transaction isnt done

    assign next_state = ~curr_state ? miss_detected : chunks_left; //transiton to WAIT if the current state is IDLE and a miss is detected, else if in WAIT state and chunks are left -> stay in WAIT state
    assign busy_ff_in = ~curr_state ? miss_detected : chunks_left;
	//set write data tp high when in WAIT state and memory data is valid
	//set write tag to high when in WAIT state and count is full and memory data is valid
    assign write_data_array = curr_state & memory_data_valid;
    assign write_tag_array  = curr_state & (word_cnt == 4'b0111) & memory_data_valid;

endmodule
