class i2cmb_test extends ncsu_component#(.T(ncsu_transaction));

  i2cmb_environment        env;
  i2cmb_generator          gen;
  string             test_name;

  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    if(!$value$plusargs("GEN_TEST_TYPE=%s", test_name)) begin
         $display("FATAL: +GEN_TEST_TYPE plusarg not found on command line");
         $fatal;
      end
  endfunction

  virtual function void build();
    $display("GEN_TEST_TYPE = %s", test_name);
    super.build();
    env = new("env",this);
    env.build();
    gen = new("gen",this);
    gen.set_agent(env.get_wb_agent(),env.get_i2c_agent());
  endfunction

  virtual task run();
    fork 
        env.run();
        begin
          if(test_name == "er_handling") gen.er_handling_test();
          else if(test_name == "FSMR_rd_test") gen.FSMR_rd_test();
          else if(test_name == "check_default_vals") gen.default_test();
          //compulsory test
          else if(test_name == "rand_read") gen.rand_rd_test();
          else if(test_name == "rand_write") gen.rand_wr_test();
          else if(test_name == "rand_alt") gen.alternate_test();
          else if(test_name == "transitions") gen.transitions_test();
          else if(test_name == "feedback_test") gen.arbitration_test();
          else gen.run();
        end
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
