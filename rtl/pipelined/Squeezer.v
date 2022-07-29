//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of Squeezer block 
// 
// Dependencies: SqueezerRound, SqueezerRule
//////////////////////////////////////////////////////////////////////////////////

module Squeezer #(parameter N=1<<9) (clock, p_in, q_in, r2, rn, rm, p_out, q_out);

input wire [N:0] p_in, q_in;
input wire [N-1:0] rn, rm;
input wire clock, r2;

output reg [N-1:0] p_out, q_out;

wire [N:0] p_tmp, q_tmp;
wire [N-1:0] p_sq, q_sq;
wire [N-1:N-2] p0, q0;
wire [2:0] rule;

assign p_tmp = {p_in[N], p0, p_in[N-3:0]};
assign q_tmp = {q_in[N], q0, q_in[N-3:0]};
SqueezerRule #(N) squeezerRule(p_in[N-1:N-2], q_in[N-1:N-2], r2, rule, p0, q0);
SqueezerRound #(N) squeezerRound(p_tmp, q_tmp, rn, rm, rule, p_sq, q_sq);

always @(posedge clock) begin
    p_out <= p_sq;
    q_out <= q_sq;
end

endmodule
