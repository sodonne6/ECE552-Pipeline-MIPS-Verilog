module shifter_tb();


	reg [15:0] Shift_In;
	reg [3:0] Shift_Val;
	reg [2:0] Mode;
	wire [15:0] Shift_Out;

	Shifter DUT (
		.Shift_In(Shift_In),
		.Shift_Val(Shift_Val),
		.Mode(Mode),
		.Shift_Out(Shift_Out)
		

	);



	initial begin
		
		//Test 1: SLL
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b0010;
		Mode = 3'b100;
		#10

		//Test 2: SRA
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b0010;
		Mode = 3'b101;
		#10

		//Test 3: ROR
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b1010;
		Mode = 3'b110;
		#10

		//Test 4: SLL
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b1010;
		Mode = 3'b100;
		#10

		//Test 5: SRA
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b0010;
		Mode = 3'b101;
		#10

		//Test 6: ROR
		Shift_In = 16'b1111101001011100;
		Shift_Val = 4'b1110;
		Mode = 3'b110;
		#10
		$stop;
		

		
	end


endmodule
	
