//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of Multiplier
// 
// Dependencies: Shrinker, Squeezer, SplitAdder21, SlrBarrel
//////////////////////////////////////////////////////////////////////////////////

module PostMain #(parameter N=1<<9, N_CYCLES=N+1, SS=N/4)
(
    clock, reset, in_p, in_q, in_r, in_rn, in_rm, in_rx1, in_k,
    out_sum, done
);

localparam LOGN = $clog2(N);
localparam LOGC = $clog2(N_CYCLES);

input wire clock, reset;
input wire [N:0] in_p, in_q;
input wire [N-1:0] in_r, in_rn, in_rm, in_rx1;
input wire [LOGN:0] in_k;

output wire [N-1:0] out_sum;
output reg done;

// states of FSM
localparam MODE_SIZE = 10;
localparam [MODE_SIZE-1:0]
    MODE_START    =   1,
    MODE_SHRINKER =   2,
    MODE_SQUEEZER =   4,
    MODE_SET_ADD  =   8,
    MODE_ADD      =  16,
    MODE_SET_RED  =  32,
    MODE_RED      =  64,
    MODE_SLR      = 128,
    MODE_OUT      = 256,
    MODE_WAIT     = 512;
reg [MODE_SIZE-1:0] mode;

reg [LOGN-1:0] i, j, nmk; // nmkm1;
//reg [LOGC-1:0] i;
//reg [1:0] j;

reg [N:0] sum_add, sain, sbin; // p, q,
reg [N-1:0] r, rn, rm, out_sum_reg; //, sain, sbin; // rx1
reg cout_add, cin, sareset, slreset, isShort;

wire [N:0] p_insh, q_insh, p_shsq, q_shsq, saout, sum;
wire [N-1:0] rx1_insh, rn_insh, p_sqadd, q_sqadd, slr_out; // sain, sbin, saout, sum 
wire [LOGN-1:0] shift;
wire r2, cout, slrdone; // cin, sareset, slreset  

// module Shrinker #(parameter N=1<<9) (clock, reset, p_in, q_in, rx1, rn, p_out, q_out);
assign p_insh   = in_p; // mode[0] ? in_p   : p;
assign q_insh   = in_q; // mode[0] ? in_q   : q;
assign rx1_insh = in_rx1; // mode[0] ? in_rx1 : rx1;
assign rn_insh  = in_rn; // mode[0] ? in_rn  : rn;
Shrinker #(N) shrinker(clock, reset, p_insh, q_insh, rx1_insh, rn_insh, p_shsq, q_shsq);

// module Squeezer #(parameter N=1<<9) (clock, p_in, q_in, r2, rn, rm, p_out, q_out);
assign r2 = r[N-2];
Squeezer #(N) squeezer(clock, p_shsq, q_shsq, r2, rn, rm, p_sqadd, q_sqadd);

// module SplitAdder21 #(
//     parameter IO = 1<<9, SS = ($clog2(IO)>>2) > 0 ? 1<<($clog2(IO)>>2): 1<<($clog2(IO)>>1)
// ) (clock, reset, a, b, cin, sum, overflow);
//assign sain = (mode == MODE_ADD) ? p_sqadd : saout;
//assign sbin = (mode == MODE_ADD) ? q_sqadd : r;
//assign cin = mode != MODE_ADD;
//assign sareset = mode == MODE_SQUEEZER;
SplitAdder21 #(N+1, SS) splitAdder21(clock, sareset, sain, sbin, cin, saout, cout);  

//module SlrBarrel #(parameter LOGSIZE = 8) (clock, in, shift, out);
//assign slreset = reset || (mode == MODE_RED);
assign sum = {cout_add, sum_add} < {1'b0, r} ? sum_add : saout;
assign shift = nmk; // nmkm1;
SlrLog #(LOGN) slr(clock, slreset, sum[N-1:0], shift, slr_out, slrdone);

// output
assign out_sum = isShort ? slr_out : out_sum_reg; 

always @(posedge clock) begin
    if (reset) begin
        mode <= MODE_START;
        slreset <= 1;
    end else case (mode)
    
        MODE_START : begin
            mode <= MODE_SHRINKER;
            done <= 0;
            i <= N_CYCLES - 2;
            j <= 2;
            // nmkm1 <= N-in_k-1;
            nmk <= N - in_k;
//            p <= in_p;
//            q <= in_q;
            r <= in_r;
            rn <= in_rn;
            rm <= in_rm;
//            rx1 <= in_rx1;
            slreset <= 1;
            isShort <= 0;
            out_sum_reg <= out_sum;
        end
        
        MODE_SHRINKER : begin
            if (!j) mode <= MODE_SQUEEZER;
            i <= i - 1;
            j <= j - 1;
        end
        
        MODE_SQUEEZER : begin
            mode <= MODE_SET_ADD;
            i <= i - 1;
            sareset <= 1;
        end
        
        MODE_SET_ADD: begin
            mode <= MODE_ADD;
            i <= i - 1;
            j <= 2;
            sareset <= 0;
            cin <= 0;
            sain <= p_sqadd;
            sbin <= q_sqadd;
        end
        
        MODE_ADD : begin
            if (!j) begin
                mode <= MODE_SET_RED;
                sareset <= 1;
            end
            i <= i - 1;
            j <= j - 1;
        end
        
        MODE_SET_RED: begin
            mode <= MODE_RED;
            i <= i - 1;
            j <= 2;
            sareset <= 0;
            cin <= 1;
            sain <= saout;
            sbin <= ~{0, r};
        end
        
        MODE_RED : begin
            if (!j) begin
                mode <= MODE_SLR;
                slreset <= 1;
                j <= LOGN; // - 1;
            end else j <= j - 1; 
            if (j == 2) begin
                sum_add <= saout;
                cout_add <= cout;
            end
            i <= i - 1;
            sareset <= 0;
        end
        
        MODE_SLR : begin
//            if (!j) mode <= MODE_OUT;
            if (!j) begin
                if (!i) begin
                    mode <= MODE_START;
                    done <= 1;
                end else mode <= MODE_OUT;
            end
            i <= i - 1;
            j <= j - 1;
            slreset <= 0;
            isShort <= 1;
        end
        
        MODE_OUT : begin
            if (!i) begin
                mode <= MODE_START;
                done <= 1;
            end else mode <= MODE_WAIT;
            i <= i - 1;
            out_sum_reg <= slr_out;
            isShort <= 0;
        end
        
        MODE_WAIT : begin
            if (!i) begin
                mode <= MODE_START;
                done <= 1;
            end
            i <= i - 1;
        end
    
    endcase
end

endmodule