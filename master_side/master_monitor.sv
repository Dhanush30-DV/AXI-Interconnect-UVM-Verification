class master_monitor extends uvm_monitor;

  `uvm_component_utils(master_monitor)

  master_agt_config m_cfg;

  virtual axi_master_interface.MAST_MON_MP mas_if;

  uvm_analysis_port #(axi_xtn) monitor_port;

  extern function new(string name = "master_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task handle_write_transaction(axi_xtn xtn);
  extern task handle_read_transaction(axi_xtn xtn);
  extern function void report_phase(uvm_phase phase);

endclass

function master_monitor::new(string name = "master_monitor", uvm_component parent);
  super.new(name, parent);
  monitor_port = new("monitor_port", this);
endfunction

function void master_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(master_agt_config)::get(this, "", "master_agt_config", m_cfg))
    `uvm_fatal("AXI_MASTER_MONITOR", "Cannot get m_cfg from uvm_config_db")
endfunction

function void master_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  mas_if = m_cfg.mas_if;
endfunction

task master_monitor::run_phase(uvm_phase phase);

  `uvm_info("MASTER_MONITOR", "Master monitor run_phase started", UVM_LOW)

  fork

    forever begin
      axi_xtn write_xtn;

      do begin
        @(mas_if.mast_mon_cb);
      end while (!(mas_if.mast_mon_cb.AWVALID === 1'b1 && mas_if.mast_mon_cb.AWREADY === 1'b1));

      write_xtn = axi_xtn::type_id::create("write_xtn");

      write_xtn.AWID    = mas_if.mast_mon_cb.AWID;
      write_xtn.AWADDR  = mas_if.mast_mon_cb.AWADDR;
      write_xtn.AWLEN   = mas_if.mast_mon_cb.AWLEN;
      write_xtn.AWSIZE  = mas_if.mast_mon_cb.AWSIZE;
      write_xtn.AWBURST = mas_if.mast_mon_cb.AWBURST;
      write_xtn.AWVALID = mas_if.mast_mon_cb.AWVALID;
      write_xtn.AWREADY = mas_if.mast_mon_cb.AWREADY;

      `uvm_info("MASTER_MONITOR", $sformatf("WRITE ADDRESS detected\n%s", write_xtn.sprint()), UVM_LOW)

      fork
        handle_write_transaction(write_xtn);
      join_none
    end

    forever begin
      axi_xtn read_xtn;

      do begin
        @(mas_if.mast_mon_cb);
      end while (!(mas_if.mast_mon_cb.ARVALID === 1'b1 && mas_if.mast_mon_cb.ARREADY === 1'b1));

      read_xtn = axi_xtn::type_id::create("read_xtn");

      read_xtn.ARID    = mas_if.mast_mon_cb.ARID;
      read_xtn.ARADDR  = mas_if.mast_mon_cb.ARADDR;
      read_xtn.ARLEN   = mas_if.mast_mon_cb.ARLEN;
      read_xtn.ARSIZE  = mas_if.mast_mon_cb.ARSIZE;
      read_xtn.ARBURST = mas_if.mast_mon_cb.ARBURST;
      read_xtn.ARVALID = mas_if.mast_mon_cb.ARVALID;
      read_xtn.ARREADY = mas_if.mast_mon_cb.ARREADY;

      `uvm_info("MASTER_MONITOR", $sformatf("READ ADDRESS detected\n%s", read_xtn.sprint()), UVM_LOW)

      fork
        handle_read_transaction(read_xtn);
      join_none
    end

  join

endtask

task master_monitor::handle_write_transaction(axi_xtn xtn);

  `uvm_info("MASTER_MONITOR", "WRITE DATA monitoring started", UVM_LOW)

  xtn.WDATA = new[xtn.AWLEN + 1];
  xtn.WSTRB = new[xtn.AWLEN + 1];

  foreach (xtn.WDATA[i]) begin

    do begin
      @(mas_if.mast_mon_cb);
    end while (!(mas_if.mast_mon_cb.WVALID === 1'b1 && mas_if.mast_mon_cb.WREADY === 1'b1));

    xtn.WDATA[i] = mas_if.mast_mon_cb.WDATA;
    xtn.WSTRB[i] = mas_if.mast_mon_cb.WSTRB;

    if (i == xtn.AWLEN)
      xtn.WLAST = mas_if.mast_mon_cb.WLAST;

    `uvm_info("MASTER_MONITOR", $sformatf("WRITE DATA[%0d] = %h  WSTRB = %b", i, xtn.WDATA[i], xtn.WSTRB[i]), UVM_LOW)
  end

  xtn.WVALID = 1'b1;
  xtn.WREADY = 1'b1;

  `uvm_info("MASTER_MONITOR", "WRITE RESPONSE monitoring started", UVM_LOW)

  forever begin
    @(mas_if.mast_mon_cb);
    if ((mas_if.mast_mon_cb.BVALID === 1'b1) &&
        (mas_if.mast_mon_cb.BREADY === 1'b1) &&
        (mas_if.mast_mon_cb.BID == xtn.AWID))
      break;
  end

  xtn.BID    = mas_if.mast_mon_cb.BID;
  xtn.BRESP  = mas_if.mast_mon_cb.BRESP;
  xtn.BVALID = mas_if.mast_mon_cb.BVALID;
  xtn.BREADY = mas_if.mast_mon_cb.BREADY;

  `uvm_info("MASTER_MONITOR", $sformatf("WRITE RESPONSE detected\nBID = %0d BRESP = %0d", xtn.BID, xtn.BRESP), UVM_LOW)

  monitor_port.write(xtn);

  m_cfg.mast_mon_rcvd_xtn_cnt++;

  `uvm_info("MASTER_MONITOR", "WRITE transaction sent to scoreboard", UVM_LOW)

endtask

task master_monitor::handle_read_transaction(axi_xtn xtn);

  `uvm_info("MASTER_MONITOR", "READ DATA monitoring started", UVM_LOW)

  xtn.RDATA = new[xtn.ARLEN + 1];
  xtn.RRESP = new[xtn.ARLEN + 1];

  foreach (xtn.RDATA[i]) begin

    do begin
      @(mas_if.mast_mon_cb);
    end while (!(mas_if.mast_mon_cb.RVALID === 1'b1 &&
                 mas_if.mast_mon_cb.RREADY === 1'b1 &&
                 mas_if.mast_mon_cb.RID == xtn.ARID));

    xtn.RID      = mas_if.mast_mon_cb.RID;
    xtn.RDATA[i] = mas_if.mast_mon_cb.RDATA;
    xtn.RRESP[i] = mas_if.mast_mon_cb.RRESP;

    if (i == (xtn.RDATA.size() - 1))
      xtn.RLAST = mas_if.mast_mon_cb.RLAST;

    xtn.RVALID = mas_if.mast_mon_cb.RVALID;
    xtn.RREADY = mas_if.mast_mon_cb.RREADY;

    `uvm_info("MASTER_MONITOR", $sformatf("READ DATA[%0d] = %h", i, xtn.RDATA[i]), UVM_LOW)
  end

  monitor_port.write(xtn);

  m_cfg.mast_mon_rcvd_xtn_cnt++;

  `uvm_info("MASTER_MONITOR", "READ transaction sent to scoreboard", UVM_LOW)

endtask

function void master_monitor::report_phase(uvm_phase phase);
  `uvm_info("AXI_MASTER_MONITOR_REPORT", $sformatf("AXI MASTER MONITOR REPORT : Total Transactions Received = %0d", m_cfg.mast_mon_rcvd_xtn_cnt), UVM_NONE)
endfunction
