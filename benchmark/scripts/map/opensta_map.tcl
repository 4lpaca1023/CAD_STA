set script_dir [file dirname [file normalize [info script]]]
set benchmark_root [file normalize [file join $script_dir .. ..]]
set design_dir [file join $benchmark_root designs map]
set design_top "map9v3"

set lib_file   [file join $design_dir "osu018_stdcells"]
set netlist    [file join $design_dir "map9v3.v"]
set sdc_file   [file join $design_dir "map9v3.sdc"]
set spef_file  [file join $design_dir "map9v3.spef"]

read_liberty $lib_file
read_verilog $netlist
link_design $design_top
read_sdc $sdc_file
read_spef $spef_file
set_propagated_clock [all_clocks]

puts "INFO: Running report_checks -path_delay min"
report_checks -path_delay min -digits 4

puts "INFO: Running report_checks -path_delay max"
report_checks -path_delay max -digits 4

puts "INFO: Running report_tns/report_wns (min/max)"
report_tns -min
report_tns -max
report_wns -min
report_wns -max
