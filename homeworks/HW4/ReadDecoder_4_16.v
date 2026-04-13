module ReadDecoder_4_16(input [3:0] RegId, output reg [15:0] Wordline);
	//use one hot encoding to set 1 bit of WordLine to low - active low because of inverter input to tristate
	//input can be a value between 0-15 which corresponds to which bit will be low in the output
    	always @(*) begin
        	Wordline = 16'b1111111111111111;
        	Wordline[RegId] = 1'b0;
    	end
endmodule