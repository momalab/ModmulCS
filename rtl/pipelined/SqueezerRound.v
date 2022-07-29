//////////////////////////////////////////////////////////////////////////////////
// Company: New York University Abu Dhabi
// Engineer: Eduardo Chielle
//
// Description: part of Squeezer block 
// 
// Dependencies: CarrySaveAdder
//////////////////////////////////////////////////////////////////////////////////

module SqueezerRound #(parameter N=1<<9) (p0, q0, rn, rm, rule, p_out, q_out);

input wire [N:0] p0, q0;
input wire [N-1:0] rn, rm;
input wire [2:0] rule;

output wire [N-1:0] p_out, q_out;

reg [N:0] p1, q1;
wire use_adder;
wire [N:0] p2, q2, rnrm;

assign rnrm = q0[N-2] ? rn : rm;
CarrySaveAdder #(N) csadder_squeezer0(p1, q1, rnrm, p2, q2);

assign use_adder = rule[1];
assign p_out = use_adder ? p2 : p1;
assign q_out = use_adder ? q2 : q1;

always @* begin
    case (rule)
        
        1 : begin
            p1 <= p0;
            q1 <= q0;
        end
        
        2 : begin
            p1 <= { p0[N]    , 2'b00, p0[N-3:0] };
            q1 <= { q0[N:N-1], 1'b0 , q0[N-3:0] };
        end
        
        3 : begin
            p1 <= { p0[N], 2'b00, p0[N-3:0] };
            q1 <= q0;
        end
        
        4 : begin
            p1 <= { p0[N]    , 2'b01, p0[N-3:0] };
            q1 <= { q0[N:N-1], 1'b1 , q0[N-3:0] };
        end
        
        5 : begin
            p1 <= p0;
            q1 <= q0;
        end
        
        default : begin
            p1 <= { p0[N:N-1], 1'b0, p0[N-3:0] };
            q1 <= { q0[N:N-1], 1'b1, q0[N-3:0] };
        end
        
    endcase
end

endmodule
