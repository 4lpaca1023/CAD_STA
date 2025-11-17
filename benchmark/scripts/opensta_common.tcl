# === User configuration =====================================================
# Set the design name and its directory once; the script derives file names
# matching the sample collateral under benchmark/designs.
set design_name "simple"
set design_top  $design_name
set design_dir  [file normalize [file join [file dirname [info script]] .. designs simple]]

# Derive standard file names.  Update these if your collateral uses different
# naming conventions.
set lib_early [file join $design_dir "${design_name}_Early.lib"]
set lib_late  [file join $design_dir "${design_name}_Late.lib"]
set netlist   [file join $design_dir "${design_name}.v"]
set sdc_file  [file join $design_dir "${design_name}.sdc"]
set spef_file [file join $design_dir "${design_name}.spef"]

puts "INFO: OpenSTA design=$design_name top=$design_top"
puts "INFO: Design directory=$design_dir"

# Standard STA bring-up: load Liberty/Verilog/constraints/SPEF and propagate clocks.
read_liberty -min $lib_early
read_liberty -max $lib_late
read_verilog $netlist
link_design $design_top
read_sdc $sdc_file
read_spef $spef_file
set_propagated_clock [all_clocks]

# Emit timing checks for both min and max delays so logs keep detailed context.
puts "INFO: Running report_checks -path_delay min"
report_checks -path_delay min -digits 4

puts "INFO: Running report_checks -path_delay max"
report_checks -path_delay max -digits 4

# Summaries: collect TNS/WNS for min/max so the summary script has structured data.
puts "INFO: Running report_tns/report_wns (min/max)"
report_tns -min
report_tns -max
report_wns -min
report_wns -max
