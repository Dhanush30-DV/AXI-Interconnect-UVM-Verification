class test extends uvm_test;

  `uvm_component_utils(test)

  env_config m_env_cfg;
  env        envh;

  function new(string name = "test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

       m_env_cfg = env_config::type_id::create("m_env_cfg");

    m_env_cfg.no_of_master_agents = 2;
    m_env_cfg.no_of_slave_agents  = 3;

    m_env_cfg.has_m_agent   = 1;
    m_env_cfg.has_s_agent   = 1;
    m_env_cfg.has_scoreboard = 1;

        m_env_cfg.m_agt_cfg = new[m_env_cfg.no_of_master_agents];
        m_env_cfg.s_agt_cfg = new[m_env_cfg.no_of_slave_agents];

    foreach(m_env_cfg.m_agt_cfg[i]) begin

      m_env_cfg.m_agt_cfg[i] = master_agt_config::type_id::create($sformatf("m_agt_cfg[%0d]", i));
      if(!uvm_config_db#(virtual axi_master_interface)::get(this,$sformatf("env.magt_top.m_agt[%0d]", i),"axi_master_interface",m_env_cfg.m_agt_cfg[i].mas_if))

     begin
        `uvm_fatal("MASTER_IF",$sformatf("Cannot get axi_master_interface for Master Agent [%0d]",i))

      end

      // Master 0 = ACTIVE
      // Master 1 = ACTIVE

      if(i == 0)
        m_env_cfg.m_agt_cfg[i].is_active = UVM_ACTIVE;
      else
        m_env_cfg.m_agt_cfg[i].is_active = UVM_ACTIVE;

    end

    foreach(m_env_cfg.s_agt_cfg[i]) begin

      m_env_cfg.s_agt_cfg[i] =slave_agt_config::type_id::create($sformatf("s_agt_cfg[%0d]", i));
      if(!uvm_config_db#(virtual axi_slave_interface)::get(this,$sformatf("env.sagt_top.s_agt[%0d]", i),"axi_slave_interface",m_env_cfg.s_agt_cfg[i].slv_if))

            begin

        `uvm_fatal("SLAVE_IF",$sformatf("Cannot get axi_slave_interface for Slave Agent [%0d]",i))
      end

      // Slave 0 = ACTIVE
      // Slave 1 = ACTIVE
      // Slave 2 = ACTIVE

      if(i == 0)
        m_env_cfg.s_agt_cfg[i].is_active = UVM_ACTIVE;
      else
        m_env_cfg.s_agt_cfg[i].is_active = UVM_ACTIVE;

    end
    m_env_cfg.has_reset_agent = 1;
    m_env_cfg.rst_agt_cfg = reset_agt_config::type_id::create("rst_agt_cfg");
    if(!uvm_config_db#(virtual reset_interface)::get(this,"","reset_interface",m_env_cfg.rst_agt_cfg.rst_if))
      `uvm_fatal("RESET_IF","Cannot get reset_interface")

    envh = env::type_id::create("env", this);
    uvm_config_db#(env_config)::set(this,"*","env_config",m_env_cfg);

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
class mas_0_test extends test;

  `uvm_component_utils(mas_0_test)

  mas_0_seq     m_seq;
  slv_second_seq s_seq;

  function new(string name = "mas_0_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

   uvm_config_db#(bit[1:0])::set(null,"*","write_addr_0",2'd0);
   uvm_config_db#(bit[1:0])::set(null,"*","read_addr_0",2'd0);

   m_seq =mas_0_seq::type_id::create("m_seq");
   s_seq =slv_second_seq::type_id::create("s_seq");

    fork

      begin
        m_seq.start(envh.magt_top.m_agt[0].m_seqr);
      end

      begin
        s_seq.start(envh.sagt_top.s_agt[0].seqr);
      end
    join
    #1000;
   phase.drop_objection(this);
endtask

endclass

class mas_1_test extends test;

  `uvm_component_utils(mas_1_test)

  mas_1_seq     m_seq;
  slv_second_seq s_seq;

  function new(string name = "mas_1_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

   uvm_config_db#(bit[1:0])::set(null,"*","write_addr_1",2'd1);
   uvm_config_db#(bit[1:0])::set(null,"*","read_addr_1",2'd1);

   m_seq =mas_1_seq::type_id::create("m_seq");
   s_seq =slv_second_seq::type_id::create("s_seq");

    fork

      begin
        m_seq.start(envh.magt_top.m_agt[1].m_seqr);
      end

      begin
        s_seq.start(envh.sagt_top.s_agt[0].seqr);
      end
    join
    #1000;
   phase.drop_objection(this);
endtask

endclass

// master 0 and master 1 -> same slave at the same time
class multi_same_slave_test extends test;

  `uvm_component_utils(multi_same_slave_test)

  mas_0_multi_seq m_seq0;
  mas_1_multi_seq m_seq1;

  function new(string name = "multi_same_slave_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    for(int i=0; i<3; i++)
      begin
        uvm_config_db#(bit[1:0])::set(null,"*","write_addr_0",i);
        uvm_config_db#(bit[1:0])::set(null,"*","read_addr_0",i);
        uvm_config_db#(bit[1:0])::set(null,"*","write_addr_1",i);
        uvm_config_db#(bit[1:0])::set(null,"*","read_addr_1",i);

        m_seq0 =mas_0_multi_seq::type_id::create("m_seq0");
        m_seq1 =mas_1_multi_seq::type_id::create("m_seq1");

        fork
          begin
            m_seq0.start(envh.magt_top.m_agt[0].m_seqr);
          end
          begin
            m_seq1.start(envh.magt_top.m_agt[1].m_seqr);
          end
        join
      end

    #1000;
    phase.drop_objection(this);
  endtask

endclass

// master 0 -> slave 0 and master 1 -> slave 2 at the same time
class multi_diff_slave_test extends test;

  `uvm_component_utils(multi_diff_slave_test)

  mas_0_multi_seq m_seq0;
  mas_1_multi_seq m_seq1;

  function new(string name = "multi_diff_slave_test",uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    uvm_config_db#(bit[1:0])::set(null,"*","write_addr_0",2'd0);
    uvm_config_db#(bit[1:0])::set(null,"*","read_addr_0",2'd0);
    uvm_config_db#(bit[1:0])::set(null,"*","write_addr_1",2'd2);
    uvm_config_db#(bit[1:0])::set(null,"*","read_addr_1",2'd2);

    m_seq0 =mas_0_multi_seq::type_id::create("m_seq0");
    m_seq1 =mas_1_multi_seq::type_id::create("m_seq1");

    fork
      begin
        m_seq0.start(envh.magt_top.m_agt[0].m_seqr);
      end
      begin
        m_seq1.start(envh.magt_top.m_agt[1].m_seqr);
      end
    join

    #1000;
    phase.drop_objection(this);
  endtask

endclass
