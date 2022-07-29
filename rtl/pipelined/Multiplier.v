// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: OM-Pipe multiplier
// 
// Dependencies: PreMain, MainTop, PostMain
//////////////////////////////////////////////////////////////////////////////////

module Multiplier #(parameter N=1<<9, N_STAGES=3, SS=N/4)
(clock, reset, in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3, in_k, out_result, out_done);

localparam LOGN = $clog2(N);
localparam MAIN_STAGES = N_STAGES-2;
localparam N_CYCLES = N / MAIN_STAGES + 2;
localparam N_PARTS = (N+1) / SS + ((N+1) % SS ? 1 : 0);
localparam LO = N_PARTS / 2 + (N_PARTS % 2);
localparam HI = N_PARTS;
localparam NLO = SS * LO;
localparam NHI = N+1 - NLO;

input wire clock;
input wire reset;
input wire[N-1:0] in_a;
input wire[N-1:0] in_b;
input wire[N-1:0] in_r;
input wire[N-1:0] in_rn;
input wire[N-1:0] in_rm;
input wire[N-1:0] in_rx1;
input wire[N-1:0] in_rx2;
input wire[N-1:0] in_rx3;
input wire[LOGN:0] in_k;

output wire[N-1:0] out_result;
output wire out_done;

// PreMain
wire [N-1:0] pre_a, pre_b, pre_r, pre_rn, pre_rm, pre_rx1, pre_rx2, pre_rx3;
wire [LOGN:0] pre_k;
wire pre_done;

// MainTop
wire [N:0] main_p, main_q;
wire [N-1:0] main_r, main_rn, main_rm, main_rx1;
wire [LOGN:0] main_k;
wire main_done;

// PostMain
// none

PreMain #(N, N_CYCLES) preMain
(
    clock, reset, in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3, in_k,
    pre_a, pre_b, pre_r, pre_rn, pre_rm, pre_rx1, pre_rx2, pre_rx3, pre_k, pre_done
);

MainTop #(N, MAIN_STAGES) mainTop
(
    clock, reset, pre_a, pre_b, pre_r, pre_rn, pre_rm, pre_rx1, pre_rx2, pre_rx3, pre_k,
    main_p, main_q, main_r, main_rn, main_rm, main_rx1, main_k, main_done
);

PostMain #(N, N_CYCLES, SS) postMain
(
    clock, reset, main_p, main_q, main_r, main_rn, main_rm, main_rx1, main_k,
    out_result, out_done
); 

endmodule