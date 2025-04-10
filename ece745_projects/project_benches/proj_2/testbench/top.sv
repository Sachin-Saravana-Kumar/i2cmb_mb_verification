`timescale 1ns / 10ps

import i2c_pkg::*;
import wb_pkg::*;
import i2cmb_env_pkg::*;
import ncsu_pkg::*;

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
  .irq_i(irq),
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


i2c_agent    i2c_ag;
wb_agent  wb_ag;
i2cmb_generator gen;
i2cmb_environment env;
test_base tst;


initial begin : write_to_i2c_bus
ncsu_config_db#(virtual i2c_if #(.ADDR_WIDTH(7),.DATA_WIDTH(8) ))::set("tst.env.i2c_agent", i2c_bus);
   
ncsu_config_db#(virtual wb_if #(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)))
                                   ::set("tst.env.wb_agent", wb_bus);
tst = new("tst",null);
tst.build();
tst.run();
$finish;
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

