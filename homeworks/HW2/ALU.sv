module ALU (
    	input  [15:0] ALU_In1, ALU_In2,  //Inputs
    	input  [3:0]  Opcode,            //4 bit opcode
    	input  [3:0]  Shamt,             //4 bit for shift as max shift should be 15 bits
    	output reg [15:0] ALU_Out,       //otuput
    	output reg Z, N, V              //flags for zero, neg, overflow
);
	//ALL SUBMODULE HAVE BEEN MADE NOW NEED TO CONNECT
    	//wire results
    	wire [15:0] xor_result, sll_result, sra_result, ror_result, paddsb_result, red_result,add_result,sub_result;
    	
	//TODO: ADD/SUB - ALREADY MADE RIPPLE ADDER CAN BE USED AGAIN FOR THIS ONE
	//TODO: Implement saturation - not difficult, if theres overflow saturate to most pos or most neg
	//Saturation implemented - must be tested but seems fairly intuitive - DONE?
	add_sub_16 add_unit (
		.A(ALU_In1),
		.B(ALU_In2),
		.sub(Opcode[0]).
		.Sum(add_result),
		.Ovfl(V)

	);
	//SUB Logic 
	//TODO: SATURATION LOGIC - DONE? (See above comments)
	//overflow is connected to V which is our overflow flag
	/*
	add_sub_16 sub_unit (
		.A(ALU_In1),
		.B(ALU_In2),
		.sub(1'd1).
		.Sum(sub_result),
		.Ovfl(V)

	);
	*/
    	//TODO: XOR - DONE?
	assign xor_result = (ALU_In1 ^ ALU_In);

   

    	//TODO: PADDSB - saturation added - DONE?
    	PADDSB_16 PADDSB(
		.A(ALU_In1),
		.B(ALU_In2),
		.Sum(paddsb_result),
		.Error()
	);

    

    	//logical left shift logic - taken from hw3 - DONE
    	Shifter sll_unit (
        	.Shift_In(ALU_In1),
        	.Shift_Val(Shamt),
        	.Mode(1'b0), // Left shift
        	.Shift_Out(sll_result)
    	);
	//arithmetic right shift logic - taken from hw3 - DONE
    	Shifter sra_unit (
        	.Shift_In(ALU_In1),
        	.Shift_Val(Shamt),
        	.Mode(1'b1), 
        	.Shift_Out(sra_result)
    	);

    	//TODO: ROTATE RIGHT
	Rotator ROR(
		.Rot_In(ALU_In1),
		.Rot_amt(Shamt),
		.Rot_Out(ror_result)
	);

	RED RED(
		.a(ALU_In1),
		.b(ALU_In2),
		.sum(red_result)
	);

    	always @(*) begin
        	case (Opcode)
            //TODO: CONNECT WIRES HOLDING VALUES TO OPCODE
			4'b0000, 4'b0001: begin  //add or sub - based on bit 0 of opcode - if Opcode[0] == 0 -> add 
                		ALU_Out = alu_result; //output solution
                		//implement V flag
			end
			4'b0010: begin
				ALU_Out = xor_result;
			end
			4'b0011: begin
				ALU_Out = red_result;
			end
			4'b0100: begin
				ALU_Out = sll_result;
			end
			4'b0101: begin
				ALU_Out = sra_result;
			end
			4'b0110: begin
				ALU_Out = ror_result;
			end
			4'b0111: begin
				ALU_Out = paddsb_result;
			end
			4'b1000: begin
				//lw logic?
			end
			4'b1001: begin
				//sw logic
			end
			4'1010: begin
				//llb logic
			end
			4'b1011: begin
				//lhb logic
			end
			4'b1100: begin 
				//B logic
			end
			
        	endcase

        	//if ALU_Out is 0 set Z to 1
        	Z = (ALU_Out == 16'b0) ? 1 : 0;
        	N = ALU_Out[15]; //MSB represents negative or positive (2's complement)
    	end

endmodule
