class slave_driver extends uvm_driver #(slave_xtn);

  `uvm_component_utils(slave_driver)

  slave_agt_config slv_cfg;
  virtual axi_slave_interface.SLV_DRV_MP slv_if;

  axi_xtn       aw_q[$];
  axi_xtn       ar_q[$];
  bit [7:0]     b_id_q[$];

  bit [31:0]    mem[*];

  function new(string name = "slave_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(slave_agt_config)::get(this, "", "slave_agt_config", slv_cfg))
      `uvm_fatal("SLV_DRV", "Cannot get slave_agt_config")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    slv_if = slv_cfg.slv_if;
    if (slv_if == null)
      `uvm_fatal("SLV_DRV", "slave interface is NULL")
  endfunction

  task run_phase(uvm_phase phase);
    init_signals();
    fork
      drive_write_address();
      drive_write_data();
      drive_write_response();
      drive_read_address();
      drive_read_data();
    join_none

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task init_signals();
    slv_if.slv_drv_cb.AWREADY <= 1'b1;
    slv_if.slv_drv_cb.WREADY  <= 1'b1;
    slv_if.slv_drv_cb.ARREADY <= 1'b1;
    slv_if.slv_drv_cb.BVALID  <= 1'b0;
    slv_if.slv_drv_cb.RVALID  <= 1'b0;
    slv_if.slv_drv_cb.RLAST   <= 1'b0;
  endtask

  task drive(slave_xtn xtn);
    slv_cfg.slave_drv_xtn_sent_cnt++;
  endtask

  task drive_write_address();
    axi_xtn xtn;
    forever begin
      @(slv_if.slv_drv_cb);
      if (slv_if.slv_drv_cb.AWVALID) begin
        xtn = axi_xtn::type_id::create("aw_xtn");
        xtn.AWID    = slv_if.slv_drv_cb.AWID;
        xtn.AWADDR  = slv_if.slv_drv_cb.AWADDR;
        xtn.AWLEN   = slv_if.slv_drv_cb.AWLEN;
        xtn.AWSIZE  = slv_if.slv_drv_cb.AWSIZE;
        xtn.AWBURST = slv_if.slv_drv_cb.AWBURST;
        xtn.AWVALID = slv_if.slv_drv_cb.AWVALID;
        aw_q.push_back(xtn);
      end
    end
  endtask

  task drive_write_data();
    axi_xtn xtn;
    bit [31:0] addr;
    forever begin
      wait (aw_q.size() > 0);
      xtn = aw_q.pop_front();
      xtn.write_addr_cal();

      for (int i = 0; i <= xtn.AWLEN; i++) begin
        do @(slv_if.slv_drv_cb); while (!slv_if.slv_drv_cb.WVALID);

        addr = xtn.w_addr[i];
        for (int b = 0; b < 4; b++)
          if (slv_if.slv_drv_cb.WSTRB[b])
            mem[addr][8*b +: 8] = slv_if.slv_drv_cb.WDATA[8*b +: 8];
      end
      b_id_q.push_back(xtn.AWID);
    end
  endtask

  task drive_write_response();
    bit [7:0] id;
    forever begin
      wait (b_id_q.size() > 0);
      id = b_id_q.pop_front();

      slv_if.slv_drv_cb.BID    <= id;
      slv_if.slv_drv_cb.BRESP  <= 2'b00;
      slv_if.slv_drv_cb.BVALID <= 1'b1;
      do @(slv_if.slv_drv_cb); while (!slv_if.slv_drv_cb.BREADY);
      slv_if.slv_drv_cb.BVALID <= 1'b0;
    end
  endtask

  task drive_read_address();
    axi_xtn xtn;
    forever begin
      @(slv_if.slv_drv_cb);
      if (slv_if.slv_drv_cb.ARVALID) begin
        xtn = axi_xtn::type_id::create("ar_xtn");
        xtn.ARID    = slv_if.slv_drv_cb.ARID;
        xtn.ARADDR  = slv_if.slv_drv_cb.ARADDR;
        xtn.ARLEN   = slv_if.slv_drv_cb.ARLEN;
        xtn.ARSIZE  = slv_if.slv_drv_cb.ARSIZE;
        xtn.ARBURST = slv_if.slv_drv_cb.ARBURST;
        xtn.ARVALID = slv_if.slv_drv_cb.ARVALID;
        ar_q.push_back(xtn);
      end
    end
  endtask

  task drive_read_data();
    axi_xtn xtn;
    bit [31:0] addr;
    bit [31:0] data;
    forever begin
      wait (ar_q.size() > 0);
      xtn = ar_q.pop_front();
      xtn.read_addr_cal();

      for (int i = 0; i <= xtn.ARLEN; i++) begin
        addr = xtn.r_addr[i];
        data = mem.exists(addr) ? mem[addr] : $urandom;

        slv_if.slv_drv_cb.RID    <= xtn.ARID;
        slv_if.slv_drv_cb.RDATA  <= data;
        slv_if.slv_drv_cb.RRESP  <= 2'b00;
        slv_if.slv_drv_cb.RLAST  <= (i == xtn.ARLEN);
        slv_if.slv_drv_cb.RVALID <= 1'b1;

        do @(slv_if.slv_drv_cb); while (!slv_if.slv_drv_cb.RREADY);
      end
      slv_if.slv_drv_cb.RVALID <= 1'b0;
      slv_if.slv_drv_cb.RLAST  <= 1'b0;
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SLAVE_DRIVER_REPORT",
      $sformatf("Slave driver transactions = %0d", slv_cfg.slave_drv_xtn_sent_cnt), UVM_LOW)
  endfunction

endclass
