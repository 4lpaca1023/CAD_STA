
set search_path ". $search_path"

read_lib osu018_stdcells.lib

#set link_path "* osu018_stdcells"
set link_path "* sky130hd_tt.lib.gz"

read_verilog unit.v

current_design simple

link_design simple

read_sdc unit.sdc

check_timing

update_timing

puts "--- Max Delay (Setup) Report ---"
report_timing -delay_type max

puts "--- Min Delay (Hold) Report ---"
report_timing -delay_type min

puts "--- Constraint Violators Report ---"
report_constraint -all_violators

puts "--- report timimg ---"

# 取得 Max Delay (即 t_pdq)
report_delay_calculation -from [get_pins l1/D] -to [get_pins l1/Q] -max

# 取得 Min Delay (即 t_cdq)
report_delay_calculation -from [get_pins l1/D] -to [get_pins l1/Q] -min

# 查詢 Setup 時間 (t_setup) 

# 方法：報告一條終點為該 Latch 的 Setup Path
report_timing -to [get_pins l1/D] -delay_type max -path_type full_clock_expanded > paths.rpt

# 查詢 Hold 時間 (t_hold)
report_timing -to [get_pins l1/D] -delay_type min -path_type full_clock_expanded >> paths.rpt


get_timing_path -max_paths 5

exit