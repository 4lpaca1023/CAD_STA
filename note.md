## PrimeTime STA Flow for Latch

**Goal:** Get a PrimeTime Static Timing Analysis (STA) flow working for a simple design with a single level-sensitive latch using the sky130 library.

**Progress:**

1.  **Initial State:** The flow was failing with a "No constrained paths" error.
2.  **Problem 1: Linking Error:** A `LNK-005` error was identified, caused by an incomplete `link_path` in `run_sky.tcl`.
    *   **Fix:** Added the specific library name `sky130_fd_sc_hd__tt_025C_1v80` to the `link_path`.
3.  **Problem 2: Incomplete Constraints:** After fixing the linking, paths were still not constrained because the output constraints in `unit.sdc` were commented out.
    *   **Fix:** Uncommented the `set_load` and `set_output_delay` commands.
4.  **Current Status:** The STA flow is now running successfully. The design links correctly, and timing paths are being analyzed.
    *   From the generated `paths.rpt` file, we have determined the following for the latch `l1`:
        *   **Setup time (t_setup):** 0.17
        *   **Hold time (t_hold):** 0.13

**Next Steps:**

*   The commands to calculate the clock-to-q delay (`report_delay_calculation`) failed in the previous runs. The next step is to execute the script again to obtain these values and complete the analysis.
