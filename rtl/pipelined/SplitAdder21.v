//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of OM-Pipe multiplier
// 
// Dependencies: SplitAdderRound, SplitAdderSelector
//////////////////////////////////////////////////////////////////////////////////

module SplitAdder21 #(
    parameter IO = 1<<9,
    SS = ($clog2(IO)>>2) > 0 ? 1<<($clog2(IO)>>2): 1<<($clog2(IO)>>1)
) (clock, reset, a, b, cin, sum, overflow);

input wire clock, reset, cin;
input wire [IO-1:0] a, b;

output reg overflow;
output reg [IO-1:0] sum;

// FSM
localparam MODE_SIZE = 3;
localparam [MODE_SIZE-1:0]
    MODE_ADD0 = 1,
    MODE_ADD1 = 2,
    MODE_SEL  = 4;
reg [MODE_SIZE-1:0] mode;

localparam N_PARTS = IO / SS + (IO % SS ? 1 : 0);
localparam MAX = 1 << IO;
localparam LO = N_PARTS / 2 + (N_PARTS % 2);
localparam HI = N_PARTS;
localparam NLO = SS * LO;
localparam NHI = IO - NLO;

//wire [IO-1:0] sum_tmp, psum0_tmp, psum1_tmp;
wire [IO-1:0] sum_tmp, psum_tmp;
//wire [N_PARTS-1:0] cout0_tmp, cout1_tmp;
wire [N_PARTS-1:0] cout_tmp;
wire overflow_tmp, bit01;
//wire overflow0, overflow1;
reg [IO-1:0] psum0, psum1;
reg [N_PARTS-1:0] cout0, cout1;

assign bit01 = mode == MODE_ADD1; 

SplitAdderRound #(IO, SS) saround(a, b, bit01, psum_tmp, cout_tmp);
//SplitAdderRound #(IO, SS) saround0(a, b, 1'b0, psum0_tmp, cout0_tmp);
//SplitAdderRound #(IO, SS) saround1(a, b, 1'b1, psum1_tmp, cout1_tmp);
SplitAdderSelector #(IO, SS) splitadder(psum0, psum1, cin, cout0, cout1, sum_tmp, overflow_tmp);
//SplitAdderSelector #(NLO, SS) sadder0(psum0[NLO-1:0], psum1[NLO-1:0],       cin, cout0[LO-1 :0], cout1[LO-1 :0], sum_tmp[NLO-1:0], overflow0);
//SplitAdderSelector #(NHI, SS) sadder1(psum0[IO :NLO], psum1[IO :NLO], overflow0, cout0[HI-1:LO], cout1[HI-1:LO], sum_tmp[IO :NLO], overflow1);

always @(posedge clock) begin
    if (reset) mode <= MODE_ADD0;
    else case (mode)
    
        MODE_ADD0 : begin
            mode <= MODE_ADD1;
            psum0 <= psum_tmp;
            cout0 <= cout_tmp;
        end
    
        MODE_ADD1: begin
            mode <= MODE_SEL;
            psum1 <= psum_tmp;
            cout1 <= cout_tmp;
        end
        
        MODE_SEL: begin
            mode <= MODE_ADD0;
            sum <= sum_tmp;
            overflow <= overflow_tmp;
        end
        
    endcase
end

endmodule
