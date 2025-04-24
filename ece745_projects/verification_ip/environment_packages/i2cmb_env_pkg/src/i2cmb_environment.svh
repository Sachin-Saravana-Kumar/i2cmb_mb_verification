class i2cmb_environment extends ncsu_component;

  i2c_configuration i2c_cfg;
  wb_configuration wb_cfg;
  i2cmb_env_configuration cfg;
  wb_agent          wb_agent1;
  i2c_agent         i2c_agent1;
  i2cmb_predictor         pred;
  i2cmb_scoreboard        scbd;
//   coverage          coverage;


  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 


  virtual function void build();
    super.build();
    cfg = new("env_cfg");
    wb_agent1 = new("wb_agent",this);
    wb_agent1.set_configuration(cfg.wb_agent_config);
    wb_agent1.build();
    i2c_agent1 = new("i2c_agent",this);
    i2c_agent1.set_configuration(cfg.i2c_agent_config);
    i2c_agent1.build();
    pred = new("pred", this);
    pred.set_configuration(cfg);
    pred.build();
    scbd = new("scbd", this);
    scbd.build();
    // coverage = new("coverage", this);
    // coverage.set_configuration(cfg);
    // coverage.build();
    // wb_agent1.connect_subscriber(coverage);
    wb_agent1.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    i2c_agent1.connect_subscriber(scbd);
  endfunction

  function i2c_agent get_i2c_agent();
    return this.i2c_agent1;
  endfunction

  function wb_agent get_wb_agent();
    return this.wb_agent1;
  endfunction

  virtual task i2c_run();
  super.run();
     i2c_agent1.run();
  endtask
  virtual task wb_run();
  super.run();
     wb_agent1.run();
  endtask
  virtual task run();
  super.run();
  wb_agent1.run();
  i2c_agent1.run();
  endtask

endclass
