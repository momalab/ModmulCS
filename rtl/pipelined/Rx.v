//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of main block 
// 
// Dependencies: none
//////////////////////////////////////////////////////////////////////////////////

module Rx #(parameter N=1<<16) (sel, rx1, rx2, rx3, ry);

input wire[1:0] sel;
input wire[N-1:0] rx1, rx2, rx3;
output reg[N-1:0] ry;

always @* begin
    case (sel)
        0 : ry <= 0;
        1 : ry <= rx1;
        2 : ry <= rx2;
        3 : ry <= rx3;
    endcase
end

endmodule
