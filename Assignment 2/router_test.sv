program router_test(router_intf intf);
	
	router_env env;

	initial 
	begin

		env=new(intf);
		env.gen.repeat_count=10;
		env.run();

	end

endprogram