module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  	reg		valid;
output  	reg		encode;
output  	reg		finish;
output 		reg [3:0] 	offset;
output 		reg [2:0] 	match_len;
output 	 	reg [7:0] 	char_nxt;

reg [3:0] State, NextState;
reg [7:0] s_l[16:0] ;
reg [7:0] sh[8:0];
reg [7:0] l_a[7:0];
reg [7:0] datamem [2047:0];
reg [10:0] memcount;
reg [3:0] look_count;
reg [3:0] search_count;
reg [3:0] k;
// reg [3:0] t [7:0];
wire [3:0] t [7:0];
assign t[7]=s_l[16-k]===l_a[7];
assign t[6]=s_l[15-k]===l_a[6];
assign t[5]=s_l[14-k]===l_a[5];
assign t[4]=s_l[13-k]===l_a[4];
assign t[3]=s_l[12-k]===l_a[3];
assign t[2]=s_l[11-k]===l_a[2];
assign t[1]=s_l[10-k]===l_a[1];
assign t[0]=s_l[9-k]===l_a[0];

reg [3:0] searching;

parameter S0=2'b00, S1=2'b01,S2=2'b10, S3=2'b11;
integer i,j,m;

always @(posedge clk or posedge reset)
	begin
		if(reset)
			begin
			State<=S0;
			end
		else if(!reset && State==S0)
			State<=S1;
		else
			State<=NextState;
	end

