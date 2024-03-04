########################################################################################
##   Last updated: Jul., 05, 2019
##   Copyright (c) [2010-2019] Dorado Design Automation, Inc.
########################################################################################
# Start of the template

set script_path ./script
set rpt_path    ../../report_db
set twf_path    ../../report_db

#source $script_path/libin_wc.tcl
 libin -timing_type best worst -name ss "../../library_db/lib/std_ss.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/MACRO_SDRAM25_512x8_ss.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/MACRO_SRAM512X8X16_D209MA.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/MACRO_TOP.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/pad_analog_ss.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/pad_gen_ss.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/pad_iopad.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/pad_net.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/std_ss_hvt.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/std_ss_uhvt.lib"
 libin -timing_type best worst -name ss "../../library_db/lib/std_ss_ehvt.lib"

#source $script_path/libin_bc.tcl
 libin -timing_type best worst -name ff "../../library_db/lib/std_ff.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/MACRO_SDRAM25_512x8_ff.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/MACRO_SRAM512X8X16_D209MA.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/MACRO_TOP.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/pad_analog_ff.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/pad_gen_ff.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/pad_iopad.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/pad_net.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/std_ff_hvt.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/std_ff_uhvt.lib"
 libin -timing_type best worst -name ff "../../library_db/lib/std_ff_ehvt.lib"

#source $script_path/lefin.tcl
 lefin -tech "../../library_db/lef/std.lef"
 lefin "../../library_db/lef/MACRO_SDRAM25_512x8.lef"
 lefin "../../library_db/lef/macro_sram512X8X16_d209ma.lef"
 lefin "../../library_db/lef/MACRO_TOP.lef"
 lefin "../../library_db/lef/pad_analog.lef"
 lefin "../../library_db/lef/pad_gen.lef"
 lefin "../../library_db/lef/pad_iopad.lef"
 lefin "../../library_db/lef/pad_net.lef"
 lefin "../../library_db/lef/std_hvt.lef"
 lefin "../../library_db/lef/std_ehvt.lef"
 lefin "../../library_db/lef/std_uhvt.lef"


#source $script_path/read_verilog.tcl
 verilogin "../../design_db/netlist/case5.dm.v"
 verilogin "../../design_db/netlist/top.eco1.v"
 set_verilog_top_cell top

#source $script_path/defin.tcl
 #Ignore physical cells
 set def_physical_cells_to_be_ignored { *FILLER* *DCAP* }
 defin -route "../../design_db/def/case5.dm.def"
 defin -place "../../design_db/def/top.def"

#source $script_path/power_domain.tcl
 set current_design top
 create_voltage_area -name off -instance U_dsub -coordinate   809.342  1296.804  1925  2110
 create_voltage_area -name on -default

source $script_path/general_setting.tcl

#source $script_path/read_sdf.tcl
 sdfin -name cbest_ff  "../../report_db/cbest_ff/top.sdf.gz"
 sdfin -name cworst_ff "../../report_db/cworst_ff/top.sdf.gz"
 sdfin -name cbest_ss  "../../report_db/cbest_ss/top.sdf.gz"
 sdfin -name cworst_ss "../../report_db/cworst_ss/top.sdf.gz"

#source $script_path/read_spef.tcl
 spefin -design top -name cbest "../../design_db/spf/top_dsub_cbest.spf.gz"
 spefin -design top -name cworst "../../design_db/spf/top_dsub_cworst.spf.gz"


set LIB  {ss ff}
set PARA {cworst cbest}
set MODE {norm}

foreach lib $LIB {
    foreach para $PARA {
        foreach mode $MODE {
            if { [file exists ${twf_path}/${para}_${lib}/top.twf.gz] } {
                begin_corner ${lib}_${para}_${mode}
                    set_group -lib -name $lib
                    set_group -spef -name $para
                    set_group -sdf -name ${para}_${lib}

                    twfin -analysis_type on_chip_variation "${twf_path}/${para}_${lib}/top.twf.gz"

                    if { [file exists ${rpt_path}/${para}_${lib}/setup_to_tweaker.rpt] } {
                    slackin -mode $mode -analysis_type on_chip_variation "${rpt_path}/${para}_${lib}/setup_to_tweaker.rpt"
                    }
                    if { [file exists ${rpt_path}/${para}_${lib}/hold_to_tweaker.rpt] } {
                    slackin -mode $mode -analysis_type on_chip_variation "${rpt_path}/${para}_${lib}/hold_to_tweaker.rpt"
                    }
                    if { [file exists ${rpt_path}/${para}_${lib}/report_constraint.rpt] } {
                    slackin -type sdf_max "${rpt_path}/${para}_${lib}/report_constraint.rpt"
                    }
                end_corner ${lib}_${para}_${mode}
            }
        }
    }
}

