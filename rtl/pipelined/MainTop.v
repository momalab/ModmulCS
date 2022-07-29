//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of OM-Pipe multiplier
// 
// Dependencies: Main
//////////////////////////////////////////////////////////////////////////////////

module MainTop #(parameter N=1<<9, N_STAGES=1) // + PRESTAGE, POSTSTAGE
(clock, reset, a, b, r, rn, rm, rx1, rx2, rx3, k, p, q, out_r, out_rn, out_rm, out_rx1, out_k, done);

localparam CLOGN = $clog2(N);
localparam N_CYCLES = N / N_STAGES;

input  wire clock, reset;
input  wire [N-1:0] a, b, r, rn, rm, rx1, rx2, rx3;
input  wire [CLOGN:0] k;
output wire [N:0] p, q;
output wire [N-1:0] out_r, out_rn, out_rm, out_rx1;
output wire [CLOGN:0] out_k;
output wire done;

wire [N-1:0]     va [0:N_STAGES-1];
wire [N-1:0]     vb [0:N_STAGES-1];
wire [N-1:0]     vr [0:N_STAGES-1];
wire [N-1:0]    vrn [0:N_STAGES-1];
wire [N-1:0]    vrm [0:N_STAGES-1];
wire [N-1:0]   vrx1 [0:N_STAGES-1];
wire [N-1:0]   vrx2 [0:N_STAGES-1];
wire [N-1:0]   vrx3 [0:N_STAGES-1];
wire [N  :0]     vp [0:N_STAGES-1];
wire [N  :0]     vq [0:N_STAGES-1];
wire [CLOGN:0]   vi [0:N_STAGES-1];
wire [CLOGN:0]   vk [0:N_STAGES-1];
wire          vdone [0:N_STAGES-1]; // internal dones are not needed

genvar i;
generate
    Main #(N,N_CYCLES) stage0(clock, reset, a, b, r, rn, rm, rx1, rx2, rx3, k, k, {(N+1){1'b0}}, {(N+1){1'b0}}, va[0], vb[0], vr[0], vrn[0], vrm[0], vrx1[0], vrx2[0], vrx3[0], vk[0], vi[0], vp[0], vq[0], vdone[0]);
    for (i=1; i<N_STAGES; i=i+1) begin
        Main #(N,N_CYCLES) stage(clock, reset, va[i-1], vb[i-1], vr[i-1], vrn[i-1], vrm[i-1], vrx1[i-1], vrx2[i-1], vrx3[i-1], vk[i-1], vi[i-1], vp[i-1], vq[i-1], va[i], vb[i], vr[i], vrn[i], vrm[i], vrx1[i], vrx2[i], vrx3[i], vk[i], vi[i], vp[i], vq[i], vdone[i]);
    end
    assign p = vp[N_STAGES-1];
    assign q = vq[N_STAGES-1];
    assign out_r = vr[N_STAGES-1];
    assign out_rn = vrn[N_STAGES-1];
    assign out_rm = vrm[N_STAGES-1];
    assign out_rx1 = vrx1[N_STAGES-1];
    assign out_k = vk[N_STAGES-1];
    assign done = vdone[N_STAGES-1];
endgenerate

endmodule