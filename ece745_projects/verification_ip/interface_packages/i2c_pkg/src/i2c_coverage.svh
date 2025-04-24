class i2c_coverage extends ncsu_component#(.T(i2c_transaction));

   i2c_configuration configuration;
   
   bit [6:0] addr;
   i2c_op_t op;
   bit [7:0] data;

   covergroup i2c_transaction_cg;
      option.per_instance = 1;
      option.name = get_full_name();
      address : coverpoint addr {bins used [1] = {7'h22};}
      data : coverpoint data {bins bin_0_63   = {[0:63]};
        bins bin_64_127 = {[64:127]};
        bins bin_128_191 = {[128:191]};
        bins bin_192_255 = {[192:255]};}
      op : coverpoint op;
      address_x_data_x_op : cross address, data, op;
   endgroup

   function new(string name = "", ncsu_component #(T) parent = null);
      super.new(name, parent);
      i2c_transaction_cg = new;
   endfunction

   function void set_configuration(i2c_configuration cfg);
      configuration = cfg;
   endfunction

   virtual function void nb_put(T trans);
      addr = trans.addr;
      data = trans.data[0];
      op = trans.op;
      i2c_transaction_cg.sample();
   endfunction

endclass
