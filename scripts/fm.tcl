#TOP CPU n-bits

set module_name top
set n-bits 8
set library saed32


##### FM #######

set_app_var search_path "$search_path . ./rtl ./libs/DBs ./outputs"

#fm_shell -f ./scripts/fm.tcl | & tee -i ./logs/fm.log

set synopsys_auto_setup true 

set_svf -append ${module_name}.svf 

read_sverilog -container r -libname WORK -05 { top.v mux4.v mux4_registered.v memory.v register_bank.v ALU.v control.v} 

set_top ${module_name}

read_verilog -container i -libname WORK -05 mapped_${module_name}${n-bits}bits_${library}.v 

read_db [glob ./libs/DBs/*.db]

set_top ${module_name}_WIDTH${n-bits}

report_guidance > reports/guidance_${module_name}${n-bits}bits_${library}.rpt

save_session -replace ./sessions/pre_verify_${module_name}${n-bits}bits_${library}.fss 

match > reports/match_${module_name}${n-bits}bits_${library}.rpt

report_matched_points > reports/matched_points_${module_name}${n-bits}bits_${library}.rpt

verify > reports/verify_${module_name}${n-bits}bits_${library}.rpt

report_verify_points > reports/verify_points_${module_name}${n-bits}bits_${library}.rpt
report_analysis_results -summary > reports/analysis_summary_${module_name}${n-bits}bits_${library}.rpt

save_session -replace ./sessions/post_verify_${module_name}${n-bits}bits_${library}.fss 

exit 