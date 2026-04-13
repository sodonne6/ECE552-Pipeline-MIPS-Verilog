module Register(
    	input clk, input rst, input [15:0] D,
    	input WriteReg, input ReadEnable1, input ReadEnable2,
    	inout [15:0] Bitline1, inout [15:0] Bitline2
);


	BitCell cell_0(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]), .D(D[0]));
	BitCell cell_1(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]), .D(D[1]));
	BitCell cell_2(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]), .D(D[2]));
	BitCell cell_3(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]), .D(D[3]));
	BitCell cell_4(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]), .D(D[4]));
	BitCell cell_5(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]), .D(D[5]));
	BitCell cell_6(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]), .D(D[6]));
	BitCell cell_7(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]), .D(D[7]));
	BitCell cell_8(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]), .D(D[8]));
	BitCell cell_9(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]), .D(D[9]));
	BitCell cell_10(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]), .D(D[10]));
	BitCell cell_11(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]), .D(D[11]));
	BitCell cell_12(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]), .D(D[12]));
	BitCell cell_13(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]), .D(D[13]));
	BitCell cell_14(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]), .D(D[14]));
	BitCell cell_15(.clk(clk), .rst(rst), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]), .D(D[15]));

endmodule
