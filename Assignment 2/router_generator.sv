class router_gen;

	// signal and instance declaration
		router_trans trans;
		mailbox gen2bfm;
		event ended;
		int repeat_count;

	//setter function for a new instance

	function new(mailbox m, event e);
		this.gen2bfm=m;
		this.ended=e;

	endfunction

	// creating a main task
	task main;
		repeat(repeat_count)
		begin
			trans=new();
			if(!trans.randomize()) $fatal("Randomization Failed");
			gen2bfm.put(trans);
		end
		->ended;
	endtask

endclass