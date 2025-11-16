namespace eval ::benchmark {}

# Helper that aborts if run_all.sh forgot to export a required variable.
proc ::benchmark::require_env {name} {
  if {![info exists ::env($name)] || $::env($name) eq ""} {
    error "Missing required environment variable $name"
  }
  return $::env($name)
}

# Resolve all design-specific file paths once, so the commands below stay clean.
set design_name [::benchmark::require_env "BENCHMARK_DESIGN_NAME"]
set design_top  [::benchmark::require_env "BENCHMARK_DESIGN_TOP"]
set lib_early   [file normalize [::benchmark::require_env "BENCHMARK_LIB_EARLY"]]
set lib_late    [file normalize [::benchmark::require_env "BENCHMARK_LIB_LATE"]]
set netlist     [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_NETLIST"]]
set sdc_file    [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_SDC"]]
set spef_file   [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_SPEF"]]

puts "INFO: OpenSTA design=$design_name top=$design_top"

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
