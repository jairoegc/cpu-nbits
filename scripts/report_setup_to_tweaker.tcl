#############################################################################################
## Description :
##
## This script file is to report timing paths of setup time violations on each endpoint
## from Prime Time.  The report file will be in the accepted file format read by 
## Tweaker to produce the eco slack path domain.
##
## Usage :
##        pt_shell> source report_setup_to_tweaker.tcl
##        pt_shell> setup_to_tweaker <temp_report setup_to_tweaker>
##
## Notes :
##      1. source the script at the end of timing analysis.
##      2. If no file names are given, "setup_to_tweaker" will dump reports into PrimeTime working directory
##         with the default file name.
##
##            ** The default of temp_report		: constraint.setup.vios
##            ** The default of setup_to_tweaker	: setup_to_tweaker.rpt
##
## Example:
##        pt_shell> setup_to_tweaker
##        or
##        pt_shell> setup_to_tweaker "../rpt/setup.vios" "../rpt/setup_to_tweaker.rpt"
##
## User controllable variables :
##
##	NWORST			=> Applied to the "-nworst" option of report_timing. (Default is 30)
##
##	SLACK_LESSER_THAN	=> Applied to the "-slack_lesser_than" option of report_timing. (Default is 0.005)
##
##	SIG_DIGITS		=> Applied to the "-significant_digits" option of report_timing. (Default is 3)
##
##      FULL_CLOCK_EXPANDED     => Applied to the "-path_type full_clock_expanded" option of report_timing.
##
##############################################################################################

proc setup_to_tweaker {{TEMP_VIOS "./constraint.setup.vios"} {SETUP_TO_TWEAKER "./setup_to_tweaker.rpt"} } {
set NWORST 5 
set SLACK_LESSER_THAN 0
set SIG_DIGITS 4
set FULL_CLOCK_EXPANDED 0
set SETUP_TO_TWEAKER_file "$SETUP_TO_TWEAKER.gz"
set START [date]
set design [get_attribute [current_design] full_name]
set time_unit [get_attribute [get_designs ] time_unit_in_second]
set cap_unit  [get_attribute [get_designs ] capacitance_unit_in_farad]

if { [info exists ::timing_report_include_eco_attributes] } {
	set timing_report_including_attribute_ori $::timing_report_include_eco_attributes
	set_app_var timing_report_include_eco_attributes false
}

puts $START

if [file exists $TEMP_VIOS] {
        file delete -force $TEMP_VIOS
       }

if [file exists $SETUP_TO_TWEAKER] {
       file delete -force $SETUP_TO_TWEAKER    
       }

report_constraint -all_violators -path_type slack_only -significant_digits $SIG_DIGITS -max_delay -recovery > $TEMP_VIOS

set viofile [ open $TEMP_VIOS "r" ]
set pass_header 0
redirect -compress -file ${SETUP_TO_TWEAKER_file} {
  puts "DORADO_TIME_UNIT $time_unit"
  puts "DORADO_CAP_UNIT $cap_unit"
  while { [gets $viofile line] >= 0 }  {
	if { ![regexp {\-\-\-\-\-\-} $line] && $pass_header == 0 } {
	 	continue
	} else { 
		set pass_header 1
		if { !( [regexp {max_delay\/setup[ ]} $line] || [regexp {recovery\s*$} $line] )} {
			if { ![regexp {\-\-\-\-\-\-} $line] && ![regexp {Endpoint[   ]} $line] && ![regexp {Sigma:} $line] } {
		  		set end_point  [lindex $line 0]
				if { ![string is double $end_point] && $end_point != "recovery" && $end_point != "clock_gating_setup" && $end_point != "End-point" } {
			  	  if { $FULL_CLOCK_EXPANDED } {
                                       eval { report_timing \
                                       -delay_type max -nworst $NWORST -input_pins -transition_time -capacitance -path_type full_clock_expanded \
                                       -include_hierarchical_pins -slack_lesser_than $SLACK_LESSER_THAN \
                                        -significant_digits $SIG_DIGITS -to $end_point }
                                  } else {
                                       eval { report_timing \
                                       -delay_type max -nworst $NWORST -input_pins -transition_time -capacitance \
                                       -include_hierarchical_pins -slack_lesser_than $SLACK_LESSER_THAN \
                                        -significant_digits $SIG_DIGITS -to $end_point }
                                    }
				}
 			}
		}
	  }
  }
close $viofile
#file delete -force $TEMP_VIOS
}
set END [date]
puts $END
if { [info exists ::timing_report_include_eco_attributes] } {
	set_app_var timing_report_include_eco_attributes $timing_report_including_attribute_ori
}
}