class reset_agent extends uvm_agent;

  `uvm_component_utils(reset_agent)

  reset_driver drv;
  reset_agt_config m_cfg;

  function new(string name = "reset_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(reset_agt_config)::get(this, "", "reset_agt_config", m_cfg))
      `uvm_fatal("RST_AGT", "Failed to get reset_agt_config from uvm_config_db")

    drv = reset_driver::type_id::create("drv", this);
  endfunction

endclass
