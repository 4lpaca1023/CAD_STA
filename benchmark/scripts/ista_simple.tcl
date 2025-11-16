namespace eval ::benchmark {}

# Guard utility identical to the OpenSTA version; stops execution when
# run_all.sh forgets to export a required path.
proc ::benchmark::require_env {name} {
  if {![info exists ::env($name)] || $::env($name) eq ""} {
    error "Missing required environment variable $name"
  }
  return $::env($name)
}

set script_dir [file dirname [info script]]

# Allow run_all.sh to inject a unique workspace via BENCHMARK_RESULT_DIR.
# Fall back to the legacy shared folder so manual runs still work.
if {[info exists ::env(BENCHMARK_RESULT_DIR)] && $::env(BENCHMARK_RESULT_DIR) ne ""} {
  set result_dir [file normalize $::env(BENCHMARK_RESULT_DIR)]
} else {
  set result_dir [file normalize [file join $script_dir .. results ieda_ista]]
}

file mkdir $result_dir
set_design_workspace $result_dir

# Resolve all design collateral up front once.
set design_name [::benchmark::require_env "BENCHMARK_DESIGN_NAME"]
set design_top  [::benchmark::require_env "BENCHMARK_DESIGN_TOP"]
set netlist     [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_NETLIST"]]
set sdc_file    [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_SDC"]]
set spef_file   [file normalize [::benchmark::require_env "BENCHMARK_DESIGN_SPEF"]]
set lib_files [list \
  [file normalize [::benchmark::require_env "BENCHMARK_LIB_EARLY"]] \
  [file normalize [::benchmark::require_env "BENCHMARK_LIB_LATE"]]]

puts "INFO: iSTA benchmark design: $design_name"
puts "INFO: Design workspace: $result_dir"

# Standard iSTA flow: read in all design inputs and constraints/SPEF.
read_netlist $netlist
read_liberty $lib_files
link_design $design_top
read_sdc  $sdc_file
read_spef $spef_file

# Emit both max/min reports so downstream parsing has consistent fields.
report_timing -delay_type max -digits 4
report_timing -delay_type min -digits 4
