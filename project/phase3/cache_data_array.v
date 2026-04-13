module cache_data_array (
    input         clk,
    input         we,
    input  [5:0]  index,
    input  [2:0]  offset,
    input         way_sel,
    input  [15:0] data_in,
    output [15:0] data_out0,
    output [15:0] data_out1
);

    wire [15:0] way0_out_0, way0_out_1, way0_out_2, way0_out_3;
    wire [15:0] way0_out_4, way0_out_5, way0_out_6, way0_out_7;

    wire [15:0] way1_out_0, way1_out_1, way1_out_2, way1_out_3;
    wire [15:0] way1_out_4, way1_out_5, way1_out_6, way1_out_7;

    wire en_way0 = we & ~way_sel;
    wire en_way1 = we &  way_sel;

    // Instantiate 16-bit DFFs for each block word in each way
    dff_16bit w0_0 (.clk(clk), .en(en_way0 & (offset == 3'd0)), .d(data_in), .q(way0_out_0));
    dff_16bit w0_1 (.clk(clk), .en(en_way0 & (offset == 3'd1)), .d(data_in), .q(way0_out_1));
    dff_16bit w0_2 (.clk(clk), .en(en_way0 & (offset == 3'd2)), .d(data_in), .q(way0_out_2));
    dff_16bit w0_3 (.clk(clk), .en(en_way0 & (offset == 3'd3)), .d(data_in), .q(way0_out_3));
    dff_16bit w0_4 (.clk(clk), .en(en_way0 & (offset == 3'd4)), .d(data_in), .q(way0_out_4));
    dff_16bit w0_5 (.clk(clk), .en(en_way0 & (offset == 3'd5)), .d(data_in), .q(way0_out_5));
    dff_16bit w0_6 (.clk(clk), .en(en_way0 & (offset == 3'd6)), .d(data_in), .q(way0_out_6));
    dff_16bit w0_7 (.clk(clk), .en(en_way0 & (offset == 3'd7)), .d(data_in), .q(way0_out_7));

    dff_16bit w1_0 (.clk(clk), .en(en_way1 & (offset == 3'd0)), .d(data_in), .q(way1_out_0));
    dff_16bit w1_1 (.clk(clk), .en(en_way1 & (offset == 3'd1)), .d(data_in), .q(way1_out_1));
    dff_16bit w1_2 (.clk(clk), .en(en_way1 & (offset == 3'd2)), .d(data_in), .q(way1_out_2));
    dff_16bit w1_3 (.clk(clk), .en(en_way1 & (offset == 3'd3)), .d(data_in), .q(way1_out_3));
    dff_16bit w1_4 (.clk(clk), .en(en_way1 & (offset == 3'd4)), .d(data_in), .q(way1_out_4));
    dff_16bit w1_5 (.clk(clk), .en(en_way1 & (offset == 3'd5)), .d(data_in), .q(way1_out_5));
    dff_16bit w1_6 (.clk(clk), .en(en_way1 & (offset == 3'd6)), .d(data_in), .q(way1_out_6));
    dff_16bit w1_7 (.clk(clk), .en(en_way1 & (offset == 3'd7)), .d(data_in), .q(way1_out_7));

    // Output mux (combinational logic only)
    assign data_out0 = (offset == 3'd0) ? way0_out_0 :
                       (offset == 3'd1) ? way0_out_1 :
                       (offset == 3'd2) ? way0_out_2 :
                       (offset == 3'd3) ? way0_out_3 :
                       (offset == 3'd4) ? way0_out_4 :
                       (offset == 3'd5) ? way0_out_5 :
                       (offset == 3'd6) ? way0_out_6 :
                                          way0_out_7;

    assign data_out1 = (offset == 3'd0) ? way1_out_0 :
                       (offset == 3'd1) ? way1_out_1 :
                       (offset == 3'd2) ? way1_out_2 :
                       (offset == 3'd3) ? way1_out_3 :
                       (offset == 3'd4) ? way1_out_4 :
                       (offset == 3'd5) ? way1_out_5 :
                       (offset == 3'd6) ? way1_out_6 :
                                          way1_out_7;

endmodule
