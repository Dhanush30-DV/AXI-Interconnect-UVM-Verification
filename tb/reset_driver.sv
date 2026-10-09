class reset_driver extends uvm_component;

  `uvm_component_utils(reset_driver)

  reset_agt_config m_cfg;
  virtual reset_interface.RST_DRV_MP rst_if;

  function new(string name = "reset_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(reset_agt_config)::get(this, "", "reset_agt_config", m_cfg))
      `uvm_fatal("RST_DRV", "Cannot get reset_agt_config from uvm_config_db")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rst_if = m_cfg.rst_if;
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this, "Applying reset");

    `uvm_info("RESET_DRIVER", "Asserting reset", UVM_LOW)

    rst_if.rst_drv_cb.reset <= 1'b1;
    repeat (5) @(rst_if.rst_drv_cb);

    rst_if.rst_drv_cb.reset <= 1'b0;

    `uvm_info("RESET_DRIVER", "Reset de-asserted", UVM_LOW)

    phase.drop_objection(this, "Reset complete");

  endtask

endclass
