module CarrySaveAdder #(parameter N=1<<16) (x, y, z, s, c);

input wire [N:0] x, y, z;
output wire [N:0] s, c;

assign s = z ^ y ^ x;
assign c = { (x[N-1:0] & y[N-1:0]) | (y[N-1:0] & z[N-1:0]) | (x[N-1:0] & z[N-1:0]), 1'b0 };

endmodule
