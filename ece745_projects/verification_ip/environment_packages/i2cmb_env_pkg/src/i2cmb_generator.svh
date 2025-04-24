class i2cmb_generator extends ncsu_component;

   i2c_transaction i2c_trans;
   i2c_rand_transaction i2c_rand;
   wb_transaction wb_trans;
   wb_rand_transaction wb_rand;
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

   task er_handling_test();
      $display("Invalid Register Address Handling Test Begin");
      enable_core_ie();

      //read original value of reg
      read_reg_val(2'd0);
      original_data[0] = wb_trans.data;
      $display("Default value of CSR : %b",original_data[0]);
      read_reg_val(2'd1);
      original_data[1] = wb_trans.data;
      $display("Default value of DPR : %b",original_data[1]);
      read_reg_val(2'd2);
      original_data[2] = wb_trans.data;
      $display("Default value of CMDR : %b",original_data[2]);
      read_reg_val(2'd3);
      original_data[3] = wb_trans.data;
      $display("Default value of FSMR : %b",original_data[3]);

      //write to register
      wb_trans = new;
      wb_trans.address = 1;
      wb_trans.data = 8'h05;
      wb_ag.bl_put(wb_trans);


      //check alaising
      read_reg_val(2'd0);
      post_transaction_data[0] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[0]);
      read_reg_val(2'd1);
      post_transaction_data[1] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[1]);
      read_reg_val(2'd2);
      post_transaction_data[2] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[2]);
      read_reg_val(2'd3);
      post_transaction_data[3] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[3]);

      if(post_transaction_data[0] == 8'b11000000 &&
         post_transaction_data[1] == 8'b00000000 &&
         post_transaction_data[2] == 8'b10000000 &&
         post_transaction_data[3] == 8'b00000000   ) begin
         $display("RESULTS: CORRECT VALUES RECIEVED");
      end
      else begin
         $display("RESULTS: INCORRECT VALUES RECIEVED");
      end
      $display("END TEST");

   endtask

      task FSMR_rd_test();
      $display("Invalid Register Address Handling Test Begin");
      enable_core_ie();

      //read original value of reg
      read_reg_val(2'd0);
      original_data[0] = wb_trans.data;
      $display("Default value of CSR : %b",original_data[0]);
      read_reg_val(2'd1);
      original_data[1] = wb_trans.data;
      $display("Default value of DPR : %b",original_data[1]);
      read_reg_val(2'd2);
      original_data[2] = wb_trans.data;
      $display("Default value of CMDR : %b",original_data[2]);
      read_reg_val(2'd3);
      original_data[3] = wb_trans.data;
      $display("Default value of FSMR : %b",original_data[3]);

      //write to register
      wb_trans = new;
      wb_trans.address = 3;
      wb_trans.data = 8'hFF;
      wb_ag.bl_put(wb_trans);


      //check alaising
      read_reg_val(2'd0);
      post_transaction_data[0] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[0]);
      read_reg_val(2'd1);
      post_transaction_data[1] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[1]);
      read_reg_val(2'd2);
      post_transaction_data[2] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[2]);
      read_reg_val(2'd3);
      post_transaction_data[3] = wb_trans.data;
      $display("Post Write Data for CSR: %b", post_transaction_data[3]);

      if(post_transaction_data[0] == 8'b11000000 &&
         post_transaction_data[1] == 8'b00000000 &&
         post_transaction_data[2] == 8'b10000000 &&
         post_transaction_data[3] == 8'b00000000   ) begin
         $display("RESULTS: CORRECT VALUES RECIEVED");
      end
      else begin
         $display("RESULTS: INCORRECT VALUES RECIEVED");
      end
      $display("END TEST");

   endtask

   task default_test();
      $display("Invalid Register Address Handling Test Begin");
      //enable_core_ie();

      //read original value of reg
      read_reg_val(2'd0);
      original_data[0] = wb_trans.data;
      $display("Default value of CSR : %b",original_data[0]);
      read_reg_val(2'd1);
      original_data[1] = wb_trans.data;
      $display("Default value of DPR : %b",original_data[1]);
      read_reg_val(2'd2);
      original_data[2] = wb_trans.data;
      $display("Default value of CMDR : %b",original_data[2]);
      read_reg_val(2'd3);
      original_data[3] = wb_trans.data;
      $display("Default value of FSMR : %b",original_data[3]);

  //check values
      if(original_data[0] == 8'b00000000 &&
         original_data[1] == 8'b00000000 &&
         original_data[2] == 8'b10000000 &&
         original_data[3] == 8'b00000000   ) begin
         $display("RESULTS: CORRECT VALUES RECIEVED");
      end
      else begin
         $display("RESULTS: INCORRECT VALUES RECIEVED");
      end
      $display("TEST END");      
   endtask

   task rand_rd_test();
   fork
      begin : i2c_flow
        i2c_rand = new;
        i2c_rand.generate_random_data(64);
        i2c_ag.bl_put(i2c_rand);
      end
      begin : wb_flow
        reset_core();
        enable_core_ie();
        set_bus(0); 
        start_cmd({8'h45});
        set_write();
        for(int i = 0; i<64; i++) begin  
            read_with_nack();
            wb_trans = new;
            wb_trans.read_data();
            wb_ag.bl_put(wb_trans);
        end
        stop_cmd();
      end
   join
   endtask

   task rand_wr_test();
   fork
      begin : i2c_flow
        i2c_trans = new;
        i2c_ag.bl_put(i2c_trans);
      end
      begin : wb_flow
        reset_core();
        enable_core_ie();
        set_bus(0); 
        start_cmd({8'h44});
        set_write();
        for(int i = 0; i<64; i++) begin
          write_rand_data();
        end
        stop_cmd();
      end
   join
   endtask

   task alternate_test();
  fork
    begin : i2c_flow
            for(int i = 0; i<64;i++)begin
            i2c_trans = new;
            i2c_ag.bl_put(i2c_trans);
            i2c_rand = new;
            i2c_rand.generate_random_data(1);
            i2c_ag.bl_put(i2c_rand);
            if(i2c_rand.transfer_complete) begin 
            i2c_rand.transfer_complete = 0;
            end
            end
    end
    begin : wb_flow
            reset_core();
            enable_core_ie();
            set_bus(0);
            wb_trans = new;
            for(int i = 0; i<64; i++) begin     
            write_rand();
            read();
            end
    end
  join
   endtask

  task arbitration_test();
    begin : wb_flow
    $display("FSM TRANSITIONS COVERAGE TEST BEGIN");
    reset_core();
    enable_core_ie();
    
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    start_cmd({8'h24});
    stop_cmd();
    enable_core_ie();
    reset_core();
    enable_core_ie();
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    start_cmd({8'h24});
    set_write();
        for(int i = 0; i<6; i++) begin
          write_rand_data();
          stop_cmd();
        end
        stop_cmd();
        reset_core();
    enable_core_ie();
    set_bus(0);
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    start_cmd({8'h44});
    set_write();
        for(int i = 0; i<6; i++) begin
          write_rand_data();
              reset_core();
            enable_core_ie();
        end
        stop_cmd();
    start_cmd({8'h45});
    set_write();
        for(int i = 0; i<6; i++) begin  
            read_with_nack();
            wb_trans = new;
            wb_trans.read_data();
            wb_ag.bl_put(wb_trans);
        end
            //read command
            wb_trans = new;
            wb_trans.address = 2;
            wb_trans.data = 8'bxxxxx011;
            wb_ag.bl_put(wb_trans);
            wb_ag.wb_bus.wait_for_interrupt();
            wb_trans = new;
            wb_trans.address = 2;
            wb_trans.we = 1;
            wb_ag.bl_put(wb_trans);
          $display("\nStart, then write address, then write stop");
          start_cmd({8'h44});
          set_write();
          stop_cmd();
          reset_core();
    enable_core_ie();
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    wb_ag.wb_bus.wait_for_interrupt();
    wb_trans.data = 8'bxxxxx001;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx000;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx010;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx011;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
     wb_trans.data = 8'bxxxxx110;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx111;
    wb_ag.bl_put(wb_trans);
    wb_trans.data = 8'bxxxxx101;
    wb_ag.bl_put(wb_trans);
    end
  endtask

  task transitions_test();
  fork
    begin : i2c_flow
      i2c_trans = new;
      i2c_ag.bl_put(i2c_trans);
    end
    begin : wb_flow
    $display("FSM TRANSITIONS COVERAGE TEST BEGIN");
    reset_core();
    enable_core_ie();
    set_bus(1);
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    start_cmd({8'h24});
    set_write();
        for(int i = 0; i<64; i++) begin
          write_rand_data();
        end
        stop_cmd();
        reset_core();
    enable_core_ie();
    set_bus(0);
    $display("Repeated Start Condition Test");
    wb_trans = new;
    wb_trans.address = 2;
    wb_trans.data = 8'bxxxxx100;
    wb_ag.bl_put(wb_trans);
    start_cmd({8'h44});
    set_write();
        for(int i = 0; i<64; i++) begin
          write_rand_data();
        end
        stop_cmd();
    start_cmd({8'h45});
    set_write();
        for(int i = 0; i<64; i++) begin  
            read_with_nack();
            wb_trans = new;
            wb_trans.read_data();
            wb_ag.bl_put(wb_trans);
        end

            //read command
            wb_trans = new;
            wb_trans.address = 2;
            wb_trans.data = 8'bxxxxx011;
            wb_ag.bl_put(wb_trans);
            wb_ag.wb_bus.wait_for_interrupt();
            wb_trans = new;
            wb_trans.address = 2;
            wb_trans.we = 1;
            wb_ag.bl_put(wb_trans);
          $display("\nStart, then write address, then write stop");
          start_cmd({8'h44});
          set_write();
          stop_cmd();
    

    end
  join


  endtask


   virtual task run();
   super.run();
      fork
         begin : i2c_flow
            int j;
            i2c_trans = new;
            i2c_trans.read_queue_data.delete();
            for(int i=28;i<60;i++) begin 
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
            reset_core();
            enable_core_ie();
            set_bus(0);  
            start_cmd({8'h44});
            set_write();
            for(int i = 128; i<160; i++) begin  
            write_data(i);
            end
            stop_cmd();
            start_cmd({8'h45});
            set_write();
            for(int i = 0; i<32; i++) begin  
            read_with_nack();
            wb_trans = new;
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
      wb_trans = new;
      wb_trans.reset_core();
      wb_ag.bl_put(wb_trans);
    end
    endtask

    task enable_core_ie();
    begin
      wb_trans = new;
      wb_trans.enable_core_ie();
      wb_ag.bl_put(wb_trans);
    end
    endtask

    task wait_for_irq();
    begin
      wb_trans = new;
      wb_ag.wb_bus.wait_for_interrupt();
      wb_trans.irq_offset();
      wb_ag.bl_put(wb_trans);
    end
    endtask

    task set_bus(input int bus_id);
    begin
      wb_trans = new;
      wb_trans.set_bus(bus_id);
      wb_ag.bl_put(wb_trans);
      wb_trans = new;
      wb_trans.set_bus_cmd();
      wb_ag.bl_put(wb_trans);
      wait_for_irq();
    end
    endtask

    task start_cmd(input bit[7:0] slave_addr);
    begin
      wb_trans = new;
      wb_trans.start_cmd();
      wb_ag.bl_put(wb_trans);
      wait_for_irq();
      wb_trans = new;
      wb_trans.set_slave_addr(slave_addr);// slave address
      wb_ag.bl_put(wb_trans);
    end
    endtask

    task set_write();
    begin
      wb_trans = new;
      wb_trans.set_write();    // write 
      wb_ag.bl_put(wb_trans);
      wait_for_irq();
    end
    endtask

    task read_reg_val(input bit[1:0] regs);
    begin
      wb_trans = new;
      wb_trans.address = regs;
      wb_trans.we = 1;
      wb_ag.bl_put(wb_trans);
    end
    endtask

    task write_data(input int data);
    begin
      wb_trans = new;
      wb_trans.write_data(data);
      wb_ag.bl_put(wb_trans);
      set_write();
    end
    endtask

    task write_rand_data();
    begin
      wb_rand = new;
      wb_rand.randomize();
      wb_rand.write_data();
      wb_ag.bl_put(wb_rand);
      set_write();
    end
    endtask

    task stop_cmd();
    begin
      wb_trans = new;
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

    task write_rand();
    begin
      start_cmd({8'h44});
      set_write();
      write_rand_data();
      stop_cmd();
    end
    endtask

    task read();
    begin
      int data;
      start_cmd({8'h45});
      set_write();
      read_with_nack();
      wb_trans = new;
      wb_trans.read_data();
      wb_ag.bl_put(wb_trans);
      stop_cmd();
    end
    endtask

endclass



