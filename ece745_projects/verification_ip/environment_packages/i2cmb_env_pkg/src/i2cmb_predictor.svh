class i2cmb_predictor extends ncsu_component #(.T(wb_transaction));

   ncsu_component#(.T(i2c_transaction)) scoreboard;
   i2c_transaction transport_trans;
   i2cmb_env_configuration configuration;
   
   bit [6:0] addr;
   bit [7:0] write_data[];
   bit [7:0] read_data[];
   i2c_op_t op;
   bit [2:0] state;
   parameter [2:0] wait_start       = 0,
		            wait_addr        = 1,
                   wait_write_data  = 2,
                   wait_read_data   = 3;

   function new(string name = "", ncsu_component_base parent = null);
      super.new(name, parent);
   endfunction

   function void set_configuration(i2cmb_env_configuration cfg);
      configuration = cfg;
   endfunction

   virtual function void set_scoreboard(ncsu_component#(.T(i2c_transaction)) scoreboard);
      this.scoreboard = scoreboard;
   endfunction

   virtual function void nb_put(wb_transaction trans);
      case(state)
         wait_start:
            begin
               if(trans.address == 2 && trans.we == 1 && trans.data[2:0] == 3'b100) begin
                  state = wait_addr;
               end
            end
         wait_addr:
            begin
               if(trans.address == 1 && trans.we == 1) begin
                  addr = trans.data >> 1;
                  if(trans.data[0]) op = I2C_READ;
                  else op = I2C_WRITE; 
                  if(trans.data[0]) state = wait_read_data; 
                  else state = wait_write_data;

               end
            end
         wait_write_data:
            begin
               //get write data, loop until stop bit
               if(trans.address == 1 && trans.we == 1) begin
                  write_data = new[write_data.size()+1](write_data);
                  write_data[write_data.size()-1] = trans.data;
                  state = wait_write_data;
               end
               //stop bit
               else if(trans.address == 2 && trans.we == 1 && trans.data[2:0] == 3'b101) begin
                  transport_trans = new;
                  transport_trans.addr = addr;
                  transport_trans.op = op;
                  //$display("transport_trans write- addr: %x, op: %x,  data: %d", addr, op, data);
                  transport_trans.data = write_data;
                  scoreboard.nb_transport(transport_trans, null);
                  write_data.delete();
                  state = wait_start;
               end
            end
         wait_read_data:
            begin
               //get read data, loop until stop bit
               if(trans.address == 1 && trans.we == 0) begin 
                  read_data = new[read_data.size()+1](read_data);
                  read_data[read_data.size()-1] = trans.data;
                  state = wait_read_data;
               end
               else if(trans.address == 2 && trans.we == 1 && trans.data[2:0] == 3'b101) begin
                  transport_trans = new;
                  transport_trans.addr = addr;
                  transport_trans.op = op;
                  //$display("transport_trans read- addr: %x, op: %x, data: %d", addr, op, data);
                  transport_trans.data = read_data;
                  scoreboard.nb_transport(transport_trans, null);
                  read_data.delete();
                  state = wait_start;
               end
            end
         default:
            begin
               state = wait_start;
            end
      endcase 
   endfunction

endclass
