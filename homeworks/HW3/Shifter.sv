module Shifter(
    	input [15:0] Shift_In, // Input data to perform shift operation on
    	input [3:0] Shift_Val, // Shift amount (used to shift the input data)
    	input Mode,            // 0=SLL (Logical Left Shift), 1=SRA (Arithmetic Right Shift)
    	output [15:0] Shift_Out // Shifted output data
);

    	wire [15:0] s1, s2, s3, s4;
	//go through each bit in shift val - check if shift val bit is high - if its check if mode is high or low to know to shift right if high or shift left if low
    	//if shift_val bit is low - take current shifted output and move to next bit value
	assign s1 = Shift_Val[0] ? (Mode ? {Shift_In[15], Shift_In[15:1]} : {Shift_In[14:0], 1'b0}) : (Shift_In);
    	assign s2 = Shift_Val[1] ? (Mode ? {{2{Shift_In[15]}}, s1[15:2]} : {s	1[13:0], 2'b00}) : (s1);
    	assign s3 = Shift_Val[2] ? (Mode ? {{4{Shift_In[15]}}, s2[15:4]} : {s2[11:0], 4'b0000}) : (s2);
    	assign s4 = Shift_Val[3] ? (Mode ? {{8{Shift_In[15]}}, s3[15:8]} : {s3[7:0], 8'b00000000}) : (s3);

    	assign Shift_Out = s4;

endmodule

