# Minimal Tcl wrapper that launches OpenTimer's ot-shell on the benchmark
# simple design, regardless of the current working directory.

set script_dir [file dirname [file normalize [info script]]]
set benchmark_root [file normalize [file join $script_dir .. ..]]
set repo_root [file normalize [file join $benchmark_root ..]]
set opentimer_bin  [file join $repo_root OpenTimer bin ot-shell]

set design_dir [file join $benchmark_root designs simple]
set lib_file   [file join $design_dir "osu018_stdcells.lib"]
set netlist    [file join $design_dir "simple.v"]
set sdc_file   [file join $design_dir "simple.sdc"]

foreach path [list $opentimer_bin $lib_file $netlist $sdc_file] {
  if {![file exists $path]} {
    error "Required file not found: $path"
  }
}
if {![file executable $opentimer_bin]} {
  error "OpenTimer binary not executable: $opentimer_bin"
}

set commands [list \
  "set_num_threads 1" \
  "read_celllib $lib_file" \
  "read_verilog $netlist" \
  "read_sdc $sdc_file" \
  "report_timing -max" \
  "report_timing -min" \
  "report_tns -max" \
  "report_tns -min" \
  "report_wns -max" \
  "report_wns -min" \
  "exit" ]

set tmpfile [file join $script_dir "opentimer_simple_[pid].ot"]
set fh [open $tmpfile w]
foreach cmd $commands {
  puts $fh $cmd
}
close $fh

puts "INFO: Launching $opentimer_bin"
puts "INFO: Design directory: $design_dir"
set rc [catch {exec $opentimer_bin --stdin $tmpfile >@stdout 2>@stderr} err options]
file delete -force $tmpfile
if {$rc} {
  if {$err ne ""} {
    puts stderr $err
  }
  if {[info exists options(-errorcode)] && [llength $options(-errorcode)] >= 3} {
    exit [lindex $options(-errorcode) 2]
  }
  exit 1
}
