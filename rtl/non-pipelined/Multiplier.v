module Multiplier #(parameter N=1<<16)
(clock, reset, in_a, in_b, r, rn, rm, rx1, rx2, rx3, k, result, done);

localparam LOGN = $clog2(N);
localparam SS = LOGN;
//localparam SS = ($clog2(N+1)>>2) > 0 ? 1<<($clog2(N+1)>>2): 1<<($clog2(N+1)>>1);
localparam N_PARTS = (N+1) / SS + ((N+1) % SS ? 1 : 0);
localparam LO = N_PARTS / 2 + (N_PARTS % 2);
localparam HI = N_PARTS;
localparam NLO = SS * LO;
localparam NHI = N+1 - NLO;

// states of FSM
localparam MODE_SIZE = 11;
localparam [MODE_SIZE-1:0]
    MODE_START    = 11'b00000000001,
    MODE_SLL      = 11'b00000000010,
    MODE_MAIN     = 11'b00000000100,
    MODE_SHRINK   = 11'b00000001000,
    MODE_SQUEEZE0 = 11'b00000010000,
    MODE_SQUEEZE1 = 11'b00000100000,
    MODE_ADDER0   = 11'b00001000000,
    MODE_ADDER1   = 11'b00010000000,
    MODE_MOD0     = 11'b00100000000,
    MODE_MOD1     = 11'b01000000000,
    MODE_SLR      = 11'b10000000000;

input wire clock;
input wire reset;
input wire[N-1:0] in_a;
input wire[N-1:0] in_b;
input wire[N-1:0] r;
input wire[N-1:0] rn;
input wire[N-1:0] rm;
input wire[N-1:0] rx1;
input wire[N-1:0] rx2;
input wire[N-1:0] rx3;
input wire[LOGN:0] k;

output wire[N-1:0] result;
output reg done;

reg [N:0] p, q, tmp;
reg [N-1:0] a, b; //, r, rn, rm, rx1, rx2, rx3;
reg [LOGN:0] nmk, i; // k
reg [MODE_SIZE-1:0] mode; // FSM
reg [2:0] rule;
reg onebit;

// Main Loop
wire [N:0] p_ml, q_ml, feed;
wire ab, ai;
assign ai = a[N-1];
assign ab = onebit;
assign feed = tmp;
MainRound #(N) main0(feed, ab, rx1, rx2, rx3, p, q, p_ml, q_ml);

// Shrinker
wire [N:0] p_sh, q_sh;
wire done_sh;
ShrinkerRound #(N) shrinker0(p, q, rx1, rn, p_sh, q_sh, done_sh);

// Squeezer
wire [N-1:0] p_sq, q_sq;

wire [N-1:N-2] p0, q0;
wire [2:0] rule_out;
SqueezerRule #(N) sqrule0(p[N-1:N-2], q[N-1:N-2], r[N-2], rule_out, p0, q0);
Squeezer #(N) squeezer0(p, q, rn, rm, rule, p_sq, q_sq);
//Squeezer #(N) squeezer0(p[N-1:0], q[N-1:0], r[N-2], rn, rm, p_sq, q_sq);

// Output
assign result = p;

