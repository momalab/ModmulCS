module SplitAdder #(
    parameter IO = 1<<16,
    SS = ($clog2(IO)>>2) > 0 ? 1<<($clog2(IO)>>2): 1<<($clog2(IO)>>1)
) (psum0, psum1, cin, cout0, cout1, sum, overflow);

localparam N_PARTS = IO / SS + (IO % SS ? 1 : 0);

input wire [IO-1:0] psum0, psum1;
input wire cin;
input wire [N_PARTS-1:0] cout0, cout1;
output wire [IO-1:0] sum;
output wire overflow;

wire [N_PARTS:0] coutSel;

genvar j;
generate
    assign coutSel[0] = cin;
    for (j=0; j<N_PARTS; j=j+1) begin
        assign coutSel[j+1] = coutSel[j] ? cout1[j] : cout0[j];
    end
endgenerate

assign overflow = coutSel[N_PARTS];

genvar i;
generate
    for (i=0; i<IO; i=i+SS) begin
        assign sum[( (i+SS)>IO?IO-1:(i+SS-1) ) :i] = coutSel[i/SS] ? psum1[( (i+SS)>IO?IO-1:(i+SS-1) ) :i] : psum0[( (i+SS)>IO?IO-1:(i+SS-1) ) :i];
    end
endgenerate

endmodule
