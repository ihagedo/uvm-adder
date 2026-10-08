class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual adder_if vif;

  uvm_analysis_port#(transaction) adder_ap;  // inputs, to the predictor
  uvm_analysis_port#(transaction) result_ap; // inputs and DUT outputs, to the comparator

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    adder_ap = new("adder_ap", this);
    result_ap = new("result_ap", this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual adder_if)::get(this, "", "adder_vif", vif)) begin
      `uvm_fatal("Monitor", "No virtual interface specified for this monitor instance")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      transaction tx;
      @(posedge vif.clk);
      // Only edges where the driver marked a transaction (and reset is released) count
      if (vif.n_rst !== 1'b1 || vif.valid !== 1'b1) continue;
      // The DUT registers these inputs on this edge...
      tx = transaction#(4)::type_id::create("tx");
      tx.a = vif.a;
      tx.b = vif.b;
      tx.carry_in = vif.carry_in;
      adder_ap.write(tx);
      // ...and its outputs are stable by the falling edge
      @(negedge vif.clk);
      tx.result_sum = vif.sum;
      tx.result_overflow = vif.overflow;
      result_ap.write(tx);
    end
  endtask: run_phase
endclass: monitor
