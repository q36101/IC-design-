module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output     reg  Gout;
output     reg  Yout;
output     reg  Rout;



reg [1:0] State ,NextState;
reg [3:0] Gin_CLK;
reg [3:0] Yin_CLK;
reg [3:0] Rin_CLK;

reg [3:0] Gin_MEM;
reg [3:0] Yin_MEM;
reg [3:0] Rin_MEM;

parameter S0=2'b00, S1=2'b01,S2=2'b10, S3=2'b11;


always @(posedge clk or posedge reset)
	begin
		if(reset)
			State <= S0;	
		else
			State <= NextState;
	end
	
always @(posedge clk)
	begin
		case(State)
			S0:	begin
					if(Gin+Yin+Rin>1'b0)
						begin
							Gin_CLK <= Gin	;
							Yin_CLK <= Yin	;
							Rin_CLK <= Rin	;
							Gin_MEM <= Gin 	;
							Yin_MEM <= Yin	;
							Rin_MEM <= Rin	;
						end
					else
						begin
							Gin_CLK <= Gin_CLK ;
							Yin_CLK <= Yin_CLK ;
							Rin_CLK <= Rin_CLK ;
						end
				end
			S1:begin
					if (Jump)
						begin
							Gin_CLK <= 1'b0	;
							Yin_CLK <= 1'b0	;
							Rin_CLK <= Rin_CLK	;
						end
					else if(Gin_CLK>=1'b1 &~Set & ~Stop)
						Gin_CLK = Gin_CLK-1'b1;
					else if(Gin_CLK>=1'b1 &~Set & Stop)
						Gin_CLK = Gin_CLK;
					else if(Set)
						begin
							Gin_CLK <= Gin	;
							Yin_CLK <= Yin	;
							Rin_CLK <= Rin	;
							Gin_MEM <= Gin 	;
							Yin_MEM <= Yin	;
							Rin_MEM <= Rin	;
						end
					else
						Gin_CLK <= Gin_CLK;
				end	
			S2:	begin
					if (Jump)
						begin
							Gin_CLK <= 1'b0	;
							Yin_CLK <= 1'b0	;
							Rin_CLK <= Rin_CLK	;
						end
					else if(Yin_CLK>=1'b1 & ~Set & ~Stop)
						Yin_CLK <= Yin_CLK-1;
					else if(Yin_CLK>=1'b1 & ~Set & Stop)
						Yin_CLK <= Yin_CLK;
					else if(Set)
						begin
							Gin_CLK <= Gin	;
							Yin_CLK <= Yin	;
							Rin_CLK <= Rin	;
							Gin_MEM <= Gin 	;
							Yin_MEM <= Yin	;
							Rin_MEM <= Rin	;
						end
					
					else
						Yin_CLK <= Yin_CLK;
				end
			S3:	begin		
					if(Rin_CLK>1'b1 & ~Set & ~Stop)	
						Rin_CLK <= Rin_CLK-1;
					else if(Rin_CLK>1'b1 & ~Set & Stop)
						Rin_CLK <= Rin_CLK;
					else if(Set)
						begin
							Gin_CLK <= Gin	;
							Yin_CLK <= Yin	;
							Rin_CLK <= Rin	;
							Gin_MEM <= Gin 	;
							Yin_MEM <= Yin	;
							Rin_MEM <= Rin	;
						end
					else if(Gin_CLK<=1'b0&Yin_CLK <=1'b0 & Rin_CLK<=1'b1 & ~Set)
						begin
							Gin_CLK <= Gin_MEM	;
							Yin_CLK <= Yin_MEM	;
							Rin_CLK <= Rin_MEM	;
						end	
					else
						Rin_CLK <= Rin_CLK;
				end
		endcase
	end



always @(*)
	begin
		case(State)
			S0: begin /*NON*/
					if(Set)	
						NextState = S1;
					else
						NextState = S0;
				end
			S1: begin /*GREEN*/
					if(Jump)
						NextState = S3;
					else if(Gin_CLK <= 1'b1 & ~Set &~Stop)
						NextState = S2;
					else if(Set)
						NextState = S1;
					else if(Gin_CLK<=1'b0&Yin_CLK <=1'b0 & Rin_CLK<=1'b1 & ~Set)
						NextState = S2;
					else
						NextState = S1;
				end
			S2: begin /*YELLOW*/
					if(Jump)
						NextState = S3;
					else if(Yin_CLK <= 1'b1 & ~Set &~Stop)
						NextState = S3;
					else if(Set)
						NextState = S1;
					else
						NextState = S2;
				end
			S3: begin /*RED*/
					if(Rin_CLK <= 1'b1 & ~Set &~Stop)
						NextState = S1;
					else if(Set)
						NextState = S1;
					else
						NextState = S3;
				end
				
		endcase
	end
always @(State)
	begin
		case(State)
			S0: begin 
					Gout=1'b0; Yout =1'b0; Rout = 1'b0; 
				end  
			S1:	begin 
					Gout = 1'b1;  Yout =1'b0; Rout = 1'b0; 
				end 
			
			S2:	begin  
					Yout = 1'b1;   Gout=1'b0; Rout = 1'b0;
				end
			S3:	begin  
					Rout = 1'b1; 	Gout=1'b0; Yout =1'b0;
				end
		endcase
	end
endmodule

	/*
parameter S0=3'b000, S1=2'b001, S2=2'b010, S3=2'b011,S4=2'b100,S5=2'b101,S6=2'b110,S7=2'b111;
always @(*)
	begin
		case(State)
			S0: begin
					if(Gin >= 1)
						Gout = 1;
						Yout <= 1'b0; 
						Rout <= 1'b0;
					else
						Gout <= 1'b0;
				end
			S1: begin
					if(Yin >= 1)
						Yout = 1;    
						Gout <= 1'b0; 
						Rout <= 1'b0;
					else
						Yout <= 1'b0; 
				end
			S2: begin
					if(Rin >= 1)
						Rout = 1; 	 
						Gout <= 1'b0; 
						Yout <= 1'b0;
					else
						Rout <= 1'b0;
				end
			S3: begin
					Gout <= 1'b0;
					Yout <= 1'b0;
					Rout <= 1'b0; 
				end
		endcase
	end
endmodule
*/
/*
    Write Your Design Here ~
*/

/*
reg       [3:0] count;
wire	  
always @(posedge clk or posedge reset)
begin
	if(reset)
		Gout <= 1'b0;
		Yout <= 1'b0;
		Rout <= 1'b0;
	else if(set)
	    always @(Gin)
		begin
			Gout = 1;
			Gin=Gin-1
		end	
		
		always @(Yin)
		begin
			Yout = 1;
			Yin=Yin-1
		end	
		
		always @(Rin)
		begin
			Rout = 1;
			Rin=Rin-1
		end	
	else
		Gout <= 1'b0;
		Yout <= 1'b0;
		Rout <= 1'b0;
end
*/
/*
    Write Your Design Here ~
*/