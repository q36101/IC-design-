module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  	reg		encode;
output  	reg		finish;
output 	 	reg	[7:0] char_nxt;

reg [7:0] sh[8:0];
reg [1:0] resulting;
reg [2:0] code_len_count;
reg [3:0] code_pos_count;

/*
wire code_pos_count=code_pos;
*/
parameter S0=2'b00, S1=2'b01,S2=2'b10, S3=2'b11;
integer i ,m;
/*
	Write Your Design Here ~
*/
always @(posedge clk or posedge reset)
	begin
		if(reset)
			begin
			finish<=1'b0;
			encode<=1'b0;
			end
		else if(char_nxt==8'h24)
			finish<=1'b1;
		else
			finish<=1'b0;
	end
always @(posedge clk or posedge reset)
	begin
		if(reset)
			begin
			resulting<=0;
			end	
		
		else if(resulting)
			begin			
				if(code_pos_count<=code_pos)
					begin
						for(m=8;m>0;m=m-1)
							begin
								sh[m]<=sh[m-1];	
							end	
						
						
							if(code_len_count<code_len)
								begin
									sh[0]<=sh[code_pos];
									char_nxt<=sh[code_pos];
									code_len_count<=code_len_count+1;
									
								end
							else
								begin
									char_nxt<=chardata;
									sh[0]<=chardata;
									if(code_len_count+1<=code_len)
										
											code_pos_count<=code_pos_count+1;
									else
											code_pos_count<=0;
											code_len_count<=0;
										
								end
						
					end

				else
					begin
					code_len_count<=0;
					code_pos_count<=0;
					for(m=8;m>0;m=m-1)
							begin
								sh[m]<=sh[m-1];	
							end	
						char_nxt<=chardata;
						sh[0]<=chardata;
					end
			end
		else
			begin
				
				code_len_count<=0;
				code_pos_count<=0;	
				char_nxt<=chardata;	
				sh[0]<=chardata;
				resulting<=1;
						
			end
	end
endmodule
		
	
		// /*歸零*/
		// code_len_count<=0;
		// code_pos_count<=0;
		
		// if(code_len_count<=code_len)
			// if(code_pos_count<=code_pos)
				// begin
					// if(code_pos+1>=code_len)/*不找lookahead*/
					// begin
					
					// char_nxt[code_len_count+1]<=sh[code_pos-code_len+code_len_count+1];/*char_nxt[]<=sh[],char_nxt[]<=sh[],....*/
					// char_nxt[0]<=chardata;	

					// code_len_count<=code_len_count+1;
					// end
					// else/*code_pos>code_len*//*找lookahead*/
						// if(code_pos-code_len+code_len_count+1<0)
							// char_nxt[code_len_count+1]<=sh[code_pos-code_len+code_len_count+1+9];/*char_nxt[]<=sh[],char_nxt[]<=sh[],....*/
						// else
						// char_nxt[0]<=chardata;
						// char_nxt[code_len_count+1]<=sh[code_pos_count];/*char_nxt[]<=sh[],char_nxt[]<=sh[],....*/
						// code_len_count<=code_len_count-1;
					
					// begin
					// end
				// end
			// else
				// begin
				// code_pos_count<=code_pos_count+1;
				// end
		// else
			// begin
			// code_len_count<=code_len_count+1;
			// end
			/*
		if(code_len_count<code_len)
				begin
						for(m=8;m>0;m=m-1)
						begin
							sh[m]<=sh[m-1];		
						end
					char_nxt[0]<=chardata;
			
				code_len_count<=code_len_count+1;
				end
		else		
					begin
					sh[m]<=sh[m-1];	
					sh[0]<=chardata;
					code_len_count<=0;
					char_nxt<=chardata;	

					end		
			
			if(resulting=0)
				for(m=8;m>0;m=m-1)
						begin
							sh[m]<=sh[m-1];		
						end
			end
			*/

/*
always @(posedge clk or posedge reset)
	begin
	if(reset)
		begin
		end
	else
		begin
		case(State)
			S0:	begin

				end
			S1: begin
					if(code_len_count<code_len)
						begin
						resulting<=1;
						for(m=8;m>0;m=m-1)
							begin
								sh[m]<=sh[m-1];	
								sh[0]<=chardata;
								code_len_count<=code_len_count+1;
							end	
						end
					else		
						begin
							resulting<=0;
								sh[m]<=sh[m-1];	
								sh[0]<=chardata;
								code_len_count<=0;
						end
									
				end
			S2:	begin		
	
					
						
				end
				
				
			S3:begin
			
				end
		endcase
		end
	end
	*/
/*always @(posedge clk or posedge reset)
	begin
	if(reset)
		begin
		end
	else
		begin
		case(State)
			S0: begin 	
						NextState <= S1;
				end
			S1: begin
					if(resulting)	
						NextState = S1;
					else
						NextState = S2;
						
				end
			S2: begin 
					
				end
			S3: begin 
					
				end
			
		endcase
		end
	end
always @(*)
	begin
		case(State)
			S0: begin 
				finish<=1'b0; encode<=1'b0;	
				end  
			S1:	begin 
					
				end 
			S2:	begin  
					begin
						finish<=1'b0;
					end
				end
			S3:	begin  
			
				end
		endcase
	end
*/


