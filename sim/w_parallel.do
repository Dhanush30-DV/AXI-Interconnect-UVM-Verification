add wave -expand -group MASTER0_to_SLAVE0 /top/a_mif_0/*
add wave -expand -group SLAVE0 /top/a_sif_0/*
add wave -expand -group MASTER1_to_SLAVE2 /top/a_mif_1/*
add wave -expand -group SLAVE2 /top/a_sif_2/*
run -all
wave zoom full
