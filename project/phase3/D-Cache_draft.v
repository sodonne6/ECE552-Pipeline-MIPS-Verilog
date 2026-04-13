//Peter Davis 4.28.2025
//Charlie Jungwirth 5/3/2025
module DCache(
    input clk,
    input rst_n,
    input [15:0] cpu_address,
    input [15:0] cpu_data_in,
    input cpu_write_en, 
    input cpu_read_en,

    output [15:0] cpu_data_out,
    output cpu_data_valid,//does the data outputting to cpu work

    //will update w/ signals from cache controller
            // Cache data array interface
 
    

    input memory_data_valid,
    input [15:0] memory_data_in,
    output[15:0] memory_data_out,
    output memory_read_en,
    output[15:0] memory_address,
    output memory_write_en,
    output mem_req,
    input mem_grant
    // Cache meta-data array interface
    // input [7:0] meta_idx,
    // input meta_wr_en,
    // input meta_wr_way,
    // input [7:0] meta_tag_in,
    // input meta_valid_in,
    // output [7:0] meta_tag_out0,
    // output meta_valid_out0,
    // output [7:0] meta_tag_out1,
    // output meta_valid_out1,
    // input meta_lru_in,
    // output meta_lru_out

);
    assign memory_data_out = cpu_data_in;
    // MetaDataArray signals
    wire [7:0] meta_data_in;
    wire meta_write_enable;
    wire [127:0] meta_block_enable;
    wire [7:0] meta_data_out;
    wire rst;
    assign rst = ~rst_n;
    // DataArray signals
    wire [15:0] data_array_in;
    wire data_write_enable;
    wire [127:0] data_block_enable;
    wire [7:0] word_enable;
    wire [15:0] data_array_out;

    // Address decoding
    wire [5:0] index;          // 6-bit index (64 sets)
    wire [2:0] block_offset;   // Which word inside 16B block (8 words)
    wire [3:0] offset;         //Which byte inside 16B block (16 bytes)
    wire [5:0] tag;            // 5-bit tag
    wire [15:0] miss_address;
    wire cpu_data_valid_d;
    wire cpu_temp;
    wire [7:0] meta_data_overwrite,meta_data_lruchange;

    parameter IDLE = 2'b00;//waiting
    parameter WRITEDATA = 2'b01;//writing to data
    parameter WAY0 = 2'b10;//just checked from way0
    parameter WAY1 = 2'b11;//checking way 1
    wire[1:0] n_state,state;
    wire victim_way, n_victim_way;
    wire found, n_found;//is there a match, if not we need to go to overwrite

    wire miss_detected,fsm_busy,match;
    wire [2:0] response_count;

    wire meta_lru_out;
    wire[5:0] tag_out;
    wire valid_out;
    wire stall;//stall if need to write but dont have access

    assign index = cpu_address[9:4];
    assign block_offset = cpu_address[3:1];
    assign offset = cpu_address[3:0];
    assign tag = cpu_address[15:10];
	wire prevway;
wire [15:0] cpu_data_out_nxt;
wire FSM_write_data;
wire FSM_write_tag;
wire fsm_started;

