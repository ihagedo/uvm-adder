class comparator extends uvm_scoreboard;
  `uvm_component_utils(comparator)

  uvm_analysis_export#(transaction) expected_export; // to recieve result from predictor
  uvm_analysis_export#(transaction) actual_export; // to recieve result from DUT
  uvm_tlm_analysis_fifo#(transaction) expected_fifo;
  uvm_tlm_analysis_fifo#(transaction) actual_fifo;

  int m_matches, m_mismatches; // number of matches and mismatches

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_matches = 0;
    m_mismatches = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    expected_export = new("expected_export", this);
    actual_export = new("actual_export", this);
    expected_fifo = new("expected_fifo", this);
    actual_fifo = new("actual_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    expected_export.connect(expected_fifo.analysis_export);
    actual_export.connect(actual_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    transaction expected_tx;
    transaction actual_tx;
    forever begin
      expected_fifo.get(expected_tx);
      actual_fifo.get(actual_tx);

      // keep count of number of matches and mismatches (actual vs expected)
      if (expected_tx.compare(actual_tx)) begin
        m_matches++;
        `uvm_info("Comparator", {"Data match: ", actual_tx.convert2string()}, UVM_HIGH)
      end else begin
        m_mismatches++;
        `uvm_error("Comparator", {"Data mismatch\n  expected: ", expected_tx.convert2string(),
                                  "\n  actual:   ", actual_tx.convert2string()})
      end
    end
  endtask

  // A test that compared nothing, or left transactions unpaired, did not check the DUT
  function void check_phase(uvm_phase phase);
    if (m_matches + m_mismatches == 0)
      `uvm_error("Comparator", "No transactions were compared")
    if (expected_fifo.used() != 0 || actual_fifo.used() != 0)
      `uvm_error("Comparator", $sformatf("Unpaired transactions: %0d expected, %0d actual",
                                         expected_fifo.used(), actual_fifo.used()))
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("Comparator", $sformatf("Matches:    %0d", m_matches), UVM_LOW)
    `uvm_info("Comparator", $sformatf("Mismatches: %0d", m_mismatches), UVM_LOW)
  endfunction
endclass
