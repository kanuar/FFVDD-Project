module router_top_tb();

	// signal declaration
	bit clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
	reg [7:0]datain;
	wire [7:0]data_out_0, data_out_1, data_out_2;
	wire vld_out_0, vld_out_1, vld_out_2, err, busy;
	integer i;

	// calling interface and test 
	router_intf intf(clk,resetn);
	counter_test test(intf);


	// creating DUT instance 
	router_top DUT(.clk(clk),
				   .resetn(resetn),
				   .read_enb_0(read_enb_0),
				   .read_enb_1(read_enb_1),
				   .read_enb_2(read_enb_2),
				   .packet_valid(packet_valid),
				   .datain(datain),
				   .data_out_0(data_out_0),
				   .data_out_1(data_out_1),
				   .data_out_2(data_out_2),
				   .vldout_0(vld_out_0),
				   .vldout_1(vld_out_1),
				   .vldout_2(vld_out_2),
				   .err(err),
				   .busy(busy) );			   
				   
	//clock generation

	always #5 clk=~clk;

	// reset generation as a part of directed testbench cases

	initial
	begin 
		resetn=1;
		#5;
		reset=0;
	end

endmodule