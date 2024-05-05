module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output reg       result;
output       c_out;
output       set;                 
output       overflow; 

wire		 a_n;
wire		 b_n;   
wire		 a_1;
wire		 b_1;
wire   [3:0] result_op;


not(a_n,a);
not(b_n,b);
assign a_1=Ainvert?a_n:a;
assign b_1=Binvert?b_n:b;
and(result_op[0],a_1,b_1);
or(result_op[1],a_1,b_1);

FA FA_1(.s(result_op[2]), .carry_out(c_out), .x(a_1), .y(b_1), .carry_in(c_in));

assign set = result_op[2];
assign result_op[3] = less;

xor(overflow,c_in,c_out);
	always@(*) 
		case(op)
			2'b00:
				result = result_op[0];
				
			2'b01:
				result = result_op[1];
				
			2'b10:
				result = result_op[2];
				
			default:
				result = result_op[3];
			
		endcase
	
endmodule
