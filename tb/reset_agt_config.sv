class reset_agt_config extends uvm_object;

  `uvm_object_utils(reset_agt_config)

  virtual reset_interface rst_if;

  function new(string name = "reset_agt_config");
    super.new(name);
  endfunction

endclass
