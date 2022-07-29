/*
    @author: Eduardo Chielle
    Shift Logical Left:
        - constant-time (for regularity)
        - LOGSIZE+1 cycles (trade-off between area and latency)
*/


module SlrLog #(
    parameter LOGSIZE = 8
) (clock, reset, in, shift, out, done);

localparam SIZE = 1<<LOGSIZE;

input  wire clock, reset;
input  wire[SIZE-1:0] in;
input  wire[LOGSIZE-1:0] shift;
output wire[SIZE-1:0] out;
output reg done;

reg [LOGSIZE-1:0] s, counter;
reg [SIZE-1:0] value;
wire isStart, isLastRound;

integer i;

// isLastRound, out
assign isStart = reset || done;
assign isLastRound = counter[LOGSIZE-1];
assign out = value;

// counter
always @(posedge clock) begin
    counter <= isStart ? 1 : counter << 1;
end

// done
always @(posedge clock) begin
    done <= !reset && isLastRound;
end

// shifting value
always @(posedge clock) begin
    if (isStart) s <= shift;
    else if (s) s <= s >> 1;
    else s <= s;
end

// register input and shift left
always @(posedge clock) begin
    if (isStart) value <= in;
    else if (s[0])
    begin
        for (i = 0; i < LOGSIZE; i = i+1) begin
            if (counter[i]) value <= value >> (1<<i);
        end
    end 
    else value <= value;
end

endmodule