always @(posedge clk or posedge reset)
	begin
	if(reset)
		begin
		memcount<=2047;look_count<=0;
		end
	else
		begin
		case(State)
			S0:	begin /*RESET*/
					datamem[2047] <= chardata;
					for(i=0;i<2047;i=i+1)
						datamem[i] <= 8'h0;
				end
			S1: begin /*lookahead沒有值補值 */
					if(memcount)
						begin
							datamem[memcount-1] <= chardata;	
							memcount<=memcount-1;
						end
					else	
						begin
							look_count<=8;
						end
				end
			S2: begin /*lookahead沒有值補值 */
					if(look_count)/*look_count是我要補得值，一開始預設8*/
					begin	
							for(m=8;m>0;m=m-1)/*search*/
								begin
								sh[m]<=sh[m-1];
								s_l[m+8]<=s_l[m+8-1];	
							end	
							sh[0]<= l_a[7];
							s_l[8]<=s_l[7];
							for(i=7;i>0;i=i-1)
								begin
								l_a[i]<=l_a[i-1];
								s_l[i]<=s_l[i-1];
							end	
							l_a[0]<=datamem[2047];
							s_l[0]<=datamem[2047];
							for(j=2047;j>0;j=j-1)/*datamem*/
								begin
								datamem[j]<= datamem[j-1];
								end
							datamem[0]<=8'h24;
							look_count<=look_count-1;
					end
					else
						look_count<=look_count;
				searching<=8;
				k<=0;
				end
			S3:	begin/*matching*/
						s_l[16]<=sh[8];
						s_l[15]<=sh[7];
						s_l[14]<=sh[6];
						s_l[13]<=sh[5];
						s_l[12]<=sh[4];
						s_l[11]<=sh[3];
						s_l[10]<=sh[2];
						s_l[9]<=sh[1];
						s_l[8]<=sh[0];
						s_l[7]<=l_a[7];
						s_l[6]<=l_a[6];
						s_l[5]<=l_a[5];
						s_l[4]<=l_a[4];
						s_l[3]<=l_a[3];
						s_l[2]<=l_a[2];
						s_l[1]<=l_a[1];
						s_l[0]<=l_a[0];
						begin
							if(k<=8&&searching>0)	
								begin
									// t[7]<=s_l[16-k]===l_a[7];
									// t[6]<=s_l[15-k]===l_a[6] ;
									// t[5]<=s_l[14-k]===l_a[5];
									// t[4]<=s_l[13-k]===l_a[4];
									// t[3]<=s_l[12-k]===l_a[3];
									// t[2]<=s_l[11-k]===l_a[2];
									// t[1]<=s_l[10-k]===l_a[1];
									// t[0]<=s_l[9-k]===l_a[0];
									
									begin 
										case(searching)
										8:	if(t[7]&t[6]&t[5]&t[4]&t[3]&t[2]&t[1])/*7match*/
													begin
														offset<=8-k;
														match_len<=7;
														char_nxt<=l_a[0];
													k<=0;
													searching<=0;
													look_count<=8;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
												begin
												k<=0;
												searching<=searching-1;
											end
										7:	if(t[7]&t[6]&t[5]&t[4]&t[3]&t[2])/*6match*/
													begin
														offset<=8-k;
														match_len<=6;
														char_nxt<=l_a[1];
													k<=0;
													searching<=0;
													look_count<=7;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
												begin
												k<=0;
												searching<=searching-1;
											end
										6:	if(t[7]&t[6]&t[5]&t[4]&t[3])/*5match*/
													begin
														offset=8-k;
														match_len=5;
													char_nxt<=l_a[2];
													k<=0;
													searching<=0;
													look_count<=6;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
												begin
												k<=0;
												searching<=searching-1;
											end
										5:	if(t[7]&t[6]&t[5]&t[4])/*4match*/
													begin
														offset<=8-k;
														match_len<=4;
													char_nxt<=l_a[3];
													k<=0;
													searching<=0;
													look_count<=5;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
											begin
												k<=0;
												searching<=searching-1;
											end
										4:	if(t[7]&t[6]&t[5])/*3match*/
													begin
														offset<=8-k;
														match_len<=3;
														char_nxt<=l_a[4];
													searching<=0;
													k<=0;
													look_count<=4;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
											begin
												k<=0;
												searching<=searching-1;
											end
										3:	if(t[7]&t[6])/*2match*/
													begin
														offset<=8-k;
														match_len<=2;
														char_nxt<=l_a[5];
													k<=0;
													searching<=0;
													look_count<=3;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
											begin
												k<=0;
												searching<=searching-1;
											end
										2:	if(t[7])/*1match*/
													begin
														offset<=8-k;
														match_len<=1;
														char_nxt<=l_a[6];
													k<=0;
													searching<=0;
													look_count<=2;
													search_count<=1;
													end
											else if(k<8)
											begin
												k<=k+1;
												searching<=searching;
											end
										    else
											begin
												k<=0;
												searching<=searching-1;
											end
										1:			/*no match*/
													begin
														k<=0;
														offset<=0;
														match_len<=0;
														char_nxt<=l_a[7];
														searching<=0;
														look_count<=1;
														search_count<=1;
													end

										endcase
									end
								end
							else
								k<=0;
						end
				end
				
		endcase
		end
	end
always @(posedge clk or posedge reset)
	begin
	if(reset)
		begin
		finish<=1'b0;
		encode<=1'b1;
		end
	else if(char_nxt==8'h24 && l_a[7]==8'h24 )
		begin
			finish<=1'b1;
		end
	else
		begin
		finish<=1'b0;
		encode<=1'b1;
		end
	end


always @(posedge clk or posedge reset)
	begin
	if(reset)
		begin
		end
	else
		begin
		case(State)
			S0: begin /*NON*/	
						NextState <= S1;
				end
			S1: begin
					if(datamem[0]>0)	
						NextState = S2;
					else
						NextState = S1;
						
				end
			S2: begin 
					if(look_count)	
						NextState <= S2;
					else
						begin
						NextState <= S3;
						end	
				end
			S3: begin 
					if(searching)	
					begin
						NextState <= S3;
						end
					else
					begin
						NextState <= S2;
					end
				end
			
		endcase
		end
	end
always @(*)
	begin
		case(State)
			S0: begin 
				valid<=1'b0; 	 	
				end  
			S1:	begin 
					
				end 
			
			S2:	begin  
					 valid<=1'b0;
				end
			S3:	begin  
				
				if(NextState==S2)
					begin
						valid<=1'b1; 
					end
				else
					begin
						valid<=1'b0; 
					end
				
				end
		endcase
	end

endmodule
