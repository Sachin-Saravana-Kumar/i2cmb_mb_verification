class wb_monitor extends ncsu_component#(.T(wb_transaction));
    
    virtual wb_if bus;
    wb_configuration  configuration;

    T monitored_trans;
    ncsu_component #(T) agent;

    function new(string name = "", ncsu_component_base  parent = null); 
        super.new(name,parent);
    endfunction

    function void set_configuration(wb_configuration cfg);
    configuration = cfg;
    endfunction

    function void set_agent(ncsu_component #(T) agent);
        this.agent = agent;
    endfunction

    bit [1:0] addr_val;
    bit we_val;
    bit [7:0] data_val;
   virtual task run();
   super.run();
      bus.wait_for_reset();
      forever begin
         monitored_trans = new("monitored_trans");
         if(enable_transaction_viewing) begin
            monitored_trans.start_time = $time;
         end
         bus.master_monitor(addr_val, data_val, we_val);
         monitored_trans.address = addr_val;
         monitored_trans.we = we_val;
         monitored_trans.data = data_val;
         //$display("wb monitored_trans data: %d", data_val);
         if(addr_val == 1 || addr_val == 2 )
         $display("transferred: addr - %x. data - %x, we - %x", addr_val, data_val, we_val);
         agent.nb_put(monitored_trans);
         if(enable_transaction_viewing) begin
            monitored_trans.end_time = $time;
            monitored_trans.add_to_wave(transaction_viewing_stream);
         end
      end

   endtask

endclass


