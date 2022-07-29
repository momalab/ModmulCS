module Topup(pi, qi, to, ta);

input wire pi, qi;
output wire to, ta;

assign to = pi | qi;
assign ta = pi & qi;

endmodule
