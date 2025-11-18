# Resolve the design directory relative to this script so the example works
# regardless of the current working directory.
set script_dir [file dirname [file normalize [info script]]]
set benchmark_root [file normalize [file join $script_dir .. ..]]
set design_dir [file join $benchmark_root designs map9v3]
set results_dir [file join $benchmark_root results map ista_map]
set design_top "map9v3"

file mkdir $results_dir
set_design_workspace $results_dir

read_netlist $design_dir/map9v3.v

read_liberty $design_dir/osu018_stdcells

read_spef $design_dir/map9v3.spef

link_design $design_top

read_sdc  $design_dir/map9v3.sdc

report_timing
