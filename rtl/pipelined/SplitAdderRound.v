//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of SplitAdder
// 
// Dependencies: None
//////////////////////////////////////////////////////////////////////////////////

module SplitAdderRound #(
    parameter IO = 1<<9,
    SS = ($clog2(IO)>>2) > 0 ? 1<<($clog2(IO)>>2): 1<<($clog2(IO)>>1)
) (a, b, cin, sum, cout);

localparam N_PARTS = IO / SS + (IO % SS ? 1 : 0);

input wire [IO-1:0] a, b;
input wire cin;
output wire [IO-1:0] sum;
output wire [N_PARTS-1:0] cout;

genvar i;
generate
    for (i=0; i<IO; i=i+SS) begin
        assign { cout[i/SS], sum[( (i+SS)>IO?IO-1:(i+SS-1) ) :i] } = a[( (i+SS)>IO?IO-1:(i+SS-1) ) :i] + b[( (i+SS)>IO?IO-1:(i+SS-1) ) :i] + cin;
    end
endgenerate

endmodule
