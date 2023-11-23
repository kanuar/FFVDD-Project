class router_trans;

// signal declaration
	rand bit load;
	rand bit updown;
	rand bit [7:0] data_in,data_out;

//display function

function void display();
	$display("----------------------------");
	$display("\t load = %0b, \n\t updown = %0b, \n\t data_in = %0b, \n\t data_out = %0b",load,updown,data_in,data_out);
	$display("----------------------------");
endfunction

endclass