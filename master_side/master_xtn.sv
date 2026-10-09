class axi_xtn extends uvm_sequence_item;
  `uvm_object_utils(axi_xtn)

  function new(string name ="axi_xtn");
     super.new(name);
  endfunction

  rand bit reset;
  rand bit [7:0]AWID;
  rand bit [31:0]AWADDR;
  rand bit [7:0]AWLEN;
  rand bit [2:0]AWSIZE;
  rand bit [1:0]AWBURST;
 /* rand bit AWLOCK;
  rand bit [3:0]AWCACHE;
  rand bit [2:0]AWPROT;
  rand bit [3:0]AWQOS;
  rand bit AWUSER;*/
  rand bit AWVALID;
  rand bit AWREADY;

  rand bit [31:0]WDATA [];
  bit [3:0]WSTRB [];
 // rand bit WUSER;
  bit WLAST;
  bit WVALID;
  bit WREADY;

  rand bit [7:0]BID;
  rand bit [1:0]BRESP;
  rand bit BUSER;
  bit BVALID;
  bit BREADY;

  rand bit [7:0]ARID;
  rand bit [31:0]ARADDR;
  rand bit [7:0]ARLEN;
  rand bit [2:0]ARSIZE;
  rand bit [1:0]ARBURST;
 /* rand bit ARLOCK;
  rand bit [3:0]ARCACHE;
  rand bit [2:0]ARPROT;
  rand bit [3:0]ARQOS;
  rand bit ARUSER;*/
  rand bit ARVALID;
  rand bit ARREADY;

  rand bit [31:0]RDATA [];
  //rand bit RUSER;
  bit RLAST;
  bit RVALID;
  bit RREADY;
  rand bit [7:0]RID;
  rand bit [1:0]RRESP [];

  bit [31:0]w_addr[];
  bit [31:0]r_addr[];
  rand bit [1:0]read_slave;
  rand bit [1:0]write_slave;

  constraint valid_reset{reset==1'b1;}
  constraint valid_AWVALID{AWVALID dist{1:=499,0:=1};}
  constraint valid_ARVALID{ARVALID dist{1:=499,0:=1};}
  constraint valid_R_ID{ARID inside{[1:255]};
                        RID==ARID;
                        }
 /* constraint valid_AWUSER{AWUSER==0;
                          WUSER==AWUSER;
                          BUSER==AWUSER;
                          }*/
 /* constraint valid_ARUSER{ARUSER==0;
                          RUSER==ARUSER;}*/
  constraint valid_Burst_AWADDR{
                                solve AWSIZE before AWBURST;
                                if(AWBURST==2)
                                  if(AWSIZE==1)
                                    AWADDR%2==0;
                                  else if(AWSIZE==2)
                                    AWADDR%4==0;}
  constraint valid_Burst_ARADDR{
                                solve ARSIZE before ARBURST;
                                if(ARBURST==2)
                                  if(ARSIZE==1)
                                    ARADDR%2==0;
                                  else if(ARSIZE==2)
                                    ARADDR%4==0;}

  constraint valid_AWADDR{
                          solve write_slave before AWADDR;
                          solve AWBURST before AWADDR;
                          if(write_slave==0)
                            AWADDR inside {[32'h4000_0000:32'h4000_0fff]};
                          else if(write_slave==1)
                            AWADDR inside {[32'h4000_1000:32'h4000_1fff]};
                          else if(write_slave==2)
                            AWADDR inside {[32'h4000_2000:32'h4000_2fff]};
                         }

  constraint valid_ARADDR{
                          solve read_slave before ARADDR;
                          solve ARBURST before ARADDR;
                          if(read_slave==0)
                            ARADDR inside {[32'h4000_0000:32'h4000_0fff]};
                          else if(read_slave==1)
                            ARADDR inside {[32'h4000_1000:32'h4000_1fff]};
                          else if(read_slave==2)
                            ARADDR inside {[32'h4000_2000:32'h4000_2fff]};
                         }

  constraint valid_AWBurst{AWBURST inside{0,1,2};}
  constraint valid_ARBurst{ARBURST inside{0,1,2};}

  constraint valid_AWsize{8*(2**AWSIZE)<=32;}
  constraint valid_ARsize{8*(2**ARSIZE)<=32;}
  constraint valid_WDATA_SIZE{
                           WDATA.size()==AWLEN+1;
                         }
  constraint valid_RDATA_SIZE{
                           RDATA.size()==ARLEN+1;
                         }
  constraint valid_no_ARaddr_Rresp{RRESP.size()==RDATA.size();}

  constraint valid_AW_length{
                           solve AWBURST before AWLEN;
                           if(AWBURST==0)
                             soft AWLEN inside {[0:2]};
                           else if(AWBURST==1)
                             soft AWLEN inside {[1:2]};
                           else if(AWBURST==2)
                             soft AWLEN inside{1,3/*,7,15,31,63,127,255*/};
                           }
  constraint valid_AR_length{
                           solve ARBURST before ARLEN;
                           if(ARBURST==0)
                             soft ARLEN inside {[0:255]};
                           else if(ARBURST==1)
                             soft ARLEN inside {[1:255]};
                           else if(ARBURST==2)
                             soft ARLEN inside{1,3,7,15,31,63,127,255};
                           }
  constraint valid_RRESP{
                        foreach(RRESP[i])
                          RRESP[i]==0;}
  constraint valid_BRESP{BRESP==0;}

 //methods
// extern function new(string name ="master_xtn");
 extern function void post_randomize();
 extern function void write_addr_cal();
 extern function void strobe_cal();
 extern function void read_addr_cal();
 extern function void do_print(uvm_printer printer);
endclass

/* function axi_xtn::new(string name = "master_xtn");
   super.new(name);
 endfunction*/

 function void axi_xtn::do_print(uvm_printer printer);
   super.do_print(printer);

   printer.print_field("AWID",this.AWID,8,UVM_DEC);
   printer.print_field("write_slave",this.write_slave,2,UVM_DEC);
   printer.print_field("AWADDR",this.AWADDR,32,UVM_HEX);
   printer.print_field("AWLEN",this.AWLEN,8,UVM_DEC);
   printer.print_field("AWSIZE",this.AWSIZE,3,UVM_DEC);
   printer.print_field("AWBURST",this.AWBURST,2,UVM_DEC);
 /*  printer.print_field("AWLOCK",this.AWLOCK,1,UVM_DEC);
   printer.print_field("AWCACHE",this.AWCACHE,4,UVM_DEC);
   printer.print_field("AWPROT",this.AWPROT,3,UVM_DEC);
   printer.print_field("AWQOS",this.AWQOS,4,UVM_DEC);
   printer.print_field("AWUSER",this.AWUSER,1,UVM_DEC);*/
   printer.print_field("AWVALID",this.AWVALID,1,UVM_DEC);
   printer.print_field("AWREADY",this.AWREADY,1,UVM_DEC);
   foreach(w_addr[i])
     printer.print_field($sformatf("w_addr[%0d]",i),this.w_addr[i],32,UVM_HEX);
   foreach(WDATA[i])
     printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_HEX);
   foreach(WSTRB[i])
     printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
  // printer.print_field("WUSER",this.WUSER,1,UVM_DEC);
   printer.print_field("WLAST",this.WLAST,1,UVM_DEC);
   printer.print_field("WVALID",this.WVALID,1,UVM_DEC);
   printer.print_field("WREADY",this.WREADY,1,UVM_DEC);
   printer.print_field("BID",this.BID,8,UVM_DEC);
   printer.print_field("BRESP",this.BRESP,2,UVM_DEC);
  // printer.print_field("BUSER",this.BUSER,1,UVM_DEC);
   printer.print_field("BVALID",this.BVALID,1,UVM_DEC);
   printer.print_field("BREADY",this.BREADY,1,UVM_DEC);
   printer.print_field("read_slave",this.read_slave,2,UVM_DEC);
   printer.print_field("ARADDR",this.ARADDR,32,UVM_HEX);
   printer.print_field("ARID",this.ARID,8,UVM_DEC);
   printer.print_field("ARLEN",this.ARLEN,8,UVM_DEC);
   printer.print_field("ARSIZE",this.ARSIZE,3,UVM_DEC);
   printer.print_field("ARBURST",this.ARBURST,2,UVM_DEC);
  /* printer.print_field("ARLOCK",this.ARLOCK,1,UVM_DEC);
   printer.print_field("ARCACHE",this.ARCACHE,4,UVM_DEC);
   printer.print_field("ARPROT",this.ARPROT,3,UVM_DEC);
   printer.print_field("ARQOS",this.ARQOS,4,UVM_DEC);
   printer.print_field("ARUSER",this.ARUSER,1,UVM_DEC);*/
   printer.print_field("ARVALID",this.ARVALID,1,UVM_DEC);
   printer.print_field("ARREADY",this.ARREADY,1,UVM_DEC);
   printer.print_field("RID",this.RID,8,UVM_DEC);
    foreach(r_addr[i])
     printer.print_field($sformatf("r_addr[%0d]",i),this.r_addr[i],32,UVM_HEX);
   foreach(RDATA[i])
     printer.print_field($sformatf("RDATA[%0d]",i),this.RDATA[i],32,UVM_HEX);
   foreach(RRESP[i])
     printer.print_field($sformatf("RRESP[%0d]",i),this.RRESP[i],4,UVM_DEC);
  // printer.print_field("RUSER",this.RUSER,1,UVM_DEC);
   printer.print_field("RLAST",this.RLAST,1,UVM_DEC);
   printer.print_field("RVALID",this.RVALID,1,UVM_DEC);
   printer.print_field("RREADY",this.RREADY,1,UVM_DEC);
 endfunction

 function void axi_xtn::post_randomize();

      write_addr_cal();
      read_addr_cal();

 endfunction

 function void axi_xtn::write_addr_cal();
   bit k=0;

  int w_wrap_lower_boundary;
  int w_wrap_upper_boundary;
  int w_start_address=AWADDR;
  int w_no_of_bytes=2**(AWSIZE);
  int w_burst_length=(AWLEN)+1;
  int w_alligned_address=(int'(w_start_address/w_no_of_bytes))*w_no_of_bytes;
  w_addr=new[AWLEN+1];
  w_wrap_lower_boundary=(int'(AWADDR/(w_no_of_bytes*w_burst_length)))*(w_no_of_bytes*w_burst_length);
  w_wrap_upper_boundary=w_wrap_lower_boundary+(w_no_of_bytes*w_burst_length);

  w_addr[0]=AWADDR;

  for(int i=2; i<=(AWLEN+1); i++)
   begin
       if(AWBURST==0)
         w_addr[i-1]=AWADDR;
       else if(AWBURST==1)
          w_addr[i-1]=((int'(AWADDR/w_no_of_bytes))*(w_no_of_bytes))+((i-1)*(w_no_of_bytes));
       else if(AWBURST==2)
         if(k==0)
           begin
             w_addr[i-1]=((int'(AWADDR/w_no_of_bytes))*(w_no_of_bytes))+((i-1)*(w_no_of_bytes));
             if(w_addr[i-1]==(w_wrap_upper_boundary))
              begin
                w_addr[i-1]=w_wrap_lower_boundary;
                k++;
              end
            end
       else
         w_addr[i-1]=AWADDR+((i-1)*w_no_of_bytes)-(w_no_of_bytes*w_burst_length);
         strobe_cal();
   end
 endfunction

 function void axi_xtn::strobe_cal();
  int data_bus_bytes=4;
  int lower_byte_lane;
  int upper_byte_lane;
  int lower_byte_lane_0;
  int upper_byte_lane_0;
  int w_start_address=AWADDR;
  int w_no_of_bytes=2**(AWSIZE);
  int w_alligned_address=int'(w_start_address/w_no_of_bytes)*w_no_of_bytes;

  WSTRB=new[(AWLEN+1)];

  lower_byte_lane_0=w_start_address -(int'(w_start_address/data_bus_bytes))*data_bus_bytes;
  upper_byte_lane_0=(w_alligned_address+(w_no_of_bytes-1))-((int'(w_start_address/data_bus_bytes))*data_bus_bytes);

  for(int j=lower_byte_lane_0; j<=upper_byte_lane_0; j++)
    begin
      WSTRB[0][j]=1;
    end

  for(int i=1; i<(WSTRB.size); i++)
    begin
      lower_byte_lane=w_addr[i]-(int'(w_addr[i]/data_bus_bytes))*data_bus_bytes;
      upper_byte_lane=lower_byte_lane+w_no_of_bytes-1;
      for(int j=lower_byte_lane; j<=upper_byte_lane; j++)
        WSTRB[i][j]=1;
    end
 endfunction

 function void axi_xtn::read_addr_cal();
   bit l=0;

   int r_wrap_boundary;
   int r_start_address=ARADDR;
   int r_no_of_bytes=2**ARSIZE;
   int r_burst_length=(ARLEN)+1;
   int r_alligned_address=(int'(r_start_address/r_no_of_bytes))*r_no_of_bytes;

   r_addr=new[ARLEN+1];
   r_wrap_boundary=(int'(ARADDR/(r_no_of_bytes*r_burst_length)))*(r_no_of_bytes*r_burst_length);
   r_addr[0]=ARADDR;

   for(int i=2; i<=(ARLEN+1); i++)
     begin
       if(ARBURST==0)
        r_addr[i-1]=ARADDR;
       else if(ARBURST==1)
        r_addr[i-1]=((int'(ARADDR/r_no_of_bytes))*(r_no_of_bytes))+((i-1)*(r_no_of_bytes));
       else if(ARBURST==2)
         if(l==0)
           begin
             r_addr[i-1]=((int'(ARADDR/r_no_of_bytes))*(r_no_of_bytes))+((i-1)*(r_no_of_bytes));
             if(r_addr[i-1]==r_wrap_boundary+(r_no_of_bytes*r_burst_length))
               begin
                 r_addr[i-1]=r_wrap_boundary;
                 l++;
               end
           end
       else
         r_addr[i-1]=ARADDR+((i-1)*r_no_of_bytes)-(r_no_of_bytes*r_burst_length);
     end

 endfunction
