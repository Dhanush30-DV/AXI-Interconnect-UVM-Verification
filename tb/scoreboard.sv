class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(axi_xtn) fifo_mas[];
  uvm_tlm_analysis_fifo #(axi_xtn) fifo_slv[];

  env_config env_cfg;

  typedef struct {
    axi_xtn xtn;
    int     mas_id;
  } pend_t;

  pend_t m_write_pending[int][$];
  pend_t m_read_pending[int][$];

  event write_pushed;
  event read_pushed;

  axi_xtn master_cov_data0;
  axi_xtn master_cov_data1;
  axi_xtn slave_cov_data0;
  axi_xtn slave_cov_data1;
  axi_xtn slave_cov_data2;

  int data_verified_count;
  int write_verified_count;
  int read_verified_count;
  bit pass = 1;

  covergroup master_covgrp0;
    option.per_instance = 1;

    RESET        : coverpoint master_cov_data0.reset   {bins rst = {0,1};}

    AW_ID        : coverpoint master_cov_data0.AWID    {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    AW_ADDR      : coverpoint master_cov_data0.AWADDR  {bins first_slave  = {[32'h4000_0000:32'h4000_0FFF]};
                                     bins second_slave = {[32'h4000_1000:32'h4000_1FFF]};
                                     bins third_slave  = {[32'h4000_2000:32'h4000_2FFF]}; }
    AW_LENGTH    : coverpoint master_cov_data0.AWLEN   {bins fixed_type_awlen1 = {[1:51]} iff (master_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen2 = {[52:103]} iff (master_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen3 = {[104:154]} iff (master_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen4 = {[155:205]} iff (master_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen5 = {[206:255]} iff (master_cov_data0.AWBURST == 2'b00);
                                     bins incr_type_awlen1  = {[1:51]} iff (master_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen2  = {[52:103]} iff (master_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen3  = {[104:154]} iff (master_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen4  = {[155:205]} iff (master_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen5  = {[206:255]} iff (master_cov_data0.AWBURST == 2'b01);
                                     bins wrap_type_awlen1  = {1,3} iff (master_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen2  = {7,15} iff (master_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen3  = {31,63} iff (master_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen4  = {127,255} iff (master_cov_data0.AWBURST == 2'b10); }
    AW_BURST_SIZE: coverpoint master_cov_data0.AWSIZE  {bins W_B_SIZE[] = {0,1,2};}
    AW_BURST_TYPE: coverpoint master_cov_data0.AWBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    AW_VALID     : coverpoint master_cov_data0.AWVALID {bins AWVALID = {0,1};}
    AW_READY     : coverpoint master_cov_data0.AWREADY {bins AWREADY = {0,1};}

    W_LAST       : coverpoint master_cov_data0.WLAST   {bins WLAST  = {0,1};}
    W_VALID      : coverpoint master_cov_data0.WVALID  {bins WVALID = {0,1};}
    W_READY      : coverpoint master_cov_data0.WREADY  {bins WREADY = {0,1};}

    B_ID         : coverpoint master_cov_data0.BID     {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    WRITE_RESP   : coverpoint master_cov_data0.BRESP   {bins W_RESP = {0,1,2,3};}
    B_VALID      : coverpoint master_cov_data0.BVALID  {bins BVALID = {0,1};}
    B_READY      : coverpoint master_cov_data0.BREADY  {bins BREADY = {0,1};}

    AR_ID        : coverpoint master_cov_data0.ARID    {bins first_id = {[0:255]};}
    AR_ADDR      : coverpoint master_cov_data0.ARADDR  {bins first_slave  = {[32'h4000_0000:32'h4000_0FFF]};
                                     bins second_slave = {[32'h4000_1000:32'h4000_1FFF]};
                                     bins third_slave  = {[32'h4000_2000:32'h4000_2FFF]}; }
    AR_LENGTH    : coverpoint master_cov_data0.ARLEN   {bins fixed_type_arlen1 = {[1:51]} iff (master_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen2 = {[52:103]} iff (master_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen3 = {[104:154]} iff (master_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen4 = {[155:205]} iff (master_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen5 = {[206:255]} iff (master_cov_data0.ARBURST == 2'b00);
                                     bins incr_type_arlen1  = {[1:51]} iff (master_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen2  = {[52:103]} iff (master_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen3  = {[104:154]} iff (master_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen4  = {[155:205]} iff (master_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen5  = {[206:255]} iff (master_cov_data0.ARBURST == 2'b01);
                                     bins wrap_type_arlen1  = {1,3} iff (master_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen2  = {7,15} iff (master_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen3  = {31,63} iff (master_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen4  = {127,255} iff (master_cov_data0.ARBURST == 2'b10); }
    R_TRANSFER_SIZE: coverpoint master_cov_data0.ARSIZE {bins fixed_byte_transfer      = {0} iff (master_cov_data0.ARBURST == 2'b00);
                                       bins fixed_half_word_transfer = {1} iff (master_cov_data0.ARBURST == 2'b00);
                                       bins fixed_word_transfer      = {2} iff (master_cov_data0.ARBURST == 2'b00);
                                       bins incr_byte_transfer       = {0} iff (master_cov_data0.ARBURST == 2'b01);
                                       bins incr_half_word_transfer  = {1} iff (master_cov_data0.ARBURST == 2'b01);
                                       bins incr_word_transfer       = {2} iff (master_cov_data0.ARBURST == 2'b01);
                                       bins wrap_byte_transfer       = {0} iff (master_cov_data0.ARBURST == 2'b10);
                                       bins wrap_half_word_transfer  = {1} iff (master_cov_data0.ARBURST == 2'b10);
                                       bins wrap_word_transfer       = {2} iff (master_cov_data0.ARBURST == 2'b10); }
    AR_BURST_SIZE: coverpoint master_cov_data0.ARSIZE  {bins R_B_SIZE[] = {0,1,2};}
    AR_BURST_TYPE: coverpoint master_cov_data0.ARBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    ARVALID      : coverpoint master_cov_data0.ARVALID {bins ARVALID = {0,1};}
    ARREADY      : coverpoint master_cov_data0.ARREADY {bins ARREADY = {0,1};}

    R_ID         : coverpoint master_cov_data0.RID     {bins first_id = {[0:255]};}
    R_LAST       : coverpoint master_cov_data0.RLAST   {bins RLAST  = {0,1};}
    R_READY      : coverpoint master_cov_data0.RREADY  {bins RREADY = {0,1};}
    R_VALID      : coverpoint master_cov_data0.RVALID  {bins RVALID = {0,1};}

    ARVALID_ARREADY       : cross ARVALID, ARREADY;
    R_VALID_R_READY       : cross R_READY, R_VALID;
    R_VALID_R_READY_RLAST : cross R_READY, R_VALID, R_LAST;
    R_LEN_X_R_BURST_SIZE  : cross AR_LENGTH, AR_BURST_SIZE;

    AW_VALID_X_AWREADY         : cross AW_READY, AW_VALID;
    W_VALID_X_W_READY          : cross W_READY, W_VALID;
    B_VALID_X_B_READY          : cross B_READY, B_VALID;
    W_VALID_X_W_READY_X_W_LAST : cross W_VALID, W_READY, W_LAST;
    W_LEN_X_W_BURST_SIZE       : cross AW_LENGTH, AW_BURST_SIZE;
  endgroup

  covergroup master_dyn_write_covgrp0 with function sample(int i);
    option.per_instance = 1;
    WRITE_DATA : coverpoint master_cov_data0.WDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    W_STROBE   : coverpoint master_cov_data0.WSTRB[i] {bins W_STRB = {1,2,3,4,8,12,14,15};}
  endgroup

  covergroup master_dyn_read_covgrp0 with function sample(int i);
    option.per_instance = 1;
    READ_DATA  : coverpoint master_cov_data0.RDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    READ_RESP  : coverpoint master_cov_data0.RRESP[i] {bins R_RESP = {0,1,2,3};}
  endgroup

  covergroup master_covgrp1;
    option.per_instance = 1;

    RESET        : coverpoint master_cov_data1.reset   {bins rst = {0,1};}

    AW_ID        : coverpoint master_cov_data1.AWID    {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    AW_ADDR      : coverpoint master_cov_data1.AWADDR  {bins first_slave  = {[32'h4000_0000:32'h4000_0FFF]};
                                     bins second_slave = {[32'h4000_1000:32'h4000_1FFF]};
                                     bins third_slave  = {[32'h4000_2000:32'h4000_2FFF]}; }
    AW_LENGTH    : coverpoint master_cov_data1.AWLEN   {bins fixed_type_awlen1 = {[1:51]} iff (master_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen2 = {[52:103]} iff (master_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen3 = {[104:154]} iff (master_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen4 = {[155:205]} iff (master_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen5 = {[206:255]} iff (master_cov_data1.AWBURST == 2'b00);
                                     bins incr_type_awlen1  = {[1:51]} iff (master_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen2  = {[52:103]} iff (master_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen3  = {[104:154]} iff (master_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen4  = {[155:205]} iff (master_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen5  = {[206:255]} iff (master_cov_data1.AWBURST == 2'b01);
                                     bins wrap_type_awlen1  = {1,3} iff (master_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen2  = {7,15} iff (master_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen3  = {31,63} iff (master_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen4  = {127,255} iff (master_cov_data1.AWBURST == 2'b10); }
    AW_BURST_SIZE: coverpoint master_cov_data1.AWSIZE  {bins W_B_SIZE[] = {0,1,2};}
    AW_BURST_TYPE: coverpoint master_cov_data1.AWBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    AW_VALID     : coverpoint master_cov_data1.AWVALID {bins AWVALID = {0,1};}
    AW_READY     : coverpoint master_cov_data1.AWREADY {bins AWREADY = {0,1};}

    W_LAST       : coverpoint master_cov_data1.WLAST   {bins WLAST  = {0,1};}
    W_VALID      : coverpoint master_cov_data1.WVALID  {bins WVALID = {0,1};}
    W_READY      : coverpoint master_cov_data1.WREADY  {bins WREADY = {0,1};}

    B_ID         : coverpoint master_cov_data1.BID     {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    WRITE_RESP   : coverpoint master_cov_data1.BRESP   {bins W_RESP = {0,1,2,3};}
    B_VALID      : coverpoint master_cov_data1.BVALID  {bins BVALID = {0,1};}
    B_READY      : coverpoint master_cov_data1.BREADY  {bins BREADY = {0,1};}

    AR_ID        : coverpoint master_cov_data1.ARID    {bins first_id = {[0:255]};}
    AR_ADDR      : coverpoint master_cov_data1.ARADDR  {bins first_slave  = {[32'h4000_0000:32'h4000_0FFF]};
                                     bins second_slave = {[32'h4000_1000:32'h4000_1FFF]};
                                     bins third_slave  = {[32'h4000_2000:32'h4000_2FFF]}; }
    AR_LENGTH    : coverpoint master_cov_data1.ARLEN   {bins fixed_type_arlen1 = {[1:51]} iff (master_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen2 = {[52:103]} iff (master_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen3 = {[104:154]} iff (master_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen4 = {[155:205]} iff (master_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen5 = {[206:255]} iff (master_cov_data1.ARBURST == 2'b00);
                                     bins incr_type_arlen1  = {[1:51]} iff (master_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen2  = {[52:103]} iff (master_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen3  = {[104:154]} iff (master_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen4  = {[155:205]} iff (master_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen5  = {[206:255]} iff (master_cov_data1.ARBURST == 2'b01);
                                     bins wrap_type_arlen1  = {1,3} iff (master_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen2  = {7,15} iff (master_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen3  = {31,63} iff (master_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen4  = {127,255} iff (master_cov_data1.ARBURST == 2'b10); }
    R_TRANSFER_SIZE: coverpoint master_cov_data1.ARSIZE {bins fixed_byte_transfer      = {0} iff (master_cov_data1.ARBURST == 2'b00);
                                       bins fixed_half_word_transfer = {1} iff (master_cov_data1.ARBURST == 2'b00);
                                       bins fixed_word_transfer      = {2} iff (master_cov_data1.ARBURST == 2'b00);
                                       bins incr_byte_transfer       = {0} iff (master_cov_data1.ARBURST == 2'b01);
                                       bins incr_half_word_transfer  = {1} iff (master_cov_data1.ARBURST == 2'b01);
                                       bins incr_word_transfer       = {2} iff (master_cov_data1.ARBURST == 2'b01);
                                       bins wrap_byte_transfer       = {0} iff (master_cov_data1.ARBURST == 2'b10);
                                       bins wrap_half_word_transfer  = {1} iff (master_cov_data1.ARBURST == 2'b10);
                                       bins wrap_word_transfer       = {2} iff (master_cov_data1.ARBURST == 2'b10); }
    AR_BURST_SIZE: coverpoint master_cov_data1.ARSIZE  {bins R_B_SIZE[] = {0,1,2};}
    AR_BURST_TYPE: coverpoint master_cov_data1.ARBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    ARVALID      : coverpoint master_cov_data1.ARVALID {bins ARVALID = {0,1};}
    ARREADY      : coverpoint master_cov_data1.ARREADY {bins ARREADY = {0,1};}

    R_ID         : coverpoint master_cov_data1.RID     {bins first_id = {[0:255]};}
    R_LAST       : coverpoint master_cov_data1.RLAST   {bins RLAST  = {0,1};}
    R_READY      : coverpoint master_cov_data1.RREADY  {bins RREADY = {0,1};}
    R_VALID      : coverpoint master_cov_data1.RVALID  {bins RVALID = {0,1};}

    ARVALID_ARREADY       : cross ARVALID, ARREADY;
    R_VALID_R_READY       : cross R_READY, R_VALID;
    R_VALID_R_READY_RLAST : cross R_READY, R_VALID, R_LAST;
    R_LEN_X_R_BURST_SIZE  : cross AR_LENGTH, AR_BURST_SIZE;

    AW_VALID_X_AWREADY         : cross AW_READY, AW_VALID;
    W_VALID_X_W_READY          : cross W_READY, W_VALID;
    B_VALID_X_B_READY          : cross B_READY, B_VALID;
    W_VALID_X_W_READY_X_W_LAST : cross W_VALID, W_READY, W_LAST;
    W_LEN_X_W_BURST_SIZE       : cross AW_LENGTH, AW_BURST_SIZE;
  endgroup

  covergroup master_dyn_write_covgrp1 with function sample(int i);
    option.per_instance = 1;
    WRITE_DATA : coverpoint master_cov_data1.WDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    W_STROBE   : coverpoint master_cov_data1.WSTRB[i] {bins W_STRB = {1,2,3,4,8,12,14,15};}
  endgroup

  covergroup master_dyn_read_covgrp1 with function sample(int i);
    option.per_instance = 1;
    READ_DATA  : coverpoint master_cov_data1.RDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    READ_RESP  : coverpoint master_cov_data1.RRESP[i] {bins R_RESP = {0,1,2,3};}
  endgroup

  covergroup slave_covgrp0;
    option.per_instance = 1;

    RESET        : coverpoint slave_cov_data0.reset   {bins rst = {0,1};}

    AW_ID        : coverpoint slave_cov_data0.AWID    {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    AW_ADDR      : coverpoint slave_cov_data0.AWADDR  {bins slave0_range = {[32'h4000_0000:32'h4000_0FFF]}; }
    AW_LENGTH    : coverpoint slave_cov_data0.AWLEN   {bins fixed_type_awlen1 = {[1:51]} iff (slave_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen2 = {[52:103]} iff (slave_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen3 = {[104:154]} iff (slave_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen4 = {[155:205]} iff (slave_cov_data0.AWBURST == 2'b00);
                                     bins fixed_type_awlen5 = {[206:255]} iff (slave_cov_data0.AWBURST == 2'b00);
                                     bins incr_type_awlen1  = {[1:51]} iff (slave_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen2  = {[52:103]} iff (slave_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen3  = {[104:154]} iff (slave_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen4  = {[155:205]} iff (slave_cov_data0.AWBURST == 2'b01);
                                     bins incr_type_awlen5  = {[206:255]} iff (slave_cov_data0.AWBURST == 2'b01);
                                     bins wrap_type_awlen1  = {1,3} iff (slave_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen2  = {7,15} iff (slave_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen3  = {31,63} iff (slave_cov_data0.AWBURST == 2'b10);
                                     bins wrap_type_awlen4  = {127,255} iff (slave_cov_data0.AWBURST == 2'b10); }
    AW_BURST_SIZE: coverpoint slave_cov_data0.AWSIZE  {bins W_B_SIZE[] = {0,1,2};}
    AW_BURST_TYPE: coverpoint slave_cov_data0.AWBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    AW_VALID     : coverpoint slave_cov_data0.AWVALID {bins AWVALID = {0,1};}
    AW_READY     : coverpoint slave_cov_data0.AWREADY {bins AWREADY = {0,1};}

    W_LAST       : coverpoint slave_cov_data0.WLAST   {bins WLAST  = {0,1};}
    W_VALID      : coverpoint slave_cov_data0.WVALID  {bins WVALID = {0,1};}
    W_READY      : coverpoint slave_cov_data0.WREADY  {bins WREADY = {0,1};}

    B_ID         : coverpoint slave_cov_data0.BID     {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    WRITE_RESP   : coverpoint slave_cov_data0.BRESP   {bins W_RESP = {0,1,2,3};}
    B_VALID      : coverpoint slave_cov_data0.BVALID  {bins BVALID = {0,1};}
    B_READY      : coverpoint slave_cov_data0.BREADY  {bins BREADY = {0,1};}

    AR_ID        : coverpoint slave_cov_data0.ARID    {bins first_id = {[0:255]};}
    AR_ADDR      : coverpoint slave_cov_data0.ARADDR  {bins slave0_range = {[32'h4000_0000:32'h4000_0FFF]}; }
    AR_LENGTH    : coverpoint slave_cov_data0.ARLEN   {bins fixed_type_arlen1 = {[1:51]} iff (slave_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen2 = {[52:103]} iff (slave_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen3 = {[104:154]} iff (slave_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen4 = {[155:205]} iff (slave_cov_data0.ARBURST == 2'b00);
                                     bins fixed_type_arlen5 = {[206:255]} iff (slave_cov_data0.ARBURST == 2'b00);
                                     bins incr_type_arlen1  = {[1:51]} iff (slave_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen2  = {[52:103]} iff (slave_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen3  = {[104:154]} iff (slave_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen4  = {[155:205]} iff (slave_cov_data0.ARBURST == 2'b01);
                                     bins incr_type_arlen5  = {[206:255]} iff (slave_cov_data0.ARBURST == 2'b01);
                                     bins wrap_type_arlen1  = {1,3} iff (slave_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen2  = {7,15} iff (slave_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen3  = {31,63} iff (slave_cov_data0.ARBURST == 2'b10);
                                     bins wrap_type_arlen4  = {127,255} iff (slave_cov_data0.ARBURST == 2'b10); }
    R_TRANSFER_SIZE: coverpoint slave_cov_data0.ARSIZE {bins fixed_byte_transfer      = {0} iff (slave_cov_data0.ARBURST == 2'b00);
                                       bins fixed_half_word_transfer = {1} iff (slave_cov_data0.ARBURST == 2'b00);
                                       bins fixed_word_transfer      = {2} iff (slave_cov_data0.ARBURST == 2'b00);
                                       bins incr_byte_transfer       = {0} iff (slave_cov_data0.ARBURST == 2'b01);
                                       bins incr_half_word_transfer  = {1} iff (slave_cov_data0.ARBURST == 2'b01);
                                       bins incr_word_transfer       = {2} iff (slave_cov_data0.ARBURST == 2'b01);
                                       bins wrap_byte_transfer       = {0} iff (slave_cov_data0.ARBURST == 2'b10);
                                       bins wrap_half_word_transfer  = {1} iff (slave_cov_data0.ARBURST == 2'b10);
                                       bins wrap_word_transfer       = {2} iff (slave_cov_data0.ARBURST == 2'b10); }
    AR_BURST_SIZE: coverpoint slave_cov_data0.ARSIZE  {bins R_B_SIZE[] = {0,1,2};}
    AR_BURST_TYPE: coverpoint slave_cov_data0.ARBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    ARVALID      : coverpoint slave_cov_data0.ARVALID {bins ARVALID = {0,1};}
    ARREADY      : coverpoint slave_cov_data0.ARREADY {bins ARREADY = {0,1};}

    R_ID         : coverpoint slave_cov_data0.RID     {bins first_id = {[0:255]};}
    R_LAST       : coverpoint slave_cov_data0.RLAST   {bins RLAST  = {0,1};}
    R_READY      : coverpoint slave_cov_data0.RREADY  {bins RREADY = {0,1};}
    R_VALID      : coverpoint slave_cov_data0.RVALID  {bins RVALID = {0,1};}

    ARVALID_ARREADY       : cross ARVALID, ARREADY;
    R_VALID_R_READY       : cross R_READY, R_VALID;
    R_VALID_R_READY_RLAST : cross R_READY, R_VALID, R_LAST;
    R_LEN_X_R_BURST_SIZE  : cross AR_LENGTH, AR_BURST_SIZE;

    AW_VALID_X_AWREADY         : cross AW_READY, AW_VALID;
    W_VALID_X_W_READY          : cross W_READY, W_VALID;
    B_VALID_X_B_READY          : cross B_READY, B_VALID;
    W_VALID_X_W_READY_X_W_LAST : cross W_VALID, W_READY, W_LAST;
    W_LEN_X_W_BURST_SIZE       : cross AW_LENGTH, AW_BURST_SIZE;
  endgroup

  covergroup slave_dyn_write_covgrp0 with function sample(int i);
    option.per_instance = 1;
    WRITE_DATA : coverpoint slave_cov_data0.WDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    W_STROBE   : coverpoint slave_cov_data0.WSTRB[i] {bins W_STRB = {1,2,3,4,8,12,14,15};}
  endgroup

  covergroup slave_dyn_read_covgrp0 with function sample(int i);
    option.per_instance = 1;
    READ_DATA  : coverpoint slave_cov_data0.RDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    READ_RESP  : coverpoint slave_cov_data0.RRESP[i] {bins R_RESP = {0,1,2,3};}
  endgroup

  covergroup slave_covgrp1;
    option.per_instance = 1;

    RESET        : coverpoint slave_cov_data1.reset   {bins rst = {0,1};}

    AW_ID        : coverpoint slave_cov_data1.AWID    {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    AW_ADDR      : coverpoint slave_cov_data1.AWADDR  {bins slave1_range = {[32'h4000_1000:32'h4000_1FFF]}; }
    AW_LENGTH    : coverpoint slave_cov_data1.AWLEN   {bins fixed_type_awlen1 = {[1:51]} iff (slave_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen2 = {[52:103]} iff (slave_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen3 = {[104:154]} iff (slave_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen4 = {[155:205]} iff (slave_cov_data1.AWBURST == 2'b00);
                                     bins fixed_type_awlen5 = {[206:255]} iff (slave_cov_data1.AWBURST == 2'b00);
                                     bins incr_type_awlen1  = {[1:51]} iff (slave_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen2  = {[52:103]} iff (slave_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen3  = {[104:154]} iff (slave_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen4  = {[155:205]} iff (slave_cov_data1.AWBURST == 2'b01);
                                     bins incr_type_awlen5  = {[206:255]} iff (slave_cov_data1.AWBURST == 2'b01);
                                     bins wrap_type_awlen1  = {1,3} iff (slave_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen2  = {7,15} iff (slave_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen3  = {31,63} iff (slave_cov_data1.AWBURST == 2'b10);
                                     bins wrap_type_awlen4  = {127,255} iff (slave_cov_data1.AWBURST == 2'b10); }
    AW_BURST_SIZE: coverpoint slave_cov_data1.AWSIZE  {bins W_B_SIZE[] = {0,1,2};}
    AW_BURST_TYPE: coverpoint slave_cov_data1.AWBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    AW_VALID     : coverpoint slave_cov_data1.AWVALID {bins AWVALID = {0,1};}
    AW_READY     : coverpoint slave_cov_data1.AWREADY {bins AWREADY = {0,1};}

    W_LAST       : coverpoint slave_cov_data1.WLAST   {bins WLAST  = {0,1};}
    W_VALID      : coverpoint slave_cov_data1.WVALID  {bins WVALID = {0,1};}
    W_READY      : coverpoint slave_cov_data1.WREADY  {bins WREADY = {0,1};}

    B_ID         : coverpoint slave_cov_data1.BID     {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    WRITE_RESP   : coverpoint slave_cov_data1.BRESP   {bins W_RESP = {0,1,2,3};}
    B_VALID      : coverpoint slave_cov_data1.BVALID  {bins BVALID = {0,1};}
    B_READY      : coverpoint slave_cov_data1.BREADY  {bins BREADY = {0,1};}

    AR_ID        : coverpoint slave_cov_data1.ARID    {bins first_id = {[0:255]};}
    AR_ADDR      : coverpoint slave_cov_data1.ARADDR  {bins slave1_range = {[32'h4000_1000:32'h4000_1FFF]}; }
    AR_LENGTH    : coverpoint slave_cov_data1.ARLEN   {bins fixed_type_arlen1 = {[1:51]} iff (slave_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen2 = {[52:103]} iff (slave_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen3 = {[104:154]} iff (slave_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen4 = {[155:205]} iff (slave_cov_data1.ARBURST == 2'b00);
                                     bins fixed_type_arlen5 = {[206:255]} iff (slave_cov_data1.ARBURST == 2'b00);
                                     bins incr_type_arlen1  = {[1:51]} iff (slave_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen2  = {[52:103]} iff (slave_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen3  = {[104:154]} iff (slave_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen4  = {[155:205]} iff (slave_cov_data1.ARBURST == 2'b01);
                                     bins incr_type_arlen5  = {[206:255]} iff (slave_cov_data1.ARBURST == 2'b01);
                                     bins wrap_type_arlen1  = {1,3} iff (slave_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen2  = {7,15} iff (slave_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen3  = {31,63} iff (slave_cov_data1.ARBURST == 2'b10);
                                     bins wrap_type_arlen4  = {127,255} iff (slave_cov_data1.ARBURST == 2'b10); }
    R_TRANSFER_SIZE: coverpoint slave_cov_data1.ARSIZE {bins fixed_byte_transfer      = {0} iff (slave_cov_data1.ARBURST == 2'b00);
                                       bins fixed_half_word_transfer = {1} iff (slave_cov_data1.ARBURST == 2'b00);
                                       bins fixed_word_transfer      = {2} iff (slave_cov_data1.ARBURST == 2'b00);
                                       bins incr_byte_transfer       = {0} iff (slave_cov_data1.ARBURST == 2'b01);
                                       bins incr_half_word_transfer  = {1} iff (slave_cov_data1.ARBURST == 2'b01);
                                       bins incr_word_transfer       = {2} iff (slave_cov_data1.ARBURST == 2'b01);
                                       bins wrap_byte_transfer       = {0} iff (slave_cov_data1.ARBURST == 2'b10);
                                       bins wrap_half_word_transfer  = {1} iff (slave_cov_data1.ARBURST == 2'b10);
                                       bins wrap_word_transfer       = {2} iff (slave_cov_data1.ARBURST == 2'b10); }
    AR_BURST_SIZE: coverpoint slave_cov_data1.ARSIZE  {bins R_B_SIZE[] = {0,1,2};}
    AR_BURST_TYPE: coverpoint slave_cov_data1.ARBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    ARVALID      : coverpoint slave_cov_data1.ARVALID {bins ARVALID = {0,1};}
    ARREADY      : coverpoint slave_cov_data1.ARREADY {bins ARREADY = {0,1};}

    R_ID         : coverpoint slave_cov_data1.RID     {bins first_id = {[0:255]};}
    R_LAST       : coverpoint slave_cov_data1.RLAST   {bins RLAST  = {0,1};}
    R_READY      : coverpoint slave_cov_data1.RREADY  {bins RREADY = {0,1};}
    R_VALID      : coverpoint slave_cov_data1.RVALID  {bins RVALID = {0,1};}

    ARVALID_ARREADY       : cross ARVALID, ARREADY;
    R_VALID_R_READY       : cross R_READY, R_VALID;
    R_VALID_R_READY_RLAST : cross R_READY, R_VALID, R_LAST;
    R_LEN_X_R_BURST_SIZE  : cross AR_LENGTH, AR_BURST_SIZE;

    AW_VALID_X_AWREADY         : cross AW_READY, AW_VALID;
    W_VALID_X_W_READY          : cross W_READY, W_VALID;
    B_VALID_X_B_READY          : cross B_READY, B_VALID;
    W_VALID_X_W_READY_X_W_LAST : cross W_VALID, W_READY, W_LAST;
    W_LEN_X_W_BURST_SIZE       : cross AW_LENGTH, AW_BURST_SIZE;
  endgroup

  covergroup slave_dyn_write_covgrp1 with function sample(int i);
    option.per_instance = 1;
    WRITE_DATA : coverpoint slave_cov_data1.WDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    W_STROBE   : coverpoint slave_cov_data1.WSTRB[i] {bins W_STRB = {1,2,3,4,8,12,14,15};}
  endgroup

  covergroup slave_dyn_read_covgrp1 with function sample(int i);
    option.per_instance = 1;
    READ_DATA  : coverpoint slave_cov_data1.RDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    READ_RESP  : coverpoint slave_cov_data1.RRESP[i] {bins R_RESP = {0,1,2,3};}
  endgroup

  covergroup slave_covgrp2;
    option.per_instance = 1;

    RESET        : coverpoint slave_cov_data2.reset   {bins rst = {0,1};}

    AW_ID        : coverpoint slave_cov_data2.AWID    {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    AW_ADDR      : coverpoint slave_cov_data2.AWADDR  {bins slave2_range = {[32'h4000_2000:32'h4000_2FFF]}; }
    AW_LENGTH    : coverpoint slave_cov_data2.AWLEN   {bins fixed_type_awlen1 = {[1:51]} iff (slave_cov_data2.AWBURST == 2'b00);
                                     bins fixed_type_awlen2 = {[52:103]} iff (slave_cov_data2.AWBURST == 2'b00);
                                     bins fixed_type_awlen3 = {[104:154]} iff (slave_cov_data2.AWBURST == 2'b00);
                                     bins fixed_type_awlen4 = {[155:205]} iff (slave_cov_data2.AWBURST == 2'b00);
                                     bins fixed_type_awlen5 = {[206:255]} iff (slave_cov_data2.AWBURST == 2'b00);
                                     bins incr_type_awlen1  = {[1:51]} iff (slave_cov_data2.AWBURST == 2'b01);
                                     bins incr_type_awlen2  = {[52:103]} iff (slave_cov_data2.AWBURST == 2'b01);
                                     bins incr_type_awlen3  = {[104:154]} iff (slave_cov_data2.AWBURST == 2'b01);
                                     bins incr_type_awlen4  = {[155:205]} iff (slave_cov_data2.AWBURST == 2'b01);
                                     bins incr_type_awlen5  = {[206:255]} iff (slave_cov_data2.AWBURST == 2'b01);
                                     bins wrap_type_awlen1  = {1,3} iff (slave_cov_data2.AWBURST == 2'b10);
                                     bins wrap_type_awlen2  = {7,15} iff (slave_cov_data2.AWBURST == 2'b10);
                                     bins wrap_type_awlen3  = {31,63} iff (slave_cov_data2.AWBURST == 2'b10);
                                     bins wrap_type_awlen4  = {127,255} iff (slave_cov_data2.AWBURST == 2'b10); }
    AW_BURST_SIZE: coverpoint slave_cov_data2.AWSIZE  {bins W_B_SIZE[] = {0,1,2};}
    AW_BURST_TYPE: coverpoint slave_cov_data2.AWBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    AW_VALID     : coverpoint slave_cov_data2.AWVALID {bins AWVALID = {0,1};}
    AW_READY     : coverpoint slave_cov_data2.AWREADY {bins AWREADY = {0,1};}

    W_LAST       : coverpoint slave_cov_data2.WLAST   {bins WLAST  = {0,1};}
    W_VALID      : coverpoint slave_cov_data2.WVALID  {bins WVALID = {0,1};}
    W_READY      : coverpoint slave_cov_data2.WREADY  {bins WREADY = {0,1};}

    B_ID         : coverpoint slave_cov_data2.BID     {bins first_id  = {[1:51]};
                                     bins second_id = {[52:103]};
                                     bins third_id  = {[104:154]};
                                     bins fourth_id = {[155:205]};
                                     bins fifth_id  = {[206:255]}; }
    WRITE_RESP   : coverpoint slave_cov_data2.BRESP   {bins W_RESP = {0,1,2,3};}
    B_VALID      : coverpoint slave_cov_data2.BVALID  {bins BVALID = {0,1};}
    B_READY      : coverpoint slave_cov_data2.BREADY  {bins BREADY = {0,1};}

    AR_ID        : coverpoint slave_cov_data2.ARID    {bins first_id = {[0:255]};}
    AR_ADDR      : coverpoint slave_cov_data2.ARADDR  {bins slave2_range = {[32'h4000_2000:32'h4000_2FFF]}; }
    AR_LENGTH    : coverpoint slave_cov_data2.ARLEN   {bins fixed_type_arlen1 = {[1:51]} iff (slave_cov_data2.ARBURST == 2'b00);
                                     bins fixed_type_arlen2 = {[52:103]} iff (slave_cov_data2.ARBURST == 2'b00);
                                     bins fixed_type_arlen3 = {[104:154]} iff (slave_cov_data2.ARBURST == 2'b00);
                                     bins fixed_type_arlen4 = {[155:205]} iff (slave_cov_data2.ARBURST == 2'b00);
                                     bins fixed_type_arlen5 = {[206:255]} iff (slave_cov_data2.ARBURST == 2'b00);
                                     bins incr_type_arlen1  = {[1:51]} iff (slave_cov_data2.ARBURST == 2'b01);
                                     bins incr_type_arlen2  = {[52:103]} iff (slave_cov_data2.ARBURST == 2'b01);
                                     bins incr_type_arlen3  = {[104:154]} iff (slave_cov_data2.ARBURST == 2'b01);
                                     bins incr_type_arlen4  = {[155:205]} iff (slave_cov_data2.ARBURST == 2'b01);
                                     bins incr_type_arlen5  = {[206:255]} iff (slave_cov_data2.ARBURST == 2'b01);
                                     bins wrap_type_arlen1  = {1,3} iff (slave_cov_data2.ARBURST == 2'b10);
                                     bins wrap_type_arlen2  = {7,15} iff (slave_cov_data2.ARBURST == 2'b10);
                                     bins wrap_type_arlen3  = {31,63} iff (slave_cov_data2.ARBURST == 2'b10);
                                     bins wrap_type_arlen4  = {127,255} iff (slave_cov_data2.ARBURST == 2'b10); }
    R_TRANSFER_SIZE: coverpoint slave_cov_data2.ARSIZE {bins fixed_byte_transfer      = {0} iff (slave_cov_data2.ARBURST == 2'b00);
                                       bins fixed_half_word_transfer = {1} iff (slave_cov_data2.ARBURST == 2'b00);
                                       bins fixed_word_transfer      = {2} iff (slave_cov_data2.ARBURST == 2'b00);
                                       bins incr_byte_transfer       = {0} iff (slave_cov_data2.ARBURST == 2'b01);
                                       bins incr_half_word_transfer  = {1} iff (slave_cov_data2.ARBURST == 2'b01);
                                       bins incr_word_transfer       = {2} iff (slave_cov_data2.ARBURST == 2'b01);
                                       bins wrap_byte_transfer       = {0} iff (slave_cov_data2.ARBURST == 2'b10);
                                       bins wrap_half_word_transfer  = {1} iff (slave_cov_data2.ARBURST == 2'b10);
                                       bins wrap_word_transfer       = {2} iff (slave_cov_data2.ARBURST == 2'b10); }
    AR_BURST_SIZE: coverpoint slave_cov_data2.ARSIZE  {bins R_B_SIZE[] = {0,1,2};}
    AR_BURST_TYPE: coverpoint slave_cov_data2.ARBURST {bins fixed_type = {0};
                                     bins incr_type  = {1};
                                     bins wrap_type  = {2}; }
    ARVALID      : coverpoint slave_cov_data2.ARVALID {bins ARVALID = {0,1};}
    ARREADY      : coverpoint slave_cov_data2.ARREADY {bins ARREADY = {0,1};}

    R_ID         : coverpoint slave_cov_data2.RID     {bins first_id = {[0:255]};}
    R_LAST       : coverpoint slave_cov_data2.RLAST   {bins RLAST  = {0,1};}
    R_READY      : coverpoint slave_cov_data2.RREADY  {bins RREADY = {0,1};}
    R_VALID      : coverpoint slave_cov_data2.RVALID  {bins RVALID = {0,1};}

    ARVALID_ARREADY       : cross ARVALID, ARREADY;
    R_VALID_R_READY       : cross R_READY, R_VALID;
    R_VALID_R_READY_RLAST : cross R_READY, R_VALID, R_LAST;
    R_LEN_X_R_BURST_SIZE  : cross AR_LENGTH, AR_BURST_SIZE;

    AW_VALID_X_AWREADY         : cross AW_READY, AW_VALID;
    W_VALID_X_W_READY          : cross W_READY, W_VALID;
    B_VALID_X_B_READY          : cross B_READY, B_VALID;
    W_VALID_X_W_READY_X_W_LAST : cross W_VALID, W_READY, W_LAST;
    W_LEN_X_W_BURST_SIZE       : cross AW_LENGTH, AW_BURST_SIZE;
  endgroup

  covergroup slave_dyn_write_covgrp2 with function sample(int i);
    option.per_instance = 1;
    WRITE_DATA : coverpoint slave_cov_data2.WDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    W_STROBE   : coverpoint slave_cov_data2.WSTRB[i] {bins W_STRB = {1,2,3,4,8,12,14,15};}
  endgroup

  covergroup slave_dyn_read_covgrp2 with function sample(int i);
    option.per_instance = 1;
    READ_DATA  : coverpoint slave_cov_data2.RDATA[i] {bins low  = {[32'h0000_0000:32'h4444_4444]};
                                                bins mid1 = {[32'h4444_4445:32'h8888_8888]};
                                                bins mid2 = {[32'h8888_8889:32'hCCCC_CCCC]};
                                                bins high = {[32'hCCCC_CCCD:32'hFFFF_FFFF]}; }
    READ_RESP  : coverpoint slave_cov_data2.RRESP[i] {bins R_RESP = {0,1,2,3};}
  endgroup

  extern function new(string name = "scoreboard", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_master(int k);
  extern task compare_slave(int k);
  extern function int  decode_slave(bit [31:0] addr);
  extern function int  find_write(int id, int target);
  extern function int  find_read(int id, int target);
  extern function void sample_master_cov(int k, axi_xtn x);
  extern function void sample_slave_cov(int k, axi_xtn x);
  extern function void check_data(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  extern function void check_write(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  extern function void check_read(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  extern function void report_phase(uvm_phase phase);

endclass

function scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);

  master_cov_data0 = new("master_cov_data0");
  slave_cov_data0  = new("slave_cov_data0");
  master_cov_data1 = new("master_cov_data1");
  slave_cov_data1  = new("slave_cov_data1");
  slave_cov_data2  = new("slave_cov_data2");

  master_covgrp0 = new();
  slave_covgrp0  = new();
  master_covgrp1 = new();
  slave_covgrp1  = new();
  slave_covgrp2  = new();

  master_dyn_write_covgrp0 = new();
  slave_dyn_write_covgrp0  = new();
  master_dyn_write_covgrp1 = new();
  slave_dyn_write_covgrp1  = new();
  slave_dyn_write_covgrp2  = new();

  master_dyn_read_covgrp0 = new();
  slave_dyn_read_covgrp0  = new();
  master_dyn_read_covgrp1 = new();
  slave_dyn_read_covgrp1  = new();
  slave_dyn_read_covgrp2  = new();
endfunction

function void scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(!uvm_config_db #(env_config)::get(this, "", "env_config", env_cfg))
    `uvm_fatal("AXI-SCOREBOARD", "Cannot get env_cfg from uvm_config_db. Have you set it?")

  fifo_mas = new[env_cfg.no_of_master_agents];
  fifo_slv = new[env_cfg.no_of_slave_agents];

  foreach(fifo_mas[i])
    fifo_mas[i] = new($sformatf("fifo_mas[%0d]", i), this);

  foreach(fifo_slv[i])
    fifo_slv[i] = new($sformatf("fifo_slv[%0d]", i), this);
endfunction

task scoreboard::run_phase(uvm_phase phase);

  foreach(fifo_mas[i])
    begin
      automatic int k = i;
      fork
        collect_master(k);
      join_none
    end

  foreach(fifo_slv[i])
    begin
      automatic int k = i;
      fork
        compare_slave(k);
      join_none
    end
endtask

task scoreboard::collect_master(int k);
  forever
    begin
      axi_xtn mast_data_local;
      pend_t  p;

      fifo_mas[k].get(mast_data_local);
      `uvm_info($sformatf("AXI_SB_MAS_%0d", k), $sformatf("Master %0d Txn Received", k), UVM_LOW)

      if(mast_data_local.AWVALID && mast_data_local.AWREADY)
        begin
          p.xtn    = mast_data_local;
          p.mas_id = k;
          m_write_pending[mast_data_local.AWID].push_back(p);
          ->write_pushed;
        end

      if(mast_data_local.ARVALID && mast_data_local.ARREADY)
        begin
          p.xtn    = mast_data_local;
          p.mas_id = k;
          m_read_pending[mast_data_local.ARID].push_back(p);
          ->read_pushed;
        end

      sample_master_cov(k, mast_data_local);
    end
endtask

task scoreboard::compare_slave(int k);
  forever
    begin
      axi_xtn slv_data_local;
      pend_t  mast_match;
      int     id;
      int     target;
      int     idx;

      fifo_slv[k].get(slv_data_local);
      `uvm_info($sformatf("AXI_SB_SLV_%0d", k), $sformatf("Slave %0d Txn Received", k), UVM_LOW)

      sample_slave_cov(k, slv_data_local);

      if(slv_data_local.AWVALID)
        begin
          id     = slv_data_local.AWID;
          target = decode_slave(slv_data_local.AWADDR);

          if(target != k)
            begin
              `uvm_error("AXI_SB_ROUTING", $sformatf("Slave %0d received WRITE addr %h which belongs to slave %0d", k, slv_data_local.AWADDR, target))
              pass = 0;
            end

          idx = find_write(id, target);
          while(idx < 0)
            begin
              @(write_pushed);
              idx = find_write(id, target);
            end

          mast_match = m_write_pending[id][idx];
          m_write_pending[id].delete(idx);
          if(m_write_pending[id].size() == 0)
            m_write_pending.delete(id);

          `uvm_info("AXI_SB", $sformatf("WRITE : Master %0d -> Slave %0d  (AWID=%0d)", mast_match.mas_id, k, id), UVM_LOW)
          check_data(mast_match.xtn, slv_data_local);
        end

      if(slv_data_local.ARVALID)
        begin
          id     = slv_data_local.ARID;
          target = decode_slave(slv_data_local.ARADDR);

          if(target != k)
            begin
              `uvm_error("AXI_SB_ROUTING", $sformatf("Slave %0d received READ addr %h which belongs to slave %0d", k, slv_data_local.ARADDR, target))
              pass = 0;
            end

          idx = find_read(id, target);
          while(idx < 0)
            begin
              @(read_pushed);
              idx = find_read(id, target);
            end

          mast_match = m_read_pending[id][idx];
          m_read_pending[id].delete(idx);
          if(m_read_pending[id].size() == 0)
            m_read_pending.delete(id);

          `uvm_info("AXI_SB", $sformatf("READ  : Master %0d -> Slave %0d  (ARID=%0d)", mast_match.mas_id, k, id), UVM_LOW)
          check_data(mast_match.xtn, slv_data_local);
        end
    end
endtask

function int scoreboard::decode_slave(bit [31:0] addr);
  if(addr >= 32'h4000_0000 && addr <= 32'h4000_0FFF) return 0;
  if(addr >= 32'h4000_1000 && addr <= 32'h4000_1FFF) return 1;
  if(addr >= 32'h4000_2000 && addr <= 32'h4000_2FFF) return 2;
  return -1;
endfunction

function int scoreboard::find_write(int id, int target);
  if(!m_write_pending.exists(id))
    return -1;
  for(int j = 0; j < m_write_pending[id].size(); j++)
    if(decode_slave(m_write_pending[id][j].xtn.AWADDR) == target)
      return j;
  return -1;
endfunction

function int scoreboard::find_read(int id, int target);
  if(!m_read_pending.exists(id))
    return -1;
  for(int j = 0; j < m_read_pending[id].size(); j++)
    if(decode_slave(m_read_pending[id][j].xtn.ARADDR) == target)
      return j;
  return -1;
endfunction

function void scoreboard::sample_master_cov(int k, axi_xtn x);
  case(k)
    0 : begin
          master_cov_data0 = x;
          master_covgrp0.sample();
          if(x.AWVALID) foreach(x.WDATA[i]) master_dyn_write_covgrp0.sample(i);
          if(x.ARVALID) foreach(x.RDATA[i]) master_dyn_read_covgrp0.sample(i);
        end
    1 : begin
          master_cov_data1 = x;
          master_covgrp1.sample();
          if(x.AWVALID) foreach(x.WDATA[i]) master_dyn_write_covgrp1.sample(i);
          if(x.ARVALID) foreach(x.RDATA[i]) master_dyn_read_covgrp1.sample(i);
        end
    default : `uvm_warning("AXI_SB_COV", $sformatf("No covergroup for master %0d", k))
  endcase
endfunction

function void scoreboard::sample_slave_cov(int k, axi_xtn x);
  case(k)
    0 : begin
          slave_cov_data0 = x;
          slave_covgrp0.sample();
          if(x.AWVALID) foreach(x.WDATA[i]) slave_dyn_write_covgrp0.sample(i);
          if(x.ARVALID) foreach(x.RDATA[i]) slave_dyn_read_covgrp0.sample(i);
        end
    1 : begin
          slave_cov_data1 = x;
          slave_covgrp1.sample();
          if(x.AWVALID) foreach(x.WDATA[i]) slave_dyn_write_covgrp1.sample(i);
          if(x.ARVALID) foreach(x.RDATA[i]) slave_dyn_read_covgrp1.sample(i);
        end
    2 : begin
          slave_cov_data2 = x;
          slave_covgrp2.sample();
          if(x.AWVALID) foreach(x.WDATA[i]) slave_dyn_write_covgrp2.sample(i);
          if(x.ARVALID) foreach(x.RDATA[i]) slave_dyn_read_covgrp2.sample(i);
        end
    default : `uvm_warning("AXI_SB_COV", $sformatf("No covergroup for slave %0d", k))
  endcase
endfunction

function void scoreboard::check_data(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  $display("******************************************** Report from Scoreboard ********************************************");

  if(mast_axi_xtn.AWVALID && mast_axi_xtn.AWREADY)
    check_write(mast_axi_xtn, slv_axi_xtn);

  if(mast_axi_xtn.ARVALID && mast_axi_xtn.ARREADY)
    check_read(mast_axi_xtn, slv_axi_xtn);

  data_verified_count++;
  $display("****************************************************************************************************************");
endfunction

function void scoreboard::check_write(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  $display("^^^^^^^^^^^^^^^^^^^^^^ Score Board Write-Transaction Comparison ^^^^^^^^^^^^^^^^^^^^^^");

  if(mast_axi_xtn.AWADDR == slv_axi_xtn.AWADDR)
    `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Address comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Address comparison is Failed")
      $display("master address = %h, slave address = %h", mast_axi_xtn.AWADDR, slv_axi_xtn.AWADDR);
      pass = 0;
    end

  if((mast_axi_xtn.AWLEN   == slv_axi_xtn.AWLEN)  &&
     (mast_axi_xtn.AWSIZE  == slv_axi_xtn.AWSIZE) &&
     (mast_axi_xtn.AWBURST == slv_axi_xtn.AWBURST))
    `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Control information comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Control information comparison is Failed")
      $display("master len=%0d size=%0d burst=%0d, slave len=%0d size=%0d burst=%0d",
               mast_axi_xtn.AWLEN, mast_axi_xtn.AWSIZE, mast_axi_xtn.AWBURST,
               slv_axi_xtn.AWLEN,  slv_axi_xtn.AWSIZE,  slv_axi_xtn.AWBURST);
      pass = 0;
    end

  if(mast_axi_xtn.WDATA.size() != slv_axi_xtn.WDATA.size())
    begin
      `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", $sformatf("Write beat count mismatch : master %0d beats, slave %0d beats",
                 mast_axi_xtn.WDATA.size(), slv_axi_xtn.WDATA.size()))
      pass = 0;
    end
  else
    begin
      foreach(slv_axi_xtn.WDATA[i])
        if(mast_axi_xtn.WDATA[i] == slv_axi_xtn.WDATA[i])
          `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", $sformatf("Write Data[%0d] comparison is Successful", i), UVM_LOW)
        else
          begin
            `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", $sformatf("Write Data[%0d] comparison is Failed", i))
            $display("master data = %h, slave data = %h", mast_axi_xtn.WDATA[i], slv_axi_xtn.WDATA[i]);
            pass = 0;
          end

      if(mast_axi_xtn.WSTRB.size() == slv_axi_xtn.WSTRB.size())
        foreach(slv_axi_xtn.WSTRB[i])
          if(mast_axi_xtn.WSTRB[i] == slv_axi_xtn.WSTRB[i])
            `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", $sformatf("Write Strobe[%0d] comparison is Successful", i), UVM_LOW)
          else
            begin
              `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", $sformatf("Write Strobe[%0d] comparison is Failed", i))
              $display("master strb = %b, slave strb = %b", mast_axi_xtn.WSTRB[i], slv_axi_xtn.WSTRB[i]);
              pass = 0;
            end
    end

  if(mast_axi_xtn.BVALID && mast_axi_xtn.BREADY)
    begin
      if(mast_axi_xtn.BRESP == slv_axi_xtn.BRESP)
        `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write Response comparison is Successful", UVM_LOW)
      else
        begin
          `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write Response comparison is Failed")
          $display("master bresp = %0d, slave bresp = %0d", mast_axi_xtn.BRESP, slv_axi_xtn.BRESP);
          pass = 0;
        end

      if(mast_axi_xtn.BID == slv_axi_xtn.BID)
        `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID comparison is Successful", UVM_LOW)
      else
        begin
          `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID comparison is Failed")
          $display("master bid = %h, slave bid = %h", mast_axi_xtn.BID, slv_axi_xtn.BID);
          pass = 0;
        end

      if(mast_axi_xtn.AWID == slv_axi_xtn.BID)
        `uvm_info("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID with transfer ID comparison is Successful", UVM_LOW)
      else
        begin
          `uvm_error("AXI_SCORE-BOARD--WRITE_DATA", "Write response ID with transfer ID comparison is Failed")
          $display("master awid = %h, slave bid = %h", mast_axi_xtn.AWID, slv_axi_xtn.BID);
          pass = 0;
        end
    end

  write_verified_count++;
  $display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
endfunction

function void scoreboard::check_read(axi_xtn mast_axi_xtn, axi_xtn slv_axi_xtn);
  $display("^^^^^^^^^^^^^^^^^^^^^^ Score Board Read-Transaction Comparison ^^^^^^^^^^^^^^^^^^^^^^^");

  if(mast_axi_xtn.ARADDR == slv_axi_xtn.ARADDR)
    `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read Address comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read Address comparison is Failed")
      $display("master address = %h, slave address = %h", mast_axi_xtn.ARADDR, slv_axi_xtn.ARADDR);
      pass = 0;
    end

  if((mast_axi_xtn.ARLEN   == slv_axi_xtn.ARLEN)  &&
     (mast_axi_xtn.ARSIZE  == slv_axi_xtn.ARSIZE) &&
     (mast_axi_xtn.ARBURST == slv_axi_xtn.ARBURST))
    `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read Control information comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read Control information comparison is Failed")
      $display("master len=%0d size=%0d burst=%0d, slave len=%0d size=%0d burst=%0d",
               mast_axi_xtn.ARLEN, mast_axi_xtn.ARSIZE, mast_axi_xtn.ARBURST,
               slv_axi_xtn.ARLEN,  slv_axi_xtn.ARSIZE,  slv_axi_xtn.ARBURST);
      pass = 0;
    end

  if(mast_axi_xtn.RDATA.size() != slv_axi_xtn.RDATA.size())
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", $sformatf("Read beat count mismatch : master %0d beats, slave %0d beats",
                 mast_axi_xtn.RDATA.size(), slv_axi_xtn.RDATA.size()))
      pass = 0;
    end
  else
    foreach(slv_axi_xtn.RDATA[i])
      begin
        if(mast_axi_xtn.RDATA[i] == slv_axi_xtn.RDATA[i])
          `uvm_info("AXI_SCORE-BOARD--READ_DATA", $sformatf("Read Data[%0d] comparison is Successful", i), UVM_LOW)
        else
          begin
            `uvm_error("AXI_SCORE-BOARD--READ_DATA", $sformatf("Read Data[%0d] comparison is Failed", i))
            $display("master data = %h, slave data = %h", mast_axi_xtn.RDATA[i], slv_axi_xtn.RDATA[i]);
            pass = 0;
          end

        if(mast_axi_xtn.RRESP[i] != slv_axi_xtn.RRESP[i])
          begin
            `uvm_error("AXI_SCORE-BOARD--READ_DATA", $sformatf("Read Response[%0d] comparison is Failed", i))
            $display("master rresp = %0d, slave rresp = %0d", mast_axi_xtn.RRESP[i], slv_axi_xtn.RRESP[i]);
            pass = 0;
          end
      end

  if(mast_axi_xtn.RID == slv_axi_xtn.RID)
    `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read ID comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read ID comparison is Failed")
      $display("master rid = %h, slave rid = %h", mast_axi_xtn.RID, slv_axi_xtn.RID);
      pass = 0;
    end

  if(mast_axi_xtn.ARID == slv_axi_xtn.RID)
    `uvm_info("AXI_SCORE-BOARD--READ_DATA", "Read ID with transfer ID comparison is Successful", UVM_LOW)
  else
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", "Read ID with transfer ID comparison is Failed")
      $display("master arid = %h, slave rid = %h", mast_axi_xtn.ARID, slv_axi_xtn.RID);
      pass = 0;
    end

  if(!mast_axi_xtn.RLAST)
    begin
      `uvm_error("AXI_SCORE-BOARD--READ_DATA", "RLAST was not seen by the master on the last read beat")
      pass = 0;
    end

  read_verified_count++;
  $display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
endfunction

function void scoreboard::report_phase(uvm_phase phase);

  foreach(m_write_pending[i])
    if(m_write_pending[i].size() > 0)
      begin
        `uvm_error("AXI_SB_REPORT", $sformatf("Found %0d un-matched master WRITE transactions with ID %0h", m_write_pending[i].size(), i))
        pass = 0;
      end

  foreach(m_read_pending[i])
    if(m_read_pending[i].size() > 0)
      begin
        `uvm_error("AXI_SB_REPORT", $sformatf("Found %0d un-matched master READ transactions with ID %0h", m_read_pending[i].size(), i))
        pass = 0;
      end

  if(data_verified_count == 0)
    begin
      `uvm_error("AXI_SB_REPORT", "No transactions were compared by the scoreboard")
      pass = 0;
    end

  `uvm_info("AXI_SB_REPORT", $sformatf("Transactions compared : %0d  (writes = %0d, reads = %0d)",
            data_verified_count, write_verified_count, read_verified_count), UVM_NONE)

  if(pass)
    begin
      $display("  ----------------------------------------------");
      $display("PASS");
      $display("  ----------------------------------------------");
    end
  else
    begin
      $display("  ----------------------------------------------");
      $display("FAIL");
      $display("  ----------------------------------------------");
    end
endfunction
