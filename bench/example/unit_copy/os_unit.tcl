# delay calc with spef parasitics
read_liberty ~/STA2/bench/example/unit/osu018_stdcells.lib
read_verilog ~/STA2/bench/example/unit/unit.v
link_design simple
read_spef ~/STA2/bench/example/unit/unit.spef
read_sdc ~/STA2/bench/example/unit/unit_sta.sdc
report_checks -path_delay max
report_checks -path_delay min