class wb_agent extends ncsu_component#(.T(wb_transaction));
    
  wb_configuration configuration;
  wb_driver        driver;
  wb_monitor       monitor;
  ncsu_component #(T) subscribers[$];
  virtual wb_if    wb_bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
        if ( !(ncsu_config_db#(virtual wb_if)::get(get_full_name(), this.wb_bus))) begin;
        $display(get_full_name());
      $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

    function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    super.build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.bus = this.wb_bus;
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 0;
    monitor.bus = this.wb_bus;
  endfunction

    virtual function void nb_put(T trans);
    foreach (subscribers[i]) subscribers[i].nb_put(trans);
  endfunction

  virtual task bl_put(T trans);
  super.bl_put(trans);
    driver.bl_put(trans);
  endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction
  
  virtual task run();
    super.run();
     fork monitor.run(); join_none
  endtask

endclass