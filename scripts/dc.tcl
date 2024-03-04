#TOP CPU n-bits

set module_name top
set n-bits 8
set library saed32
set_host_options -max_cores 8

####### DC ###########

# Search Path and Logic Library Setup
define_design_lib WORK -path  ./work

set_app_var search_path "$search_path . ./rtl/ ./libs/DBs"
set_app_var target_library [glob ./libs/DBs/*.db]
set_app_var link_library "* $target_library"

# Set SVF name
set_svf  ./outputs/${module_name}.svf

# RTL Reading and Link
analyze -format sverilog {top.v mux4.v mux4_registered.v memory.v register_bank.v ALU.v control.v} > reports/analyze_${module_name}.rpt
elaborate ${module_name} -parameters WIDTH=${n-bits} > reports/elaborate_${module_name}.rpt

# Save pre-Design
#write_file -format verilog -hier -out ./outputs/unmapped_${module_name}${n-bits}bits_${library}.v
#write_sdc ./outputs/unmapped_${module_name}${n-bits}bits_${library}.sdc
#write_file -format ddc -hier -out ./outputs/unmapped_${module_name}${n-bits}bits_${library}.ddc

load_upf ./inputs/power.upf

# Constraints
#read_sdc ./inputs/constraints.sdc
## Power

set_voltage -object_list VDD 0.95
set_voltage -object_list VSS 0.0

## Timing

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


# Check and exit if any supply nets are missing a defined voltage.
if {![check_mv_design -power_nets]} {
  puts "RM-Error: One or more supply nets are missing a defined voltage.  Use the set_voltage command to set the appropriate voltage upon the supply."
  puts "This script will now exit."
  sproc_script_stop
}

# Pre-compile Reports
# report_clock -skew > reports/pre_clock_${module_name}${n-bits}bits_${library}.rpt
# report_timing > reports/pre_design_timing_${module_name}${n-bits}bits_${library}.rpt

# check_timing > reports/check_pre_timing_${module_name}${n-bits}bits_${library}.rpt
# check_design > reports/check_pre_design_${module_name}${n-bits}bits_${library}.rpt


# Compile/Synthesis
#compile_ultra -no_autoungroup -gate_clock -scan  > reports/compile_${module_name}${n-bits}bits_${library}.rpt
compile_ultra -no_autoungroup 

#sizeof_collection [all_registers]
#optimize_registers
#sizeof_collection [all_registers]

#optimize_netlist -area

#create_test_protocol -infer_clock -infer_asynch
#dft_drc

#preview_dft
#insert_dft
#dft_drc

#compile_ultra -no_autoungroup -gate_clock -incr -scan
#dft_drc

#write_scan_def -output ./outputs/dft_${module_name}${n-bits}bits_${library}.scandef

# Post-compile Reports
#report_clock_gating > reports/clock_gating_${module_name}${n-bits}bits_${library}.rpt
#report_scan_path -view existing_dft -chain all > reports/scan_${module_name}${n-bits}bits_${library}.rpt
report_timing > reports/timing_${module_name}${n-bits}bits_${library}.rpt
report_constraint -all_violators > reports/constraint_${module_name}${n-bits}bits_${library}.rpt
report_qor > reports/qor_${module_name}${n-bits}bits_${library}.rpt
report_power > reports/power_${module_name}${n-bits}bits_${library}.rpt
report_area > reports/area_${module_name}${n-bits}bits_${library}.rpt
check_timing > reports/check_timing_${module_name}${n-bits}bits_${library}.rpt
check_design > reports/check_design_${module_name}${n-bits}bits_${library}.rpt

# Save Design
#change_names -hier -rule verilog
write_file -format verilog -hier -out ./outputs/mapped_${module_name}${n-bits}bits_${library}.v
write_sdc ./outputs/mapped_${module_name}${n-bits}bits_${library}.sdc
#write_file -format ddc -hier -out ./outputs/mapped_${module_name}${n-bits}bits_${library}.ddc
write_parasitics -output ./outputs/parasitics_${module_name}${n-bits}bits_${library}.spef

# Exit
exit

