#TOP CPU n-bits

set module_name top
set n-bits 8
set library saed32

###################
## Import design ##
###################

set_host_options -max_cores 8
set_app_var search_path  "."
set TECH_FILE "libs/tech/saed32nm_1p9m.tf"
set REFERENCE_LIBRARY           [join "
        libs/CLIBs/saed32_hvt.ndm
        libs/CLIBs/saed32_lvt.ndm
        libs/CLIBs/saed32_rvt.ndm
        libs/CLIBs/saed32_sram_lp.ndm

"]

set TOP "top_WIDTH8"
set FILE_HDL "outputs/mapped_${module_name}${n-bits}bits_${library}.v"
set UPF_file "inputs/power.upf"
set SDC_file "outputs/mapped_${module_name}${n-bits}bits_${library}.sdc"
set Project_lib "mapped_${module_name}${n-bits}bits_${library}.db"

create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBRARY $Project_lib 

read_verilog -top $TOP $FILE_HDL
read_sdc $SDC_file

################
## Tech setup ##
################

set_technology -node 28

read_parasitic_tech -layermap libs/tech/saed32nm_tf_itf_tluplus.map -tlup libs/tech/saed32nm_1p9m_Cmax.lv.nxtgrd -name maxTLU
read_parasitic_tech -layermap libs/tech/saed32nm_tf_itf_tluplus.map -tlup libs/tech/saed32nm_1p9m_Cmin.lv.nxtgrd -name minTLU
report_lib -parasitic_tech [current_lib]

get_site_defs
set_attribute [get_site_defs unit] symmetry Y
set_attribute [get_site_defs unit] is_default true

set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical
get_attribute [get_layers M?] routing_direction

report_ignored_layers
set_ignored_layers -max_routing_layer M8
report_ignored_layers

set_dont_touch [get_lib_cells */TIE*] false
set_lib_cell_purpose -include optimization [get_lib_cells */TIE*]

##############
## Load UPF ##
##############

load_upf $UPF_file
commit_upf

##########
## MCCM ##
##########

remove_scenarios -all
remove_modes -all
remove_corners -all

## func_ss_0p96v_125c 

create_corner ss_125c
set_parasitic_parameters -early_spec maxTLU -late_spec maxTLU -library $Project_lib
set_process_number 0.99
set_process_label slow
set_voltage -object_list VDD 0.95
set_voltage -object_list VSS 0.0
set_temperature 125

create_mode func
create_scenario -mode func -corner ss_125c
set_scenario_status func::ss_125c -hold false ;#agregar ff y true para hold jejeje

create_clock -period 50 -name clk [get_ports clk]

## func_ff_0p96v_125c 

create_corner ff_125c
set_parasitic_parameters -early_spec minTLU -late_spec minTLU -library $Project_lib
set_process_number 0.99
set_process_label fast
set_voltage -object_list VDD 0.95
set_voltage -object_list VSS 0.0
set_temperature 125

#create_mode func
create_scenario -mode func -corner ff_125c
set_scenario_status func::ff_125c -hold true

#create_clock -period 50 -name clk [get_ports clk]

current_scenario func::ss_125c

###############
## Floorplan ##
###############
initialize_floorplan -shape Rect -side_ratio {1 1} -core_offset {20}
shape_blocks
create_placement -floorplan
set_block_pin_constraints -self -allowed_layers {M3 M4 M5 M6}
place_pins -self

legalize_placement

#create_boundary_cells -left_boundary_cell   \
             -right_boundary_cell $REFERENCE_LIBRARY 

########
## PG ##
########

remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect > /dev/null

connect_pg_net

#set_pg_via_master_rule pgvia_8x10 -via_array_dimension {8 10}

## top power ring

create_pg_ring_pattern ring_pattern -horizontal_layer M5 \
   -horizontal_width {5} -horizontal_spacing {2} \
   -vertical_layer M6 -vertical_width {5} -vertical_spacing {2}

set_pg_strategy core_ring \
   -pattern {{name: ring_pattern} \
   {nets: {VDD VSS}} {offset: {3 3}}} -core

compile_pg -strategies core_ring

## power stripes

create_pg_std_cell_conn_pattern rail_pattern -layers M1

set_pg_strategy M1_rails -core \
   -pattern {{name: rail_pattern}{nets: VDD VSS}}

compile_pg -strategies M1_rails

################
### Placement ##
################

report_app_options place.coarse.auto_density_control
set_app_options -name place.coarse.enhanced_auto_density_control -value true
set_app_options -name place.legalize.enable_advanced_legalizer -value true

place_opt

check_legality
check_mv_design

#########
## CTS ##
#########

## Pre-CTS setup

set CTS_LIB_CELL_PATTERN_LIST "*/NBUFF*LVT */NBUFF*RVT */INVX*_LVT */INVX*_RVT */CG*RVT */CG*HVT */AOBUFX*_LVT */AOINV* */*DFF*"
set CTS_CELLS [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]
set_dont_touch $CTS_CELLS false
suppress_message ATTR-12
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts $CTS_CELLS
unsuppress_message ATTR-12

## NDR for cloks

set CTS_NDR_MIN_ROUTING_LAYER	"M4"
set CTS_NDR_MAX_ROUTING_LAYER	"M5"
set CTS_LEAF_NDR_MIN_ROUTING_LAYER	"M1"
set CTS_LEAF_NDR_MAX_ROUTING_LAYER	"M5"
set CTS_NDR_RULE_NAME 		"cts_w2_s2_vlg"
set CTS_LEAF_NDR_RULE_NAME	"cts_w1_s2"

if {$CTS_NDR_RULE_NAME != ""} {
	remove_routing_rules $CTS_NDR_RULE_NAME > /dev/null

	create_routing_rule $CTS_NDR_RULE_NAME \
		-default_reference_rule \
		-widths { M1 0.1 M2 0.11 M3 0.11 M4 0.11 M5 0.11 } \
		-spacings { M2 0.16 M3 0.45 M4 0.45 M5 1.1 } \
		-taper_distance 0.4 \
		-driver_taper_distance 0.4 \
		-cuts { \
			{ VIA1 {V1LG 1} } \
			{ VIA2 {V2LG 1} } \
			{ VIA3 {V3LG 1} } \
			{ VIA4 {V4LG 1} } \
			{ VIA5 {V5LG 1} } \
		}

	set_clock_routing_rules -rules $CTS_NDR_RULE_NAME \
		-min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER \
		-max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER

}

if {$CTS_LEAF_NDR_RULE_NAME != ""} {
	remove_routing_rules $CTS_LEAF_NDR_RULE_NAME > /dev/null

	create_routing_rule $CTS_LEAF_NDR_RULE_NAME \
		-default_reference_rule \
		-spacings { M2 0.16 M3 0.45 M4 0.45 M5 1.1 }

	set_clock_routing_rules -net_type sink -rules $CTS_LEAF_NDR_RULE_NAME \
		-min_routing_layer $CTS_LEAF_NDR_MIN_ROUTING_LAYER \
		-max_routing_layer $CTS_LEAF_NDR_MAX_ROUTING_LAYER
}

set_lib_cell_purpose -include cts {*/AND2X2_HVT}
set_lib_cell_purpose -include cts {*/AND2X1_HVT}
set_lib_cell_purpose -include cts {*/AND2X4_HVT}
set_lib_cell_purpose -include cts {*/AO22X1_HVT}
set_lib_cell_purpose -include cts {*/AO22X2_HVT}
set_lib_cell_purpose -include cts {*/AOI22X1_HVT}
set_lib_cell_purpose -include cts {*/AOI22X2_HVT}
set_lib_cell_purpose -include cts {*/CGLNPRX2_HVT}
set_lib_cell_purpose -include cts {*/CGLNPRX8_HVT}
set_lib_cell_purpose -include cts {*/CGLPPRX2_HVT}
set_lib_cell_purpose -include cts {*/CGLPPRX8_HVT}
set_lib_cell_purpose -include cts {*/MUX21X1_HVT}
set_lib_cell_purpose -include cts {*/MUX21X2_HVT}
set_lib_cell_purpose -include cts {*/AND2X2_RVT}
set_lib_cell_purpose -include cts {*/AND2X1_RVT}
set_lib_cell_purpose -include cts {*/AND2X4_RVT}
set_lib_cell_purpose -include cts {*/AO22X1_RVT}
set_lib_cell_purpose -include cts {*/AO22X2_RVT}
set_lib_cell_purpose -include cts {*/AOI22X1_RVT}
set_lib_cell_purpose -include cts {*/AOI22X2_RVT}
set_lib_cell_purpose -include cts {*/CGLNPRX2_RVT}
set_lib_cell_purpose -include cts {*/CGLNPRX8_RVT}
set_lib_cell_purpose -include cts {*/CGLPPRX2_RVT}
set_lib_cell_purpose -include cts {*/CGLPPRX8_RVT}
set_lib_cell_purpose -include cts {*/MUX21X1_RVT}
set_lib_cell_purpose -include cts {*/MUX21X2_RVT}
set_lib_cell_purpose -include cts {*/AND2X2_LVT}
set_lib_cell_purpose -include cts {*/AND2X1_LVT}
set_lib_cell_purpose -include cts {*/AND2X4_LVT}
set_lib_cell_purpose -include cts {*/AO22X1_LVT}
set_lib_cell_purpose -include cts {*/AO22X2_LVT}
set_lib_cell_purpose -include cts {*/AOI22X1_LVT}
set_lib_cell_purpose -include cts {*/AOI22X2_LVT}
set_lib_cell_purpose -include cts {*/CGLNPRX2_LVT}
set_lib_cell_purpose -include cts {*/CGLNPRX8_LVT}
set_lib_cell_purpose -include cts {*/CGLPPRX2_LVT}
set_lib_cell_purpose -include cts {*/CGLPPRX8_LVT}
set_lib_cell_purpose -include cts {*/MUX21X1_LVT}
set_lib_cell_purpose -include cts {*/MUX21X2_LVT}
set_lib_cell_purpose -include cts {*/LSUPX1_HVT}
set_lib_cell_purpose -include cts {*/LSUPX2_HVT}
set_lib_cell_purpose -include cts {*/LSUPX4_HVT}
set_lib_cell_purpose -include cts {*/LSUPX8_HVT}
set_lib_cell_purpose -include cts {*/LSUPX1_RVT}
set_lib_cell_purpose -include cts {*/LSUPX2_RVT}
set_lib_cell_purpose -include cts {*/LSUPX4_RVT}
set_lib_cell_purpose -include cts {*/LSUPX8_RVT}
set_lib_cell_purpose -include cts {*/LSUPX1_LVT}
set_lib_cell_purpose -include cts {*/LSUPX2_LVT}
set_lib_cell_purpose -include cts {*/LSUPX4_LVT}
set_lib_cell_purpose -include cts {*/LSUPX8_LVT}

## CTS 

foreach_in_collection scen [all_scenarios] {
	current_scenario $scen
	set_clock_uncertainty 0.1 -setup [all_clocks]
	set_clock_uncertainty 0.05 -hold [all_clocks]
}

set_app_options -list {time.remove_clock_reconvergence_pessimism true}

set_lib_cell_purpose -exclude hold [get_lib_cells] 
set_lib_cell_purpose -include hold [get_lib_cells "*/DELLN*_HVT */NBUFFX2_HVT */NBUFFX4_HVT */NBUFFX8_HVT"]
set_lib_cell_purpose -include hold [get_lib_cells "*/DELLN*_RVT */NBUFFX2_RVT */NBUFFX4_RVT */NBUFFX8_RVT"]

set_app_options -list {opt.dft.clock_aware_scan true}
set_app_options -list {clock_opt.hold.effort high}

set_clock_tree_options -target_skew 0.05 -corners [get_corners ss*]
set_clock_tree_options -target_skew 0.02 -corners [get_corners ff*]

report_clock_routing_rules

clock_opt

#############
## Routing ##
#############

check_design -checks pre_route_stage

set_app_options -name route.global.timing_driven    -value true
set_app_options -name route.global.crosstalk_driven -value false
set_app_options -name route.track.timing_driven     -value true
set_app_options -name route.track.crosstalk_driven  -value true
set_app_options -name route.detail.timing_driven    -value true
set_app_options -name route.detail.force_max_number_iterations -value false

set_app_options -name route.common.number_of_secondary_pg_pin_connections -value 2
set_app_options -name route.common.separate_tie_off_from_secondary_pg     -value true

if {[get_routing_rules -quiet VDDwide] != ""} {remove_routing_rules VDDwide }
create_routing_rule VDDwide -widths {M1 0.1 M2 0.1 M3 0.1} -taper_distance 0.2
set_routing_rule -rule VDDwide -min_routing_layer M2 -min_layer_mode allow_pin_connection -max_routing_layer M3 [get_nets VDD]

route_group -nets {VDD}

route_auto

check_routes

## For week 6 (Signoff)
#set_starrc_in_design -config ./scripts/starrc_config.txt

set_app_options -name time.si_enable_analysis -value true
set_app_options -name time.enable_ccs_rcv_cap -value true

#First route optimization

route_opt

report_qor

#Second route optimization

set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false
set_app_options -name route_opt.flow.enable_ccd -value false

route_opt
report_qor
