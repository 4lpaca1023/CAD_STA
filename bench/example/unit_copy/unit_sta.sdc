create_clock -period 50 -name tau2015_clk [get_ports tau2015_clk]

# Input delays on normal inputs are fine
set_input_delay 0 -min -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 0 -min -fall [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -fall [get_ports inp1] -clock tau2015_clk
set_input_delay 0 -min -rise [get_ports inp2] -clock tau2015_clk
set_input_delay 0 -min -fall [get_ports inp2] -clock tau2015_clk
set_input_delay 1 -max -rise [get_ports inp2] -clock tau2015_clk
set_input_delay 1 -max -fall [get_ports inp2] -clock tau2015_clk

# Removed -clock from set_input_transition
set_input_transition 10 -min -rise [get_ports inp1]
set_input_transition 15 -min -fall [get_ports inp1]
set_input_transition 20 -max -rise [get_ports inp1]
set_input_transition 25 -max -fall [get_ports inp1]
set_input_transition 30 -min -rise [get_ports inp2]
set_input_transition 30 -min -fall [get_ports inp2]
set_input_transition 40 -max -rise [get_ports inp2]
set_input_transition 40 -max -fall [get_ports inp2]

# Transition on clock port (removed -clock)
set_input_transition 10 -min -rise [get_ports tau2015_clk]
set_input_transition 15 -min -fall [get_ports tau2015_clk]
set_input_transition 10 -max -rise [get_ports tau2015_clk]
set_input_transition 15 -max -fall [get_ports tau2015_clk]

set_load -pin_load 4 [get_ports out]
set_output_delay -10 -min -rise [get_ports out] -clock tau2015_clk
set_output_delay -10 -min -fall [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -rise [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -fall [get_ports out] -clock tau2015_clk
