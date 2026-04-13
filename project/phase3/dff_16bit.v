module dff_16bit (
    input         clk,
    input         en,
    input  [15:0] d,
    output [15:0] q
);

    dff dff0  (.clk(clk), .en(en), .d(d[0]),  .q(q[0]));
    dff dff1  (.clk(clk), .en(en), .d(d[1]),  .q(q[1]));
    dff dff2  (.clk(clk), .en(en), .d(d[2]),  .q(q[2]));
    dff dff3  (.clk(clk), .en(en), .d(d[3]),  .q(q[3]));
    dff dff4  (.clk(clk), .en(en), .d(d[4]),  .q(q[4]));
    dff dff5  (.clk(clk), .en(en), .d(d[5]),  .q(q[5]));
    dff dff6  (.clk(clk), .en(en), .d(d[6]),  .q(q[6]));
    dff dff7  (.clk(clk), .en(en), .d(d[7]),  .q(q[7]));
    dff dff8  (.clk(clk), .en(en), .d(d[8]),  .q(q[8]));
    dff dff9  (.clk(clk), .en(en), .d(d[9]),  .q(q[9]));
    dff dff10 (.clk(clk), .en(en), .d(d[10]), .q(q[10]));
    dff dff11 (.clk(clk), .en(en), .d(d[11]), .q(q[11]));
    dff dff12 (.clk(clk), .en(en), .d(d[12]), .q(q[12]));
    dff dff13 (.clk(clk), .en(en), .d(d[13]), .q(q[13]));
    dff dff14 (.clk(clk), .en(en), .d(d[14]), .q(q[14]));
    dff dff15 (.clk(clk), .en(en), .d(d[15]), .q(q[15]));

endmodule

