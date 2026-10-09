class master_driver extends uvm_driver#(axi_xtn);
  `uvm_component_utils(master_driver)
   master_agt_config m_cfg;
   virtual axi_master_interface.MAST_DRV_MP mas_if;
   virtual reset_interface.RST_DRV_CB r_if;

   axi_xtn q1[$],q2[$],q3[$],q4[$],q5[$];
   int w_mem[*];
   semaphore sem=new();
   semaphore sem1=new();
   semaphore sem2=new(1);
   semaphore sem3=new(1);
   semaphore sem4=new(1);
   semaphore sem5=new(1);
   semaphore sem6=new(1);
   semaphore sem7=new();

  function new(string name = "master_driver",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
    if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",m_cfg))
          `uvm_fatal("DRV","Cannot get master_agt_config")
   if(!uvm_config_db #(virtual reset_interface)::get(this,"","reset_interface",r_if))
        `uvm_fatal("DRV","Cannot get reset")
    endfunction

 function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mas_if=m_cfg.mas_if;
  endfunction

  task run_phase(uvm_phase phase);

        repeat(10) @(mas_if.mast_drv_cb);   // wait for reset agent to finish reset
        forever begin
                seq_item_port.get_next_item(req);
                drive(req);
                m_cfg.master_drv_cnt++;
                seq_item_port.item_done();
                $display("master driving is finished");
        end
  endtask

  task drive(axi_xtn xtn);
        `uvm_info("AXI_MASTER_DRIVER",$sformatf("The data from the master driver \n %s",xtn.sprint()),UVM_LOW)
        q1.push_back(xtn);
        q2.push_back(xtn);
        q3.push_back(xtn);
        q4.push_back(xtn);
        q5.push_back(xtn);
        fork
          begin
                sem3.get(1);
                drive_write_address(q1.pop_front());
                sem.put(1);
                sem3.put(1);
         end
         begin
                sem.get(1);
                sem2.get(1);
                drive_write_data(q2.pop_front());
                sem1.put(1);
                sem2.put(1);
         end
         begin
                sem1.get(1);
                sem4.get(1);
                drive_write_response(q3.pop_front());
                sem4.put(1);
         end
         begin
                sem5.get(1);
                drive_read_address(q4.pop_front());
                sem7.put(1);
                sem5.put(1);
         end
         begin
                sem7.get(1);
                sem6.get(1);
                drive_read_data(q5.pop_front());
                sem6.put(1);
         end
        join
  endtask

  task drive_write_address(axi_xtn xtn);
     $display("master write address start");
        mas_if.mast_drv_cb.AWVALID <= xtn.AWVALID;
        mas_if.mast_drv_cb.AWID <= xtn.AWID;
        mas_if.mast_drv_cb.AWADDR <= xtn.AWADDR;
        mas_if.mast_drv_cb.AWLEN <= xtn.AWLEN;
        mas_if.mast_drv_cb.AWSIZE <= xtn.AWSIZE;
        mas_if.mast_drv_cb.AWBURST <= xtn.AWBURST;
/*      mas_if.mast_drv_cb.AWLOCK <= xtn.AWLOCK;
        mas_if.mast_drv_cb.AWCACHE <= xtn.AWCACHE;
        mas_if.mast_drv_cb.AWPROT <= xtn.AWPROT;
        mas_if.mast_drv_cb.AWQOS <= xtn.AWQOS;
        mas_if.mast_drv_cb.AWUSER <= xtn.AWUSER;*/
        @(mas_if.mast_drv_cb);
        //$display("m");
       wait(mas_if.mast_drv_cb.AWREADY)
      // $display("m");
        mas_if.mast_drv_cb.AWVALID <= 1'b0;
        repeat($urandom_range(1,5))
                @(mas_if.mast_drv_cb);
        $display("master address driver task end");
       // `uvm_info("AXI_MASTER_DRIVER_WRITE_ADDRESS",$sformatf("Displaying data from master driver drive_write_address \n %s",xtn.sprint()),UVM_LOW)
  endtask

  task drive_write_data(axi_xtn xtn);
        $display("master  write data driver task before AWLEN=%0d",xtn.AWLEN);
               for(int i=0;i<xtn.AWLEN+1;i++)
          begin
                mas_if.mast_drv_cb.WVALID <= 1'b1;
        //      mas_if.mast_drv_cb.WUSER <= xtn.WUSER;
                mas_if.mast_drv_cb.WDATA <= xtn.WDATA[i];
                mas_if.mast_drv_cb.WSTRB <= xtn.WSTRB[i];
               // $display("master data driver task outside AWLEN=%0d",xtn.AWLEN);
                if(i==(xtn.AWLEN))
                  begin
                        mas_if.mast_drv_cb.WLAST <= 1'b1;
                    //    $display("master data driver task AWLEN=%0d",xtn.AWLEN);
                 end
                else
                        mas_if.mast_drv_cb.WLAST <= 1'b0;
                        @(mas_if.mast_drv_cb);
                       wait(mas_if.mast_drv_cb.WREADY)
                        mas_if.mast_drv_cb.WVALID <= 1'b0;
                        mas_if.mast_drv_cb.WLAST <= 1'b0;
                        repeat($urandom_range(1,5))
                        @(mas_if.mast_drv_cb);
          end
        //`uvm_info("AXI_MASTER_DRIVER_WRITE_DATA",$sformatf("Displaying data from master driver drive_write_data \n %s",xtn.sprint()),UVM_LOW)
       $display("master write data end");
endtask

  task drive_write_response(axi_xtn xtn);
      $display("master write response start");
        mas_if.mast_drv_cb.BREADY <= 1'b1;
        @(mas_if.mast_drv_cb);
     // $display(" master BREADY=%0d BID=%0d",mas_if.mast_drv_cb.BREADY,mas_if.mast_drv_cb.BID);

        wait(mas_if.mast_drv_cb.BVALID)
       $display($time," master BREADY=%0d BID=%0d",mas_if.mast_drv_cb.BREADY,mas_if.mast_drv_cb.BID);

        $display($time," master BVALID=%0d",mas_if.mast_drv_cb.BVALID);

        mas_if.mast_drv_cb.BREADY <= 1'b0;
       //$display("master BREADY=%0d BID=%Od",mas_if.mast_drv_cb.BREADY,mas_if.mast_drv_cb.BID);

        repeat($urandom_range(1,5))
                @(mas_if.mast_drv_cb);
        $display("master write response driver task end");
        //`uvm_info("AXI_MASTER_DRIVER_WRITE_RESPONSE",$sformatf("Displaying data from master driver drive_write_response \n %s",xtn.sprint()),UVM_LOW)
  endtask

  task drive_read_address(axi_xtn xtn);
    $display("master read address start");
        mas_if.mast_drv_cb.ARVALID <= xtn.ARVALID;
        mas_if.mast_drv_cb.ARID <= xtn.ARID;
        mas_if.mast_drv_cb.ARADDR <= xtn.ARADDR;
        mas_if.mast_drv_cb.ARLEN <= xtn.ARLEN;
        mas_if.mast_drv_cb.ARSIZE <= xtn.ARSIZE;
        mas_if.mast_drv_cb.ARBURST <= xtn.ARBURST;
/*      mas_if.mast_drv_cb.ARLOCK <= xtn.ARLOCK;
        mas_if.mast_drv_cb.ARCACHE <= xtn.ARCACHE;
        mas_if.mast_drv_cb.ARPROT <= xtn.ARPROT;
        mas_if.mast_drv_cb.ARQOS <= xtn.ARQOS;
        mas_if.mast_drv_cb.ARUSER <= xtn.ARUSER;*/
        @(mas_if.mast_drv_cb);
        wait(mas_if.mast_drv_cb.ARREADY)
        mas_if.mast_drv_cb.ARVALID <= 1'b0;
        repeat($urandom_range(1,5))
                @(mas_if.mast_drv_cb);
        $display("master read address driver task end");
        //`uvm_info("AXI_MASTER_DRIVER_READ_ADDRESS",$sformatf("Displaying data from master driver drive_read_address \n %s",xtn.sprint()),UVM_LOW)
  endtask

  task drive_read_data(axi_xtn xtn);
    $display("master read data start");
        xtn.read_addr_cal();
        xtn.RDATA =new[xtn.ARLEN+1];
        for(int i=0;i<(xtn.ARLEN+1);i++)
          begin
                mas_if.mast_drv_cb.RREADY <= 1'b1;
                @(mas_if.mast_drv_cb);
                wait(mas_if.mast_drv_cb.RVALID)

                $display("master RID=%0d",mas_if.mast_drv_cb.RID);
                mas_if.mast_drv_cb.RREADY <= 1'b0;
               // repeat($urandom_range(1,5))
                @(mas_if.mast_drv_cb);
          end
        $display("master read data driver task end %0d",mas_if.mast_drv_cb.RID);
        //`uvm_info("AXI_MASTER_DRIVER_READ_DATA",$sformatf("Displaying data from master driver drive_read_data \n %s",xtn.sprint()),UVM_LOW)
  endtask

  function void report_phase(uvm_phase phase);
        `uvm_info("AXI_MASTER_DRIVER_REPORT_PHASE",$sformatf("Report:master driver has send %0d transactions",m_cfg.master_drv_cnt),UVM_LOW)
  endfunction

endclass
