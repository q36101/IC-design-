`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

input				clk;
input				rst;
input		[7:0]	in_data;
input		[7:0]	data_rd;
output		reg		req;
output		reg		wen;
output		reg[9:0]	addr;
output		reg[7:0]	data_wr;
output		reg		done;


	//--------------------------------------
	//		Write your code here
	//--------------------------------------
reg [3:0] State, NextState;
reg [9:0] datamem_top [31:0];
reg [9:0] datamem_down [31:0];
reg [9:0] datamem_middle [31:0];
reg [6:0] memcount_top;
reg [6:0] memcount_down,caculate,top_count,middle_count,change_count,addr_count;
reg [7:0] d,d1,d2,d3,d13,dd;
parameter S0=2'b00, S1=2'b01,S2=2'b10, S3=2'b11 ;

always @(posedge clk or posedge rst)
	begin
		if(rst)
			begin
			State<=S0;
			end
		else if(!rst && State==S0)
			State<=S1;
		else
			State<=NextState;
	end
always @(posedge clk or posedge rst)
	begin
	if(rst)
		begin	
		memcount_top<=32;
		memcount_down<=32;
		addr<=-1;
		end
	else
		begin
		case(State)
			S0:	begin /*RESET*/				
				end
			S1: begin /*讀數據，上行和下行*/
				if(memcount_top)
					begin/*addr & datamem_top*/
						datamem_top[memcount_top-1] <= in_data;
						memcount_top<=memcount_top-1;
					end
				else	
					begin
					end
				if(memcount_down && memcount_top==0 )
					begin/*datamem_down*/
						datamem_down[memcount_down-1] <= in_data;
						memcount_down<=memcount_down-1;
					end
				else	
					begin
						caculate<=32;
					end			
				end
			S2: begin 
					datamem_middle[caculate-1]<=d;
					caculate<=caculate-1;
					middle_count<=33;
					top_count<=33;
					change_count<=32;				
				end
			S3:	begin
					if(top_count==33)
						begin
							top_count<=top_count-1;
						end
					else if(top_count)
						begin
							addr<=addr+1;
							data_wr<=datamem_top[top_count-1];/*上行存入*/
							top_count<=top_count-1;
						end
					else if(middle_count==33&&top_count==0)
						begin
							middle_count<=middle_count-1;
						end
					else if(middle_count&&top_count==0)
						begin
							addr<=addr+1;
							data_wr<=datamem_middle[middle_count-1];/*中間行存入*/
							middle_count<=middle_count-1;
						end
					else if(change_count&&middle_count==0&&top_count==0)
						begin
						datamem_top[change_count]<= datamem_down[change_count];
						change_count<=change_count-1;	
						end
					else
						begin
						datamem_top[change_count]<= datamem_down[change_count];
						memcount_down<=32;
						memcount_top<=0;
						end
				end
			default:
				begin
				end
		endcase
		end
	end
always @(*)
		begin
		case(State)
			S0: begin 
				req=1'b0;
				end
			S1: begin	
					if(memcount_top)
						begin
						req=1'b1;
						end
					else if(memcount_top==0 && memcount_down==32)
						begin
						req=1'b1;
						end
					else
						begin
						req=1'b0;
						end
				end
			S2: begin
					req=1'b0;
				end
			S3: begin 
					req=1'b0;
				end
			default:
				begin
					req=1'b0;
				end	
		endcase
		end
always @(*)
	begin
		if(addr==992)
		begin	
			done=1'b1;			
		end
		else
			begin
			done=1'b0;
			end
	end
always @(*)
	begin
		if(top_count||middle_count||change_count)
		begin	
			wen=1'b1;			
		end
		else
		begin
			wen=1'b0;
		end
	end
always @(posedge clk)
	begin
		if(caculate)
			begin
									/*d給值*/
				if(datamem_top[caculate]>=datamem_down[caculate-2])
					d1<=(datamem_top[caculate]- datamem_down[caculate-2]);
				else
					d1<=(datamem_down[caculate-2] -datamem_top[caculate]);
				if(datamem_top[caculate-1] >= datamem_down[caculate-1])
					d2<=(datamem_top[caculate-1] - datamem_down[caculate-1]);
				else
					d2<=(datamem_down[caculate-1] - datamem_top[caculate-1]);
				if(datamem_top[caculate-2] >= datamem_down[caculate])
					d3<=(datamem_top[caculate-2] - datamem_down[caculate]);
				else
					d3<=(datamem_down[caculate] - datamem_top[caculate-2]);
							
			end
		else
			begin
				d1<=1'b0;
				d2<=1'b0;
				d3<=1'b0;
			end
	end
always @(posedge clk)
	begin
		if(caculate && caculate!=32 &&caculate!=1)
			begin								/*d比較*/
			if(d1<=d3)
				begin
				dd<=(datamem_top[caculate]+datamem_down[caculate-2])>>1;
				d13<=d1;
				end
			else
				begin
				dd<=(datamem_top[caculate-2]+datamem_down[caculate])>>1;
				d13<=d3;
				end
			if(d2<=d13)
					d<=(datamem_top[caculate-1]+datamem_down[caculate-1])>>1;
				else
					d<=dd;
			end
		else
				begin
					d<=(datamem_top[caculate-1]+datamem_down[caculate-1])>>1;
					dd<=1'b0;
					d13<=1'b0;	
				end
	end
always @(*)
		begin
		case(State)

			S0: begin 
					NextState<=S1;
				end
			S1: begin
					if(memcount_top || memcount_down)
						begin
							NextState <= S1;
						end
					else	
						begin
							NextState <= S2;	
						end		
				end
			S2: begin 
					if(caculate)
						begin
							NextState <= S2;
						end
					else	
						begin
							NextState <= S3;
						end						
				end
			S3: begin 
					if(top_count || middle_count || change_count)
						begin
							NextState <= S3;
						end
					else	
						begin
							NextState <= S1;
						end	

				end
			
		endcase
		end
endmodule