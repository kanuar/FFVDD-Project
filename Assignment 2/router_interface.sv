interface router_intf(input logic clk,reset);

// signal declaration
	logic load;
	logic updown;
	logic [7:0] data_in,data_out;

// data instream 

clocking bfm_router @(posedge clk);
	default input #1 output #1;
	output load;
	output updown;
	output data_in;
	input data_out;
endclocking

// data outstream

clocking monitor_router @(posedge clk);
	default input #1 output #1;
	input load;
	input updown;
	input data_in;
	input data_out;
endclocking

// modport instance declaration

modport BFM (clocking bfm_router,input clk,reset);
modport MONITOR(clocking monitor_router,input clk,reset);

endinterface