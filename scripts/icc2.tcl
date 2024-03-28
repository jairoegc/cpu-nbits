#TOP CPU n-bits

set module_name top
set n-bits 8
set library cgrt

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

#create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBRARY $Project_lib 
open_lib -write $Project_lib
read_verilog -top $TOP $FILE_HDL
read_sdc $SDC_file
read_def outputs/dft_${module_name}${n-bits}bits_${library}.scandef

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

create_clock -period 100 -name clk [get_ports clk]

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

#create_clock -period 100 -name [get_ports clk]

current_scenario func::ss_125c 

###############
## Floorplan ##
###############
initialize_floorplan -shape Rect -side_ratio {1 1} -core_offset {20}
shape_blocks
create_placement -floorplan


create_pin_constraint -type individual -layers {M3 M4 M5 M6} -sides {1} -offset {25 312} -pin_spacing_distance {15} -ports {din_1* din_2*}
create_pin_constraint -type individual -layers {M3 M4 M5 M6} -sides {2} -offset {25 250} -pin_spacing_distance {15} -ports {cmdin* test* rst}
create_pin_constraint -type individual -layers {M3 M4 M5 M6} -sides {3} -offset {25 312} -pin_spacing_distance {15} -ports {dout* error zero}
create_pin_constraint -type individual -layers {M3 M4 M5 M6} -sides {4} -offset {190 312} -pin_spacing_distance {15} -ports {din_3*}
create_pin_constraint -type individual -layers {M3 M4 M5 M6} -sides {4} -offset {160 180} -pin_spacing_distance {15} -ports {clk}

place_pins -self

legalize_placement


save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/floorplant.design

write_floorplan -net_types {power ground} \
  -include_physical_status {fixed locked} \
  -read_def_options {-add_def_only_objects all -no_incremental} \
  -force -output ${module_name}${n-bits}bits_${library}.fp/

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

#################
# PG Power Ring #
#################

# ## top power ring

# create_pg_ring_pattern ring_pattern -horizontal_layer M5 \
#    -horizontal_width {5} -horizontal_spacing {2} \
#    -vertical_layer M6 -vertical_width {5} -vertical_spacing {2}

# set_pg_strategy core_ring \
#    -pattern {{name: ring_pattern} \
#    {nets: {VDD VSS}} {offset: {3 3}}} -core

# compile_pg -strategies core_ring

# ## power stripes

# create_pg_std_cell_conn_pattern rail_pattern -layers M1

# set_pg_strategy M1_rails -core \
#    -pattern {{name: rail_pattern}{nets: VDD VSS}}

# compile_pg -strategies M1_rails

# ###########
# PG Mesh #
###########

set_pg_via_master_rule pgvia_8x10 -via_array_dimension {8 10}

# set all_macros [get_cells -hierarchical -filter "is_hard_macro && !is_physical_only"]
# set hm(risc_core) [get_cells -filter "is_hard_macro==true" -physical_context *REG_FILE_*_RAM*]
# set hm(top) [remove_from_collection $all_macros $hm(risc_core)]


# create_keepout_margin -outer {3 3 3 3}  $all_macros


################################################################################
# Build the main power mesh.  Consists of:
# * a coarse mesh on m7/m8
# * a finer mesh on M2 - vertical only - to connect to the std cell rails
#

# width m7/m8: pitch=1.216, min_spacing=0.056, min_width=0.056; m7: 2*1.216 - 4*0.056
create_pg_mesh_pattern P_top_two \
	-layers { \
		{ {horizontal_layer: M7} {width: 1.104} {spacing: interleaving} {pitch: 13.376} {offset: 0.856} {trim : true} } \
		{ {vertical_layer: M8}   {width: 4.64 } {spacing: interleaving} {pitch: 19.456} {offset: 6.08}  {trim : true} } \
		} \
	-via_rule { {intersection: adjacent} {via_master : pgvia_8x10} }

# m2 pitch=0.152; 0.152*48=7.296
create_pg_mesh_pattern P_m2_triple \
	-layers { \
		{ {vertical_layer: M2}  {track_alignment : track} {width: 0.44 0.192 0.192} {spacing: 2.724 3.456} {pitch: 9.728} {offset: 1.216} {trim : true} } \
		}


##==> top mesh - M7/M8
set_pg_strategy S_default_vddvss \
	-core \
	-pattern   { {name: P_top_two} {nets:{VSS VDD}} {offset_start: {20 20}} } \
	-extension { {{stop:design_boundary_and_generate_pin}} }

