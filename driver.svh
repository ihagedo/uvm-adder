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
    DUT_reset();

    forever begin
      seq_item_port.get_next_item(req_item);
      // Drive on the falling edge so the DUT and the monitor see stable inputs on the rising edge
      @(negedge vif.clk);
      vif.a = req_item.a;
      vif.b = req_item.b;
      vif.carry_in = req_item.carry_in;
      vif.valid = 1;
      @(negedge vif.clk);
      vif.valid = 0;
      seq_item_port.item_done();
    end
  endtask: run_phase

  // Hold the DUT in reset for two clocks
  task DUT_reset();
    vif.valid = 0;
    vif.a = 0;
    vif.b = 0;
    vif.carry_in = 0;
    vif.n_rst = 0;
    repeat (2) @(negedge vif.clk);
    vif.n_rst = 1;
  endtask

endclass: driver
