class slave_agt_top extends uvm_env;
  `uvm_component_utils(slave_agt_top)
   slave_agent s_agt[];
   env_config m_cfg;

  function new(string name ="slave_agt_top",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
      if(!uvm_config_db#(env_config)::get(this,"","env_config",m_cfg))
        `uvm_fatal("AGT_TOP","cannot get env_config")
        s_agt=new[m_cfg.no_of_slave_agents];

      foreach(s_agt[i])begin
        uvm_config_db#(slave_agt_config)::set(this,$sformatf("s_agt[%0d]*",i),"slave_agt_config", m_cfg.s_agt_cfg[i]);

        s_agt[i]=slave_agent::type_id::create($sformatf("s_agt[%0d]",i),this);
      end

  endfunction
endclass