# set_pg_strategy S_va_vddh \
# 	-voltage_areas PD_RISC_CORE \
# 	-pattern   { {name: P_top_two} {nets: {- VDDH}} {offset_start: {20 20}} } \
# 	-extension { {{direction:TR} {stop:design_boundary_and_generate_pin}} }


##==> low mesh - M2
set_pg_strategy S_m2_vddvss \
	-core \
	-pattern   { {name: P_m2_triple} {nets: {VDD VSS VSS}} {offset_start: {20 0}} } \
	-extension { {{direction:BT} {stop:design_boundary_and_generate_pin}} }

# set_pg_strategy S_m2_vddh \
# 	-voltage_areas PD_RISC_CORE \
# 	-pattern   { {name: P_m2_triple} {nets: {VDDH - -}} {offset_start: {20 0}} } \
# 	-blockage  { {macros_with_keepout: $hm(risc_core)} } \
# 	-extension { {{direction:T} {stop:design_boundary_and_generate_pin}} }

set_pg_strategy_via_rule S_via_m2_m7 \
	-via_rule { \
		{  {{strategies: {S_m2_vddvss}}      {layers: { M2 }} {nets: { VDD }} } \
		   {{strategies: {S_default_vddvss}} {layers: { M7 }} }  \
			{via_master: {default}} } \
		{  {{strategies: {S_m2_vddvss}}      {layers: { M2 }} {nets: { VSS }} } \
		   {{strategies: {S_default_vddvss}} {layers: { M7 }} } \
			{via_master: {default}} } \
	}

# You can use the -ignore_drc switch to speed things up a little. Not an issue in this lab though!
#compile_pg -strategies {S_va_vddh S_m2_vddh}
compile_pg -strategies {S_default_vddvss S_m2_vddvss} -via_rule {S_via_m2_m7}

################################################################################
# Build the standard cell rails

create_pg_std_cell_conn_pattern P_std_cell_rail

set_pg_strategy S_std_cell_rail_VSS_VDD \
	-core \
	-pattern {{pattern: P_std_cell_rail}{nets: {VSS VDD}}}
	#-extension {{stop: outermost_ring}{direction: L B R T }}

set_pg_strategy_via_rule S_via_stdcellrail \
        -via_rule {{intersection: adjacent}{via_master: default}}

compile_pg -strategies S_std_cell_rail_VSS_VDD -via_rule {S_via_stdcellrail}

check_pg_missing_vias
check_pg_drc -ignore_std_cells
check_pg_connectivity -check_std_cell_pins none

create_pg_special_pattern pt1 -insert_channel_straps { \
      {layer: M1} {direction: vertical} {width: 0.2}
      {channel_between_objects: macro} {channel_threshold: 5} }

set_pg_strategy st1 \
  -core \
  -pattern {{name: pt1} {nets: VDD VSS}}


compile_pg -strategies st1 -tag channel_straps

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/PG.design

#return

################
### Placement ##
################

report_app_options place.coarse.auto_density_control
set_app_options -name place.coarse.enhanced_auto_density_control -value true
set_app_options -name place.legalize.enable_advanced_legalizer -value true

set_qor_strategy -stage pnr -mode extreme_power -metric total_power

place_opt

check_legality
check_mv_design

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/placement.design

#return 

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
		-spacing_length_thresholds { M2 3.0 M3 3.0 M4 3.0 M5 3.0 } \
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
		-spacings { M2 0.16 M3 0.45 M4 0.45 M5 1.1 } \
		-spacing_length_thresholds { M2 3.0 M3 3.0 M4 3.0 M5 3.0 }



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
set_app_options -list {opt.common.hold_effort high}
#set_app_options -list {clock_opt.hold.effort high}

set_clock_tree_options -target_skew 0.05 -corners [get_corners ss*]
set_clock_tree_options -target_skew 0.02 -corners [get_corners ff*]

report_clock_routing_rules

clock_opt

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/cts.design


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

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/route_auto.design

## For week 6 (Signoff)
#set_starrc_in_design -config ./scripts/starrc_config.txt

set_app_options -name time.si_enable_analysis -value true
set_app_options -name time.enable_ccs_rcv_cap -value true

#First route optimization

route_opt

report_qor

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/route_opt1.design


#Second route optimization

set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false
set_app_options -name route_opt.flow.enable_ccd -value false

route_opt
report_qor

save_block -as mapped_${module_name}${n-bits}bits_${library}.db:top_WIDTH8/route_opt2.design

write_gds top8bits_cgrt.gdsii
write_sdc -output outputs/final.sdc
write_name_map outputs/design_map.map
write_def -design [current_design] design.def
write_lef -design [current_design] outputs/tech.lef -include tech
write_parasitics -output outputs/parasitics_icc2