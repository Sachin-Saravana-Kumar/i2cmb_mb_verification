class wb_transaction extends ncsu_transaction;
    `ncsu_register_object(wb_transaction)

    bit [1:0] address; //register address
   bit we = 0; //operation
   bit [7:0] data; //data

     bit [1:0] CSR_offset  = 2'b00;
  bit [1:0] DPR_offset  = 2'b01;
  bit [1:0] CMDR_offset = 2'b10;
  bit [1:0] FSMR_offset = 2'b11;

  // Register values
  bit [7:0] csr_value  = 8'h00;
  bit [7:0] dpr_value  = 8'h00;
  bit [7:0] cmdr_value = 8'h00;
  bit [7:0] fsmr_value = 8'h00;

   function new(string name = "");
      super.new(name);
   endfunction

     task reset_core();
     we = 0;
    csr_value = 8'b0xxx_xxxx; // Reset bits set
    address = CSR_offset;
    data = csr_value;
  endtask

  task enable_core_ie();

    we = 0;
    csr_value = 8'b1100_0000;
    address = CSR_offset;
    data = csr_value;
  endtask

  task irq_offset();
    we = 1;
    address = CMDR_offset;
  endtask 

  task set_bus(input int bus_id);

    we = 0;
    address = DPR_offset;
    data = bus_id;
  endtask

  task set_bus_cmd();
  we = 0;
    cmdr_value = 8'b0000_0110; // Bus command
    address = CMDR_offset;
    data = cmdr_value;
  endtask

  task start_cmd();
    we = 0;
    cmdr_value = 8'b0000_0100; // Start command
    address = CMDR_offset;
    data = cmdr_value;
  endtask

  virtual task set_slave_addr(input bit [7:0] slave_addr);
    we = 0;
    address = DPR_offset;
    data = slave_addr;
  endtask

  task set_write();
  we = 0;
    cmdr_value = 8'b0000_0001;
    address = CMDR_offset;
    data = cmdr_value;
  endtask

virtual task write_data(input int get_data);
  we = 0;
  address = DPR_offset;
  data = get_data;
endtask

  task stop_cmd();
  we = 0;
    cmdr_value = 8'b0000_0101;
    address = CMDR_offset;
    data = cmdr_value;
  endtask

  task read_with_ack();
  we = 0;
    cmdr_value = 8'b0000_0010;
    address = CMDR_offset; 
    data = cmdr_value;
  endtask

  task read_data();
  we = 1;
  address = DPR_offset;
  endtask



   virtual function string convert2string();
      return {super.convert2string(), $sformatf("address:0x%x write enable:0x%x data:0x%x",
              address, we, data)};
   endfunction

   virtual function void add_to_wave(int transaction_viewing_stream_h);
      super.add_to_wave(transaction_viewing_stream_h);
      $add_attribute(transaction_view_h, address, "address");
      $add_attribute(transaction_view_h, we, "write_enable");
      $add_attribute(transaction_view_h, data, "data");
      $end_transaction(transaction_view_h, end_time);
      $free_transaction(transaction_view_h);
   endfunction
endclass

class wb_rand_transaction extends wb_transaction;
    `ncsu_register_object(wb_rand_transaction)

    randc bit [7:0] rand_data;
    randc bit [6:0] rand_addr;

     function new(string name = "");
      super.new(name);
      endfunction

   function void post_randomize();
      data = rand_data;
   endfunction

   virtual task write_data(input int get_data = rand_data);
      we = 0;
      address = DPR_offset;
      data = get_data;
    endtask

  // virtual task set_slave_addr(input bit [7:0] slave_addr);
  //   we = 0;
  //   address = DPR_offset;
  //   data = slave_addr;
  // endtask

endclass