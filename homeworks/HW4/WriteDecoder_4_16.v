module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output reg [15:0] Wordline);
	//enable a selected register between 0-15
    	always @(*) begin
        	Wordline = 16'b0;
        	if (WriteReg)	//when writeReg is high set the [RegId0th bit of wordline to high
            		Wordline[RegId] = 1'b1;
    	end
endmodule
