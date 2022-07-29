//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of OM-Pipe multiplier
// 
// Dependencies: ShrinkerRound
//////////////////////////////////////////////////////////////////////////////////

module Shrinker #(parameter N=1<<9) (clock, reset, p_in, q_in, rx1, rn, p_out, q_out);

localparam N_CYCLES = 4;
localparam CYCLE_SIZE = $clog2(N_CYCLES);

input wire clock, reset;
input wire [N:0] p_in, q_in;
input wire [N-1:0] rx1, rn;

output wire [N:0] p_out, q_out;

// states of FSM
localparam MODE_SIZE = 3;
localparam [MODE_SIZE-1:0]
    MODE_START    = 1,
    MODE_SHRINK   = 2,
    MODE_WAIT     = 4;
reg [MODE_SIZE-1:0] mode;
reg [CYCLE_SIZE-1:0] i;

reg [N:0] p, q;
wire [N:0] pi, qi, po, qo;
wire done;

assign pi = mode == MODE_START ? p_in : p;
assign qi = mode == MODE_START ? q_in : q;
assign p_out = p;
assign q_out = q;
ShrinkerRound #(N) shrinkerRound(pi, qi, rx1, rn, po, qo, done);

always @(posedge clock) begin
    if (reset) begin
        mode <= MODE_START;
        p <= 0;
        q <= 0;
    end else case (mode)
    
        MODE_START : begin
            mode <= done ? MODE_WAIT : MODE_SHRINK;
            i <= N_CYCLES - 2;
            p <= po;
            q <= qo;
        end
        
        MODE_SHRINK : begin
            mode <= !i ? MODE_START : (done ? MODE_WAIT : MODE_SHRINK);
            i <= i - 1;
            p <= po;
            q <= qo;
        end
        
        MODE_WAIT : begin
            mode <= !i ? MODE_START : MODE_WAIT;
            i <= i - 1;
        end
    endcase
end

endmodule