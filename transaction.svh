class transaction #(parameter NUM_BITS = 4) extends uvm_sequence_item;
  rand bit [NUM_BITS - 1:0] a;
  rand bit [NUM_BITS - 1:0] b;
  rand bit carry_in;
  bit [NUM_BITS - 1:0] result_sum;
  bit result_overflow;

  // compare() checks only the results; the inputs are carried along for messages
  `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_NOCOMPARE)
    `uvm_field_int(b, UVM_NOCOMPARE)
    `uvm_field_int(carry_in, UVM_NOCOMPARE)
    `uvm_field_int(result_sum, UVM_DEFAULT)
    `uvm_field_int(result_overflow, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "transaction");
    super.new(name);
  endfunction: new

  function string convert2string();
    return $sformatf("a=%0d b=%0d carry_in=%0d -> sum=%0d overflow=%0d",
                     a, b, carry_in, result_sum, result_overflow);
  endfunction
endclass
