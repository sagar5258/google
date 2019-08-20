// slave.sv file (DUT)
module slave (
  input bit clk,
  input bit rstn,

  input  abc_valid,
  input  [31:0] abc_data,
  output  abc_ready,

  input  xyz_valid,
  input  [31:0] xyz_data,
  output  xyz_ready
);
  //...
endmodule : slave


// master_if.sv file
interface master_if (
  input bit clk,
  input bit rstn
);
  logic valid;
  logic [31:0] data;
  logic ready;

  clocking drv_cb @(posedge clk);
    output valid;
    output data;
    input ready;
  endclocking

  clocking mon_cb @(posedge clk);
    input valid;
    input data;
    output ready;
  endclocking
endinterface : master_if


// top_defines.sv file
`define TB_TOP slave_tb
define RTL_TOP_PATH TB_TOP.S


// Synethisable TB_TOP
module slave_tb ();
  bit clk;
  bit rstn;

  slave S(.clk(clk),
          .rstn(rstn),
          .abc_valid(),
          .abc_data(),
          .abc_ready(),
          .xyz_valid(),
          .xyz_data(),
          .xyz_ready()
  );

  // Instantiate Interfaces
  // 1. Clock
  // 2. Reset
  // 3. Interrupt

  // Assertions

  `include "slave_force_and_probe.sv"
endmodule : slave_tb

// Non-Synthesizable TB_TOP
module slave_dv();
  // Set Timescale - in module
  timeunit       1ns;
  timeprecision  1ps;

  // Include / Import UVM
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // Import
  //import master_if_pkg::*;
  initial begin
    uvm_config_db#(virtual master_if)::set(null, "*", "master_abc_vif", slave_tb.m_abc_if);
    uvm_config_db#(virtual master_if)::set(null, "*", "master_xyz_vif", slave_tb.m_xyz_if);
  end

  // Reset Interface Import and uvm_config_db set
  // Clock Interface Import and uvm_config_db set
  // Interrupt Interface Import and uvm_config_db set

  initial begin
    // Disable Assertions until Reset Rises (and repeat if reset falls)
    forever begin
      $assertoff;
      @(posedge slave_tb.rstn);
      $asserton;
      @(negedge slave_tb.rstn);
    end
  end

  // Run Test
  initial begin
    $timeformat(-9, 0, " ns", 5); // show time in ns
    // Start UVM
    run_test();
  end

endmodule : slave_dv
