`include "router_cov.sv"

class router_env;
	
	// signal and instance declaration
	virtual router_gen gen;
	virtual router_bfm bfm;
	virtual router_cov cov;

	mailbox gen2bfm;

	virtual router_intf intf;

	event ended;

	// setter function for a new router interface 
	function new(virtual router_intf i);
		this.intf=i;
		gen2bfm=new();
		gen=new(gen2bfm,ended);
		bfm=new(intf,gen2bfm);
		cov=new();

	endfunction

	// pretest tasks to run before even starting the test cases section of the code
	task pre_test;
		bfm.reset();
	endtask

	// main task section to run test cases
	task test;

		fork
		gen.main();
		bfm.main();
		cov.main();
		// allowing the code to join back the main thread the moment any of the threads end execution
		join_any

	endtask

	// post test cases task to run 
	task post_test;

		pre_test();
		test();
		post_task();
		$finish;

	endtask

endclass