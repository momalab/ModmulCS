module SqueezerRule #(parameter N=1<<16) (p, q, r2, rule, p_out, q_out);

input wire [N-1:N-2] p, q;
input wire r2;
output reg [2:0] rule;
output wire [N-1:N-2] p_out, q_out;

wire [N-1:N-2] p0, q0;

Topup topup0(p[N-1], q[N-1], p0[N-1], q0[N-1]);
Topup topup1(p[N-2], q[N-2], p0[N-2], q0[N-2]);

assign p_out = p0;
assign q_out = q0;

always @* begin
    if (!p0[N-1]) begin
        rule <= 1;
    end else if (q0[N-2]) begin
        rule <= 2;
    end else if (!r2) begin
        if (p0[N-2]) begin
            rule <= 3;
        end else begin
            rule <= 4;
        end
    end else begin
        if (!p0[N-2]) begin
            rule <= 5;
        end else begin
            rule <= 0;
        end
    end
end

endmodule
