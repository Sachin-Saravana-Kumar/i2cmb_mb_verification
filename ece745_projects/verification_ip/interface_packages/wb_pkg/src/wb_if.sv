interface wb_if       #(
      int ADDR_WIDTH = 2,                                
      int DATA_WIDTH = 8                                
      )
(
  // System sigals
  input wire clk_i,
  input wire rst_i,
  input wire irq_i,
  // Master signals
  output reg cyc_o,
  output reg stb_o,
  input wire ack_i,
  output reg [ADDR_WIDTH-1:0] adr_o,
  output reg we_o,
  // Slave signals
  input wire cyc_i,
  input wire stb_i,
  output reg ack_o,
  input wire [ADDR_WIDTH-1:0] adr_i,
  input wire we_i,
  // Shred signals
  output reg [DATA_WIDTH-1:0] dat_o,
  input wire [DATA_WIDTH-1:0] dat_i
  );

    property rst_i_correct;
    @(posedge clk_i)((clk_i==1&&rst_i==1)==0);
  endproperty

  property i2cmb_arbitration;
    @(posedge irq_i) 1'b1;
  endproperty

  property WB_feedback;
    @(posedge clk_i)
    (adr_o == 2) |->
        ((^dat_o[7:4] === 1'bx) ||  // If any bit is x/z, skip
         (dat_o[7:4] == 4'b0000)   || 
         ($countones(dat_o[7:4]) == 1));
   endproperty

assert property(WB_feedback)
    else $error("ERROR: WB_feedback failed at time %0t. dat_o[7:4] = %b", $time, dat_o[7:4]);


assert property(WB_feedback)
    else $error("ERROR: WB_feedback violation at time %0t: dat_o[7:4] = %b", $time, dat_o[7:4]);

  assert property(rst_i_correct) else $error("rst_i was not passed correctly");
  assert property(i2cmb_arbitration) else $error("error in i2cmb arbitration");

  initial reset_bus();
// ****************************************************************************              
   task wait_for_reset();
       if (rst_i !== 0) @(negedge rst_i);
   endtask

// ****************************************************************************              
   task wait_for_num_clocks(int num_clocks);
       repeat (num_clocks) @(posedge clk_i);
   endtask

// ****************************************************************************              
   task wait_for_interrupt();
       @(posedge irq_i);
   endtask

// ****************************************************************************              
   task reset_bus();
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        we_o <= 1'b0;
        adr_o <= 'b0;
        dat_o <= 'b0;
   endtask

// ****************************************************************************              
  task master_write(
                   input bit [ADDR_WIDTH-1:0]  addr,
                   input bit [DATA_WIDTH-1:0]  data
                   );  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= data;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b1;
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        @(posedge clk_i);

endtask        

// ****************************************************************************              
task master_read(
                 input bit [ADDR_WIDTH-1:0]  addr,
                 output bit [DATA_WIDTH-1:0] data
                 );                                                  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= 'bx;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b0;
        @(posedge clk_i);
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        data = dat_i;

endtask        

// ****************************************************************************              
     task master_monitor(
                   output bit [ADDR_WIDTH-1:0] addr,
                   output bit [DATA_WIDTH-1:0] data,
                   output bit we                    
                  );
                         
          while (!cyc_o) @(posedge clk_i);                                                  
          while (!ack_i) @(posedge clk_i);
          addr = adr_o;
          we = we_o;
          if (we_o) begin
            data = dat_o;
          end else begin
            data = dat_i;
          end
          while (cyc_o) @(posedge clk_i); 

         if(adr_o == 2) begin
            if(dat_o[6] == 1) $display("byte NOT ACKNOWLEDGE");
            if(dat_o[5] == 1) $display("Arbitration Lost");
            if(dat_o[4] == 1) $display("Error State");
         end
   endtask 
            

endinterface