dff sttartff(.d(fsm_busy|fsm_started),.q(fsm_started),.wen(1'b1),.rst(rst|(state!=WRITEDATA)),.clk(clk));
wire[6:0] block_shift_old;
    assign miss_detected = ((n_state== WRITEDATA))|(state == WRITEDATA&(~fsm_started));


cache_fill_FSM FSM(
    .clk(clk),
    .rst_n(~rst),
    .miss_detected(miss_detected&mem_grant),
    .memory_data_valid(memory_data_valid),
    .miss_address(miss_address),
    .fsm_busy(fsm_busy),
    .memory_read_en(memory_read_en), //one read signal for the memory
    .write_data_array(FSM_write_data),
    .write_tag_array(FSM_write_tag),
    .memory_address(memory_address),
    .response_countp(response_count)
    );
    


    assign miss_address = {cpu_address[15:4],4'h0};
    // Way selection (for now assume way 0, placeholder)
    wire way_select;
    wire searching;
    assign searching = (state == WAY0)|(n_state == WAY0);
    dff foundff(.d(n_found),.q(found),.rst(rst),.wen(1'b1),.clk(clk));
    dff victimff(.d(n_victim_way),.q(victim_way),.rst(rst),.wen(1'b1),.clk(clk));
    assign n_found = (state==IDLE)? ((cpu_read_en|cpu_write_en)?match:1'b0):
                (state == WAY0) ? match|found:
                found;
    assign n_victim_way = (n_state== WAY0)? (meta_lru_out?victim_way:1'b0)://if checking way 0
    (state== WAY0)?(meta_lru_out?victim_way:1'b1) ://check to see if way 1 is LRU
    victim_way;



    dff stateff[1:0](.d(n_state),.q(state),.clk(clk),.rst(rst),.wen(1'b1));
    assign n_state =    stall? state: 
                    (state== WAY0)? (n_found?IDLE:WAY1):
                    (state==WAY1)? (n_found?IDLE:WRITEDATA):
                    (state== IDLE)? ((cpu_read_en|cpu_write_en)? WAY0:IDLE):
                    (fsm_busy|(~fsm_started))?WRITEDATA:IDLE;//TODO: add write state

    assign way_select = (state==WAY0) ? 1'b1:1'b0;//if just finished with way 1 go to way 0,
    dff pwff(.d(way_select),.q(prevway),.wen(1'b1),.clk(clk),.rst(rst));//previous way, used to read datablocks
    //otherwise continue at way 1

    // Block Enable generation (2 ways × 64 sets = 128 entries)
    wire [127:0] block_enable;
    assign block_enable =   1 <<{index,way_select}; 
    //dff bo [6:0](.q(block_shift_old),.d({index,way_select}),.wen(1'b1),.rst(rst),.clk(clk));
    //(way_select) ? (128'b1 << (index + 64)) : (128'b1 << index);
    //uses 'illegal' operators. Will fix later

    assign meta_block_enable = 1<<((state == WAY1)? {index,victim_way}:{index,way_select});//block_enable;
    assign data_block_enable = 1 <<((state == WRITEDATA)? {index,victim_way}:{index,~found});

    // Word Enable generation (8 possible 2-byte words inside block)
    assign word_enable = {7'h00,(cpu_write_en|cpu_read_en)} << ((state == WRITEDATA)?response_count:block_offset);
    //also illegal

    // MetaData input format (Tag[4:0], Valid[0], LRU[0]) packed into 8 bits
    wire valid_bit = 1'b1; // Always setting valid = 1 when filling for now
    wire lru_bit = way_select; // LRU: 0/1 depending on which way replaced
    
    assign meta_data_overwrite = {tag,valid_bit, 1'b1};//meta data in case we overwrite
    assign meta_data_lruchange= {tag_out,valid_out, 1'b0};//if not correct just mark for replacement

    assign meta_data_in =((state==WAY1)&(n_state==WRITEDATA))? meta_data_overwrite:
        match? meta_data_overwrite: meta_data_lruchange;//set lru bit to 0 if no match

    assign {tag_out,valid_out,meta_lru_out} = meta_data_out;


    assign match = valid_out &(tag_out == tag)&(searching);//Found correct tag
    //dff cpu_outff[15:0](.d(cpu_data_out_nxt),.q(cpu_data_out),.wen(1'b1),.rst(rst),.clk(clk));
    assign cpu_data_out = data_array_out;
    assign cpu_data_valid = n_found;//cpu_temp;
    dff validff(.d(cpu_data_valid_d),.q(cpu_temp),.rst(rst),.clk(clk),.wen(1'b1));

    assign mem_req = ((n_found&(state==WAY0))&(cpu_write_en))|(miss_detected);
    assign stall = mem_req&((n_found&(state==WAY0))&(cpu_write_en))&(~mem_grant);

    
    assign cpu_data_valid_d = (~stall)&match &(cpu_read_en|cpu_write_en);//correct data is about to be read

    assign memory_write_en = cpu_data_valid_d&cpu_write_en;



    MetaDataArray meta_data_array (
        .clk(~clk),//use the opposite edge, so data and meta data are staggered
        .rst(~rst_n),
        .DataIn(meta_data_in),
        .Write(meta_write_enable),
        .BlockEnable(meta_block_enable),
        .DataOut(meta_data_out)
    );

    DataArray data_array (
        .clk(clk),
        .rst(~rst_n),
        .DataIn(data_array_in),
        .Write(data_write_enable),
        .BlockEnable(data_block_enable),
        .WordEnable(word_enable),
        .DataOut(data_array_out)
    );



    // Default control behavior for now
    assign data_array_in =  (cpu_data_valid&cpu_write_en)?  cpu_data_in:memory_data_in;//cpu_data_in; // Write data from CPU to cache/memory
    assign data_write_enable = ((state==WRITEDATA)&FSM_write_data)|(cpu_data_valid&cpu_write_en);//|(match&searching); 
    assign meta_write_enable = searching|((state==WAY1)&(n_state==WRITEDATA));


endmodule
