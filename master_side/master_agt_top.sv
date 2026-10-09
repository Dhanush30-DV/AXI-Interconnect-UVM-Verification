class master_agt_top extends uvm_env;
  `uvm_component_utils(master_agt_top)
   master_agent m_agt[];
   env_config m_cfg;

  function new(string name ="master_agt_top",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
      if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
        `uvm_fatal("AGT_TOP","cannot get env_config")
        m_agt=new[m_cfg.no_of_master_agents];
      foreach(m_agt[i])begin
        uvm_config_db#(master_agt_config)::set(this,$sformatf("m_agt[%0d]*",i),"master_agt_config", m_cfg.m_agt_cfg[i]);
        m_agt[i]=master_agent::type_id::create($sformatf("m_agt[%0d]",i),this);
      end

  endfunction
endclass
