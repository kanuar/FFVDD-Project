
// router driver class
// router driver is the same as router bfm

class router_bfm;
	// signal and function declaration 
	virtual router_intf intf;
	mailbox gen2bfm;
	static integer no_transactions=0;

	// setter function for new instance 
	function new_bfm(virtual router_intf i, mailbox m);
		this.intf=i;
		this.gen2bfm=m;
	endfunction

	// creating a reset task that resets the data stream based on reset toggles 
  task reset();
		wait(intf.resetn);
		$display("Reset initiated");
		intf.bfm_router.load <=0;
		intf.bfm_router.updown <=0;
		intf.bfm_router.data_in <=0;
		intf.bfm_router.data_out <=0;
		wait(!intf.resetn);
   		$display("Reset finished");
  endtask
	// creating a main task that covers the non reset points 
  task main();
		forever
		begin
			virtual router_trans trans;
			gen2bfm.get(trans);
			$display("Transaction number = %0d",no_transactions);
			intf.bfm_router.load <=trans.load;
			intf.bfm_router.updown <=trans.updown;
			intf.bfm_router.data_in <=trans.data_in;
			repeat(2)@(posedge intf.clk);
			trans.data_out = intf.bfm_router.data_out;
			trans.display();
			this.no_transactions++;
		end
  endtask
endclass


// router coverage class


class router_cov;
	
	//signal declaration 
	virtual router_trans trans;

	// creating a covergroup for the coverage instance 
	covergroup cov_inst;
		option.per_instance=1;
		LD:coverpoint trans.load {bins ld= {0,1};}
		UD:coverpoint trans.updown {bins ud= {0,1};}
      	DIN:coverpoint trans.data_in {bins Di= {[0:255]};}
      	DO:coverpoint trans.data_out {bins Do= {[0:255]};}
	endgroup
  	
  function new();
    cov_inst=new();
  endfunction

	// creating a new covergroup instance
	function new_cov();
      cov_inst=new();
	endfunction

	// creating a main task to run
	task main;
		cov_inst.sample();
	endtask
	
endclass
          
          
// router generator class
          
class router_gen;

	// signal and instance declaration
		virtual router_trans trans;
		mailbox gen2bfm;
		event ended;
		int repeat_count;

	//setter function for a new instance

	function new_gen(mailbox m, event e);
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


          
// router interface
          
interface router_intf(input logic clk,resetn);

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

  modport BFM (clocking bfm_router,input clk,resetn);
  modport MONITOR(clocking monitor_router,input clk,resetn);

endinterface

    
// router test program
    
program router_test(router_intf intf);
	
	router_env env;

	initial 
	begin

		env=new(intf);
		env.gen.repeat_count=10;
		env.run();

	end

endprogram
    
// router transaction
    
class router_trans;

  // signal declaration
      rand bit load;
      rand bit updown;
      rand bit [7:0] data_in;
      bit [7:0]data_out;

  //display function

  function void display();
      $display("----------------------------");
      $display("\t load = %0b, \n\t updown = %0b, \n\t data_in = %0b, \n\t data_out = %0b",load,updown,data_in,data_out);
      $display("----------------------------");
  endfunction

endclass
    

// router environment class

class router_env;
	
	// signal and instance declaration
	router_gen gen;
	router_bfm bfm;
	router_cov cov;

	mailbox gen2bfm;

	virtual router_intf intf;

	event ended;

	// setter function for a new router interface 
	function new(virtual router_intf i);
		this.intf=i;
		gen2bfm=new();
		gen.new_gen(gen2bfm,ended);
		bfm.new_bfm(intf,gen2bfm);
		cov.new_cov();

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
    
    
// top module router 
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
		resetn=0;
	end

endmodule
