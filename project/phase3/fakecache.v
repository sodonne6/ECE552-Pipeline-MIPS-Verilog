module fake_cache(maddr,clk,rst,mdata_in,mwen,mren,mdata_out,mdata_ready,iaddr,iren,idata,idata_ready);


    input [15:0] maddr;//address to read/write to
    input clk,rst; 
    input [15:0] mdata_in;
    input mwen, mren;//write/read enabled
    output [15:0] mdata_out;
    output mdata_ready;//assert high when data is valid

    input [15:0] iaddr;//address to read/write to
    input iren; //clock, reset, read enabled
    output [15:0] idata;//instruction pulled
    output idata_ready;//assert high when data is valid


    reg[2:0] count;
    reg[3:0] count2;
    always @(posedge clk,posedge rst)begin

        if(rst)begin
            count <= 0;
            count2<= 0;
        end
        else begin
            if (count == 7) begin
                count2 = count2+1;
                count = count2;
            end
            else begin
                count = count+1;

            end
        end



    end

    assign idata_ready = (count==7);
    assign mdata_ready = (count==6);

    memory1c_instr dataMem(.data_out(idata), .data_in(16'hxxxx), .addr(iaddr), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));
    memory1c_instr instructionMem(.data_out(mdata_out), .data_in(mdata_in), .addr(maddr), .enable(1'b1), .wr(mwen), .clk(clk), .rst(rst));

endmodule