//interface from thbe fetch stage of the cpu and the I cache

module FICacheInterface(addr,clk,rst,data,data_ready,ren);

    input [15:0] addr;//address to read/write to
    input clk,rst,ren; //clock, reset, read enabled
    output [15:0] data;//instruction pulled
    output data_ready;//assert high when data is valid

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

    assign data_ready = (count==7);
    memory1c_instr instructionMem(.data_out(data), .data_in(16'hxxxx), .addr(addr), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));

endmodule