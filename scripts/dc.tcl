#TOP CPU n-bits

set module_name top
set n-bits 8
set library hvt ;#hvt lvt rvt  high, low, regular?
set speed ff ;#ff ss tt: fast slow and typical
set voltage 0p85 ;# 
set temperature 25 ;# 24 n40 125

####### DC ###########

# Search Path and Logic Library Setup
define_design_lib WORK -path  ./work

set_app_var search_path "$search_path . ./rtl/ ./libs/stdcell_${library}/db_nldm/"
set_app_var target_library "saed32${library}_${speed}${voltage}v${temperature}c.db" ;#synopsys armenia educational 32nm low voltage transistor fast-fast 0.85V 25°C
set_app_var link_library "* $target_library"



# Set SVF name
set_svf  ./my_run/${module_name}.svf

# RTL Reading and Link
analyze -format sverilog {top.v mux4.v mux4_registered.v memory.v register_bank.v ALU.v control.v} > reports/analyze_${module_name}.rpt
elaborate ${module_name} -parameters WIDTH=${n-bits} > reports/elaborate_${module_name}.rpt
if {[link]==0} {exit}

# Save pre-Design
write_file -format verilog -hier -out ./my_run/unmapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.v
#write_sdc ./my_run/unmapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.sdc
#write_file -format ddc -hier -out ./my_run/unmapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.ddc

# Timing
set clk_val 50
create_clock -period $clk_val [get_port clk]
set_clock_uncertainty -setup [expr {$clk_val*0.1}] clk
set_clock_transition -max [expr {$clk_val*0.20}] clk
set_clock_latency -source -max [expr {$clk_val*0.05}] clk
set_input_delay -max [expr {$clk_val*0.4}] -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay -max [expr {$clk_val*0.5}] -clock clk [all_outputs]
set_load -max 1 [all_outputs]
set_input_transition -min [expr {$clk_val*0.01}] [all_inputs]
set_input_transition -max [expr {$clk_val*0.10}] [all_inputs]

# Pre-compile Reports
report_clock -skew > reports/pre_clock_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_timing > reports/pre_design_timing_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt

check_timing > reports/check_pre_timing_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
check_design > reports/check_pre_design_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt


# Compile/Synthesis
#compile_ultra -no_autoungroup -gate_clock -scan  > reports/compile_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
compile_ultra -gate_clock > reports/compile_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt

sizeof_collection [all_registers]
optimize_registers
sizeof_collection [all_registers]

#optimize_netlist -area

#create_test_protocol -infer_clock -infer_asynch
#dft_drc

#preview_dft
#insert_dft
#dft_drc

#compile_ultra -no_autoungroup -gate_clock -incr -scan
#dft_drc

#write_scan_def -output ./my_run/dft_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.scandef

# Post-compile Reports
report_clock_gating > reports/clock_gating_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
#report_scan_path -view existing_dft -chain all > reports/scan_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_timing > reports/timing_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_constraint -all_violators > reports/constraint_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_qor > reports/qor_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_power > reports/power_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
report_area > reports/area_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
check_timing > reports/check_timing_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt
check_design > reports/check_design_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.rpt

# Save Design
change_names -hier -rule verilog
write_file -format verilog -hier -out ./my_run/mapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.v
write_sdc ./my_run/mapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.sdc
#write_file -format ddc -hier -out ./my_run/mapped_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.ddc
write_parasitics -output ./my_run/parasitics_${module_name}${n-bits}bits_${library}_${speed}${voltage}v${temperature}c.spef

# Exit
exit

