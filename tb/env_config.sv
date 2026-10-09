class env_config extends uvm_object;
  `uvm_object_utils(env_config)
   bit has_scoreboard;
   bit has_m_agent;
   bit has_s_agent;
   bit has_reset_agent;
   int no_of_master_agents;
   int no_of_slave_agents;
   master_agt_config m_agt_cfg[];
   slave_agt_config s_agt_cfg[];
  reset_agt_config rst_agt_cfg;

   function new(string name = "env_config");
      super.new(name);
   endfunction
endclass
