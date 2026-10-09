class slave_sequence extends uvm_sequence#(slave_xtn);
  `uvm_object_utils(slave_sequence)

  function new(string name = "slave_sequence");
    super.new(name);
  endfunction

endclass

class slv_second_seq extends slave_sequence;
  `uvm_object_utils(slv_second_seq)
  extern function new(string name = "slv_second_seq");
  extern task body();
endclass

function slv_second_seq::new(string name = "slv_second_seq");
  super.new(name);
endfunction

task slv_second_seq::body();
  repeat(1)
  begin
    req = slave_xtn::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  end
endtask
