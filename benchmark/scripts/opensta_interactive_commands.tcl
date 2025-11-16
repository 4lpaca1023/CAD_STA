# Interactive-style entry for OpenSTA.
# Even though commands are fed via stdin, we log the script directory
# so it is easier to trace which shared command file was executed.
if {[info script] eq ""} {
  if {[info exists ::env(BENCHMARK_SCRIPT_DIR)] && $::env(BENCHMARK_SCRIPT_DIR) ne ""} {
    set script_dir $::env(BENCHMARK_SCRIPT_DIR)
  } else {
    set script_dir [pwd]
  }
} else {
  set script_dir [file dirname [info script]]
}
puts "INFO: Running OpenSTA interactive-style commands from $script_dir"

# Re-use the shared flow so batch/interactive executions stay identical.
source [file join $script_dir opensta_common.tcl]

# Terminate the shell once the shared script completes.
exit
