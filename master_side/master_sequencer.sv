class master_sequencer extends uvm_sequencer #(axi_xtn);

  `uvm_component_utils(master_sequencer)


  //========================================================
  // CONSTRUCTOR
  //========================================================

  function new(string name = "master_sequencer",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction

endclass
