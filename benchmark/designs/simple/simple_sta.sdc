create_clock -period 50 -name tau2015_clk [get_ports tau2015_clk]

# Clock arrival offsets modeled with set_clock_latency because OpenSTA
# forbids set_input_delay on the clock source port.
set_clock_latency -source -min -rise 0   [get_clocks tau2015_clk]
set_clock_latency -source -max -rise 0   [get_clocks tau2015_clk]
set_clock_latency -source -min -fall 25  [get_clocks tau2015_clk]
set_clock_latency -source -max -fall 25  [get_clocks tau2015_clk]

# Clock slew must use set_clock_transition instead of set_input_transition -clock.
set_clock_transition -min -rise 10 [get_clocks tau2015_clk]
set_clock_transition -min -fall 15 [get_clocks tau2015_clk]
set_clock_transition -max -rise 10 [get_clocks tau2015_clk]
set_clock_transition -max -fall 15 [get_clocks tau2015_clk]

set_input_delay 0 -min -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 0 -min -fall [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -rise [get_ports inp1] -clock tau2015_clk
set_input_delay 5 -max -fall [get_ports inp1] -clock tau2015_clk

set_input_delay 0 -min -rise [get_ports inp2] -clock tau2015_clk
set_input_delay 0 -min -fall [get_ports inp2] -clock tau2015_clk
set_input_delay 1 -max -rise [get_ports inp2] -clock tau2015_clk
set_input_delay 1 -max -fall [get_ports inp2] -clock tau2015_clk

set_input_transition 10 -min -rise [get_ports inp1]
set_input_transition 15 -min -fall [get_ports inp1]
set_input_transition 20 -max -rise [get_ports inp1]
set_input_transition 25 -max -fall [get_ports inp1]

set_input_transition 30 -min -rise [get_ports inp2]
set_input_transition 30 -min -fall [get_ports inp2]
set_input_transition 40 -max -rise [get_ports inp2]
set_input_transition 40 -max -fall [get_ports inp2]

set_load -pin_load 4 [get_ports out]

set_output_delay -10 -min -rise [get_ports out] -clock tau2015_clk
set_output_delay -10 -min -fall [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -rise [get_ports out] -clock tau2015_clk
set_output_delay 30 -max -fall [get_ports out] -clock tau2015_clk
