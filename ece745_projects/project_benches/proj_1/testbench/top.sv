`timescale 1ns / 10ps

import i2c_types::*;

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int ADDR_WIDTH = 7;
parameter int DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl_o;
tri  [NUM_I2C_BUSSES-1:0] sda_o;
tri  [NUM_I2C_BUSSES-1:0] scl_i;
tri  [NUM_I2C_BUSSES-1:0] sda_i;
tri  [NUM_I2C_BUSSES-1:0] scl_ox;
tri  [NUM_I2C_BUSSES-1:0] sda_ox;
tri  [NUM_I2C_BUSSES-1:0] scl_ix;
tri  [NUM_I2C_BUSSES-1:0] sda_ix;

localparam bit[1:0] CSR_offset =2'd00;
localparam bit[1:0] DPR_offset = 2'd01;
localparam bit[1:0] CMDR_offset = 2'd02;
localparam bit[1:0] FSMR_offset = 2'd03;
bit [WB_DATA_WIDTH-1:0] csr_value;
bit [WB_DATA_WIDTH-1:0] dpr_value;
bit [WB_DATA_WIDTH-1:0] cmdr_value;
bit [WB_DATA_WIDTH-1:0] fsmr_value;

typedef enum bit { WB_WRITE = 0 , WB_READ = 1 } wb_op_t;

// ****************************************************************************
// Instantiate the Slave I2C Bus Functional Model
i2c_if #(
        .ADDR_WIDTH(7),     // 7-bit address for I2C
        .DATA_WIDTH(8)      // 8-bit data width for I2C
    ) i2c_bus (
        .scl_o(scl_i[0]),
        .sda(sda_i[0]),
        .scl_i(scl_o[0]),         // I2C clock input (slave side)
        .sda_i(sda_o[0])          // I2C data input (slave side)
    );

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Clock generator
initial begin : clk_gen
  clk = 0;
  forever #5 clk = ~clk;
end

// ****************************************************************************
// Reset generator
initial begin : rst_gen
  rst = 1;
  #113 rst = 0; 
end

// ****************************************************************************
//Monitor Wishbone bus and display transfers in the transcript
initial begin : wb_monitoring
bit [WB_ADDR_WIDTH-1:0] trans_adr;
bit [WB_DATA_WIDTH-1:0] trans_data;
bit trans_we;
wb_op_t we;
forever begin
  wb_bus.master_monitor(.addr(trans_adr),.data(trans_data),.we(trans_we));
  if(trans_adr == 1)begin
    we = trans_we ? WB_WRITE : WB_READ;
  $display("Time: %t | Addr: %h | Data: %d  | WE: %d", $time, trans_adr, trans_data, trans_we);
  end
  #1 ;
end
end

task reset_core();
begin
  csr_value = 8'b0xxx_xxxx; // enable core
  wb_bus.master_write(.addr(CSR_offset), .data(csr_value));
end
endtask
task enable_core_ie();
begin
  csr_value = 8'b11xx_xxxx; // enable core
  wb_bus.master_write(.addr(CSR_offset), .data(csr_value));
end
endtask

task wait_for_irq();
begin
  wait(irq);
  wb_bus.master_read(.addr(CMDR_offset), .data(cmdr_value));
end
endtask

task set_bus(input int bus_id);
begin
  dpr_value = bus_id;
  wb_bus.master_write(.addr(DPR_offset), .data(dpr_value));
  cmdr_value = 8'bxxxx_x110; // set bus command
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  wait_for_irq();
end
endtask

task start_cmd(input bit[8:0] slave_addr);
begin
  //while(!irq)begin
  //set_bus(0);
  cmdr_value = 8'bxxxx_x100; // start
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  //end
  wait_for_irq();
  dpr_value = slave_addr; // slave address
  wb_bus.master_write(.addr(DPR_offset), .data(dpr_value));
end
endtask

task set_write();
begin
  cmdr_value = 8'bxxxx_x001;    // write 
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  wb_bus.master_read(.addr(CMDR_offset), .data(cmdr_value));
  wait_for_irq();
end
endtask

task write_data(input int data);
begin
  wb_bus.master_write(.addr(DPR_offset), .data(data));
  cmdr_value = 8'bxxxx_x001; 
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  wait_for_irq();
end
endtask

task stop_cmd();
begin
  cmdr_value = 8'bxxxx_x101;
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  wait_for_irq();
end
endtask


task read_with_nack();
begin
  cmdr_value = 8'bxxxx_x010;    // read with nak 
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
  wb_bus.master_read(.addr(CMDR_offset), .data(cmdr_value));
  wait_for_irq();
end
endtask

task repeat_start();
begin
  cmdr_value = 8'bxxxx_x100; // start
  wb_bus.master_write(.addr(CMDR_offset), .data(cmdr_value));
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
  wb_bus.master_read(.addr(DPR_offset), .data(data));
stop_cmd();
end
endtask
// ****************************************************************************
// Define the flow of the simulation
initial begin : test_flow
int data;
@(negedge rst)
repeat(3) @(posedge clk);
//reset_core();
enable_core_ie();
set_bus(0);  
start_cmd({7'h44});
set_write();
for(int i = 0; i<32; i++) begin     
write_data(i);
end
stop_cmd();
start_cmd({8'h45});
set_write();
for(int i = 0; i<32; i++) begin  
  read_with_nack();
  wb_bus.master_read(.addr(DPR_offset), .data(data));
end
stop_cmd();
reset_core();
enable_core_ie();
set_bus(0);
for(int i = 64; i<128; i++) begin     
write(i);
read();
end

end


initial begin : i2c_monitoring
bit [ADDR_WIDTH-1:0] trans_adr ;
bit [DATA_WIDTH-1:0] trans_data [];
int size;
i2c_types::i2c_op_t trans_we;
forever begin
  i2c_bus.monitor(.addr(trans_adr),.op(trans_we),.data(trans_data));
  $display("///////////////////////////////i2c_monitors_data_starts/////////////////////////////////////");
  size = trans_data.size();
  for (int i = 0; i < size; i++) begin
    $display("Time: %t |Addr: %h | Data: %d | WE: %d ", $time, trans_adr, trans_data[i] , trans_we);
  end
  $display("///////////////////////////////i2c_monitors_data_ends/////////////////////////////////////");
end
end


initial begin : write_to_i2c_bus
bit [DATA_WIDTH-1:0] read_i2c_data [32];
bit [DATA_WIDTH-1:0] read_i2c[1];
bit transfer_complete;
i2c_types::i2c_op_t trans_i2c_we;
bit [DATA_WIDTH-1:0] trans_i2c_data [];
for(int i=00;i<32;i++) read_i2c_data [i] = i + 100;
forever begin
i2c_bus.wait_for_i2c_transfer(trans_i2c_we,trans_i2c_data);
if(trans_i2c_we == I2C_READ)begin 
i2c_bus.provide_read_data(read_i2c_data, transfer_complete); 
end
if(transfer_complete) begin
  transfer_complete = 0;
break;
end
end

//alternate writes and read for 64 transfers
read_i2c[0] = 63;
forever begin
i2c_bus.wait_for_i2c_transfer(trans_i2c_we,trans_i2c_data);
if(trans_i2c_we == I2C_READ)begin 
i2c_bus.provide_read_data(read_i2c, transfer_complete); 
end
if(transfer_complete) begin 
  transfer_complete = 0;
read_i2c[0] = read_i2c[0] - 1;
end
end
end


// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl_i),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda_i),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl_o),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda_o)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule

