import uvm_pkg::*;
`include "adder_Nbit.sv"
`include "adder_if.svh"
`include "test.svh"

module tb_adder();
  logic clk;

  // generate clock
  initial begin
    clk = 0;
    forever #10 clk = !clk;
  end

  adder_if add_if(clk);

  adder_nbit adder(add_if.adder);
  initial begin
    uvm_config_db#(virtual adder_if)::set(null, "", "adder_vif", add_if);
    run_test("test");
  end
endmodule
