module d_cache (
    input         clk,
    input         wr_en,         // 1 = write, 0 = read
    input  [15:0] addr,          // Byte address
    input  [15:0] write_data,    // Data from pipeline
    output [15:0] read_data,     // Data to pipeline
    output        hit,           // Cache hit
    output        miss,          // Cache miss
    output        mem_wr_en,     // Forwarded write enable
    output [15:0] mem_addr,      // Forwarded address to memory
    output [15:0] mem_write_data // Forwarded data to memory
);

    // Address breakdown
    wire [4:0] tag    = addr[15:11];
    wire [5:0] index  = addr[10:5];
    wire [2:0] offset = addr[4:2];

    // Cache metadata outputs
    wire [4:0] tag0_out, tag1_out;
    wire       valid0, valid1;
    wire       lru_out;

    // Cache data outputs
    wire [15:0] dout0, dout1;

    // Request tag comparisons
    wire tag0_match, tag1_match;
    assign tag0_match = (tag0_out == tag) & valid0;
    assign tag1_match = (tag1_out == tag) & valid1;

    // Hit logic
    assign hit  = tag0_match | tag1_match;
    assign miss = ~hit;

    // Way select for reading
    wire use_way0 = tag0_match;
    wire use_way1 = tag1_match;

    // Data select logic
    assign read_data = use_way0 ? dout0 :
                       use_way1 ? dout1 :
                       16'hXXXX;

    // Write enable to cache_data_array
    wire write_hit_way0 = wr_en & tag0_match;
    wire write_hit_way1 = wr_en & tag1_match;

    // Forward memory write-through (only on write hit)
    assign mem_wr_en       = wr_en & hit;
    assign mem_addr        = addr;
    assign mem_write_data  = write_data;

    // Instantiate data and meta arrays
    cache_data_array data_array (
        .clk(clk),
        .we(write_hit_way0 | write_hit_way1),
        .index(index),
        .offset(offset),
        .way_sel(write_hit_way1), // write to way1 if that hit
        .data_in(write_data),
        .data_out0(dout0),
        .data_out1(dout1)
    );

    cache_meta_array meta_array (
        .clk(clk),
        .we(1'b0),                // metadata not updated in this module
        .way_sel(1'b0),           // not relevant when write disabled
        .addr(index),
        .tag_in(5'b00000),
        .valid_in(1'b0),
        .lru_in(1'b0),
        .tag_out0(tag0_out),
        .tag_out1(tag1_out),
        .valid_out0(valid0),
        .valid_out1(valid1),
        .lru_out(lru_out)
    );

endmodule

