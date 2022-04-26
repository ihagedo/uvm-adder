import uvm_pkg::*;
`include "uvm_macros.svh"
`include "adder_if.svh"

class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)

  virtual adder_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get interface
    if(!uvm_config_db#(virtual adder_if)::get(this, "", "adder_vif", vif)) begin
      `uvm_fatal("Driver", "No virtual interface specified for this test instance");
    end
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    transaction req_item;
    vif.check = 0;

    forever begin
      seq_item_port.get_next_item(req_item);
      DUT_reset();
      vif.a = req_item.a;
      vif.b = req_item.b;
      vif.carry_in = req_item.carry_in;
      #(0.2)
      @(posedge vif.clk);
      seq_item_port.item_done();
    end
  endtask: run_phase

  task DUT_reset();
    @(posedge vif.clk);
    vif.n_rst = 1;
    @(posedge vif.clk);
  endtask

endclass: driver
