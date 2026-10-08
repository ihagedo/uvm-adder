// Flex adder, default width of 4 bits.
// Registered: {overflow, sum} = a + b + carry_in, one clock after the inputs.
// Build with +define+ADDER_BUG (make BUG=1) to drop carry_in and watch the testbench catch it.

module adder_nbit #(parameter BIT_WIDTH = 4) (adder_if.adder add_if);
  always_ff @(posedge add_if.clk, negedge add_if.n_rst) begin
    if(add_if.n_rst) begin
`ifdef ADDER_BUG
      {add_if.overflow, add_if.sum} <= (add_if.a + add_if.b);
`else
      {add_if.overflow, add_if.sum} <= (add_if.a + add_if.b + add_if.carry_in);
`endif
    end
    else begin
      add_if.sum <= 0;
      add_if.overflow <= 0;
    end
  end
endmodule
