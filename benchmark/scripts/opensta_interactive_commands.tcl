set script_dir [file dirname [info script]]
puts "INFO: Running OpenSTA interactive-style commands from $script_dir"
source [file join $script_dir opensta_common.tcl]
exit
