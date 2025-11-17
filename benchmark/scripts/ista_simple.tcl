set script_dir [file dirname [info script]]

# === User configuration =====================================================
# Update the design name/top and directory to match your collateral.
set design_name "simple"
set design_top  $design_name
set design_dir  [file normalize [file join $script_dir .. designs simple]]
set result_dir  [file normalize [file join $script_dir .. results ieda_ista]]

# Derive all design files.  Edit these if your naming differs.
set lib_files [list \
  [file join $design_dir "${design_name}_Early.lib"] \
  [file join $design_dir "${design_name}_Late.lib"]]
set netlist   [file join $design_dir "${design_name}.v"]
set sdc_file  [file join $design_dir "${design_name}.sdc"]
set spef_file [file join $design_dir "${design_name}.spef"]

file mkdir $result_dir
set_design_workspace $result_dir

puts "INFO: iSTA benchmark design: $design_name"
puts "INFO: Design directory: $design_dir"
puts "INFO: Design workspace: $result_dir"

# Standard iSTA flow: read in all design inputs and constraints/SPEF.
read_netlist $netlist
read_liberty $lib_files
link_design $design_top
read_sdc  $sdc_file
read_spef $spef_file

# Emit both max/min reports so downstream parsing has consistent fields.
report_timing -delay_type max -digits 4
report_timing -delay_type min -digits 4
