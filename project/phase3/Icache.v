module Icache(
    input clk,
    input rst_n,

    input [15:0] cpu_addr,
    input cpu_read_en,
    output [15:0] cpu_data_out,
    output cpu_data_valid, //does the data outputting to cpu work

    //refill logic 
    input [15:0] cache_data_out;
    output [15:0] cache_addr;
    output cache_wr_en;         // 1 = write, 0 = read
    //output hit,miss

    //MetaDataArray interface
    output wire [7:0]  meta_idx,
    output wire meta_wr_en,
    output wire meta_wr_way,
    output wire [7:0] meta_tag_in,
    output wire meta_valid_in,
    input  wire [7:0] meta_tag_out0,
    input  wire meta_valid_out0,
    input  wire [7:0] meta_tag_out1,
    input  wire meta_valid_out1,
    input  wire meta_lru_out,

    //— Memory side (shared with DCache arbiter)
    input  wire memory_data_valid,
    input  wire [15:0] memory_data,
    output wire memory_read_en
)
    //on a miss the pipeline flushes or nops are used to stall
    //no dirty bit is used in this cache
    //cache is 2-way set associative, 64 sets, 16 bytes per block
    
    //address decoding (based off dcache i assume they need to be the same)
    //16 bit address [15:0] is tag [9:4] index and [3:0] word and lsb is byte

    /*
     assign index = cpu_address[9:4];
    assign block_offset = cpu_address[3:1];
    assign offset = cpu_address[3:0];
    assign tag = cpu_address[15:10];
    */

    //is block enable logic the same as d_cache?
    

    assign tag = cpu_address[15:10];
    assign index = cpu_address[9:4];
    assign block_offset = cpu_address[3:1];
    assign offset = cpu_address[3:0];

    //hit or miss logic read only 
    wire hit_way0, hit_way1;
    wire hit;
    wire miss;

    assign hit_way0 = meta_valid_out0 && (meta_tag_out0 == tag);
    assign hit_way0 = meta_valid_out1 && (meta_tag_out1 == tag);
    assign hit = (hit_way0 || hit_way1) && !fsm_busy; //hit if either way is valid and tag matches but only if fsm not busy
    assign miss = cpu_read_en && !hit && !fsm_busy; //miss if read is enabled and not a hit and fsm not busy


    //DataArray signal
    assign cache_addr = {cpu_address[15:1], 1'b0}; //align to 2-byte boundary
    assign cache_wr_en = (cpu_read_en && hit) ? 1'b0 : 1'b1; //write if not a hit, read if a hit
    DataArray iDataArray(
        .clk(~clk),
        .rst_n(~rst_n),
        .DataIn(memory_data),
        .Write(cache_wr_en),
        .BlockEnable(block_enable),
        .WordEnable(word_enable),
        .DataOut(cache_data_out)
    );

    MetaDataArray iMetaDataArray(
        .clk(clk),
        .rst_n(rst_n),
        .DataIn({tag,meta_valid_in, 1'b0}),
        .Write(meta_wr_en),
        .BlockEnable(block_enable),
        .DataOut()//not needed for icache?
    );


    wire miss_detected;
    wire fsm_busy;

    cache_fill_FSM iCacheFillFSM(
        .clk(clk),
        .rst_n(rst_n),
        .miss_detected(miss_detected),
        .memory_data_valid(memory_data_valid),
        .miss_address({tag,index,4'b0000}), //address to be written to
        .fsm_busy(fsm_busy)
        .memory_read_en(memory),
        .write_data_array(write_data_array),
        .write_tag_array(write_tag_array),
        .memory_address()
    );





endmodule

