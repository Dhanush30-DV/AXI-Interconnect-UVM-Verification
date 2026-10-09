class env extends uvm_env;
  `uvm_component_utils(env)
   env_config m_cfg;
   master_agt_top magt_top;
   slave_agt_top sagt_top;
   scoreboard sb;
   reset_agent rst_agt;

   function new(string name="env",uvm_component parent);
      super.new(name,parent);
   endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
           `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")

     if(m_cfg.has_m_agent==1)
       magt_top=master_agt_top::type_id::create("magt_top",this);
     if(m_cfg.has_s_agent==1)
       sagt_top=slave_agt_top::type_id::create("sagt_top",this);
     if(m_cfg.has_scoreboard==1)
       sb=scoreboard::type_id::create("sb",this);
     if(m_cfg.has_reset_agent==1)
       begin
         uvm_config_db#(reset_agt_config)::set(this,"rst_agt*","reset_agt_config",m_cfg.rst_agt_cfg);
         rst_agt=reset_agent::type_id::create("rst_agt",this);
       end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_cfg.has_scoreboard==1)
      begin
        if(m_cfg.has_m_agent==1)
          foreach(magt_top.m_agt[i])
            magt_top.m_agt[i].mon.monitor_port.connect(sb.fifo_mas[i].analysis_export);

        if(m_cfg.has_s_agent==1)
          foreach(sagt_top.s_agt[i])
            sagt_top.s_agt[i].mon.slv_mon_port.connect(sb.fifo_slv[i].analysis_export);
      end
  endfunction

endclass
