namespace eval ::benchmark {}

proc ::benchmark::join_design_path {base path} {
  if {[file pathtype $path] eq "absolute"} {
    return [file normalize $path]
  }
  return [file normalize [file join $base $path]]
}

proc ::benchmark::read_design_env {path} {
  set data {}
  set fh [open $path r]
  while {[gets $fh line] >= 0} {
    regsub {#.*$} $line "" line
    set line [string trim $line]
    if {$line eq ""} {
      continue
    }
    if {[regexp {^([^=]+)=(.*)$} $line -> key value]} {
      dict set data [string trim $key] [string trim $value]
    }
  }
  close $fh
  return $data
}

set script_dir [file dirname [info script]]

# === User configuration =====================================================
# Update the design name/top and directory to match your collateral.
if {![info exists design_name]} {
  set design_name "simple"
}
if {![info exists design_top]} {
  set design_top $design_name
}
if {![info exists design_dir]} {
  set design_dir [file normalize [file join $script_dir .. designs $design_name]]
}
if {![info exists result_dir]} {
  set result_dir [file normalize [file join $script_dir .. results ieda_ista]]
}

# Derive all design files.  Designs may provide design.env to override these.
set lib_early [::benchmark::join_design_path $design_dir "${design_name}_Early.lib"]
set lib_late  [::benchmark::join_design_path $design_dir "${design_name}_Late.lib"]
set netlist   [::benchmark::join_design_path $design_dir "${design_name}.v"]
set sdc_file  [::benchmark::join_design_path $design_dir "${design_name}.sdc"]
set spef_file [::benchmark::join_design_path $design_dir "${design_name}.spef"]

set design_env [file join $design_dir design.env]
if {[file readable $design_env]} {
  puts "INFO: Loading design configuration: $design_env"
  set cfg [::benchmark::read_design_env $design_env]
  if {[dict exists $cfg DESIGN_NAME]} {
    set design_name [dict get $cfg DESIGN_NAME]
  }
  if {[dict exists $cfg DESIGN_TOP]} {
    set design_top [dict get $cfg DESIGN_TOP]
  }
  if {[dict exists $cfg DESIGN_LIB_EARLY]} {
    set lib_early [::benchmark::join_design_path $design_dir [dict get $cfg DESIGN_LIB_EARLY]]
  }
  if {[dict exists $cfg DESIGN_LIB_LATE]} {
    set lib_late [::benchmark::join_design_path $design_dir [dict get $cfg DESIGN_LIB_LATE]]
  }
  if {[dict exists $cfg DESIGN_NETLIST]} {
    set netlist [::benchmark::join_design_path $design_dir [dict get $cfg DESIGN_NETLIST]]
  }
  if {[dict exists $cfg DESIGN_SDC]} {
    set sdc_file [::benchmark::join_design_path $design_dir [dict get $cfg DESIGN_SDC]]
  }
  if {[dict exists $cfg DESIGN_SPEF]} {
    set spef_file [::benchmark::join_design_path $design_dir [dict get $cfg DESIGN_SPEF]]
  }
}

set lib_files [list $lib_early $lib_late]

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
