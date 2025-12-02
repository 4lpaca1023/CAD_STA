
set search_path ". $search_path"

read_lib osu018_stdcells.lib

set link_path "* osu018_stdcells"

read_verilog unit.v

current_design simple

link_design simple

read_sdc unit.sdc

check_timing

update_timing

puts "--- Max Delay (Setup) Report ---"
report_timing -delay_type max 

# 報告 Hold Time (Min Delay)
puts "--- Min Delay (Hold) Report ---"
report_timing -delay_type min -max_paths 999

# 報告所有違反規則的路徑 (Violators)
puts "--- Constraint Violators Report ---"
report_constraint -all_violators

puts "--- report timimg ---"