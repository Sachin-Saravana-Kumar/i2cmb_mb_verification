class i2c_transaction extends ncsu_transaction;
    `ncsu_register_object(i2c_transaction)

    bit [6:0] addr;
    i2c_op_t  op;
    bit [7:0] data[] ;
    int int_array_data[];
    bit [7:0] byte_queue_data[$];
    bit [7:0] read_queue_data [$];
    bit transfer_complete;

    function new(string name = ""); 
        super.new(name);
    endfunction

    virtual function string convert2string();
      return { super.convert2string(), $sformatf("\nop : 0x%x\nAddress : 0x%x \ndata : %p",
	       op, addr, int_array_data)};
   endfunction

      function bit compare(i2c_transaction rhs);
      return ((this.addr  == rhs.addr) &&
	      (this.op == rhs.op) &&
	      (this.data == rhs.data));
   endfunction

    virtual function void add_to_wave(int transaction_viewing_stream_h);
      super.add_to_wave(transaction_viewing_stream_h);
      $add_attribute(transaction_view_h, addr, "addr");
      $add_attribute(transaction_view_h, op, "op");
      $add_attribute(transaction_view_h, data[data.size()-1], "data");
      $end_transaction(transaction_view_h, end_time);
      $free_transaction(transaction_view_h);
   endfunction
endclass

class i2c_rand_transaction extends i2c_transaction;
    `ncsu_register_object(i2c_rand_transaction);

    bit [7:0] i2c_random_queue[$];

    function new(string name = ""); 
        super.new(name);
    endfunction

    virtual function string convert2string();
      return { super.convert2string(), $sformatf("\nop : 0x%x\nAddress : 0x%x \ndata : %p",
	       op, addr, int_array_data)};
   endfunction

       // Populate the queue with random values
    virtual function void generate_random_data(int num_values = 32);
        // Optional seed control
        i2c_random_queue.delete(); // Clean slate

        for (int i = 0; i < num_values; i++) begin
            i2c_random_queue.push_back($urandom_range(0, 127)); // 7-bit I2C range
        end

        $display("[I2C_TRANSACTION] Random data queue populated:");
        foreach (i2c_random_queue[i])
            $display("  Index %0d: 0x%0h", i, i2c_random_queue[i]);
        read_queue_data = i2c_random_queue;
    endfunction
    
endclass