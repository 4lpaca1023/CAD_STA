# Resolve the benchmark design directory relative to this script so the
# example works regardless of the current working directory.
set script_dir [file dirname [file normalize [info script]]]
set benchmark_root [file normalize [file join $script_dir .. ..]]
set design_dir [file join $benchmark_root designs simple]
set results_dir [file join $benchmark_root results simple ista_simple]
set design_top "simple"

file mkdir $results_dir
set_design_workspace $results_dir

read_netlist $design_dir/simple.v

set LIB_FILES $design_dir/osu018_stdcells.lib

read_liberty $LIB_FILES

link_design $design_top

read_sdc  $design_dir/simple.sdc
# read_spef $design_dir/simple.spef

report_timing
