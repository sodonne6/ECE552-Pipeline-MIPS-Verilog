module RED (
  input [15:0] a,  
  input [15:0] b,  
  output [15:0] sum 
);
    wire [3:0] sum0, sum1, sum2, sum3, sum01, sum23, total_sum, sum01c, sum23c, total_sumc;
    wire [3:0] c00, c01, c02, c03;
    wire [3:0] c0;
    wire [1:0] c1;
    wire c2;
    wire ovfl0, ovfl1, ovfl2, ovfl3;
    
    // Level 1
    add_sub_4 ADD_0 (
        .A(a[15:12]), .B(b[15:12]), .Cin(1'b0),
        .Sum(sum0), .Cout(c0[0]), .Ovfl(ovfl0), .PG(), .GG()
    );
    
    add_sub_4 ADD_1 (
        .A(a[11:8]), .B(b[11:8]), .Cin(1'b0),
        .Sum(sum1), .Cout(c0[1]), .Ovfl(ovfl1), .PG(), .GG()
    );
    
    add_sub_4 ADD_2 (
        .A(a[7:4]), .B(b[7:4]), .Cin(1'b0),
        .Sum(sum2), .Cout(c0[2]), .Ovfl(ovfl2), .PG(), .GG()
    );
    
    add_sub_4 ADD_3 (
        .A(a[3:0]), .B(b[3:0]), .Cin(1'b0),
        .Sum(sum3), .Cout(c0[3]), .Ovfl(ovfl3), .PG(), .GG()
    );
    
    // 1 -> 4-bit
    assign c00 = {4{(ovfl0?c0[0]:sum0[3])}};
    assign c01 = {4{(ovfl1?c0[1]:sum1[3])}};
    assign c02 = {4{(ovfl2?c0[2]:sum2[3])}};
    assign c03 = {4{(ovfl3?c0[3]:sum3[3])}};

    // Level 2
    add_sub_4 ADD_01 (
        .A(sum0), .B(sum1), .Cin(1'b0),
        .Sum(sum01), .Cout(c1[0]), .Ovfl(), .PG(), .GG()
    );

    add_sub_4 ADD_01C (
        .A(c00), .B(c01), .Cin(c1[0]),
        .Sum(sum01c), .Cout(), .Ovfl(), .PG(), .GG()
    );
    
    add_sub_4 ADD_23 (
        .A(sum2), .B(sum3), .Cin(1'b0),
        .Sum(sum23), .Cout(c1[1]), .Ovfl(), .PG(), .GG()
    );

    add_sub_4 ADD_23C (
        .A(c02), .B(c03), .Cin(c1[1]),
        .Sum(sum23c), .Cout(), .Ovfl(), .PG(), .GG()
    );
    
    // Level 3
    add_sub_4 ADD_FINAL (
        .A(sum01), .B(sum23), .Cin(1'b0),
        .Sum(total_sum), .Cout(c2), .Ovfl(), .PG(), .GG()
    );

    add_sub_4 ADD_FINALC (
        .A(sum01c), .B(sum23c), .Cin(c2),
        .Sum(total_sumc), .Cout(), .Ovfl(), .PG(), .GG()
    );
    
    // use total_sumc[2] for sign extension, as it is the MSB of the significant bits
    assign sum = {{9{total_sumc[2]}}, total_sumc[2:0], total_sum};
endmodule