// Full adder and reduction
reg [N_PARTS-1:0] cout0, cout1;
reg p_over;
wire [N:0] qnr, psum, sum;
wire [N_PARTS-1:0] cout;
wire cin, overflow0, overflow1;
assign cin = mode[8] | mode[9];
assign qnr = cin ? {1'b0, ~r} : q;
SplitAdderRound #(N+1, SS) saround(p, qnr, ~i[0], psum, cout);
//SplitAdder #(N+1, SS) sadder(psum0, q, cin, cout0, cout1, sum, overflow0);
SplitAdder #(NLO, SS) sadder0(tmp[NLO-1:0], q[NLO-1:0],    cin, cout0[LO-1 :0], cout1[LO-1 :0], sum[NLO-1:0], overflow0);
SplitAdder #(NHI, SS) sadder1(tmp[N  :NLO], q[N  :NLO], p_over, cout0[HI-1:LO], cout1[HI-1:LO], sum[N  :NLO], overflow1);

// Reduction
wire plr;
assign plr = {onebit, p} < r;

// FSM and counter
always @(posedge clock) begin
    if (reset) begin
        done <= 0;
        mode <= MODE_START;
    end else case (mode)

        MODE_START : begin
            a <= in_a;
            b <= in_b;
            done <= 0;
            nmk <= N-k;
            if (k == N) begin
                i <= k;
                mode <= MODE_MAIN;
            end
            else begin
                i <= N-k-1;
                mode <= MODE_SLL;
            end
        end

        MODE_SLL : begin
            a <= { a[N-1:0], 1'bx }; // shift left (ignore lsb)
            b <= { b[N-1:0], 1'b0 }; // shift left
            if (!i) begin
                i <= k;
                mode <= MODE_MAIN;
            end else begin
                i <= i - 1;
            end
        end

        MODE_MAIN : begin
            a <= { a[N-1:0], 1'bx }; // shift left (ignore lsb)
            onebit <= ai & b[N-1];
            tmp <= ai ? { 1'b0, b } : 0;
            if (i == k) begin
                p <= 0;
                q <= 0;
            end else begin
                p <= p_ml;
                q <= q_ml;
            end
            if (!i) begin
                i <= 3;
                mode <= MODE_SHRINK;
            end else i <= i - 1;
        end

        MODE_SHRINK : begin
            i <= i - 1;
            p <= p_sh;
            q <= q_sh;
            tmp <= {(N+1){1'bx}};
            if (!i || done_sh) begin
                mode <= MODE_SQUEEZE0;
            end
        end

        MODE_SQUEEZE0 : begin
            mode <= MODE_SQUEEZE1;
            p[N-1:N-2] <= p0;
            q[N-1:N-2] <= q0;
            rule <= rule_out;
        end

        MODE_SQUEEZE1 : begin
            i <= 1;
            mode <= MODE_ADDER0;
            p <= { 1'b0, p_sq };
            q <= { 1'b0, q_sq };
        end

        MODE_ADDER0 : begin
            if (i[0]) begin // psum0
                cout0 <= cout;
                tmp <= psum;
                i <= i - 1;
            end else begin // psum1
                cout1 <= cout;
                q <= psum;
                i <= 1;
                mode <= MODE_ADDER1;
            end
        end

        MODE_ADDER1 : begin
            p <= sum;
            if (i[0]) begin // lower half
                i <= i - 1;
//                p[NLO:0] <= sum[NLO:0];
                p_over <= overflow0;
            end else begin // higher half
                i <= 1;
                mode <= MODE_MOD0;
                onebit <= overflow1;
//                p[N-1:NLO] <= sum[N-1:NLO];
            end
        end

        MODE_MOD0 : begin
            if (i[0]) begin // psum 0
                cout0 <= cout;
                tmp <= psum;
                i <= i - 1;
            end else begin // psum 1
                cout1 <= cout;
                q <= psum;
                i <= 1;
                mode <= MODE_MOD1;
            end
        end

        MODE_MOD1 : begin
            if (i[0]) begin
                i <= i - 1;
                p_over <= overflow0;
            end else begin
//                p <= sum[N] ? p : sum;
                p <= plr ? p : {1'b0, sum[N-1:0]};
                i <= nmk - 1;
                if (nmk) begin
                    mode <= MODE_SLR;
                end else begin
                    done <= 1;
                    mode <= MODE_START;
                end
            end
        end

        MODE_SLR : begin
            p <= {1'b0, p[N:1]}; // p >> 1;
            if (!i) begin
                done <= 1;
                mode <= MODE_START;
            end else begin
                i <= i - 1;
            end
        end

    endcase
end

endmodule
