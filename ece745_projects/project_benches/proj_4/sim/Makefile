export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile


GEN_TRANS_TYPE ?= wb_transaction
GEN_TEST_TYPE ?= i2cmb_test
TEST_SEED ?= random

clean: 
	rm -rf work *.wlf transcript qrun.out

comp_I2C_MB:
	vcom -cover f ../rtl/iicmb_int_pkg.vhd
	vcom -cover f ../rtl/iicmb_pkg.vhd
	vcom -cover f ../rtl/mbyte.vhd
	vcom -cover f ../rtl/mbit.vhd
	vcom -cover f ../rtl/bus_state.vhd
	vcom -cover f ../rtl/filter.vhd
	vcom -cover f ../rtl/conditioner.vhd
	vcom -cover f ../rtl/conditioner_mux.vhd
	vcom -cover f ../rtl/iicmb_m.vhd
	vcom -cover f ../rtl/regblock.vhd
	vcom -cover f ../rtl/wishbone.vhd
	vcom -cover f ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_env_pkg 
	vlog ../testbench/top.sv


optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

run: clean compile
	vsim  -batch -classdebug -msgmode both -l transcript -do "set NoQuitOnFinish 1; add wave -r *; log -r *; run -all; exit" optimized_debug_top_tb #-pli /mnt/apps/public/COE/synopsys_apps/verdi/S-2021.09-SP1/share/PLI/MODELSIM/LINUX/novas_fli.so

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" +GEN_TEST_TYPE=$(GEN_TEST_TYPE) optimized_debug_top_tb

debug_3step: clean compile simulate

debug: clean compile simulate

run_cli:
	vsim -coverage -c -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TEST_TYPE); coverage save $(GEN_TEST_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +GEN_TEST_TYPE=$(GEN_TEST_TYPE) optimized_debug_top_tb

cli: clean compile run_cli

regress: clean compile
	$(MAKE) run_cli
	$(MAKE) run_cli GEN_TEST_TYPE=invalid
	$(MAKE) run_cli GEN_TEST_TYPE=read_only
	$(MAKE) run_cli GEN_TEST_TYPE=default_vals
	$(MAKE) run_cli GEN_TEST_TYPE=rand_rd
	$(MAKE) run_cli GEN_TEST_TYPE=rand_wr
	$(MAKE) run_cli GEN_TEST_TYPE=alternate
	$(MAKE) run_cli GEN_TEST_TYPE=transitions

run_cov:
	vsim -i -classdebug -msgmode both -do "do load_ucdbs_and_merge_with_test_plan.do" optimized_debug_top_tb


merge_coverage_with_test_plan: clean compile run_cov

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
 
merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 
	coverage open ./sim_and_testplan_merged.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

proj_3: convert_testplan merge_coverage report_coverage