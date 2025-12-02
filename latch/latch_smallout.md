# Latch Timing Analysis: Output Load Sensitivity Comparison

## 1. Timing Parameters Comparison

The table below compares the timing parameters under two different output load conditions:
1.  **Heavy Load (Old):** ~4.0 pF (Caused massive violations)
2.  **Light Load (New):** ~0.01 pF (Optimized condition)

| Parameter | Symbol | Heavy Load (4pF) | Light Load (0.01pF) | Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **D-to-Q Propagation Delay** | **$t_{pdq}$** | **25.92 ns** | **0.41 ns** | **98.4% Reduction** |
| **D-to-Q Contamination Delay** | **$t_{cdq}$** | **13.64 ns** | **0.30 ns** | **97.8% Reduction** |
| **Setup Time** | **$t_{setup}$** | **-0.17 ns** | **-0.17 ns** | No Change (Intrinsic) |
| **Hold Time** | **$t_{hold}$** | **-0.13 ns** | **-0.13 ns** | No Change (Intrinsic) |
| **Setup Slack** (at Output) | **-** | **-37.94 ns (VIOLATED)** | **-5.50 ns (VIOLATED)** | Improved by 32.44 ns |

---

## 2. Analysis of Changes

### A. Huge Reduction in Delay ($t_{pdq}$ / $t_{cdq}$)
*   **Observation:** The propagation delay dropped significantly from ~26ns to ~0.4ns.
*   **Reason:** The Latch output driver no longer needs to charge a massive capacitor. It is now operating within its optimal range (lookup table range).
*   **Evidence:**
    *   *Old:* `Rise Delay = 25.9169` (Extrapolated from large load)
    *   *New:* `Rise Delay = 0.4093` (Interpolated from small load table)

### B. Setup & Hold Times remain constant
*   **Observation:** $t_{setup}$ and $t_{hold}$ are identical in both reports (-0.17 / -0.13).
*   **Reason:** These are intrinsic characteristics of the Latch input stage relative to the Clock pin. Changing the **Output Load** does not affect the physics of the **Input Stage** latching data.

### C. Why is there still a Setup Violation? (-5.50 ns)
Even with the light load, the Setup Slack is still negative (-5.50 ns). Let's analyze the new path:
*   **Launch Path:**
    *   Clock Fall (Open): 25.00 ns
    *   Latch Delay ($t_{pdq}$): **0.48 ns** (Fast!)
    *   Arrival Time: **25.50 ns**
*   **Capture Path:**
    *   Clock Rise (Close): 50.00 ns
    *   Output External Delay: **-30.00 ns** (This is the culprit!)
    *   Required Time: 50.00 - 30.00 = **20.00 ns**
*   **Calculation:**
    *   Slack = Required (20.00) - Arrival (25.50) = **-5.50 ns**
*   **Conclusion:** The Latch itself is now fast enough. The violation is caused by an extremely tight **Output External Delay constraint (30ns)** defined in the SDC file, which demands the data to be ready *very early* (relative to the 50ns clock).

---

## 3. Detailed Data for Light Load (0.01pF)

### $t_{pdq}$ (Max Delay)
*   **Source:** `latch/paths.rpt` - `report_delay_calculation -max`
*   **Value:** **0.409 ns** (Rise)
```text
 Rise Delay
   cell delay = 0.409346 (in library unit)
     Table is indexed by ... (Y) output_net_total_cap = 0.0103305
```

### $t_{cdq}$ (Min Delay)
*   **Source:** `latch/paths.rpt` - `report_delay_calculation -min`
*   **Value:** **0.300 ns** (Fall)
```text
 Fall Delay
   cell delay = 0.300471 (in library unit)
```

### Setup / Hold
*   **Setup:** -0.17 ns (`library setup time`)
*   **Hold:** -0.13 ns (`library hold time`)
