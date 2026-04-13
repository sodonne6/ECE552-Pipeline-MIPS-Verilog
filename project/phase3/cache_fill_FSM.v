module cache_fill_FSM(
    input clk,
    input rst_n,
    input miss_detected,
    input memory_data_valid,
    input [15:0] miss_address,
    output fsm_busy,
    output memory_read_en, //one read signal for the memory
    output write_data_array,
    output write_tag_array,
    output [15:0] memory_address,
    output [2:0]  response_countp
);
    wire [3:0] response_count;
    assign response_countp = response_count[2:0];
    //state logic -> store curr state and next state in a flop in order to transition when needded 
    wire curr_state, next_state; //IDLE = 0 AND WAIT = 1
    dff state_ff(.clk(clk), .rst(~rst_n), .q(curr_state), .d(next_state), .wen(1'b1));

    //FSM busy logic
	// fsm_busy high when in WAIT STATE or if busy_out is high from pervious cycle
    /*
    wire busy_ff_out, busy_ff_in;
    dff busy_ff(.clk(clk), .rst(~rst_n), .q(busy_ff_out), .d(busy_ff_in), .wen(1'b1));
    assign fsm_busy = busy_ff_out | next_state;
    */
    assign fsm_busy = curr_state; //stays high until after the last read is done
    assign memory_read_en = curr_state; //one request per clk cycle while in wait
    //keeps track of the number of words that have been read so far 
	//16 bytes in total

    //reuqest counter -> 4 bits to count up to 16 bytes
    //increment every clock cycle when in WAIT state 
    wire [3:0] word_cnt; //word_cnt_next;
    wire [3:0] word_cnt_inc;

    wire word_last = (word_cnt[2:0] == 3'b111);
    wire word_cnt_en = curr_state & ~word_last; //stop at 7 -> 8 words in total
	//store count value -> reset when rst_n is low or when counter reaches 8 -> meaning all bytes have been read
	//flip flop provided is 1 bit wide so by instantiating 4 you can store the entire count value 
    dff word_count_0(.clk(clk), .rst(~rst_n | ~curr_state), .q(word_cnt[0]), .d(word_cnt_inc[0]), .wen(word_cnt_en));
    dff word_count_1(.clk(clk), .rst(~rst_n | ~curr_state), .q(word_cnt[1]), .d(word_cnt_inc[1]), .wen(word_cnt_en));
    dff word_count_2(.clk(clk), .rst(~rst_n | ~curr_state), .q(word_cnt[2]), .d(word_cnt_inc[2]), .wen(word_cnt_en));
    dff word_count_3(.clk(clk), .rst(~rst_n | ~curr_state), .q(word_cnt[3]), .d(word_cnt_inc[3]), .wen(word_cnt_en));
	//resuse adder to increment the word counter
    add_sub_4 wordcnt_adder(
        .A(word_cnt),
        .B(4'b0000),
        .Cin(1'b1),
        .Sum(word_cnt_inc),
        .Ovfl(), .PG(), .GG(),.Cout()//unused outputs -> keep unconnected
    );

    //if in WAIT state and memory returns a word -> increment -> if not keep current count val
    //assign word_cnt_next = (curr_state & memory_data_valid) ? word_cnt_inc : word_cnt;
    //second counter to let the cache read faster -> read and response times can vary
    //repsonse timer -> increments when data valid is high
    //detect when 8th word arrives

    wire [3:0]  response_count_next;//,response_count;
    wire response_last = (response_count[2:0] == 3'b111);
    wire response_count_en = memory_data_valid & ~response_last;

    dff resp0(.clk(clk), .rst(~rst_n | ~curr_state), .q(response_count[0]), .d(response_count_next[0]), .wen(response_count_en));
    dff resp1(.clk(clk), .rst(~rst_n | ~curr_state), .q(response_count[1]), .d(response_count_next[1]), .wen(response_count_en));
    dff resp2(.clk(clk), .rst(~rst_n | ~curr_state), .q(response_count[2]), .d(response_count_next[2]), .wen(response_count_en));
    dff resp3(.clk(clk), .rst(~rst_n | ~curr_state), .q(response_count[3]), .d(response_count_next[3]), .wen(response_count_en));

    //use adder for counter increment
    add_sub_4 response_adder(
        .A(response_count),
        .B(4'b0000),
        .Cin(1'b1),
        .Sum(response_count_next),
        .Ovfl(), .PG(), .GG(),.Cout() //unused outputs -> keep unconnected
    );
    //tag + index + word count and lsb is 0 for word alignment
    assign memory_address = {miss_address[15:4],word_cnt[2:0],1'b0};
    
    //write data and tag array logic
    assign write_data_array = curr_state & memory_data_valid; //every time data is valid and in WAIT state write to data array
    assign write_tag_array = curr_state & memory_data_valid & response_last; //only write tag when all data has been written

    wire done = memory_data_valid & response_last; //done when all data has been written and response is valid

    //fsm logic 
    assign next_state = (curr_state == 1'b0) ? miss_detected : (done ? 1'b0 : 1'b1);

endmodule
