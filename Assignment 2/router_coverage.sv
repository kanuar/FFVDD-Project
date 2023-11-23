class router_cov;
	
	//signal declaration 
	router_trans trans=new();

	// creating a covergroup for the coverage instance 
	covergroup cov_inst;
		option.per_instance=1;
		LD:coverpoint trans.load {bins ld= {0,1};}
		UD:coverpoint trans.updown {bins ud= {0,1};}
		DIN:coverpoint trans.data_in {bins di= {[0:255]};}
		DO:coverpoint trans.data_out {bins do= {[0:255]};}
	endgroup

	// creating a new covergroup instance
	function new();
		cov_inst=new;
	endfunction

	// creating a main task to run
	task main;
		cov_inst.sample();
	endtask
	
endclass