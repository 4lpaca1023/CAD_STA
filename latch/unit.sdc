create_clock -period 50 -waveform {0 25} -name tau2015_clk [get_ports tau2015_clk]

# Input delays on normal inputs are fine
set_input_delay 0 -min -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 0 -min -fall [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -fall [get_ports inp1] -clock tau2015_clk

set_input_transition 0.10 -min -rise [get_ports inp1]
set_input_transition 0.15 -min -fall [get_ports inp1]
set_input_transition 0.20 -max -rise [get_ports inp1]
set_input_transition 0.25 -max -fall [get_ports inp1]

set_input_transition 0.10 -min -rise [get_ports tau2015_clk]
set_input_transition 0.15 -min -fall [get_ports tau2015_clk]
set_input_transition 0.10 -max -rise [get_ports tau2015_clk]
set_input_transition 0.15 -max -fall [get_ports tau2015_clk]

set_load -pin_load 0.01 [get_ports out]
set_output_delay -10 -min -rise [get_ports out] -clock tau2015_clk
set_output_delay -10 -min -fall [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -rise [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -fall [get_ports out] -clock tau2015_clk
