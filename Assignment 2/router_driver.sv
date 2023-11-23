// router driver is the same as router bfm

class router_bfm;
	// signal and function declaration 
	virtual router_intf intf;
	mailbox gen2bfm;
	int no_transactions;

	// setter function for new instance 
	function new(virtual router_intf i, mailbox m);
		this.intf=i;
		this.gen2bfm=m;
	endfunction

	// creating a reset task that resets the data stream based on reset toggles 
	task reset;
		wait(intf.resetn);
		$display("Reset initiated");
		intf.bfm_router.load <=0;
		intf.bfm_router.updown <=0;
		intf.bfm_router.data_in <=0;
		intf.bfm_router.data_out <=0;
		wait(!intf.resetn);
		$display("Reset finished")
	endtask

	// creating a main task that covers the non reset points 
	task main;
		forever
		begin
			router_trans trans;
			gen2bfm.get(trans);
			$display("Transaction number = %0d",no_transactions);
			intf.bfm_router.load <=trans.load;
			intf.bfm_router.updown <=trans.updown;
			intf.bfm_router.data_in <=trans.data_in;
			repeat(2)@(posedge intf.clk);
			trans.data_out = intf.bfm_router.data_out;
			trans.display();
			no_transcations++;
		end
	endtask
endclass
