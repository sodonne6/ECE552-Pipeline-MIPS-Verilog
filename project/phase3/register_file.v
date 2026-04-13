//Peter Davis
//HW4, ECE 552
//16-bit Register File Implementation

module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
    wire [15:0] w8, w4, w2, w1;

    assign w8 = (RegId[3]) ? (16'b1 << 8) : 16'b1;
    assign w4 = (RegId[2]) ? (w8 << 4) : w8;
    assign w2 = (RegId[1]) ? (w4 << 2) : w4;
    assign w1 = (RegId[0]) ? (w2 << 1) : w2;

    assign Wordline = w1;
endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
    wire [15:0] w8, w4, w2, w1;

    assign w8 = (RegId[3]) ? (16'b1 << 8) : 16'b1;
    assign w4 = (RegId[2]) ? (w8 << 4) : w8;
    assign w2 = (RegId[1]) ? (w4 << 2) : w4;
    assign w1 = (RegId[0]) ? (w2 << 1) : w2;

    assign Wordline = WriteReg ? w1 : 16'b0;
endmodule

module BitCell(input clk, input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);
    wire q;
    dff dff_inst(.q(q), .d(D), .wen(WriteEnable), .clk(~clk), .rst(rst));
    assign Bitline1 = ReadEnable1 ? q : 1'bz;
    assign Bitline2 = ReadEnable2 ? q : 1'bz;
endmodule

module Register(
    input clk, 
    input rst, 
    input [15:0] D, 
    input WriteReg, 
    input ReadEnable1, 
    input ReadEnable2, 
    inout [15:0] Bitline1, 
    inout [15:0] Bitline2
);   
    BitCell bitcell_inst[15:0](.clk(clk), 
                .rst(rst), 
                .D(D), 
                .WriteEnable(WriteReg), 
                .ReadEnable1(ReadEnable1), 
                .ReadEnable2(ReadEnable2), 
                .Bitline1(Bitline1), 
                .Bitline2(Bitline2)
        );
endmodule

module RegisterFile(
    input clk,
    input rst,
    input [3:0] SrcReg1,
    input [3:0] SrcReg2,
    input [3:0] DstReg,
    input WriteReg,
    input [15:0] DstData,
    inout [15:0] SrcData1,
    inout [15:0] SrcData2
);
    wire [15:0] read1_enable, read2_enable, write_enable;
    wire [15:0] bitlines1 ;//[15:0];
    wire [15:0] bitlines2;//[15:0];
    
    ReadDecoder_4_16 read_decoder1(.RegId(SrcReg1), .Wordline(read1_enable));
    ReadDecoder_4_16 read_decoder2(.RegId(SrcReg2), .Wordline(read2_enable));
    WriteDecoder_4_16 write_decoder(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_enable));
    
    Register reg_inst[15:0](
                .clk(clk),
                .rst(rst),
                .D(DstData),
                .WriteReg(write_enable),
                .ReadEnable1(read1_enable),
                .ReadEnable2(read2_enable),
                .Bitline1(bitlines1),
                .Bitline2(bitlines2)
            );
    
    //hard code register 0 to 0
    //assign bitlines1[0] = 16'b0;
    //assign bitlines2[0] = 16'b0;
    
    assign SrcData1 = bitlines1;//(WriteReg && (SrcReg1 == DstReg)) ? DstData : bitlines1[SrcReg1];
    assign SrcData2 = bitlines2;//(WriteReg && (SrcReg2 == DstReg)) ? DstData : bitlines2[SrcReg2];
endmodule

// module dff (q, d, wen, clk, rst);

//     output         q; //DFF output
//     input          d; //DFF input
//     input 	   wen; //Write Enable
//     input          clk; //Clock
//     input          rst; //Reset (used synchronously)

//     reg            state;

//     assign q = state;

//     always @(posedge clk) begin
//       state <= rst ? 0 : (wen ? d : state);
//     end

// endmodule
