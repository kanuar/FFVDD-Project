module router_fifo(clk,resetn,soft_reset,write_enb,read_enb,lfd_state,datain,full,empty,dataout);
//INPUT,OUTPUT
input clk,resetn,soft_reset,write_enb,read_enb,lfd_state;
input [7:0]datain;
output reg full,empty;
output reg [7:0]dataout;
//internal Data types
reg [3:0]read_ptr,write_ptr;
reg [5:0]count;
reg [8:0]fifo[15:0];//9 BIT DATA WIDTH 1 BIT EXTRA FOR HEADER AND 16 DEPTH SIZE
integer i;
reg temp;
reg [4:0] incrementer;
//lfd_state:This block monitors the lfd_state signal.
//It stores the state of lfd_state in the temp variable for future reference.
always@(posedge clk)
	begin
		if(!resetn)
			temp<=1'b0;
		else 
			temp<=lfd_state;
	end 

//Incrementer
// This block calculates the incrementer value.
// It takes into account the resetn signal and the read and write operations.
// The incrementer is updated based on whether data is being written or read.
always @(posedge clk )
begin
   if( !resetn )
       incrementer <= 0;

   else if( (!full && write_enb) && ( !empty && read_enb ) )
          incrementer<= incrementer;

   else if( !full && write_enb )
          incrementer <=    incrementer + 1;					//inc is increased because data is written

   else if( !empty && read_enb )									// inc is decrease because data is read
          incrementer <=    incrementer - 1;
   else
         incrementer <=    incrementer;
end

//full and empty logic
// This block determines whether the FIFO is full or empty based on the incrementer value.
// If incrementer is zero, it sets empty to 1, indicating that the FIFO is empty.
// If incrementer is 15 (binary 1111), it sets full to 1, indicating that the FIFO is full.
always @(incrementer)
begin
if(incrementer==0)      //nothing in fifo
  empty = 1 ;
  else
  empty = 0;

  if(incrementer==4'b1111)  // fifo is full
   full = 1;
   else
   full = 0;
end 

//Fifo write logic
// This block handles writing data into the FIFO.
// It considers the resetn, soft_reset, write_enb, and FIFO full status.
// When data is to be written (write_enb is asserted and FIFO is not full), it writes data into the appropriate location in the FIFO based on write_ptr.
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				for(i=0;i<16;i=i+1)
					fifo[i]<=0; 
			end
		
		else if(write_enb && !full)
				{fifo[write_ptr[3:0]][8],fifo[write_ptr[3:0]][7:0]}<={temp,datain}; //temp=1 for header data and 0 for other data
	
	end


//FIFO READ logic
// This block handles reading data from the FIFO.
// It considers the resetn, soft_reset, read_enb, empty status, and count.
// If data is available for reading (read_enb is asserted and FIFO is not empty), it reads data from the FIFO and decrements the internal counter (count) based on whether a header byte is being read.
always@(posedge clk)
	begin
		if(!resetn)
			dataout<=8'd0;

		else if(soft_reset)
			dataout<=8'bzz;
		
		else
			begin 
				if(read_enb && !empty)
					dataout<=fifo[read_ptr[3:0]];
				if(count==0) // COMPLETELY READ
					dataout<=8'bz;
			end
	end

//counter logic
// This block handles the internal counter (count) for tracking payload length.
// When reading a header byte, it loads the counter with the payload length and starts decrementing it every clock cycle until it reaches zero
always@(posedge clk)
	begin
		
		 if(read_enb && !empty)
			begin
				if(fifo[read_ptr[3:0]][8])                          //a header byte is read, an internal counter is loaded with the payload
                                                               //length of the packet plus(parity byte) and starts decrementing every clock till it reached 
					count<=fifo[read_ptr[3:0]][7:2]+1'b1;

				else if(count!=6'd0)
					count<=count-1'b1;
				
			end
	
	end
//pointer logic
// This block updates the read and write pointers for the FIFO.
// It takes into account resetn, soft_reset, write_enb, and read_enb signals.
// When data is written (write_enb is asserted), it increments the write_ptr.
// When data is read (read_enb is asserted), it increments the read_ptr.
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				read_ptr=5'd0;
				write_ptr=5'd0;
			end

		else 
			begin
				if(write_enb && !full)
					write_ptr=write_ptr+1'b1;

				if(read_enb && !empty)
					read_ptr=read_ptr+1'b1;
			end
	end

endmodule
