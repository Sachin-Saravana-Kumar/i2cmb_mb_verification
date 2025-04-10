class i2c_monitor extends ncsu_component#(.T(i2c_transaction));
    
    virtual i2c_if i2c_bus;
    bit transfer_complete;
    i2c_configuration  configuration;
    T monitored_trans;
    ncsu_component #(T) agent;

    function new(string name = "", ncsu_component_base  parent = null); 
        super.new(name,parent);
    endfunction
    
    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    function void set_agent(ncsu_component#(T) agent);
        this.agent = agent;
    endfunction
   bit [6:0] i2c_addr;
   i2c_op_t operation;
   bit [7:0] i2c_data[];

    virtual task run ();
    super.run();
    //i2c_bus.wait_for_reset();
        
    while(1) begin
        monitored_trans = new;
        if(i2c_bus == null) $fatal("sbhjbjhjf");
        if(enable_transaction_viewing) begin
            monitored_trans.start_time = $time;
        end
        i2c_bus.monitor(i2c_addr, operation, i2c_data);
        monitored_trans.addr = i2c_addr;
        monitored_trans.op = operation;
        monitored_trans.data = i2c_data; 
        if(monitored_trans.op == 1'b0) begin
            $display("I2C_BUS WRITE Transfer: addr - %x, data - %p", monitored_trans.addr, monitored_trans.data);
        end
         else begin
            $display("I2C_BUS READ  Transfer: addr - %x, data - %p", monitored_trans.addr, monitored_trans.data);
        end
        //agent.nb_put(monitored_trans);
         if(enable_transaction_viewing) begin
            monitored_trans.end_time = $time;
            monitored_trans.add_to_wave(transaction_viewing_stream);
            end
        end
    endtask
endclass


