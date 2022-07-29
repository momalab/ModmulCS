//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of Multiplier
// 
// Dependencies: SllBarrel
//////////////////////////////////////////////////////////////////////////////////

module PreMain #(parameter N=1<<9, N_CYCLES=N+1)
(
    clock, reset, in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3, in_k,
    out_a, out_b, out_r, out_rn, out_rm, out_rx1, out_rx2, out_rx3, out_k, done
);

localparam LOGN = $clog2(N);
localparam LOGC = $clog2(N_CYCLES);

input wire clock, reset;
input wire [N-1:0] in_a, in_b, in_r, in_rn, in_rm, in_rx1, in_rx2, in_rx3;
input wire [LOGN:0] in_k;

output wire [N-1:0] out_a, out_b;
output reg  [N-1:0] out_r, out_rn, out_rm, out_rx1, out_rx2, out_rx3;
output reg [LOGN:0] out_k;
output reg done;

// states of FSM
localparam MODE_SIZE = 6;
localparam [MODE_SIZE-1:0]
    MODE_START    =  1,
    MODE_SLL_A    =  2,
    MODE_SLL_AB   =  4,
    MODE_SLL_B    =  8,
    MODE_SLL_BOUT = 16,
    MODE_WAIT     = 32;
reg [MODE_SIZE-1:0] mode;

reg [N-1:0] a, b;
reg [LOGN-1:0] i, j, nmk; // nmkm1;
//reg [LOGC-1:0] i;

// SllBarrel
wire [N-1:0] sllin, sllout;
wire [LOGN-1:0] shift;
wire sllreset, slldone;
assign sllreset = mode[0];
assign sllin = mode[0] ? in_a : b;
assign shift = mode[0] ? N - in_k : nmk; // nmkm1;   
SllLog #(LOGN) sll(clock, sllreset, sllin, shift, sllout, slldone); 

// output
assign out_a = a;
assign out_b = b;

always @(posedge clock) begin
    if (reset) begin
        mode <= MODE_START;
        out_r <= 0;
        out_rn <= 0;
        out_rm <= 0;
        out_rx1 <= 0;
        out_rx2 <= 0;
        out_rx3 <= 0;
        out_k <= 0;
        done <= 0;
        a <= 0;
        b <= 0;
        
    end else case (mode)
    
        MODE_START : begin
            mode <= MODE_SLL_A;
            i <= N_CYCLES - 2;
            j <= LOGN - 1;
            done <= 0;
//            a <= in_a;
            b <= in_b;
//            nmkm1 <= N-in_k-1;
            nmk <= N - in_k;
            out_k <= in_k;
            out_r <= in_r;
            out_rn <= in_rn;
            out_rm <= in_rm;
            out_rx1 <= in_rx1;
            out_rx2 <= in_rx2;
            out_rx3 <= in_rx3;
        end
        
        MODE_SLL_A : begin
            if (!j) begin
                mode <= MODE_SLL_AB;
                j <= LOGN - 1;
            end else j <= j - 1;
            i <= i - 1;
        end
        
        MODE_SLL_AB : begin
            mode <= MODE_SLL_B;
            i <= i - 1;
//            j <= j - 1;
            a <= sllout;
        end
        
        MODE_SLL_B : begin
            if (!j) begin
                mode <= MODE_SLL_BOUT;
                j <= LOGN - 1;
            end else j <= j - 1;
            i <= i - 1;
        end
        
        MODE_SLL_BOUT : begin
            if (!i) begin
                mode <= MODE_START;
                done <= 1;
            end else mode <= MODE_WAIT;
            i <= i - 1;
            b <= sllout;
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