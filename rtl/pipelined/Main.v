//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of OM-Pipe multiplier
// 
// Dependencies: MainRound
//////////////////////////////////////////////////////////////////////////////////

module Main #(parameter N=1<<9, N_CYCLES=N)
(clock, reset, in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3, in_k, in_i, in_p, in_q, a, b, r, rn, rm, rx1, rx2, rx3, k, i, p, q, done);

localparam CLOGN = $clog2(N);

input wire clock, reset;
input wire[N:0] in_p, in_q;
input wire[N-1:0] in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3;
input wire[CLOGN:0] in_k, in_i; // first in_i in the pipeline must be set to k
output reg[N:0] p, q;
output reg[N-1:0] a, b, r, rn, rm, rx1, rx2, rx3;
output reg[CLOGN:0] k, i;
output reg done;

// FSM
localparam MODE_SIZE = 3;
localparam [MODE_SIZE-1:0]
    MODE_START = 1,
    MODE_MAIN  = 2,
    MODE_WAIT  = 4;
reg [MODE_SIZE-1:0] mode;

reg [CLOGN:0] counter;
wire [N:0] feed;
wire ab;
wire [N:0] p_tmp, q_tmp;

MainRound #(N) main0(feed, ab, rx1, rx2, rx3, p, q, p_tmp, q_tmp);

assign ab = a[N-1] & b[N-1];
assign feed = a[N-1] ? {1'b0, b} : 0;

always @(posedge clock) begin
    if (reset) begin
        // reset
        mode <= MODE_START;
        a <= 0; // { {(N){1'bx}} };
        b <= 0; // { {(N){1'bx}} };
        r <= 0;
        rn <= 0;
        rm <= 0;
        rx1 <= 0; // { {(N){1'bx}} };
        rx2 <= 0; // { {(N){1'bx}} };
        rx3 <= 0; // { {(N){1'bx}} };
        k <= 0;
        i <= 0; // { {(CLOGN+1){1'bx}} };
        counter <= 0; // { {(CLOGN+1){1'bx}} };
        p <= 0; // { {(N+1){1'bx}} };
        q <= 0; // { {(N+1){1'bx}} };
        done <= 0;
        
    end else case (mode)
        MODE_START: begin
            // register inputs
            a <= in_a;
            b <= in_b;
            r <= in_r;
            rn <= in_rn;
            rm <= in_rm;
            rx1 <= in_rx1;
            rx2 <= in_rx2;
            rx3 <= in_rx3;
            k <= in_k;
            p <= in_p;
            q <= in_q;
            i <= in_i; // k
            counter <= N_CYCLES; // N-1;
            done <= 0;
            mode <= !in_i ? MODE_WAIT : MODE_MAIN;
        end
        
        MODE_MAIN: begin
            // MainRound
            a <= a << 1;
            p <= p_tmp;
            q <= q_tmp;
            i <= !i ? 0 : i - 1;
            counter <= counter - 1;
            if (counter == 1 || i == 1) begin
                done <= 0;
                mode <= MODE_WAIT;
            end
        end
        
        MODE_WAIT: begin
            // Wait
            counter <= counter - 1;
            if (!counter) begin
                done <= 1;
                mode <= MODE_START;
            end
        end
    endcase
end

endmodule
