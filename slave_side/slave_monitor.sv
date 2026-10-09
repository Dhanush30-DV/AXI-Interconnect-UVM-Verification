class slave_monitor extends uvm_monitor;

  `uvm_component_utils(slave_monitor)
  slave_agt_config slv_cfg;

   virtual axi_slave_interface.SLV_MON_MP slv_if;

   uvm_analysis_port #(axi_xtn) slv_mon_port;
  axi_xtn xtn;
  axi_xtn xtn1;
  axi_xtn xtn2;
  axi_xtn xtn3;
  axi_xtn xtn4;
  axi_xtn xtn5;

  axi_xtn q1[$];
  axi_xtn q2[$];
  axi_xtn q3[$];
  axi_xtn q4[$];
  axi_xtn q5[$];

    int pkt_rcvd;
  semaphore sem  = new();
  semaphore sem1 = new();
  semaphore sem2 = new(1);
  semaphore sem3 = new(1);
  semaphore sem4 = new(1);
  semaphore sem5 = new(1);
  semaphore sem6 = new(1);
  semaphore sem7 = new();

    function new(string name = "slave_monitor",
               uvm_component parent);

    super.new(name, parent);

    slv_mon_port = new("slv_mon_port", this);

  endfunction

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",slv_cfg))

      `uvm_fatal("MON","Cannot get slave_agt_config")

  endfunction

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if(slv_cfg == null)
      `uvm_fatal("MON_CFG","slv_cfg is NULL")

    slv_if = slv_cfg.slv_if;

    if(slv_if == null)`uvm_fatal("MON_IF","slv_if is NULL")

  endfunction

  task run_phase(uvm_phase phase);

    forever begin

      collect_data();

    end

  endtask

  task collect_data();

    fork

      begin

        sem3.get(1);

        collect_write_address();

        sem.put(1);

        sem3.put(1);

      end
      begin

        sem.get(1);

        sem2.get(1);

        if(q1.size() != 0)
          collect_write_data(q1.pop_front());

        sem1.put(1);

        sem2.put(1);

      end

      begin

        sem1.get(1);

        sem4.get(1);

        if(q3.size() != 0)
          collect_write_response(q3.pop_front());

        sem4.put(1);

      end

      begin

        sem5.get(1);

        collect_read_address();

        sem7.put(1);

        sem5.put(1);

      end

      begin

        sem7.get(1);

        sem6.get(1);

        if(q2.size() != 0)
          collect_read_data(q2.pop_front());

        sem6.put(1);

      end

    join_any

  endtask
  task collect_write_address();

    if(slv_if == null)
      `uvm_fatal("MON_IF","slv_if is NULL in collect_write_address")

    xtn = axi_xtn::type_id::create("xtn");

    if(xtn == null)
      `uvm_fatal("MON_XTN", "xtn creation failed")

    wait(slv_if.slv_mon_cb.AWVALID &&slv_if.slv_mon_cb.AWREADY);

    xtn.AWID    = slv_if.slv_mon_cb.AWID;
    xtn.AWADDR  = slv_if.slv_mon_cb.AWADDR;
    xtn.AWLEN   = slv_if.slv_mon_cb.AWLEN;
    xtn.AWSIZE  = slv_if.slv_mon_cb.AWSIZE;
    xtn.AWBURST = slv_if.slv_mon_cb.AWBURST;
    xtn.AWVALID = slv_if.slv_mon_cb.AWVALID;

    q1.push_back(xtn);
    q3.push_back(xtn);

    @(slv_if.slv_mon_cb);

    `uvm_info("AXI_SLAVE_MONITOR_WRITE_ADDRESS", $sformatf("Displaying data from slave monitor write address\n%s",xtn.sprint()),UVM_LOW)

  endtask

  task collect_write_data(axi_xtn xtn);

    if(slv_if == null)
      `uvm_fatal("MON_IF","slv_if is NULL in collect_write_data")

    if(xtn == null)
      `uvm_fatal("MON_XTN","Write data transaction is NULL")

    xtn1 = axi_xtn::type_id::create("xtn1");

    xtn1 = xtn;

    xtn1.WDATA = new[xtn1.AWLEN+1];
    xtn1.WSTRB = new[xtn1.AWLEN+1];

    foreach(xtn1.WDATA[i])
    begin

      wait(slv_if.slv_mon_cb.WVALID && slv_if.slv_mon_cb.WREADY);

      xtn1.WDATA[i] = slv_if.slv_mon_cb.WDATA;
      xtn1.WSTRB[i] = slv_if.slv_mon_cb.WSTRB;

      if(i == xtn1.AWLEN)
      begin

        if(!slv_if.slv_mon_cb.WLAST)

          `uvm_error("AXI_SLAVE_MONITOR","Expected WLAST on final beat")

      end

      @(slv_if.slv_mon_cb);

    end

    `uvm_info("AXI_SLAVE_MONITOR_WRITE_DATA",
      $sformatf(
        "Displaying data from slave monitor write data\n%s",
        xtn1.sprint()),
      UVM_LOW)

  endtask

  task collect_write_response(axi_xtn xtn);

    if(slv_if == null)
      `uvm_fatal("MON_IF","slv_if is NULL in collect_write_response")

    if(xtn == null)
      `uvm_fatal("MON_XTN","Write response transaction is NULL")

    xtn2 = axi_xtn::type_id::create("xtn2");

    xtn2 = xtn;

    wait(slv_if.slv_mon_cb.BVALID && slv_if.slv_mon_cb.BREADY);

    xtn2.BID   = slv_if.slv_mon_cb.BID;
    xtn2.BRESP = slv_if.slv_mon_cb.BRESP;

    slv_mon_port.write(xtn2);

    pkt_rcvd++;

    `uvm_info("AXI_SLAVE_MONITOR_WRITE_RESPONSE",$sformatf("Displaying data from slave monitor write response\n%s", xtn2.sprint()),UVM_LOW)

    @(slv_if.slv_mon_cb);

  endtask

  task collect_read_address();

    if(slv_if == null)
      `uvm_fatal("MON_IF","slv_if is NULL in collect_read_address")

    xtn3 = axi_xtn::type_id::create("xtn3");

    if(xtn3 == null)
      `uvm_fatal("MON_XTN","xtn3 creation failed")

    wait(slv_if.slv_mon_cb.ARVALID && slv_if.slv_mon_cb.ARREADY);

    xtn3.ARID    = slv_if.slv_mon_cb.ARID;
    xtn3.ARADDR  = slv_if.slv_mon_cb.ARADDR;
    xtn3.ARLEN   = slv_if.slv_mon_cb.ARLEN;
    xtn3.ARSIZE  = slv_if.slv_mon_cb.ARSIZE;
    xtn3.ARBURST = slv_if.slv_mon_cb.ARBURST;
    xtn3.ARVALID = slv_if.slv_mon_cb.ARVALID;

    q2.push_back(xtn3);

    @(slv_if.slv_mon_cb);

    `uvm_info("AXI_SLAVE_MONITOR_READ_ADDRESS",$sformatf("Displaying data from slave monitor read address\n%s",xtn3.sprint()),UVM_LOW)

  endtask

  task collect_read_data(axi_xtn xtn);

    if(slv_if == null)
      `uvm_fatal("MON_IF","slv_if is NULL in collect_read_data")

    if(xtn == null)
      `uvm_fatal("MON_XTN","Read data transaction is NULL")

    xtn4 = axi_xtn::type_id::create("xtn4");

    xtn4 = xtn;

    xtn4.RDATA = new[xtn4.ARLEN+1];
    xtn4.RRESP = new[xtn4.ARLEN+1];

    foreach(xtn4.RDATA[i])
    begin

      wait(slv_if.slv_mon_cb.RVALID && slv_if.slv_mon_cb.RREADY);

      xtn4.RID = slv_if.slv_mon_cb.RID;

      xtn4.RDATA[i] = slv_if.slv_mon_cb.RDATA;
      xtn4.RRESP[i] = slv_if.slv_mon_cb.RRESP;

      if(i == xtn4.ARLEN)
      begin

        if(!slv_if.slv_mon_cb.RLAST)

          `uvm_error( "AXI_SLAVE_MONITOR","Expected RLAST on final beat")

      end

      @(slv_if.slv_mon_cb);

    end

    slv_mon_port.write(xtn4);

    pkt_rcvd++;

    `uvm_info("AXI_SLAVE_MONITOR_READ_DATA",$sformatf("Displaying data from slave monitor read data\n%s",xtn4.sprint()),UVM_LOW)

  endtask

  function void report_phase(uvm_phase phase);

    `uvm_info("AXI_SLAVE_MONITOR_REPORT_PHASE",$sformatf("Report: slave monitor has received %0d transactions",pkt_rcvd),UVM_LOW)

  endfunction

endclass
