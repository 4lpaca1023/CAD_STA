set script_dir [file dirname [info script]]
set benchmark_dir [file normalize [file join $script_dir .. simple]]

puts "INFO: OpenSTA benchmark directory: $benchmark_dir"

read_liberty -min [file join $benchmark_dir simple_Early.lib]
read_liberty -max [file join $benchmark_dir simple_Late.lib]
read_verilog [file join $benchmark_dir simple.v]
link_design simple
read_sdc [file join $benchmark_dir simple.sdc]
read_spef [file join $benchmark_dir simple.spef]
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
