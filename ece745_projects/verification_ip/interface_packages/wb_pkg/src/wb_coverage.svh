class wb_coverage extends ncsu_component#(.T(wb_transaction));
    bit [1:0] address; //register address
   bit we = 0; //operation
   bit [7:0] data; //data

  wb_configuration cfg;

  covergroup wb_transaction_cg;
    option.per_instance = 1;
    option.name = get_full_name();
    data:coverpoint data {bins ranges [4] = {[0:255]};}
    address:coverpoint address{bins used = {1,2};}
    we:coverpoint we;
    address_x_data_x_we: cross we, data, address;
  endgroup

  covergroup register_cg;
    option.per_instance = 1;
    option.name = get_full_name();
    address : coverpoint address {bins valid [4] = {0,1,2,3};}
  endgroup

  function void set_configuration(wb_configuration cfg);
    this.cfg = cfg;
  endfunction
  

  function new(string name = "", ncsu_component_base parent =null);
    super.new(name, parent);
    wb_transaction_cg = new;
    register_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    this.data = trans.data;
    this.we   = trans.we;
    this.address = trans.address;
    wb_transaction_cg.sample();
    register_cg.sample();
  endfunction


endclass