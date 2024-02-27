## Function : -normal : Generating GBA TWF (TIME WINDOW FILE)
##            -pba    : Generating GBA TWF and PBA TWF with endpoints which contain of output ports and ../ff/d pins only
##                      (not including ../te, ../ti, ../se, etc.)
##
## Usage :
##        pt_shell> source twfout.tcl
##        pt_shell> twfout <-normal/-pba> ["filename.twf"] [pba_setup_threshold pba_hold_threshold] ["pba_clock_list"]
##
## Notes :
##        1. source the script at end of timing analysis.
##        2. if no option is given, "twfout" will dump all pins at normal mode to PrimeTime working directory
##           with the default file name.
##
## Example :
##        pt_shell> twfout -normal "../report/top.twf"
##        or
##        pt_shell> twfout -pba "../report/top.twf" 0.4 0.05 "clock_a clock_b clock_c"
##        or
##        pt_shell> twfout -pba
##        or
##        pt_shell> twfout
##
## Copyright (c) [2007-2018] Dorado Design Automation, Inc.
#############################################################################################

set timing_save_pin_arrival_and_slack true
set design [get_attribute [current_design] full_name]
set twf_fp "twf"

set unit [get_attribute [get_designs ] time_unit_in_second]
set P_STATUS 1
set DUMP_CLOCK_GROUP 0 
set DUMP_SDC_COMP 0 
set DUMP_PT_SOURCE_GENERATED_CLK 0
set DUMP_EXTRA_TIMING_CHECK 0
set VER "0704.2019"

