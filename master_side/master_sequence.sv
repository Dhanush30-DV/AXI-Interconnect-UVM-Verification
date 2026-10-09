class master_sequence extends uvm_sequence#(axi_xtn);
        `uvm_object_utils (master_sequence)
               extern function new(string name="master_sequence");

endclass

function master_sequence::new(string name="master_sequence");
        super.new(name);
endfunction

class mas_0_seq extends master_sequence;
        `uvm_object_utils (mas_0_seq)
        bit[1:0] write_addr;
        bit [1:0] read_addr;
        extern function new(string name="mas_0_seq");
        extern task body();
endclass

function mas_0_seq::new(string name="mas_0_seq");
        super.new(name);
endfunction

task mas_0_seq:: body();
        repeat(1)
          begin
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "write_addr_0", write_addr))
                   `uvm_fatal(get_type_name(),"Cannot get write addr of Master o from uvm_config_db")
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "read_addr_0", read_addr))
                    `uvm_fatal(get_type_name(),"Cannot get read addr of Master 0 from uvm_config_db")
                req =axi_xtn::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {write_slave == write_addr; read_slave == read_addr;});
                finish_item(req);
                $display("Master sequence is finished");
           end
endtask

class mas_1_seq extends master_sequence;
        `uvm_object_utils (mas_1_seq)
        bit[1:0] write_addr;
        bit [1:0] read_addr;
        extern function new(string name="mas_1_seq");
        extern task body();
endclass

function mas_1_seq::new(string name="mas_1_seq");
        super.new(name);
endfunction

task mas_1_seq:: body();
        repeat(1)
          begin
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "write_addr_1", write_addr))
                   `uvm_fatal(get_type_name(),"Cannot get write addr of Master 1 from uvm_config_db")
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "read_addr_1", read_addr))
                    `uvm_fatal(get_type_name(),"Cannot get read addr of Master 1 from uvm_config_db")
                req =axi_xtn::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {write_slave == write_addr; read_slave == read_addr;});
                finish_item(req);
                $display("Master 1 sequence is finished");
           end
endtask

class mas_0_multi_seq extends master_sequence;
        `uvm_object_utils (mas_0_multi_seq)
        bit[1:0] write_addr;
        bit [1:0] read_addr;
        extern function new(string name="mas_0_multi_seq");
        extern task body();
endclass

function mas_0_multi_seq::new(string name="mas_0_multi_seq");
        super.new(name);
endfunction

task mas_0_multi_seq:: body();
        repeat(1)
          begin
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "write_addr_0", write_addr))
                   `uvm_fatal(get_type_name(),"Cannot get write addr of Master 0 from uvm_config_db")
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "read_addr_0", read_addr))
                    `uvm_fatal(get_type_name(),"Cannot get read addr of Master 0 from uvm_config_db")
                req =axi_xtn::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {write_slave == write_addr; read_slave == read_addr;
                                             AWVALID == 1; ARVALID == 1;
                                             AWID inside {[1:99]}; ARID inside {[1:99]};
                                             AWLEN < 4; ARLEN < 4;});
                finish_item(req);
                $display("Master 0 multi sequence is finished");
           end
endtask

class mas_1_multi_seq extends master_sequence;
        `uvm_object_utils (mas_1_multi_seq)
        bit[1:0] write_addr;
        bit [1:0] read_addr;
        extern function new(string name="mas_1_multi_seq");
        extern task body();
endclass

function mas_1_multi_seq::new(string name="mas_1_multi_seq");
        super.new(name);
endfunction

task mas_1_multi_seq:: body();
        repeat(1)
          begin
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "write_addr_1", write_addr))
                   `uvm_fatal(get_type_name(),"Cannot get write addr of Master 1 from uvm_config_db")
                if(!uvm_config_db #(bit[1:0])::get(null, get_full_name(), "read_addr_1", read_addr))
                    `uvm_fatal(get_type_name(),"Cannot get read addr of Master 1 from uvm_config_db")
                req =axi_xtn::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {write_slave == write_addr; read_slave == read_addr;
                                             AWVALID == 1; ARVALID == 1;
                                             AWID inside {[101:199]}; ARID inside {[101:199]};
                                             AWLEN < 4; ARLEN < 4;});
                finish_item(req);
                $display("Master 1 multi sequence is finished");
           end
endtask
