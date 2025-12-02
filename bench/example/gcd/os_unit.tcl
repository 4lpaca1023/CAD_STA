# delay calc with spef parasitics
read_liberty ~/STA2/bench/example/gcd/sky130hd_tt.lib.gz
read_verilog ~/STA2/bench/example/gcd/gcd_sky130hd.v
link_design gcd
read_spef ~/STA2/bench/example/gcd/gcd_sky130hd.spef
read_sdc ~/STA2/bench/example/gcd/gcd_sky130hd.sdc
report_checks -path_delay max
report_checks -path_delay min
exit