module PC_control(
    input [2:0] C, 
    input [8:0] I, 
    input [2:0] F, 
    input [15:0] PC_in, 
    output [15:0] PC_out
);

    wire [15:0] ADD_2, ADD_JUMP;
    wire Z, V, N, cond;
    
    // Extracting flag bits
    assign Z = F[2];
    assign V = F[1];
    assign N = F[0];

    // Compute condition based on Table 1
    assign cond =  (C == 3'b000) ? ~Z :    // Not Equal (Z=0)
                   (C == 3'b001) ? Z  :    // Equal (Z=1)
                   (C == 3'b010) ? (~Z & ~N) : // Greater Than (Z=N=0)
                   (C == 3'b011) ? N  :   // Less Than (N=1)
                   (C == 3'b100) ? (Z | ~(Z | N)) : // Greater Than or Equal (Z=1 or Z=N=0)
                   (C == 3'b101) ? (N | Z) : // Less Than or Equal (N=1 or Z=1)
                   (C == 3'b110) ? V  :    // Overflow (V=1)
                   (C == 3'b111) ? 1'b1 :  // Unconditional
                   1'b0;

    //Binary addition for PC+2
    wire [15:0] sum1, carry1, sum2, carry2, sum3, carry3;

    assign sum1 = PC_in ^ 16'd2;           //xor 2 with pc_in and disregard carry for now
    assign carry1 = (PC_in & 16'd2) << 1;  //and pc_in and 2 and shift left by 1 bit

    assign sum2 = sum1 ^ carry1;           //add carry to sum1
    assign carry2 = (sum1 & carry1) << 1;  //compute the next carry bit to ensure all carries are accounted for

    assign sum3 = sum2 ^ carry2;           //add the second computed carry to the 
    assign carry3 = (sum2 & carry2) << 1;  // Step 6: Compute next carry

    assign ADD_2 = sum3 ^ carry3;          // Step 7: Final sum

    // ---------------------- Binary Addition for ADD_JUMP ---------------------- //
    wire [15:0] offset;
    assign offset = {{6{I[8]}}, I, 1'b0};  // Sign-extended offset (left-shifted by 1)

    wire [15:0] sumJ1, carryJ1, sumJ2, carryJ2, sumJ3, carryJ3;

    assign sumJ1 = ADD_2 ^ offset;         // Step 1: Sum without carry
    assign carryJ1 = (ADD_2 & offset) << 1;// Step 2: Compute carry

    assign sumJ2 = sumJ1 ^ carryJ1;        // Step 3: Add carry
    assign carryJ2 = (sumJ1 & carryJ1) << 1;// Step 4: Compute next carry

    assign sumJ3 = sumJ2 ^ carryJ2;        // Step 5: Add next carry
    assign carryJ3 = (sumJ2 & carryJ2) << 1;// Step 6: Compute final carry

    assign ADD_JUMP = sumJ3 ^ carryJ3;     // Step 7: Final sum

    // ---------------------- Conditional PC Update ---------------------- //
    assign PC_out = cond ? ADD_JUMP : ADD_2;

endmodule
