// Top module: clock, interface, DUT and run_test().

module tb_adder();
  import uvm_pkg::*;
  import adder_pkg::*;

  logic clk;

  // generate clock
  initial begin
    clk = 0;
    forever #10 clk = !clk;
  end

  adder_if add_if(clk);

  adder_nbit adder(add_if.adder);

  initial begin
`ifdef WAVES
    // make WAVES=1: FST on Verilator, VCD elsewhere
`ifdef VERILATOR
    $dumpfile("waves.fst");
`else
    $dumpfile("waves.vcd");
`endif
    $dumpvars(0, tb_adder);
`endif
    uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top", "adder_vif", add_if);
    run_test("test");
  end
endmodule
