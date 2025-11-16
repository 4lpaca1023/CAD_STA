# Batch-mode entry for OpenSTA.
# This script simply sources the shared command list and exits,
# allowing run_all.sh to re-use the same flow across modes.
source [file join [file dirname [info script]] opensta_common.tcl]

# Explicit exit so the shell terminates after executing the shared commands.
exit
