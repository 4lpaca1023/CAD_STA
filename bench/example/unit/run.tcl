
set search_path ". $search_path"

read_lib osu018_stdcells.lib

set link_path "* osu018_stdcells"

read_verilog unit.v

current_design simple

link_design simple

read_parasitics unit.spef

read_sdc unit_sta.sdc

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
