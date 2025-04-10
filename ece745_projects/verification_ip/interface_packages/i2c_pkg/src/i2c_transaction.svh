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