module fulladder_1bit(a, b, cin, s, cout);
  //a and b are the bits to add
  //cin is carry in
  input wire a, b, cin;
  
  //s is the sum of a and b. cout is any carry out bit
  //wires since just using assign here
  output wire s, cout;

  //logic for sum and carry
  assign s = cin ^ a ^ b;
  assign cout = (b & cin) | (a & cin) | (a & b); 
  
endmodule
