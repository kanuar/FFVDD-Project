module router_fsm(input clk,resetn,packet_valid,
				  input [1:0] datain,
				  input fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid, 
				  output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
				  
 parameter  decode_address		=	4'b0001, 			// assigning state parameters in 4 bit binary form
			wait_till_empty		=	4'b0010,
			load_first_data		=	4'b0011,
			load_data			=	4'b0100,
			load_parity			=	4'b0101,
			fifo_full_state		=	4'b0110,
			load_after_full		=	4'b0111,
			check_parity_error	=	4'b1000;
			
reg [3:0] present_state, next_state;
reg [1:0] temp;
//temp logic
always@(posedge clk)
	begin
		if(~resetn)
			temp<=2'b0;
		else if(detect_add)          // decides the address of out channel
		 	temp<=datain;
	end

// reset logic for states
always@(posedge clk)
	begin
		if(!resetn)
				present_state<=decode_address;  // hard reset
		else if (((soft_reset_0) && (temp==2'b00)) || ((soft_reset_1) && (temp==2'b01)) || ((soft_reset_2) && (temp==2'b10)))		//if there is soft_reset and also using same channel so we do here and opertion
				 
				present_state<=decode_address;

		else
				present_state<=next_state;
			
	end
	
//state machine logic 

always@(*)
	begin
		case(present_state)
		decode_address:   // decode address state 
		// In this state, the router is decoding the destination address (datain) and checking the empty status of the respective FIFO.
		// If packet_valid and the corresponding FIFO is empty, it transitions to the load_first_data state.
		// If packet_valid and the FIFO is not empty, it transitions to the wait_till_empty state.
		// If none of the conditions are met, it remains in the decode_address state.
		begin
			if((packet_valid && (datain==2'b00) && fifo_empty_0)|| (packet_valid && (datain==2'b01) && fifo_empty_1)|| (packet_valid && (datain==2'b10) && fifo_empty_2))

					next_state<=load_first_data;   //lfd_state

			else if((packet_valid && (datain==2'b00) && !fifo_empty_0)||(packet_valid && (datain==2'b01) && !fifo_empty_1)||(packet_valid && (datain==2'b10) && !fifo_empty_2))
					next_state<=wait_till_empty;  //wait till empty state
				
			else 
				next_state<=decode_address;	   // same state
		end

		load_first_data: //In this state, the router transitions to the load_data state unconditionally.
		begin	
			next_state<=load_data;
		end

		wait_till_empty:          //wait till empty state
		// In this state, the router waits until the corresponding FIFO becomes empty.
		// If the FIFO is empty and the same channel (temp) is being used, it transitions back to the load_first_data state.
		// Otherwise, it remains in the wait_till_empty state.
		begin
			if((fifo_empty_0 && (temp==2'b00))||(fifo_empty_1 && (temp==2'b01))||(fifo_empty_2 && (temp==2'b10))) //fifo is empty and were using same fifo
					next_state<=load_first_data;
	
				else
					next_state<=wait_till_empty;
			end

		load_data:        //load data
		// In this state, the router checks if the FIFO is full.
		// If the FIFO is full, it transitions to the fifo_full_state.
		// If the FIFO is not full and there is no packet_valid, it transitions to the load_parity state.
		// If the FIFO is not full and packet_valid is true, it remains in the load_data state.
		begin
			if(fifo_full==1'b1) 
					next_state<=fifo_full_state;
			else 
					begin
						if (!fifo_full && !packet_valid)
							next_state<=load_parity;
						else
							next_state<=load_data;
					end
		end

			fifo_full_state:			//fifo full state
			// In this state, the router waits until the FIFO is no longer full.
			// Once the FIFO is not full, it transitions to the load_after_full state.
			begin
				if(fifo_full==0)
					next_state<=load_after_full;
				else 
					next_state<=fifo_full_state;
			end

			load_after_full:         	// load after full state
			// In this state, the router checks if parity_done is false and low_packet_valid is true.
			// If these conditions are met, it transitions to the load_parity state.
			// If parity_done is false and low_packet_valid is false, it transitions to the load_data state.
			// If parity_done is true, it remains in the load_after_full state.
			begin
				if(!parity_done && low_packet_valid)
					next_state<=load_parity;
				else if(!parity_done && !low_packet_valid)
					next_state<=load_data;
	
				else 
					begin 
						if(parity_done==1'b1)
							next_state<=decode_address;
						else
							next_state<=load_after_full;
					end
				
			end

			load_parity:             //In this state, the router transitions to the check_parity_error state
			begin
				next_state<=check_parity_error;
			end
			
			check_parity_error:			// check parity error
			// In this state, the router checks if the FIFO is no longer full.
			// If the FIFO is not full, it transitions back to the decode_address state.
			// If the FIFO is still full, it transitions to the fifo_full_state.
			begin
				if(!fifo_full)
					next_state<=decode_address;
				else
					next_state<=fifo_full_state;
			end

			default:					//default state:In the default state, the router transitions to the decode_address state unconditionally.
				next_state<=decode_address; 

		endcase																					// state machine completed
	end
	
// output logic


assign busy=((present_state==load_first_data)||(present_state==load_parity)||(present_state==fifo_full_state)||(present_state==load_after_full)||(present_state==wait_till_empty)||(present_state==check_parity_error))?1:0;//The busy signal is assigned based on multiple states.It is set to 1 if the current state matches any of the following: load_first_data, load_parity, fifo_full_state, load_after_full, wait_till_empty, or check_parity_error.
assign detect_add=((present_state==decode_address))?1:0;//The detect_add signal is assigned 1 if the router is in the decode_address state. It indicates that the router is actively detecting the destination address.
assign lfd_state=((present_state==load_first_data))?1:0;//The lfd_state signal is set to 1 when the router is in the load_first_data state.It reflects that the router is currently loading the first data.
assign ld_state=((present_state==load_data))?1:0;//The ld_state signal is assigned 1 when the router is in the load_data state. It signifies that the router is in the process of loading data
assign write_enb_reg=((present_state==load_data)||(present_state==load_after_full)||(present_state==load_parity))?1:0;//The write_enb_reg signal is set to 1 in multiple states: load_data, load_after_full, and load_parity. It indicates that the router is ready for writing data into the FIFO. In all other states, write_enb_reg is set to 0.
assign full_state=((present_state==fifo_full_state))?1:0;
assign laf_state=((present_state==load_after_full))?1:0;// The laf_state signal is set to 1 when the router is in the load_after_full state. It signifies that the router is loading data after the FIFO is full.
	assign rst_int_reg=((present_state==check_parity_error))?1:0;//The rst_int_reg signal is assigned 1 when the router is in the check_parity_error state.

endmodule