### Main Procedure ###
proc twfout { {operation "-normal"} {twf_file "twf"} {pba_setup_threshold "0.500"} {pba_hold_threshold "0.005"} {input_clk_list "*"} {pba_setup_path_ratio "0.1"} {pba_hold_path_ratio "0.1"} } {
  puts "Begin: DORADO_PT_TWF"
  set START [date]
  puts $START


  global sh_enable_stdout_redirect
  set save_var_1 $sh_enable_stdout_redirect 
  set sh_enable_stdout_redirect true
  global DUMP_PT_SOURCE_GENERATED_CLK
  global DUMP_CLOCK_GROUP
  global DUMP_SDC_COMP
  global design
  global twf_fp

  set ::runtime_P_TWF_CLK_COMP 0
  set ::runtime_P_TWF_SLACK_COMP 0
  set ::runtime_P_TWF_SDC 0
  set ::runtime_P_TWF_DESIGN_INFO 0
  set ::runtime_P_TWF_CLOCK_GROUP 0
  set ::runtime_P_TWF_PT_CLOCK 0
  set ::runtime_P_TWF_PT_GENERATED_CLOCK 0
  set ::runtime_P_TWF_PT_EXTRA_TIMING_CHECK 0
  set ::runtime_P_TWF_ENDPOINT_PBA_COMP_3 0
  set ::runtime_P_TWF_ENDPOINT_PBA_COMP_2 0
  set ::runtime_P_TWF_EPILOGUE 0 

  global runtime_P_TWF_CLK_COMP
  global runtime_P_TWF_SLACK_COMP
  global runtime_P_TWF_SDC
  global runtime_P_TWF_DESIGN_INFO 
  global runtime_P_TWF_CLOCK_GROUP 
  global runtime_P_TWF_PT_CLOCK 
  global runtime_P_TWF_PT_GENERATED_CLOCK 
  global runtime_P_TWF_PT_EXTRA_TIMING_CHECK 
  global runtime_P_TWF_ENDPOINT_PBA_COMP_3 
  global runtime_P_TWF_ENDPOINT_PBA_COMP_2 
  global runtime_P_TWF_EPILOGUE 

  suppress_message CMD-041                                                
  suppress_message ATTR-3                                                
  suppress_message ATTR-1                                                
  suppress_message UITE-416
  suppress_message UITE-464
  suppress_message UITE-465
  suppress_message UITE-487
  suppress_message UITE-502
  suppress_message UITE-503
  suppress_message UITE-479
  suppress_message RC-009
  suppress_message RC-011
  suppress_message RC-004
  suppress_message RC-005
  suppress_message RC-203
  suppress_message XTALK-001
  suppress_message XTALK-105
  suppress_message XTALK-303
  suppress_message PTE-003
  suppress_message PTE-060
  if { $twf_file == "twf" } { 
        set twf_file "$design.twf.gz"
  } else {
        if { ![string match "*.gz" $twf_file] } { set twf_file "${twf_file}.gz"}
  }

  set twf_fp $twf_file

  if { $DUMP_SDC_COMP } { write_sdc -version 1.8 ${twf_file}.tmp.sdc }

  if { $operation == "-normal" } {
      redirect -compress -file ${twf_file} {
          P_TWF_HEADER
	  P_TWF_SDC $DUMP_SDC_COMP
          P_TWF_CLK_COMP
          P_TWF_SLACK_COMP
          puts "1"
          P_TWF_PT_EXTRA_TIMING_CHECK
          P_TWF_DESIGN_INFO $DUMP_CLOCK_GROUP 
          P_TWF_PT_CLOCK $DUMP_PT_SOURCE_GENERATED_CLK
          P_TWF_PT_GENERATED_CLOCK $DUMP_PT_SOURCE_GENERATED_CLK
          P_TWF_EPILOGUE
      }

  } elseif { ($operation == "-pba") } {
      redirect -compress -file ${twf_file} {
          P_TWF_HEADER
	  P_TWF_SDC $DUMP_SDC_COMP
          P_TWF_CLK_COMP
          P_TWF_SLACK_COMP
          puts "1"
          P_TWF_PT_EXTRA_TIMING_CHECK
        # P_TWF_ENDPOINT_PBA_COMP_2 $operation $pba_setup_threshold $pba_hold_threshold $input_clk_list
	  P_TWF_ENDPOINT_PBA_COMP_3 $operation $pba_setup_path_ratio $pba_hold_path_ratio
          P_TWF_DESIGN_INFO $DUMP_CLOCK_GROUP 
          P_TWF_PT_CLOCK $DUMP_PT_SOURCE_GENERATED_CLK 
          P_TWF_PT_GENERATED_CLOCK $DUMP_PT_SOURCE_GENERATED_CLK
          P_TWF_EPILOGUE
      }

  } else {

      puts "Error : twfout operation type is specified incorrectly and abort !!"

  }
   
  set sh_enable_stdout_redirect $save_var_1 

puts "Runtime for CLK_COMP: $runtime_P_TWF_CLK_COMP sec "
puts "Runtime for SLACK_COMP : $runtime_P_TWF_SLACK_COMP sec"
puts "Runtime for SDC : $runtime_P_TWF_SDC sec"
puts "Runtime for DESIGN_INFO : $runtime_P_TWF_DESIGN_INFO sec" 
puts "Runtime for CLOCK_GROUP : $runtime_P_TWF_CLOCK_GROUP sec" 
puts "Runtime for PT_CLOCK : $runtime_P_TWF_PT_CLOCK sec" 
puts "Runtime for PT_GENERATED_CLOCK : $runtime_P_TWF_PT_GENERATED_CLOCK sec" 
puts "Runtime for PT_EXTRA_TIMING_CHECK : $runtime_P_TWF_PT_EXTRA_TIMING_CHECK sec" 
puts "Runtime for ENDPOINT_PBA_COMP_3 : $runtime_P_TWF_ENDPOINT_PBA_COMP_3 sec" 
puts "Runtime for ENDPOINT_PBA_COMP_2 : $runtime_P_TWF_ENDPOINT_PBA_COMP_2 sec" 
puts "Runtime for EPILOGUE : $runtime_P_TWF_EPILOGUE sec" 

puts "End: DORADO_PT_TWF"
set END [date]
puts $END
if { [file exists ${twf_file}.tmp.sdc] } { file delete -force ${twf_file}.tmp.sdc }
}
echo 1
##-------------------------------------------------------------------------------------------
##--- sub procedures ------------------------------------------------------------------------

