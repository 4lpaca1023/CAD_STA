# Helper utilities for resolving design collateral and parsing design.env.
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
# Edit the defaults below (or set the variables before sourcing this file)
# to point the script at the desired benchmark design.
if {![info exists design_name]} {
  set design_name "simple"
}
if {![info exists design_top]} {
  set design_top $design_name
}
if {![info exists design_dir]} {
  set design_dir [file normalize [file join $script_dir .. designs $design_name]]
}

# Derive standard file names.  Designs can optionally provide a design.env file
# with DESIGN_* assignments to override these defaults automatically.
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

puts "INFO: OpenSTA design=$design_name top=$design_top"
puts "INFO: Design directory=$design_dir"

# Standard STA bring-up: load Liberty/Verilog/constraints/SPEF and propagate clocks.
read_liberty -min $lib_early
read_liberty -max $lib_late
read_verilog $netlist
link_design $design_top
read_sdc $sdc_file
read_spef $spef_file
set_propagated_clock [all_clocks]

# Emit timing checks for both min and max delays so logs keep detailed context.
puts "INFO: Running report_checks -path_delay min"
report_checks -path_delay min -digits 4

puts "INFO: Running report_checks -path_delay max"
report_checks -path_delay max -digits 4

# Summaries: collect TNS/WNS for min/max so the summary script has structured data.
puts "INFO: Running report_tns/report_wns (min/max)"
report_tns -min
report_tns -max
report_wns -min
report_wns -max
