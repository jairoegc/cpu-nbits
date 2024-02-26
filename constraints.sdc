# Power

set_voltage -object_list VDD 0.95 1.16
set_voltage -object_list VSS 0.0

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
