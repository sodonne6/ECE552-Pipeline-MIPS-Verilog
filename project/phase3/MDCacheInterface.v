module MDCacheInterface(addr,clk,rst,data_in,data_out, data_ready,wen,ren);

    input [15:0] addr;//address to read/write to
    input clk,rst; 
    input [15:0] data_in;
    input wen, ren;//write/read enabled
    output [15:0] data_out;
    output data_ready;//assert high when data is valid
    


    dataMem(.data_out(MReadData), .data_in(write_data), .addr(MALU_Out), .enable(dataMemEn), .wr(MemWrite), .clk(clk), .rst(rst));
endmodule