########################################################################################
##   Last updated: Jul., 05, 2019
##   Copyright (c) [2010-2019] Dorado Design Automation, Inc.
########################################################################################
# Start of the template

# pba/ssta mode
#set slk_path_base_analysis true
#set slk_ssta_mode true

set script_path ./script
set rpt_path    ../../report_db
set twf_path    ../../report_db

source $script_path/libin_wc.tcl
source $script_path/libin_bc.tcl
source $script_path/lefin.tcl
source $script_path/read_verilog.tcl
source $script_path/defin.tcl
source $script_path/power_domain.tcl
source $script_path/general_setting.tcl
source $script_path/read_sdf.tcl
source $script_path/read_spef.tcl

set LIB  {ss ff}
set PARA {cworst cbest}
set MODE {norm}

foreach lib $LIB {
    foreach para $PARA {
        foreach mode $MODE {
            begin_corner ${lib}_${para}_${mode}
                set_group -lib -name $lib
                set_group -spef -name $para
                set_group -sdf -name ${para}_${lib}
                twfin -analysis_type on_chip_variation "${twf_path}/${para}_${lib}/top.twf.gz"
                slackin -mode $mode -analysis_type on_chip_variation "${rpt_path}/${para}_${lib}/hold_to_tweaker.rpt"
            end_corner ${lib}_${para}_${mode}
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
slkdc -check_slack_consistency

### if pba mode is used, sync path slack back to twf
# slkdb -update_twf_by_path -hold 0.02

##### check clock as data #####
check_clock_as_data -auto
set slk_fix_watch_clock_as_data true

##### avoid space fragmentation (specify a cell name) #####
set avoid_space_fragmentation_by_cell { DDLAY1S1 }

##################################################################################
## Fix Hold
##################################################################################

# apply drv factor
set_drv_factor 0.8

slkfix -design_list { top dsub }
slkreport -summary -high_resolution -slack_range ./ecoout/pre_slk.rpt

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

# Extract setup margin by vtswap
source $script_path/fix_hold_setting.vtswap.tcl
set slk_cell_mapping_rule_regexp { @ @HVT }
set slk_fix_hold_by_extract_setup_margin true
set slk_extract_setup_margin_trans 0.1
set slk_setup_target_slk 0.05
slkfix -hold -all

# Extract setup margin by size up
#source $script_path/fix_hold_setting.sz.tcl
#set slk_cell_mapping_rule_regexp {@D[0-9]+@ @D[0-9]+@ : @M[0-9]+@ @M[0-9]+@}
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
ecotclout -pt                                       ./ecoout/eco.tcl
verilogout                                          ./ecoout/
defout -folder                                      ./ecoout/
spefout                                             ./ecoout/eco