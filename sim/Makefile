# AXI4 Interconnect (2 Masters x 3 Slaves) - UVM testbench
# Simulator : Questa (vlog / vsim / vcover)
# RTL is NOT part of this repo (provided by Maven Silicon). Put it in ../AXI_Interconnect_rtl

RTL      = ../AXI_Interconnect_rtl/*.v ../AXI_Interconnect_rtl/*.sv
INTF     = ../interface/*.sv
INC      = +incdir+../tb +incdir+../test +incdir+../master_side +incdir+../slave_side
SVTB     = ../test/test_pkg.sv ../test/top.sv
WORK     = work
SEED     = -sv_seed random
VSIMOPT  = -cvgperinstance -vopt -voptargs=+acc -coverage -sva -c
TIMEOUT  = +UVM_TIMEOUT=20000000,YES
NUM_SEEDS = 1 2 3 4 5 6 7 8 9 10

help:
	@echo "============================================================================================"
	@echo "! clean      => clean logs and intermediate files                                          !"
	@echo "! sv_cmp     => create library and compile                                                 !"
	@echo "! run_test   => mas_0_test            (master 0 -> slave 0)                                !"
	@echo "! run_test1  => mas_1_test            (master 1 -> slave 1)                                !"
	@echo "! run_test2  => multi_diff_slave_test (M0 -> S0 and M1 -> S2 at the same time)             !"
	@echo "! run_test3  => multi_same_slave_test (both masters -> same slave, arbitration)            !"
	@echo "! regress    => compile, run all 4 tests and merge coverage                                !"
	@echo "! seeds      => run the multi master tests with 10 random seeds                            !"
	@echo "! merge_all  => merge regress + seeds coverage and print summary                           !"
	@echo "! waves      => open 4 Questa windows: M0-S0, M1-S1, parallel, arbitration                 !"
	@echo "============================================================================================"

sv_cmp:
	vlib $(WORK)
	vmap work $(WORK)
	vlog -work $(WORK) $(INC) $(RTL) $(INTF) $(SVTB)

run_test: sv_cmp
	vsim $(VSIMOPT) -do "log -r /* ;coverage save -onexit mem_cov;run -all; exit" $(TIMEOUT) -wlf wave_file.wlf -l test.log $(SEED) work.top +UVM_TESTNAME=mas_0_test

run_test1:
	vsim $(VSIMOPT) -do "log -r /* ;coverage save -onexit mem_cov1;run -all; exit" $(TIMEOUT) -wlf wave_file1.wlf -l test1.log $(SEED) work.top +UVM_TESTNAME=mas_1_test

run_test2:
	vsim $(VSIMOPT) -do "log -r /* ;coverage save -onexit mem_cov2;run -all; exit" $(TIMEOUT) -wlf wave_file2.wlf -l test2.log $(SEED) work.top +UVM_TESTNAME=multi_diff_slave_test

run_test3:
	vsim $(VSIMOPT) -do "log -r /* ;coverage save -onexit mem_cov3;run -all; exit" $(TIMEOUT) -wlf wave_file3.wlf -l test3.log $(SEED) work.top +UVM_TESTNAME=multi_same_slave_test

report:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3
	vcover report -summary mem_cov | tee coverage_summary.txt

regress: clean run_test run_test1 run_test2 run_test3 report

seeds: sv_cmp
	for i in $(NUM_SEEDS); do \
	vsim $(VSIMOPT) -do "coverage save -onexit seed_same_$$i;run -all; exit" $(TIMEOUT) -l seed_same_$$i.log $(SEED) work.top +UVM_TESTNAME=multi_same_slave_test; \
	vsim $(VSIMOPT) -do "coverage save -onexit seed_diff_$$i;run -all; exit" $(TIMEOUT) -l seed_diff_$$i.log $(SEED) work.top +UVM_TESTNAME=multi_diff_slave_test; \
	done

merge_all:
	vcover merge axi_final mem_cov $(filter-out %.log,$(wildcard seed_same_* seed_diff_*))
	vcover report -summary axi_final | tee axi_cov_summary.txt
	vcover report -cvg -details -nocompactcrossbins -assert -directive -html -output covhtml_final axi_final

waves: sv_cmp
	vsim -vopt -voptargs=+acc -gui work.top +UVM_TESTNAME=mas_0_test -do w_m0s0.do &
	vsim -vopt -voptargs=+acc -gui work.top +UVM_TESTNAME=mas_1_test -do w_m1s1.do &
	vsim -vopt -voptargs=+acc -gui work.top +UVM_TESTNAME=multi_diff_slave_test -do w_parallel.do &
	vsim -vopt -voptargs=+acc -gui work.top +UVM_TESTNAME=multi_same_slave_test -do w_arbitration.do &

clean:
	rm -rf work modelsim.ini *.log *.wlf transcript mem_cov* seed_* axi_final covhtml* *_summary.txt

.PHONY: help sv_cmp run_test run_test1 run_test2 run_test3 report regress seeds merge_all waves clean
