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

  task set_slave_addr(input bit [7:0] slave_addr);
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

task write_data(input int get_data);
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
// class wb_transaction_base extends ncsu_transaction;
//   `ncsu_register_object(wb_transaction_base)

//   // Associative arrays for symbolic access
//   bit [1:0] write_addr[string];
//   bit [7:0] write_data[string];

//   // Basic read/write info
//   bit [1:0] read_addr = 2'b00;
//   bit [7:0] read_data = 8'h00;

//   // Data arrays
//   bit [7:0] write_data_array_1[]; // 32 expected
//   bit [7:0] write_data_array_2[]; // 64 expected
//   bit [7:0] read_data_array_1[]; // 33 expected
//   bit [7:0] read_data_array_2[]; // 64 expected

//   // Control
//   bit rw = 0;
//   bit irq = 0;
//   bit trans_data = 0;

//   // Register offsets


//   bit [1:0] offset = 2'b00;

//   function new(string name = "");
//     super.new(name);
//   endfunction

//   virtual function string convert2string();
//     return {
//       super.convert2string(),
//       $sformatf(
//         "write addr: 0x%x write data: 0x%x read addr: 0x%x read data: 0x%x",
//         write_addr, write_data, read_addr, read_data
//       )
//     };
//   endfunction

//   function bit compare(wb_transaction_base rhs);
//     return ((this.write_data_array_1 == rhs.write_data_array_1) &&
//             (this.write_data_array_2 == rhs.write_data_array_2));
//   endfunction
// endclass


// class wb_transaction_read_p extends wb_transaction_base;
//   `ncsu_register_object(wb_transaction_read_p)

//   function new(string name = "");
//     super.new(name);
//     write_data_array_1 = new[32]; 
//     write_data_array_2 = new[64];
//     read_data_array_1  = new[33]; 
//     read_data_array_2  = new[64];
//   endfunction

//   task reset_core();
//     csr_value = 8'b0xxx_xxxx; // Reset bits set
//     write_addr["reset_core"] = CSR_offset;
//     write_data["reset_core"] = csr_value;
//   endtask

//   task enable_core_ie();
//     csr_value = 8'b1100_0000;
//     write_addr["enable_core_ie"] = CSR_offset;
//     write_data["enable_core_ie"] = csr_value;
//   endtask

//   task read_cmdr();
//     read_addr = CMDR_offset;
//     cmdr_value = read_data;
//   endtask

//   task set_bus(input int bus_id);
//     dpr_value = bus_id[7:0]; // Ensure width
//     write_addr["set_bus"] = DPR_offset;
//     write_data["set_bus"] = dpr_value;
//   endtask

//   task set_bus_cmd();
//     cmdr_value = 8'b0000_0110; // Bus command
//     write_addr["set_bus_cmd"] = CMDR_offset;
//     write_data["set_bus_cmd"] = cmdr_value;
//   endtask

//   task start_cmd();
//     cmdr_value = 8'b0000_0100; // Start command
//     write_addr["start_cmd"] = CMDR_offset;
//     write_data["start_cmd"] = cmdr_value;
//   endtask

//   task set_slave_addr(input bit [6:0] slave_addr);
//     dpr_value = slave_addr;
//     write_addr["set_slave_addr_w"] = DPR_offset;
//     write_data["set_slave_addr_w"] = {slave_addr, 1'b0};
//     write_addr["set_slave_addr_r"] = DPR_offset;
//     write_data["set_slave_addr_r"] = {slave_addr, 1'b1};
//   endtask

//   task set_write();
//     cmdr_value = 8'b0000_0001;
//     write_addr["set_write"] = CMDR_offset;
//     write_data["set_write"] = cmdr_value;
//   endtask

//   task stop_cmd();
//     cmdr_value = 8'b0000_0101;
//     write_addr["stop_cmd"] = CMDR_offset;
//     write_data["stop_cmd"] = cmdr_value;
//   endtask

//   task read_with_ack();
//     cmdr_value = 8'b0000_0010;
//     write_addr["read_with_ack"] = CMDR_offset; 
//     write_data["read_with_ack"] = cmdr_value;
//   endtask

//   task build();
//     reset_core();
//     enable_core_ie();
//     read_cmdr();
//     set_bus(0);
//     set_bus_cmd();
//     start_cmd();
//     set_slave_addr(7'h22);
//     set_write();
//     stop_cmd();
//     read_with_ack();

//     // Initialize data arrays
//     for (int i = 0; i < 32; i++)
//       write_data_array_1[i] = i;

//     for (int i = 0; i < 64; i++)
//       write_data_array_2[i] = i + 64;
//   endtask
// endclass


// // class wb_transaction_alternate_read_p extends wb_transaction_base;
// //     `ncsu_register_object(wb_transaction_alternate_read_p)
// //     static int read_i2c= 63;

// //     function new(string name="");
// //         super.new(name);
// //         read_i2c_data = new[1];
// //     endfunction

// //     function void alternate_i2c(ref bit transfer_complete);
// //         read_i2c_data[0] = read_i2c;
// //         if(transfer_complete) begin
// //             transfer_complete = 0;  
// //             read_i2c = read_i2c - 1;
// //         end
// //     endfunction

// // endclass