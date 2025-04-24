export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile

include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile

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
	vsim -i -classdebug -msgmode both -coverage -voptargs="+cover=bcestf" -do "set NoQuitOnFinish 1; do wave.do; run -all; coverage save test_top.ucdb" optimized_debug_top_tb

debug_3step: clean compile simulate

debug: clean compile simulate

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	vsim -viewcov ./i2cmb_test_plan.ucdb
 
merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 
	vsim -viewcov ./sim_and_testplan_merged.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

proj_3: convert_testplan merge_coverage report_coverage
	add testbrowser ./*.ucdb