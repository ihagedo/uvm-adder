`ifndef TRANSACTION_SVH
`define TRANSACTION_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"

class transaction #(parameter NUM_BITS = 4) extends uvm_sequence_item;
  rand bit [NUM_BITS - 1:0] a;
  rand bit [NUM_BITS - 1:0] b;
  rand bit carry_in;
  bit [NUM_BITS - 1:0] result_sum;
  bit result_overflow;

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_NOCOMPARE)
    `uvm_field_int(b, UVM_NOCOMPARE)
    `uvm_field_int(carry_in, UVM_NOCOMPARE)
    `uvm_field_int(result_sum, UVM_DEFAULT)
    `uvm_field_int(result_overflow, UVM_DEFAULT)
  `uvm_object_utils_end

  // add constrains for randomization

  function new(string name = "transaction");
    super.new(name);
  endfunction: new

  // if two transactions are the same, return 1
  function int input_equal(transaction tx);
    int result;
    if((a == tx.a) && (b == tx.b) && (carry_in == tx.carry_in)) begin
      result = 1;
      return result;
    end
    result = 0;
    return result;
  endfunction
endclass

`endif