#################################################
## Build unit rc table (if no rctablein)
#################################################
build_unit_rc_table -slack_domain

#########################################################################################################
# IMPORTANT NOTICE!!                                                                                    #
# "slkdc -check_slack_consistency" calculates delay and slack values, then compares the slack values    #
# against slack report.                                                                                 #
# It's strongly recommended to get "Pass slack consistency check" before doing any timing fix jobs.     #
#########################################################################################################
slkfix -create_twf_setup_domain
slkdc -check_slack_consistency

### if pba mode is used, sync path slack back to twf
# slkdb -update_twf_by_path -hold 0.02

##### check clock as data #####
check_clock_as_data -auto
set slk_fix_watch_clock_as_data true

##### avoid space fragmentation (specify a cell name) #####
set avoid_space_fragmentation_by_cell { DDLAY1S1 }

slkfix -design_list { top dsub }
slkreport -summary -high_resolution -slack_range ./ecoout/pre_slk.rpt

#return

##################################################################################
## Fix max transition, Please modify design_list which block/top want to fix
##################################################################################

# 1st run Fix Max. Transition Setting with vt swap
source $script_path/fix_max_transition_setting.vtswap.tcl
set slk_cell_mapping_rule_regexp { @HVT @ }
slkfix -max_trans -all

# 2nd run Fix Max. Transition Setting
source $script_path/fix_max_transition_setting.sz.tcl
set slk_cell_mapping_rule_regexp { @S[0-9]+@ @S[0-9]+@ : @S[0-9]+ @S[0-9]+ }
slkfix -max_trans -all

# 3rd run Fix Max. Transition Setting
source $script_path/fix_max_transition_setting.hfs.tcl
set slk_repeater_insertion_buff_list { DBFS4 DBFS8 DBFS12 DBFS16 }
slkfix -max_trans -all

## # 3.1 run Fix Max. Transition Setting
## source $script_path/fix_max_transition_setting.hfs.byspare.tcl
## set slk_repeater_insertion_buff_list { DBFS4 DBFS8 DBFS12 DBFS16 }
## slkfix -max_trans -all
## eco -clear_spare

##################################################################################
## Fix Setup
##################################################################################
# Apply drv factor
set_drv_factor 0.8

# If user wants to reduce WNS as first priority, please set below variable "true"
set slk_fix_setup_minimize_worst_slack true
set slk_twf_cost_v2 true

# 1st run Fix Setup Setting by vt swapping ( if allowed )
source $script_path/fix_setup_setting.vtswap.tcl
set slk_cell_mapping_rule_regexp { @HVT @ }
slkfix -setup -all

# 2nd run Fix Setup Setting -- sizing (max_shift_distance 0)
source $script_path/fix_setup_setting.1.tcl
set slk_cell_mapping_rule_regexp { @S[0-9]+@ @S[0-9]+@ : @S[0-9]+ @S[0-9]+ }
slkfix -setup -all

# 3rd run Fix Setup Setting -- sizing (max_shift_distance 7)
source $script_path/fix_setup_setting.2.tcl
slkfix -setup -all

# 4th run Fix Setup Setting -- sizing (max_shift_distance 15)
source $script_path/fix_setup_setting.3.tcl
slkfix -setup -all

# 5th run Fix Setup Setting -- bypass buffer
source $script_path/fix_setup_setting.bypass.tcl
slkfix -setup -all
set slk_rce_long_wire_unit_r_derate 1.1

# 6th run Fix Setup Setting -- split load
source $script_path/fix_setup_setting.split.tcl
set slk_repeater_insertion_buff_list { DBFS4 DBFS8 DBFS12 }
slkfix -setup -all

### # 7th run Fix Setup Setting -- pin swap
### source $script_path/fix_setup_setting.pinswap.tcl
### slkfix -setup -all
### set slk_fix_setup_by_pinswap false

