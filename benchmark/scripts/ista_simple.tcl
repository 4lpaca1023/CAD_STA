set script_dir [file dirname [info script]]
set benchmark_dir [file normalize [file join $script_dir .. simple]]
set result_dir [file normalize [file join $script_dir .. results ieda_ista]]

file mkdir $result_dir
set_design_workspace $result_dir

set lib_files [list \
  [file join $benchmark_dir simple_Early.lib] \
  [file join $benchmark_dir simple_Late.lib]]

puts "INFO: iSTA benchmark dir: $benchmark_dir"
puts "INFO: Design workspace: $result_dir"

read_netlist [file join $benchmark_dir simple.v]
read_liberty $lib_files
link_design simple
read_sdc  [file join $benchmark_dir simple.sdc]
read_spef [file join $benchmark_dir simple.spef]

report_timing -delay_type max -digits 4
report_timing -delay_type min -digits 4
