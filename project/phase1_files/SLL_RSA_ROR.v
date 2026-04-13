module Shifter(
    	input [15:0] Shift_In, //Input data to perform shift
	input [3:0] Shift_Val, //Shift amount OPCODE CONNECTION
    	input [2:0] Mode,            //CHANGE TO USE OPCODES 
	output [15:0] Shift_Out //OUT
);


	//OPCODES:
	//	SLL: 0100
	//	SRA: 0101
	//	ROR: 0110

	//Keep it simple - check opcode[0] if the its 0 it can only be SLL or ROR
	//then check mode[1] if it is high it is ROR if low its SLL
	//if the opcode[0] is 1 it can only be SRA

    	wire [15:0] s1, s2, s3, s4;
	//go through each bit in shift val - check if shift val bit is high - if its check if mode is high or low to know to shift right if high or shift left if low
    	//if shift_val bit is low - take current shifted output and move to next bit value

	
    	assign s1 = Shift_Val[0] ? 
                	(Mode == 3'b101 ? {Shift_In[15], Shift_In[15:1]} : //SRA 
                 	Mode == 3'b110 ? {Shift_In[0], Shift_In[15:1]} :  //ROR 
                 	{Shift_In[14:0], 1'b0}) : //SLL 
                	Shift_In;

    	
    	assign s2 = Shift_Val[1] ? 
                	(Mode == 3'b101 ? {{2{Shift_In[15]}}, s1[15:2]} : //SRA
                 	Mode == 3'b110 ? {s1[1:0], s1[15:2]} :  //ROR
                 	{s1[13:0], 2'b00}) : //SLL
                	s1;

    	
    	assign s3 = Shift_Val[2] ? 
                	(Mode == 3'b101 ? {{4{Shift_In[15]}}, s2[15:4]} : //SRA
                 	Mode == 3'b110 ? {s2[3:0], s2[15:4]} :  //ROR
                 	{s2[11:0], 4'b0000}) : //SLL
                	s2;

    	
    	assign s4 = Shift_Val[3] ? 
                	(Mode == 3'b101 ? {{8{Shift_In[15]}}, s3[15:8]} : //SRA
                 	Mode == 3'b110 ? {s3[7:0], s3[15:8]} :  //ROR
                 	{s3[7:0], 8'b00000000}) : //SLL
                	s3;





/*
	assign s1 = Shift_Val[0] ? (Mode ? {Shift_In[15], Shift_In[15:1]} : {Shift_In[14:0], 1'b0}) : (Shift_In);
    	assign s2 = Shift_Val[1] ? (Mode ? {{2{Shift_In[15]}}, s1[15:2]} : {s1[13:0], 2'b00}) : (s1);
    	assign s3 = Shift_Val[2] ? (Mode ? {{4{Shift_In[15]}}, s2[15:4]} : {s2[11:0], 4'b0000}) : (s2);
    	assign s4 = Shift_Val[3] ? (Mode ? {{8{Shift_In[15]}}, s3[15:8]} : {s3[7:0], 8'b00000000}) : (s3);

*/

    	assign Shift_Out = s4;

endmodule
