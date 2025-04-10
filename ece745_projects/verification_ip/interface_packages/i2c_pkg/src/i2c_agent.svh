class i2c_agent extends ncsu_component#(.T(i2c_transaction));
  i2c_configuration configuration;
  i2c_driver        driver;
  i2c_monitor       monitor;
  i2c_coverage i2c_cover;
  ncsu_component #(T) subscribers[$];
  virtual i2c_if    i2c_bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
        if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.i2c_bus))) begin;
      $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    super.build();
    //setup driver
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.i2c_bus = this.i2c_bus;
    //setup coverage
      if(configuration.collect_coverage) begin
         i2c_cover = new("i2c_cover", this);
         i2c_cover.set_configuration(configuration);
         i2c_cover.build();
         connect_subscriber(i2c_cover);
      end
    //setup monitor
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 0;
    monitor.i2c_bus = this.i2c_bus;if(i2c_bus == null) $fatal("sbhjbjhjf");
  endfunction

    virtual function void get_bus(virtual i2c_if bus);
      this.i2c_bus= bus;
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
  fork
       monitor.run(); 
  join_none
    endtask

  virtual task run_monitor(T trans);
  super.run();
    if (trans == null) begin
        $fatal("Error: Null transaction passed to bl_put");
    end
    fork
      //monitor.run(); 
      driver.bl_put(trans);
    join

  endtask

endclass