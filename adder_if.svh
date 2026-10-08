`ifndef ADDER_IF_SVH
`define ADDER_IF_SVH

interface adder_if #(parameter BIT_WIDTH = 4) (input logic clk);
  logic n_rst;

  logic [BIT_WIDTH - 1:0] a;
  logic [BIT_WIDTH - 1:0] b;
  logic carry_in;

  logic [BIT_WIDTH - 1:0] sum;
  logic overflow;

  // Testbench only (not a DUT port): high while a, b and carry_in hold a transaction
  logic valid;

  modport tester
  (
    input sum, overflow, clk,
    output n_rst, a, b, carry_in, valid
  );

  modport adder
  (
    output sum, overflow,
    input n_rst, a, b, carry_in, clk
  );
endinterface

`endif
