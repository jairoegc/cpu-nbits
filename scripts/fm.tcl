#TOP CPU n-bits

set module_name top
set n-bits 16


##### FM #######

set_app_var search_path "$search_path . ./rtl ./libs ./my_run"

#fm_shell -f ./scripts/fm.tcl | & tee -i ./logs/fm.log

set synopsys_auto_setup true 

set_svf -append ${module_name}.svf 

read_sverilog -container r -libname WORK -05 { top.v mux4.v mux4_registered.v memory.v register_bank.v ALU.v control.v} 

set_top ${module_name}

read_verilog -container i -libname WORK -05 mapped_${module_name}.v 

read_db { sky130_fd_sc_hd__ff_100C_1v95.db sky130_fd_sc_hd__ss_100C_1v40.db } 

set_top ${module_name}_WIDTH${n-bits}

report_guidance > reports/guidance_${module_name}.rpt

save_session -replace ./my_run/pre_verify_${module_name}.fss 

match > reports/match_${module_name}.rpt

report_matched_points > reports/matched_points_${module_name}.rpt

verify > reports/verify_${module_name}.rpt

report_verify_points > reports/verify_points_${module_name}.rpt
report_analysis_results -summary > reports/analysis_summary_${module_name}.rpt

save_session -replace ./my_run/post_verify_${module_name}.fss 

exit 