### # 8th run Fix Setup Setting -- split load by free space from spare cell
### source $script_path/fix_setup_setting.split.byspare.tcl
### set slk_repeater_insertion_buff_list { BUFFD4 BUFFD6 BUFFD8 BUFFD12 }
### slkfix -setup -all
### eco -clear_spare

##################################################################################
## Fix Hold
##################################################################################

# apply drv factor
set_drv_factor 0.8

# 1st run Fix Hold Setting -- swapping (if allowed)
source $script_path/fix_hold_setting.vtswap.tcl
set slk_cell_mapping_rule_regexp { @ @HVT }
slkfix -hold -all

# 2nd run Fix Hold Setting -- sizing
source $script_path/fix_hold_setting.sz.tcl
set slk_cell_mapping_rule_regexp { @S[0-9]+ @S[0-9]+ : @S[0-9]+@ @S[0-9]+@ }
slkfix -hold -all

# 3rd run Fix Hold Setting -- dummy load hook-ups
source $script_path/fix_hold_setting.dmy.tcl
set slk_dummy_load_cell_list { DIVS1 }
slkfix -hold -all

# 4-1 run Fix Hold Setting -- insert buffers and delay cells
source $script_path/fix_hold_setting.bi.1.tcl
set slk_delay_insertion_buff_list { DDLAY1S1 DBFS2 DBFS3 DBFS8 }
slkfix -hold -all

# 4-2 run Fix Hold Setting -- insert buffers and delay cells
source $script_path/fix_hold_setting.bi.2.tcl
set slk_delay_insertion_buff_list { DDLAY1S1 DBFS2 DBFS3 DBFS8 }
slkfix -hold -all

# 4-3 run Fix Hold Setting -- insert buffers and delay cells
source $script_path/fix_hold_setting.bi.3.tcl
set slk_delay_insertion_buff_list { DDLAY1S1 DBFS2 DBFS3 DBFS8 }
slkfix -hold -all

source $script_path/fix_hold_setting.vtswap.tcl
set slk_cell_mapping_rule_regexp { @ @HVT }
set slk_fix_hold_by_extract_setup_margin true
set slk_extract_setup_margin_trans 0.1
set slk_setup_target_slk 0.05
slkfix -hold -all

# Extract setup margin by size up
#source $script_path/fix_hold_setting.sz.tcl
#set slk_cell_mapping_rule_regexp { @D[0-9]+@ @D[0-9]+@ : @M[0-9]+@ @M[0-9]+@ }
#set slk_fix_hold_by_extract_setup_margin true
#set slk_extract_setup_margin_trans 0.1
#set slk_setup_target_slk 0.05
#slkfix -hold -all

set slk_fix_hold_by_extract_setup_margin false

# 4-4 run Fix Hold Setting -- insert buffers and delay cells
source $script_path/fix_hold_setting.bi.4.tcl
set slk_delay_insertion_buff_list { DDLAY1S1 DBFS2 DBFS3 DBFS8 }
slkfix -hold -all

### # 4-5 run Fix Hold Setting -- insert buffers and delay cells by free space from spare cell
### source $script_path/fix_hold_setting.bi.spare.tcl
### set slk_delay_insertion_buff_list { DELHVT05 BUFFHVTD2 BUFFHVTD3 BUFFHVTD8 }
### slkfix -hold -all
### eco -clear_spare

##################################################################################
## Dump Output
## 1. verilogout -file "filename" dumps whole chip netlist
##    verilogout "folder_name" dumps all .v's into the specified folder. ( normally for hierarchical case )
## 2. defout dumps a partial def where only the new or moved instances will be dumped.
##    The def pulls all hold buffers to legal space.
##    It is suggested to feed this partial def to the P&R tool before eco route.
## 3. sdfout dumps partial sdf's for each scenario.
## 4. Do Pre-ECO STA before handing off the result for real P&R ECO:
##               Pre-ECO STA ==> do STA with (top_eco.v + main sdf + top_eco.sdf)
##################################################################################
slkreport -summary -high_resolution -slack_range    ./ecoout/post_slk.rpt
slkreport -autofix                                  ./ecoout/autofix_slk.rpt
slkreport -power -file                              ./ecoout/power.rpt
ecotclout -pt                                       ./ecoout/eco_pt.tcl
ecotclout -icc                                      ./ecoout/eco_icc.tcl
verilogout                                          ./ecoout/
defout -folder                                      ./ecoout/
spefout                                             ./ecoout/eco