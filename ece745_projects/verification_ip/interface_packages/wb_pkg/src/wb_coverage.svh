// class wb_coverage extends ncsu_component#(.T(wb_transaction_base));
//   bit [7:0] wb_data;
//   bit [1:0] wb_offsets;
//   bit rw;

//   wb_configuration cfg;

//   covergroup coverage_wb_cg;
//     option.per_instance = 1;
//     option.name = get_full_name();
//     data:coverpoint wb_data;
//     offset:coverpoint wb_offsets;
//     op:coverpoint rw;
//     wb_op_x_wb_data_x_wb_offsets: cross rw, wb_data, wb_offsets;
//   endgroup

//   function void set_configuration(wb_configuration cfg);
//     this.cfg = cfg;
//   endfunction
  

//   function new(string name = "", ncsu_component_base parent =null);
//     super.new(name, parent);
//     coverage_wb_cg = new;
//   endfunction

//   virtual function void nb_put(T trans);
//     wb_data = trans. write_data_array_1[0];
//     wb_offsets = trans.offset;
//     rw = trans.rw;
//     coverage_wb_cg.sample();
//   endfunction


// endclass