### Procedure for printing TWF header ###
proc P_TWF_HEADER { } {
  global design
  global unit
  global hierarchy_separator
  global VER
  global timing_pocvm_enable_analysis
  global timing_enable_slew_variation
  global timing_enable_constraint_variation
  global timing_pocvm_corner_sigma

  puts "DORADO_PT_TWF"
  puts "DATE \"[date]\""
  puts "DESIGN \"$design\""
  puts "DELIMITERS \"$hierarchy_separator\[\]\""
  puts "TIME_SCALE $unit"
  puts "TCL_VERSION $VER"
  puts "#pocv Tweaker commands"
  puts "#set enable_ocv_sigma $timing_pocvm_enable_analysis"
  puts "#set enable_timing_slew_variation $timing_enable_slew_variation"
  puts "#set enable_timing_constraint_variation $timing_enable_constraint_variation"	
  puts "#set set_timing_ocv_sigma sigma_value $timing_pocvm_corner_sigma"

}

proc P_TWF_CLK_COMP { } {
      set a [clock clicks -milliseconds]
      puts "CLK_COMP"
      if { [get_clocks * -quiet] != "" } {
#	      foreach_in_collection clock_pin_object [get_clock_network_objects -type pin [get_clocks * ] -include_clock_gating_network] {
#        	    puts "[get_attribute $clock_pin_object full_name]"
#      	      }
	      report_attribute -attribute {} [get_clock_network_objects -type pin [get_clocks * ] -include_clock_gating_network] -summary
      }
      set b [clock clicks -milliseconds]  
      set ::runtime_P_TWF_CLK_COMP [expr ($b-$a)/1000]
}

proc P_TWF_SLACK_COMP { } {
      set a [clock clicks -milliseconds]
      puts "SLACK_COMP"
      report_global_slack -sig 4 -nosplit
      set b [clock clicks -milliseconds]
      set ::runtime_P_TWF_SLACK_COMP [expr ($b-$a)/1000]
}

proc P_TWF_SDC { {DUMP_SDC_COMP} } {
set a [clock clicks -milliseconds]
global design
global twf_fp
set twf_file $twf_fp
   if { $DUMP_SDC_COMP } { 
        puts "DORADO_SDC_COMP"
        if { [file exists ${twf_file}.tmp.sdc] } {
             set fd [open ${twf_file}.tmp.sdc r]
             while { ![eof $fd] } {
                     set data [read $fd 1048576]
                     puts -nonewline $data
                   }
             close $fd
        }
   } else {
        puts "DORADO_SDC_COMP"
     }
     set b [clock clicks -milliseconds]
      set ::runtime_P_TWF_SDC [expr ($b-$a)/1000]

}


proc P_TWF_DESIGN_INFO { {DUMP_CLOCK_GROUP} } {
   set a [clock clicks -milliseconds]
   global design
   global twf_fp
   set twf_file $twf_fp
   puts "DORADO_DESIGN_INFO"
   #set dod_max_transition [get_attribute [current_design] max_transition]
   #if { $dod_max_transition == "" } { set dod_max_transition "*" }
   #puts "current_design_max_transition $dod_max_transition"
   if { $DUMP_CLOCK_GROUP } { 
           P_TWF_CLOCK_GROUP
   } else {	   
	   puts "DORADO_CLOCK_GROUP" 
     } 
    set b [clock clicks -milliseconds]
    set ::runtime_P_TWF_DESIGN_INFO [expr ($b-$a)/1000] 
}

