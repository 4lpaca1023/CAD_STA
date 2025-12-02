
set search_path ". $search_path"

# Read the sky130 library and set the link_path.
# Note: The library name is 'sky130_fd_sc_hd', not the filename.
read_lib sky130hd_tt.lib.gz
set link_path [list "*" "sky130_fd_sc_hd__tt_025C_1v80"]

read_verilog unit.v

current_design simple

link_design simple

# for latch analysis
set timing_enable_latch_time_borrow true

read_sdc unit.sdc

set_propagated_clock [all_clocks]

update_timing

check_timing

report_clock


puts "--- Max Delay (Setup) Report ---"
report_timing -delay_type max 

# 報告 Hold Time (Min Delay)
puts "--- Min Delay (Hold) Report ---"
report_timing -delay_type min -max_paths 999

# 報告所有違反規則的路徑 (Violators)
puts "--- Constraint Violators Report ---"
report_constraint -all_violators

echo "## 產生路徑報告檔案 paths.rpt" > paths.rpt

echo "## t_pcq" >> paths.rpt
report_delay_calculation -from [get_pins l1/GATE_N] -to [get_pins l1/Q] -max >> paths.rpt

echo "## t_cdq" >> paths.rpt
report_delay_calculation -from [get_pins l1/GATE_N] -to [get_pins l1/Q] -min >> paths.rpt

echo "## 取得 Max Delay (即 t_pdq)" >> paths.rpt
report_delay_calculation -from [get_pins l1/D] -to [get_pins l1/Q] -max >> paths.rpt

echo "## 取得 Min Delay (即 t_cdq)" >> paths.rpt
report_delay_calculation -from [get_pins l1/D] -to [get_pins l1/Q] -min >> paths.rpt

echo "## 查詢 Setup 時間 (t_setup)" >> paths.rpt
report_timing -to [get_pins l1/D] -delay_type max -path_type full_clock_expanded >> paths.rpt

echo "## 查詢 Hold 時間 (t_hold)" >> paths.rpt
report_timing -to [get_pins l1/D] -delay_type min -path_type full_clock_expanded >> paths.rpt

echo "## 最差的兩條 Setup 路徑與 Hold 路徑" >> paths.rpt
report_timing -delay_type max -max_paths 2 -slack_lesser_than 7777 -input_pins -nets >> paths.rpt

report_timing -delay_type min -max_paths 2 -slack_lesser_than 7777 -input_pins -nets >> paths.rpt 

echo "## 報告所有違反規則的路徑 (Violators)" >> paths.rpt
report_constraint -all_violators >> paths.rpt

get_timing_path -max_paths 5

exit
