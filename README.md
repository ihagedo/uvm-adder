# uvm-adder

Worked example 1 of the [SiliconBadgers UVM training](https://github.com/ihagedo/uvm-training). The smallest complete UVM testbench: one agent, a predictor and a comparator around a registered N-bit adder. Start here.

## Run it

From a `uvm-training` checkout (`git clone --recurse-submodules git@github.com:ihagedo/uvm-training.git`):

```bash
cd examples/adder
make run                 # Verilator (default)
make run SIM=questa      # or xcelium, vcs
make run BUG=1           # a DUT that ignores carry_in: watch the comparator catch it
make waves               # FST waves; open with gtkwave
```

Set up the tools first; see the `uvm-training` README. Outside `uvm-training`, point `UVM_HOME` at the `src/` directory of a UVM 1.2 checkout.

A passing run reports `Matches: 25`, `Mismatches: 0` and `PASS test`.

## The design

`adder_nbit` registers `{overflow, sum} = a + b + carry_in` on each rising clock edge; `n_rst` is an active-low asynchronous reset. All signals live in `adder_if`.

## The testbench

```
             adder_sequence
                   │
   test ── environment ─────────────────────────────┐
             │                                      │
             agent                                  │
             ├─ sequencer ──► driver ──► adder_if ──► adder_nbit
             └─ monitor ◄───────────────── adder_if
                 │ adder_ap (inputs)    │ result_ap (inputs + outputs)
                 ▼                      ▼
             predictor ── pred_ap ──► comparator
```

## Walkthrough

Read the files in this order.

1. `adder_Nbit.sv`, `adder_if.svh`: the DUT and the interface. `valid` is a testbench-only signal that marks the clock edges carrying a transaction.
2. `tb_adder.sv`: makes the clock, instantiates the interface and DUT, puts the interface in `uvm_config_db` and calls `run_test()`.
3. `transaction.svh`: inputs `a`, `b`, `carry_in` and results `result_sum`, `result_overflow`. The field macros give it `copy`, `compare` and `print`; inputs are `UVM_NOCOMPARE`, so `compare` checks only the results.
4. `sequence.svh`: 25 randomized transactions, and the sequencer.
5. `driver.svh`: holds reset for two clocks, then drives each transaction on a falling edge with `valid` high for one clock. Driving on the falling edge keeps the rising-edge samples race-free.
6. `monitor.svh`: on each rising edge with `valid` high, sends the inputs to the predictor; on the next falling edge, adds the DUT outputs and sends the result to the comparator.
7. `predictor.svh`: computes the expected result from the inputs.
8. `comparator.svh`: pairs expected and actual transactions through two FIFOs and raises `uvm_error` on a mismatch. In `check_phase` it also fails a test that compared nothing or left transactions unpaired.
9. `agent.svh`, `environment.svh`: build the components and connect the analysis ports.
10. `test.svh`: passes the interface down, starts the sequence, and holds an objection until it finishes.
11. `adder_pkg.sv`: puts all the classes in one package, in dependency order.

## Exercises

1. Run `make run BUG=1`. Which transactions fail, and why only those?
2. Change the DUT width to 8 bits. What else must change?
3. Add a constraint that makes `a + b + carry_in` overflow in about half the transactions, and a test that uses it.
4. Add a covergroup on `a`, `b` and `carry_in` (including the corners 0 and max) to the monitor, and print its coverage in `report_phase`.
