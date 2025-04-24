import i2c_pkg::*;

interface i2c_if #(
    int ADDR_WIDTH = 7,                                
    int DATA_WIDTH = 8
)(
    output bit scl_o,
    logic  sda,
    input tri scl_i,
    input triand sda_i
);

    int test;
    bit [DATA_WIDTH-1:0] data_queue[$];
    bit bit_queue[8];
    bit [DATA_WIDTH-1:0] data_monitor[$];
    bit [DATA_WIDTH-1:0] read_data_t[];
    bit [DATA_WIDTH-1:0] data_ret[];
    bit bus_is_busy;
    bit [DATA_WIDTH-1:0] first_data;
    bit [DATA_WIDTH-1:0] data_reg;
    bit [6:0] addr_i;
    reg [DATA_WIDTH-1:0] data_in;
    reg [DATA_WIDTH-1:0] data_out;
    bit ack_i;
    bit sda_o;
    bit ch_scl_io;
    i2c_op_t we;
    event complete;
    bit stop;
    bit ack_check ;
    bit [DATA_WIDTH-1:0]monitor_data;
    initial begin
        ch_scl_io = 0;
    assign sda = ch_scl_io ? sda_o : sda_i;
    //assign sda = sda_i;
    assign scl_o =  scl_i;
    end

    property scl_arbitration;
    @(posedge scl_i) 1'b1;
    endproperty

    assert property(scl_arbitration) else $error("error in scl_arbitration");



    task  stop_condition();
            forever begin
                @(posedge sda_i);
                if(scl_i && bus_is_busy) 
                begin
                //bus_is_busy = 0;
                break;
                end
            end
    endtask
    
    
    // Task to wait for I2C transfer
    task wait_for_i2c_transfer(
        output i2c_op_t op,
        output bit [DATA_WIDTH-1:0] write_data[]
    );
        ch_scl_io = 0;
        // Start condition
        wait(scl_i);
        @(negedge sda_i)
        bus_is_busy = 1;
        for(int j = DATA_WIDTH-1;j>=0;j--)begin
                @(posedge scl_i);
                first_data[j] = sda_i;
                @(negedge scl_i);
            end
        addr_i[6:0] = first_data[7:1];
        we = first_data[0] ? I2C_READ : I2C_WRITE;
        op = we;
        if(addr_i != 7'h22)begin
                    ch_scl_io = 1;
                    sda_o = 1'b1;
                @(posedge scl_i);
                @(negedge scl_i);  // nack 1'b1 in sba_o is not ack
                    sda_o = 1'b0;
                    ch_scl_io = 0;
        end
        else begin
                    ch_scl_io = 1;
                    sda_o = 1'b0;
                    @(posedge scl_i);
                    @(negedge scl_i);  // ack 1'b0 in sda is ack 
                    sda_o = 1'b1;
                    ch_scl_io = 0;
        end
    fork //Storing data in queue
        stop_condition();
        begin
            while (bus_is_busy && we == I2C_WRITE) begin
            for (int j = DATA_WIDTH-1; j >= 0; j--) begin
                @(posedge scl_i);
                data_reg[j] = sda_i;  // Sample data bit by bit
                @(negedge scl_i);
            end
            data_queue.push_back(data_reg);  // Store data
            // Send ACK
            ch_scl_io = 1;
            sda_o = 1'b0;
            @(posedge scl_i);
            @(negedge scl_i);
            sda_o = 1'b1;
            ch_scl_io = 0;
        end
        end
    join_any
    disable fork;
        if(we == I2C_WRITE)begin
            write_data = new[data_queue.size()];
            while(data_queue.size()>0) begin
            write_data[data_queue.size()] = data_queue.pop_back();
        end
        end
        else begin
            write_data = new[1];
            write_data[0][7:0] = {0,addr_i};
        end
    endtask

    // Task to provide read data
    task provide_read_data(
        input bit [DATA_WIDTH-1:0] read_data[],
        output bit transfer_complete
    );
        bit [7:0] bit_array;
        we = I2C_READ; 
        ch_scl_io = 0;
        fork
        stop_condition();
        // Storing data in queue
        begin
            forever begin
        for(int byte_count = 0; byte_count < read_data.size(); byte_count++) begin
            for(int j = DATA_WIDTH-1;j>=0;j--)begin
                ch_scl_io = 1;
                sda_o = read_data[byte_count][j];
                @(posedge scl_i);
                @(negedge scl_i);
                sda_o = 1'bz;
                ch_scl_io = 0;
            end 
                @(posedge scl_i);// SDA remains LOW during the 9th clock pulse
                ack_i = sda_i;
                @(negedge scl_i);
                if(byte_count == (test -1)) begin
                    transfer_complete = 1'b1; 
                    break;
                end
            end
            end
        end
        join_any
        disable fork;
        transfer_complete = 1'b1;
    endtask

    // Task to monitor I2C operation
    task monitor(output bit [ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [DATA_WIDTH-1:0] data[]);
        // Start condition
        wait(scl_i == 1);
        @(negedge sda_i);
        for(int j = DATA_WIDTH-1;j>=0;j--)begin
                @(posedge scl_i);
                monitor_data[j] = sda;
                @(negedge scl_i);
            end
        addr = monitor_data[7:1];
        we = monitor_data[0] ? I2C_READ : I2C_WRITE;
        op = we;
        @(posedge scl_i);
        // ack_check = !ack_check & !sda_i;
        @(negedge scl_i);  // ack 1'b0 in sda is ack 
    fork //Storing data in queue
        begin
        // while(bus_is_busy);
        stop_condition();
        end
        begin
            forever begin
            for (int j = DATA_WIDTH-1; j >= 0; j--) begin
                @(posedge scl_i);
                monitor_data[j] = sda;  // Sample data bit by bit
                @(negedge scl_i);
            end
            data_monitor.push_back(monitor_data);  // Store data
            // monitor ACK
            @(posedge scl_i);
            @(negedge scl_i);
        end
        end
    join_any
    disable fork;
            data = new[data_monitor.size()];
            for (int i = data_monitor.size() - 1; i >= 0; i--) begin
                data[i] = data_monitor.pop_back();
            end
    endtask

endinterface

