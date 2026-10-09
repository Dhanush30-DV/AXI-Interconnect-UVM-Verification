class master_agt_config extends uvm_object;
   `uvm_object_utils(master_agt_config)

   uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "master_agt_config");
      super.new(name);
  endfunction
 virtual  axi_master_interface mas_if;
  int master_drv_cnt;
  int mast_mon_rcvd_xtn_cnt;

endclass
