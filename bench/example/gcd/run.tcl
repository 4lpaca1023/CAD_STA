set script_dir [file dirname [file normalize [info script]]]
set search_path "$script_dir $search_path"

read_lib sky130hd_tt.lib.gz

set link_path sky130hd_tt

read_verilog gcd_sky130hd.v

current_design gcd
link_design gcd

read_parasitics gcd_sky130hd.spef
read_sdc gcd_sky130hd.sdc

check_timing

update_timing

puts "--- Max Delay (Setup) Report ---"
report_timing -delay_type max

puts "--- Min Delay (Hold) Report ---"
report_timing -delay_type min

puts "--- Constraint Violators Report ---"
report_constraint -all_violators

puts "--- report timimg ---"
report_timing -delay_type max -max_paths 2 -slack_lesser_than 7777 -input_pins -nets > paths.rpt

report_timing -delay_type min -max_paths 2 -slack_lesser_than 7777 -input_pins -nets >> paths.rpt
exit