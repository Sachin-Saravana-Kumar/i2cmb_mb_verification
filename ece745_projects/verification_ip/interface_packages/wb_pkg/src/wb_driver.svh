class wb_driver extends ncsu_component#(.T(wb_transaction));

   function new(string name = "", ncsu_component_base parent = null);
      super.new(name, parent);
   endfunction

   virtual wb_if #(2,8) bus;
   wb_configuration configuration;
   wb_transaction wb_trans;

   function void set_configuration(wb_configuration cfg);
      configuration = cfg;
   endfunction


   virtual task bl_put(T trans);
   super.bl_put(trans);
      if(trans.we) bus.master_read(trans.address, trans.data);
      else bus.master_write(trans.address, trans.data);
   endtask
     
endclass