proc P_TWF_CLOCK_GROUP { } {
   set a [clock clicks -milliseconds]
   puts "DORADO_CLOCK_GROUP"
       foreach_in_collection clock_pin_object [all_registers -clock_pins] {
            set clock_list [get_attribute -quiet $clock_pin_object clocks]
            if { [sizeof_collection $clock_list] } {
               puts [join [list [get_attribute -quiet $clock_pin_object full_name] [get_object_name $clock_list] " "]]
            }
       }
    set b [clock clicks -milliseconds]
    set ::runtime_P_TWF_CLOCK_GROUP [expr ($b-$a)/1000] 
}

proc P_TWF_PT_CLOCK { DUMP_PT_SOURCE_GENERATED_CLK } {
   set a [clock clicks -milliseconds]
   if { !$DUMP_PT_SOURCE_GENERATED_CLK } {	
   	    puts "DORADO_PT_CLOCK"
   } else { 	
   	    puts "DORADO_PT_CLOCK"
         	foreach_in_collection g_clock [get_clocks * -quiet] {
             		if { ![get_attribute $g_clock is_generated] } {
                  		set sources_pin [get_attribute [get_attribute $g_clock sources] full_name]
                  	if { $sources_pin == "" } { set sources_pin "*" }
                 		 foreach x $sources_pin {
                       	puts "[get_attribute $g_clock full_name] $x"
                  }
             }
         }
   }
   set b [clock clicks -milliseconds]
   set ::runtime_P_TWF_PT_CLOCK [expr ($b-$a)/1000] 

}

proc P_TWF_PT_GENERATED_CLOCK { DUMP_PT_SOURCE_GENERATED_CLK  } {
    set a [clock clicks -milliseconds]
    if {  !$DUMP_PT_SOURCE_GENERATED_CLK  } {	
		puts "DORADO_PT_GENERATED_CLOCK"
    } else {	    
		puts "DORADO_PT_GENERATED_CLOCK"
      		    foreach_in_collection g_clock [get_clocks * -quiet] {
         		if { [get_attribute $g_clock is_generated] } {
              		    set sources_pin [get_attribute [get_attribute $g_clock sources] full_name]
              		if { $sources_pin == "" } { set sources_pin "*" }
                            set master_pin [get_attribute [get_attribute $g_clock master_pin] full_name]
              		if { $master_pin == "" } { set master_pin "*" }
                            foreach x $sources_pin {
                 		    foreach y $master_pin {
                    			      puts "[get_attribute $g_clock full_name] $x $y"
                 }
              }
         }
      }
   }
   set b [clock clicks -milliseconds]
   set ::runtime_P_TWF_PT_GENERATED_CLOCK [expr ($b-$a)/1000] 
}


