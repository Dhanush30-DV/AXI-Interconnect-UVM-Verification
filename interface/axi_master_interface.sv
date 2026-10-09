//Interface File

 interface axi_master_interface(input bit clock);

                       //Write Address Signals
                        logic [7:0] AWID;
                        logic [31:0] AWADDR;
                        logic [7:0] AWLEN;
                        logic [2:0] AWSIZE;
                        logic [1:0] AWBURST;
                        logic AWVALID;
                        logic AWREADY;
                        logic AWLOCK;
                        logic [3:0] AWCACHE;
                        logic [2:0] AWPROT;
                        logic [3:0] AWQOS;
                        logic AWUSER;

                       //Write Data Channels Signals
                        logic [31:0] WDATA;
                        logic [3:0] WSTRB;
                        logic WLAST;
                        logic WVALID;
                        logic WREADY;
                        logic WUSER;

                      //Write Response Channel Signals
                        logic [7:0] BID;
                        logic [1:0] BRESP;
                        logic BVALID;
                        logic BREADY;
                        logic BUSER;

                      // Read Address Channel Signals
                        logic [7:0] ARID;
                        logic [31:0] ARADDR;
                        logic [7:0] ARLEN;
                        logic [2:0] ARSIZE;
                        logic [1:0] ARBURST;
                        logic ARVALID;
                        logic ARREADY;
                        logic ARLOCK;
                        logic [3:0] ARCACHE;
                        logic [2:0] ARPROT;
                        logic [3:0] ARQOS;
                        logic ARUSER;

                     //Read Data Channel Signals
                       logic [7:0] RID;
                       logic [31:0] RDATA;
                       logic [1:0] RRESP;
                       logic RLAST;
                       logic RVALID;
                       logic RREADY;
                       logic RUSER;

    modport DUV_MP(input clock, AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, AWUSER, AWVALID, WDATA, WSTRB,
                         WLAST, WUSER, WVALID, BREADY, ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, ARUSER, ARVALID, RREADY,
                   output AWREADY, WREADY, BID, BRESP, BUSER, BVALID, ARREADY, RID, RDATA, RRESP, RLAST, RUSER, RVALID);

   // Master Driver Clocking Block
    clocking mast_drv_cb @(posedge clock);
      default input #1 output #1;

  // Write Address Signal
      output AWID;
      output AWADDR;
      output AWLEN;
      output AWSIZE;
      output AWBURST;
      output AWLOCK;
      output AWCACHE;
      output AWPROT;
      output AWQOS;
      output AWUSER;
      output AWVALID;
      input AWREADY;

  // Write Data Signals
      output WDATA;
      output WSTRB;
      output WLAST;
      output WUSER;
      output WVALID;
      input WREADY;

 //Write Response Signals
      input BID;
      input BRESP;
      input BUSER;
      input BVALID;
      output BREADY;

// Read Address Signals
      output ARID;
      output ARADDR;
      output ARLEN;
      output ARSIZE;
      output ARBURST;
      output ARLOCK;
      output ARCACHE;
      output ARPROT;
      output ARQOS;
      output ARUSER;
      output ARVALID;
      input ARREADY;

 // Read Data Signals
      input RID;
      input RDATA;
      input RRESP;
      input RLAST;
      input RUSER;
      input RVALID;
      output RREADY;

    endclocking

    clocking mast_mon_cb @(posedge clock);
      default input #1 output #1;

     // Write Address Signals
      input AWID;
      input AWADDR;
      input AWLEN;
      input AWSIZE;
      input AWBURST;
      input AWLOCK;
      input AWCACHE;
      input AWPROT;
      input AWQOS;
      input AWUSER;
      input AWVALID;
      input AWREADY;

     // Write Data Signals
      input WDATA;
      input WSTRB;
      input WLAST;
      input WUSER;
      input WVALID;
      input WREADY;

    //Write Response Signals
      input BID;
      input BRESP;
      input BUSER;
      input BVALID;
      input BREADY;

    // Read Address Signals
      input ARID;
      input ARADDR;
      input ARLEN;
      input ARSIZE;
      input ARBURST;
      input ARLOCK;
      input ARCACHE;
      input ARPROT;
      input ARQOS;
      input ARUSER;
      input ARVALID;
      input ARREADY;

    // Read Data Signals
      input RID;
      input RDATA;
      input RRESP;
      input RLAST;
      input RUSER;
      input RVALID;
      input RREADY;

    endclocking


  modport MAST_DRV_MP (clocking mast_drv_cb );
  modport MAST_MON_MP(clocking mast_mon_cb);

