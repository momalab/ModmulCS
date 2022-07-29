//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of main block 
// 
// Dependencies: Majority
//////////////////////////////////////////////////////////////////////////////////

module Lcu(p, q, b, f);

input wire [4:2] p;
input wire [4:2] q;
input wire b;
output wire [1:0] f;

wire [5:3] c;
wire [4:3] s;
wire a, t;

assign s[3] = p[3] ^ q[3];
assign s[4] = p[4] ^ q[4];
Majority m0(p[2], q[2], b, c[3]);
assign c[4] = p[3] & q[3];
assign c[5] = p[4] & q[4];
assign a = s[3] & c[3];
Majority m1(s[4], c[4], a, t);
assign f[0] = a ^ s[4] ^ c[4];
assign f[1] = t ^ c[5];

endmodule
