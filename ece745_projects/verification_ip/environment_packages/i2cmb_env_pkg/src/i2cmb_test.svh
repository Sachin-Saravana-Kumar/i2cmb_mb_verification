class test_base extends ncsu_component#(.T(ncsu_transaction));

  i2cmb_environment        env;
  i2cmb_generator          gen;

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    
  endfunction

  virtual function void build();
    super.build();
    env = new("env",this);
    env.build();
    gen = new("gen",this);
    gen.set_agent(env.get_wb_agent(),env.get_i2c_agent());
  endfunction

  virtual task run();
    fork 
        env.run();
        gen.run();
    join
  endtask

//   function void check_null_class();
//     if (env == null || gen == null) begin
//       $fatal(1, "Null class handle detected: 'env' is null.");
//     end
//     env.check_null_class();
//     gen.check_null_class();
//   endfunction

  function i2cmb_generator get_gen();
    return gen;
  endfunction

endclass
