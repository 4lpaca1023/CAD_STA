# Resolve the design directory relative to this script so the example works
# regardless of the current working directory.
set script_dir [file dirname [file normalize [info script]]]
set benchmark_root [file normalize [file join $script_dir .. ..]]
set design_dir [file join $benchmark_root designs gcd]
set results_dir [file join $benchmark_root results gcd ista_gcd]
set design_top "gcd"

file mkdir $results_dir
set_design_workspace $results_dir

read_netlist $design_dir/gcd_sky130hd.v

read_liberty $design_dir/sky130hd_tt.lib

read_spef $design_dir/gcd_sky130hd.spef

link_design $design_top

read_sdc  $design_dir/gcd_sky130hd.sdc

report_timing
