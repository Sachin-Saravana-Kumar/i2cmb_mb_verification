class i2cmb_generator extends ncsu_component;

   i2c_transaction i2c_trans;
   wb_transaction wb_trans;
//    wb_rand_transaction wb_rand;
   wb_agent  wb_ag;
   i2c_agent  i2c_ag;
   int alt_write_val = 64;
   int i2c_rand_data;
   string trans_name;
   int success;
   bit [7:0] original_data[4];
   bit [7:0] post_transaction_data[4];

   function new(string name = "", ncsu_component_base parent = null);
      super.new(name, parent);
      //if(!$valcue$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
        // $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
        // $fatal;
      //end
   endfunction

 

   virtual task run();
   super.run();
      fork
         begin : i2c_flow
         int j;
            i2c_trans = new;
            i2c_trans.read_queue_data.delete();
            for(int i=00;i<32;i++) begin 
            i2c_trans.read_queue_data.push_back(i + 100);
            end
            while(!i2c_trans.transfer_complete) begin
            i2c_ag.bl_put(i2c_trans);
            end
            i2c_trans = new;
            i2c_trans.transfer_complete = 0;
            i2c_trans.read_queue_data.delete();
            j=63;
            for(int i = 0; i<128;i++)begin
            i2c_trans.read_queue_data.push_back(j);
            i2c_ag.bl_put(i2c_trans);
            if(i2c_trans.transfer_complete) begin 
            j--;
            i2c_trans.transfer_complete = 0;
            end
            end
         end
         begin : wb_flow
            wb_ag.wb_bus.wait_for_reset();
            wb_ag.wb_bus.wait_for_num_clocks(3);
            //reset_core();
            wb_trans = new;
            enable_core_ie();
            set_bus(0);  
            start_cmd({8'h44});
            set_write();
            wb_trans = new;
            for(int i = 0; i<32; i++) begin     
            write_data(i);
            end
            wb_trans = new;
            stop_cmd();
            start_cmd({8'h45});
            set_write();
            wb_trans = new;
            for(int i = 0; i<32; i++) begin  
            read_with_nack();
            wb_trans.read_data();
            wb_ag.bl_put(wb_trans);
            end
            stop_cmd();
            reset_core();
            enable_core_ie();
            set_bus(0);
            wb_trans = new;
            for(int i = 64; i<128; i++) begin     
            write(i);
            read();
            end
         end
      join
   endtask

   function void set_agent(wb_agent agent1, i2c_agent agent2);
      this.wb_ag = agent1;
      this.i2c_ag = agent2;
      $display(this.wb_ag.wb_bus);
      $display(this.i2c_ag.i2c_bus);
   endfunction

    task reset_core();
    begin
    wb_trans.reset_core();
    wb_ag.bl_put(wb_trans);
    end
    endtask

    task enable_core_ie();
    begin
    wb_trans.enable_core_ie();
    wb_ag.bl_put(wb_trans);
    end
    endtask

    task wait_for_irq();
    begin
    wb_ag.wb_bus.wait_for_interrupt();
    wb_trans.irq_offset();
    wb_ag.bl_put(wb_trans);
    end
    endtask

    task set_bus(input int bus_id);
    begin
    wb_trans.set_bus(bus_id);
    wb_ag.bl_put(wb_trans);
    wb_trans.set_bus_cmd();
    wb_ag.bl_put(wb_trans);
    wait_for_irq();
    end
    endtask

    task start_cmd(input bit[7:0] slave_addr);
    begin
    wb_trans.start_cmd();
    wb_ag.bl_put(wb_trans);
    wait_for_irq();
    wb_trans.set_slave_addr(slave_addr);// slave address
    wb_ag.bl_put(wb_trans);
    end
    endtask

    task set_write();
    begin
    wb_trans.set_write();    // write 
    wb_ag.bl_put(wb_trans);
    wait_for_irq();
    end
    endtask

    task write_data(input int data);
    begin
    wb_trans.write_data(data);
    wb_ag.bl_put(wb_trans);
    set_write();
    end
    endtask

    task stop_cmd();
    begin
    wb_trans.stop_cmd();
    wb_ag.bl_put(wb_trans);
    wait_for_irq();
    end
    endtask


    task read_with_nack();
    begin
    wb_trans.read_with_ack();
    wb_ag.bl_put(wb_trans);
    wait_for_irq();
    end
    endtask


    task write(input int i);
    begin
    start_cmd({8'h44});
    set_write();
    write_data(i);
    stop_cmd();
    end
    endtask

    task read();
    begin
    int data;
    start_cmd({8'h45});
    set_write();
    read_with_nack();
    wb_trans.read_data();
    wb_ag.bl_put(wb_trans);
    stop_cmd();
    end
    endtask

endclass



