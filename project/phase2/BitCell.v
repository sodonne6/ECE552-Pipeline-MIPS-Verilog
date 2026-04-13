module BitCelli(
    input clk, 
    input rst, 
    input D, 
    input WriteEnable, 
    input ReadEnable1, 
    input ReadEnable2,
    inout Bitline1, 
    inout Bitline2
);
    //hold data in flop
    reg Q;
    
    //flip flop for memory - when enable is high load new value
    always @(posedge (clk),rst) begin
        if (rst)
            Q <= 1'b0;
        else if (WriteEnable)
            Q <= D;
    end
    
    
    //2 tri states - active high so Q when low 
    assign Bitline1 = ReadEnable1 ? 1'bz : Q;
    assign Bitline2 = ReadEnable2 ? 1'bz : Q;
endmodule
