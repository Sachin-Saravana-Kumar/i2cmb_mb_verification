class i2c_driver extends ncsu_component#(.T(i2c_transaction));

    function new(string name = "", ncsu_component_base parent = null); 
        super.new(name, parent);
    endfunction
    virtual i2c_if #(7,8) i2c_bus;
    i2c_transaction txn;
    i2c_configuration configuration;

    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction


   bit [7:0] read_data[];
    virtual task bl_put(T trans);
    super.bl_put(trans);
    trans.transfer_complete = 0;
    read_data = new[trans.read_queue_data.size()];
    i2c_bus.wait_for_i2c_transfer(trans.op,trans.data);
    if(trans.op == I2C_READ)begin 
        foreach(read_data[i]) begin
             read_data[i] = trans.read_queue_data.pop_front();
        end
        i2c_bus.provide_read_data(read_data, trans.transfer_complete); 
    end
    endtask


endclass
