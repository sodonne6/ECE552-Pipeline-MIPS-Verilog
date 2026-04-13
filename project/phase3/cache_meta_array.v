module cache_meta_array (
    input         clk,
    input         we,
    input         way_sel,
    input  [5:0]  addr,
    input  [4:0]  tag_in,
    input         valid_in,
    input         lru_in,
    output [4:0]  tag_out0,
    output [4:0]  tag_out1,
    output        valid_out0,
    output        valid_out1,
    output        lru_out
);

    wire [4:0] tag0, tag1;

    dff t0_0 (.clk(clk), .en(we & ~way_sel), .d(tag_in[0]), .q(tag0[0]));
    dff t0_1 (.clk(clk), .en(we & ~way_sel), .d(tag_in[1]), .q(tag0[1]));
    dff t0_2 (.clk(clk), .en(we & ~way_sel), .d(tag_in[2]), .q(tag0[2]));
    dff t0_3 (.clk(clk), .en(we & ~way_sel), .d(tag_in[3]), .q(tag0[3]));
    dff t0_4 (.clk(clk), .en(we & ~way_sel), .d(tag_in[4]), .q(tag0[4]));

    dff t1_0 (.clk(clk), .en(we &  way_sel), .d(tag_in[0]), .q(tag1[0]));
    dff t1_1 (.clk(clk), .en(we &  way_sel), .d(tag_in[1]), .q(tag1[1]));
    dff t1_2 (.clk(clk), .en(we &  way_sel), .d(tag_in[2]), .q(tag1[2]));
    dff t1_3 (.clk(clk), .en(we &  way_sel), .d(tag_in[3]), .q(tag1[3]));
    dff t1_4 (.clk(clk), .en(we &  way_sel), .d(tag_in[4]), .q(tag1[4]));

    dff v0 (.clk(clk), .en(we & ~way_sel), .d(valid_in), .q(valid_out0));
    dff v1 (.clk(clk), .en(we &  way_sel), .d(valid_in), .q(valid_out1));

    dff lru (.clk(clk), .en(we), .d(lru_in), .q(lru_out));

    assign tag_out0 = tag0;
    assign tag_out1 = tag1;

endmodule