proc P_TWF_PT_EXTRA_TIMING_CHECK { } {
   set a [clock clicks -milliseconds]
   global DUMP_EXTRA_TIMING_CHECK

   if { $DUMP_EXTRA_TIMING_CHECK } { 

      puts "DORADO_EXTRA_TIMING_CHECK"
      puts "CELLNAME SETUP HOLD RECOVERY REMOVAL"

      foreach_in_collection sel [get_lib_cells */* ] {

         if { [ get_attribute -quiet $sel is_sequential ] } {

            #### is_sequential includes flop/latch/CG cells ####

            set my_cell         [ get_attribute -quiet $sel base_name ]

            set my_setup_tax    [ get_attribute -quiet $sel stdcell_setup_tax    ]
            set my_hold_tax     [ get_attribute -quiet $sel stdcell_hold_tax     ]
            set my_recovery_tax [ get_attribute -quiet $sel stdcell_recovery_tax ]
            set my_removal_tax  [ get_attribute -quiet $sel stdcell_removal_tax  ]

            if { $my_setup_tax    eq "" } { set my_setup_tax    "*" }
            if { $my_hold_tax     eq "" } { set my_hold_tax     "*" }
            if { $my_recovery_tax eq "" } { set my_recovery_tax "*" }
            if { $my_removal_tax  eq "" } { set my_removal_tax  "*" }

            if { $my_setup_tax eq "*" && $my_hold_tax eq "*" && $my_recovery_tax eq "*" && $my_removal_tax eq "*" } {
               continue
            }

            puts "$my_cell $my_setup_tax $my_hold_tax $my_recovery_tax $my_removal_tax" 

         }
      } 

      puts "1"
   } 
   set b [clock clicks -milliseconds]
   set ::runtime_P_TWF_PT_EXTRA_TIMING_CHECK [expr ($b-$a)/1000] 
}

proc P_TWF_ENDPOINT_PBA_COMP_3 { {op "-pba"} {pba_setup_path_ratio $pba_setup_path_ratio} {pba_hold_path_ratio $pba_hold_path_ratio} } {
    set a [clock clicks -milliseconds]
    global pba_path_mode_sort_by_gba_slack
    set save_var_2 $pba_path_mode_sort_by_gba_slack
    set pba_path_mode_sort_by_gba_slack true

    set report_path_max_number   [ sizeof_collection [ all_registers -data_pins ] ]
    set pba_setup_max_path_threshold [ expr round($report_path_max_number * $pba_setup_path_ratio) ]
    if { $pba_setup_max_path_threshold > 250000 } {
    	set pba_setup_max_path_threshold 250000
    }
    set pba_hold_max_path_threshold  [ expr round($report_path_max_number * $pba_hold_path_ratio)  ]
    if { $pba_hold_max_path_threshold > 250000 } {
    	set pba_hold_max_path_threshold 250000
    }

    puts "ENDPOINT_PBA_COMP_2_MAX"		; # TOKEN for PrimeTime only

    report_timing -path_type summary -delay_type max -max_paths $pba_setup_max_path_threshold -nworst 1 -significant_digits 4 -slack_lesser_than 5 -pba_mode path -nosplit
    puts "1"

    puts "ENDPOINT_PBA_COMP_2_MIN"		; # TOKEN for PrimeTime only

    report_timing -path_type summary -delay_type min -max_paths $pba_hold_max_path_threshold  -nworst 1 -significant_digits 4 -slack_lesser_than 5 -pba_mode path -nosplit
    puts "1"

    set pba_path_mode_sort_by_gba_slack $save_var_2
    set b [clock clicks -milliseconds]
    set ::runtime_P_TWF_ENDPOINT_PBA_COMP_3 [expr ($b-$a)/1000] 
}


proc P_TWF_ENDPOINT_PBA_COMP_2 { {op "-pba"} {pba_setup_threshold $pba_setup_threshold} {pba_hold_threshold $pba_hold_threshold} {input_clk_list $input_clk_list} } {

    set a [clock clicks -milliseconds]
    global pba_path_mode_sort_by_gba_slack
    set save_var_2 $pba_path_mode_sort_by_gba_slack
    set pba_path_mode_sort_by_gba_slack true


    puts "ENDPOINT_PBA_COMP_2_MAX"		; # TOKEN for PrimeTime only

    report_timing -path_type summary -delay_type max -max_paths 2000000 -nworst 1 -significant_digits 4 -slack_lesser_than $pba_setup_threshold -pba_mode path -nosplit
    puts "1"

    puts "ENDPOINT_PBA_COMP_2_MIN"		; # TOKEN for PrimeTime only

    report_timing -path_type summary -delay_type min -max_paths 2000000 -nworst 1 -significant_digits 4 -slack_lesser_than $pba_hold_threshold  -pba_mode path -nosplit
    puts "1"

    set pba_path_mode_sort_by_gba_slack $save_var_2
    set b [clock clicks -milliseconds]
    set ::runtime_P_TWF_ENDPOINT_PBA_COMP_2 [expr ($b-$a)/1000] 
}

proc P_TWF_EPILOGUE { } {
     ### EPILOGUE ###
     set a [clock clicks -milliseconds]	
     puts "DORADO_PT_TWF_END"
     set b [clock clicks -milliseconds]
     set ::runtime_P_TWF_EPILOGUE [expr ($b-$a)/1000]
}

unsuppress_message CMD-041                                
unsuppress_message ATTR-3          
unsuppress_message ATTR-1        

