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
 lefin "../../library_db/lef/std_uhvt.lef"
 lefin "../../library_db/lef/std_ehvt.lef"

#source $script_path/read_verilog.tcl
 verilogin "../../design_db/netlist/case5.dm.v"
 verilogin "../../design_db/netlist/top.eco1.v"
 set_verilog_top_cell top

#source $script_path/defin.tcl
 #Ignore physical cells
 set def_physical_cells_to_be_ignored { *FILLER* *DCAP* }

 defin -route "../../design_db/def/case5.dm.def"
 defin -place "../../design_db/def/top.def"

 # if under 40nm, please turn true enable_no_fill1_spacing_rule
 set enable_no_fill1_spacing_rule false

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

slkdc -check_slack_consistency