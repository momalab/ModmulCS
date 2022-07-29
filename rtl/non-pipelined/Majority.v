module Majority(a, b, c, out);

input wire a, b, c;
output wire out;

assign out = (a && b) || (a && c) || (b && c);

endmodule
