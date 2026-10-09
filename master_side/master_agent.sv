class master_agent extends uvm_agent;
  `uvm_component_utils(master_agent)
   master_monitor mon;
   master_driver drv;
   master_sequencer m_seqr;
   master_agt_config m_cfg;

   function new(string name = "master_agent",uvm_component parent);
       super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       if(!uvm_config_db#(master_agt_config)::get(this, "", "master_agt_config", m_cfg)) begin
      `uvm_fatal("AGT_CFG", "Failed to get master_agt_config from uvm_config_db")
    end
       mon=master_monitor::type_id::create("mon",this);
       if(m_cfg.is_active==UVM_ACTIVE)begin
       drv=master_driver::type_id::create("drv",this);
       m_seqr=master_sequencer::type_id::create("seqr",this);
       end
   endfunction

  function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if(m_cfg.is_active==UVM_ACTIVE)
        drv.seq_item_port.connect(m_seqr.seq_item_export);
  endfunction
endclass
