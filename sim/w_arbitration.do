add wave -expand -group MASTER0 /top/a_mif_0/AWVALID /top/a_mif_0/AWREADY /top/a_mif_0/AWADDR /top/a_mif_0/WLAST /top/a_mif_0/BVALID
add wave -expand -group MASTER1 /top/a_mif_1/AWVALID /top/a_mif_1/AWREADY /top/a_mif_1/AWADDR /top/a_mif_1/WLAST /top/a_mif_1/BVALID
add wave -expand -group ARBITER_SLAVE0 {/top/AXI_INC/dut/GEN_ARB[0]/arb_aw/request} {/top/AXI_INC/dut/GEN_ARB[0]/arb_aw/grant}
add wave -expand -group ARBITER_SLAVE1 {/top/AXI_INC/dut/GEN_ARB[1]/arb_aw/request} {/top/AXI_INC/dut/GEN_ARB[1]/arb_aw/grant}
add wave -expand -group ARBITER_SLAVE2 {/top/AXI_INC/dut/GEN_ARB[2]/arb_aw/request} {/top/AXI_INC/dut/GEN_ARB[2]/arb_aw/grant}
run -all
wave zoom full
