module tb_add_sub_16;
    reg signed [15:0] A, B;
    reg sub;
    wire signed [15:0] Sum;
    wire Ovfl;

    add_sub_16 test (.A(A), .B(B), .sub(sub), .Sum(Sum), .Ovfl(Ovfl));

    initial begin
        $display("time | A      | B      | Sub | Sum     | Ovfl | Expected");
        $monitor("%4t | %6d | %6d |  %b  | %6d  |   %b   | %6d", 
                 $time, A, B, sub, Sum, Ovfl, 
                 (sub ? (A - B > 32767 ? 32767 : (A - B < -32768 ? -32768 : A - B)) : 
                        (A + B > 32767 ? 32767 : (A + B < -32768 ? -32768 : A + B))));

        repeat (10) begin
            A = $random % 65536 - 32768;  // Signed 16-bit range
            B = $random % 65536 - 32768;
            sub = $random % 2; 
            #10; // delay
        end

        $finish;
    end
endmodule