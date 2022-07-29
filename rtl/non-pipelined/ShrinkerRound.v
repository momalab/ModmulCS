module ShrinkerRound #(parameter N=1<<16) (p, q, rx1, rn, p_out, q_out, done);

input wire [N:0] p, q;
input wire [N-1:0] rx1, rn;

output reg [N:0] p_out, q_out;
output wire done;

wire [N:0] p0, q0, p1, q1, rx1rn;
wire [2:0] f;

// topup p and q
Topup topup0(p[N]  , q[N]  , p0[N]  , q0[N]  );
Topup topup1(p[N-1], q[N-1], p0[N-1], q0[N-1]);
assign p0[N-2:0] = p[N-2:0];
assign q0[N-2:0] = q[N-2:0];

// calculate f
assign f[0] = p0[N-1] & q0[N-1];
assign f[1] = f[0]    & p0[N];
assign f[2] = p0[N]   & q0[N];

// select between rx1 and rn, and add
assign rx1rn = { 1'b0, ( (f[2] | f[1]) ? rx1 : rn ) };
CarrySaveAdder #(N) csadder0(p0, q0, rx1rn, p1, q1);

assign done = !(|f | p0[N]);

always @* begin
//    if (f[2]) begin
//        p_out <= p1;
//        q_out <= q1;
//    end else if (f[1]) begin
//        p_out <= { 1'b0, p1[N-1:0] };
//        q_out <= { 1'b0, q1[N-1:0] };
//    end else if (p0[N]) begin
//        p_out <= { 1'b0, p1[N-1:0] };
//        q_out <= q1;
//    end else if (f[0]) begin
//        p_out <= p1;
//        q_out <= { 1'b0, q1[N-1:0] };
//    end else begin
//        p_out <= p0;
//        q_out <= q0;
//    end

    // set p_out
    if (f[2] | (f[0] & !f[1] & !p0[N])) p_out <= p1;
    else if (f[1] | p0[N]) p_out <= { 1'b0, p1[N-1:0] };
    else p_out <= p0;

    // set q_out
    if (f[2] | (p0[N] & !f[1])) q_out <= q1;
    else if (f[1] | f[0]) q_out <= { 1'b0, q1[N-1:0] };
    else q_out <= q0;
end

endmodule