// **************************************************** Assertions ****************************************************//
  property awaddr_signal_stable;
   @(posedge clock) $rose(AWVALID) |-> ($stable(AWID) &&
                    $stable(AWADDR) &&
                    $stable(AWLEN) &&
                    $stable(AWSIZE) &&
                    $stable(AWBURST)) until AWREADY[->1];

 endproperty

  property wdata_signal_stable;
   @(posedge clock) $rose(WVALID) |-> (
                    $stable(WDATA) &&
                    $stable(WSTRB) &&
                    $stable(WLAST)) until WREADY[->1];
 endproperty


  property araddr_signal_stable;
   @(posedge clock) $rose(ARVALID) |-> ($stable(ARID) &&
                    $stable(ARADDR) &&
                    $stable(ARLEN) &&
                    $stable(ARSIZE) &&
                    $stable (ARBURST)) until ARREADY[->1];
  endproperty

  property bresp_signal_stable;
   @(posedge clock) $rose(BVALID) |-> ($stable(BID) &&
                    $stable(BRESP)) until BREADY[->1];
  endproperty


  property rdata_signal_stable;
   @(posedge clock) $rose(RVALID) |-> ($stable(RID) &&
                    $stable(RDATA) &&
                    $stable(RRESP) &&
                    $stable(RLAST)) until RREADY[->1];
  endproperty


  property write_burst_resrved;
   @(posedge clock) AWVALID |-> (AWBURST != 2'b11);
  endproperty

  property read_burst_reserved;
   @(posedge clock) ARVALID |-> (ARBURST != 2'b11);
  endproperty

  property awlen_for_wrap;
   @(posedge clock) (AWBURST == 2'b10) |-> (AWLEN == 8'd1 || AWLEN == 8'd3 || AWLEN == 8'd7 || AWLEN == 8'd15 || AWLEN == 8'd31 || AWLEN == 8'd63 || AWLEN == 8'd127 || AWLEN == 8'd255) ;
  endproperty

  property arlen_for_wrap;
    @(posedge clock) (ARBURST == 2'b10) |-> (ARLEN == 8'd1 || ARLEN == 8'd3 || ARLEN == 8'd7 || ARLEN == 8'd15 || ARLEN == 8'd31 || ARLEN == 8'd63 || ARLEN == 8'd127 || ARLEN == 8'd255) ;
  endproperty

  property awvalid_wait_awready;
    @(posedge clock) (AWVALID && !AWREADY) |=> AWVALID;
  endproperty

  property wvalid_wait_wready;
    @(posedge clock) (WVALID && !WREADY) |=> WVALID;
  endproperty

  property arvalid_wait_arready;
    @(posedge clock) (ARVALID && !ARREADY) |=> ARVALID;
  endproperty

  /*property bvalid_wait_bready;
    @(posedge clock) (BVALID && !BREADY) |=> BVALID;
  endpropert

  property rvalid_wait_rready;
    @(posedge clock) (RVALID && !RREADY) |=> RVALID;
  endproperty*/

  property size_awsize;
    @(posedge clock) AWVALID |-> (AWSIZE <3'b011);
  endproperty

  property size_arsize;
    @(posedge clock) ARVALID |-> (ARSIZE <3'b011);
  endproperty
//
  property axi_write_wrap_allign;
    @(posedge clock) ((AWBURST == 2'b10) && (AWSIZE ==3'b001))|->(AWADDR%2 == 0);
  endproperty

  property axi_write_wrap_allign1;
    @(posedge clock) ((AWBURST == 2'b10) && (AWSIZE ==3'b010))|->(AWADDR%4 == 0);
  endproperty

  property axi_read_wrap_allign;
    @(posedge clock) ((ARBURST == 2'b10) && (ARSIZE ==3'b001))|->(ARADDR%2 == 0);
  endproperty

  property axi_read_wrap_allign1;
    @(posedge clock) ((ARBURST == 2'b10) && (ARSIZE ==3'b010))|->(ARADDR%4 == 0);
  endproperty

  property write_boundry;
    @(posedge clock) AWVALID |-> ((AWLEN+1)*(2**AWSIZE) < 4096);
  endproperty

  property read_boundry;
    @(posedge clock) ARVALID |-> ((ARLEN+1)*(2**ARSIZE) < 4096);
  endproperty

  property axi_bresp;
    @(posedge clock) (AWVALID && AWREADY) |=> ##[1:$] (BVALID && BREADY);
  endproperty

  property width_awsize;
    @(posedge clock) $rose(AWVALID) |-> ((8*(2**AWSIZE))<=32);
  endproperty

  property width_arsize;
    @(posedge clock) $rose(ARVALID) |-> ((8*(2**ARSIZE))<=32);
  endproperty


  AWADDR_STABLE : assert property(awaddr_signal_stable);
  WDATA_STABLE: assert property(wdata_signal_stable);
  ARADDR_STABLE: assert property(araddr_signal_stable);

  BRESP_STABLE: assert property(bresp_signal_stable);
  RDATA_STABLE: assert property(rdata_signal_stable);

  WBRUST_RESV: assert property (write_burst_resrved);
  RBURST_RESV: assert property (read_burst_reserved);
  AWLEN_WRAP: assert property( awlen_for_wrap);
  ARLEN_WRAP: assert property( arlen_for_wrap);
  AWVALID_WAIT_AWREADY: assert property(awvalid_wait_awready);
  WVALID_WAIT_WREADY: assert property(wvalid_wait_wready);
  ARVALID_WAIT_ARREADY: assert property(arvalid_wait_arready);
  //BVALID_WAIT_BREADY: assert property(bvalid_wait_bready);
  //RVALID_WAIT_RREADY: assert property(rvalid_wait_rready);
  SIZE_AWSIZE: assert property (size_awsize);
  SIZE_ARSIZE: assert property (size_arsize);

//
  WRITE_WRAP: assert property(axi_write_wrap_allign);
  WRITE_WRAP1: assert property(axi_write_wrap_allign1);
  READ_WRAP: assert property(axi_read_wrap_allign);
  READ_WRAP1: assert property(axi_read_wrap_allign1);
  WRITE_BOUNDRY: assert property(write_boundry);
  READ_BOUNDRY: assert property(read_boundry);
  AXI_BRESP: assert property(axi_bresp);
  WIDTH_AWSIZE: assert property(width_awsize);
  WIDTH_ARSIZE: assert property(width_arsize);

// ************************************************************************************************************************//

  endinterface
