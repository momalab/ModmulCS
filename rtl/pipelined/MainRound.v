//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of main block 
// 
// Dependencies: CarrySaveAdder, Lcu, Rx
//////////////////////////////////////////////////////////////////////////////////

module MainRound #(parameter N=1<<16) (feed, ab, rx1, rx2, rx3, p, q, p_out, q_out);

input wire [N:0] p, q, feed;
input wire [N-1:0] rx1, rx2, rx3;
input wire ab;

output wire [N:0] p_out, q_out;

wire [N:0] s, c;
wire [N-1:0] ry;
wire [1:0] f1f0;

CarrySaveAdder #(N) csadder0( {p[N-1:0],1'b0}, {q[N-1:0],1'b0}, feed, s, c);
Lcu lcu(p[N:N-2], q[N:N-2], ab, f1f0);
Rx #(N) rx(f1f0, rx1, rx2, rx3, ry);
CarrySaveAdder #(N) csadder1(s, c, {1'b0, ry}, p_out, q_out);

endmodule
