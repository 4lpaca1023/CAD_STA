# opensta
OpenSTA 2.7.0 4475f89024 Copyright (c) 2025, Parallax Software, Inc.
License GPLv3: GNU GPL version 3 <http://gnu.org/licenses/gpl.html>

This is free software, and you are free to change and redistribute it
under certain conditions; type `show_copying' for details. 
This program comes with ABSOLUTELY NO WARRANTY; for details type `show_warranty'.
Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Endpoint: out (output port clocked by tau2015_clk)
Path Group: tau2015_clk
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00 v f1/CLK (DFFNEGX1)
   0.15   25.15 ^ f1/Q (DFFNEGX1)
   0.30   25.45 v u2/Y (INVX1)
   2.37   27.81 ^ u3/Y (INVX2)
   4.78   32.60 ^ out (out)
          32.60   data arrival time

  50.00   50.00   clock tau2015_clk (rise edge)
   0.00   50.00   clock network delay (ideal)
   0.00   50.00   clock reconvergence pessimism
 -30.00   20.00   output external delay
          20.00   data required time
---------------------------------------------------------
          20.00   data required time
         -32.60   data arrival time
---------------------------------------------------------
         -12.60   slack (VIOLATED)


Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Path Group: tau2015_clk
Path Type: min

  Delay    Time   Description
---------------------------------------------------------
  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00 v f1/CLK (DFFNEGX1)
   0.14   25.14 v f1/Q (DFFNEGX1)
   0.55   25.68 ^ u4/Y (NOR2X1)
   0.03   25.71 ^ f1/D (DFFNEGX1)
          25.71   data arrival time

  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00   clock reconvergence pessimism
          25.00 v f1/CLK (DFFNEGX1)
  -0.08   24.92   library hold time
          24.92   data required time
---------------------------------------------------------
          24.92   data required time
         -25.71   data arrival time
---------------------------------------------------------
           0.79   slack (MET)


# opentimer
TNS: -11.2566
WNS: -5.63573
Min WNS: 15.6209
OpenTimer 2.1.0
Time unit        : 1e-09 s
Capacitance unit : 1e-12 F
Voltage unit     : 1 V
Resistance unit  : 1000 Ohm
Current unit     : 1e-06 A
Power unit       : 1e-09 W
Voltage          : 1.8
# Pins           : 18
# POs            : 1
# PIs            : 3
# Gates          : 5
# Nets           : 8
# Arcs           : 28
# SCCs           : 0
# Tests          : 1
# Cells          : 32
------ Report Timing (Max) ------
Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.228      25.228       0.139  fall  f1:Q (DFFNEGX1)
        pin       0.248      25.476       0.000  fall  u2:A (INVX1)
        pin       0.120      25.597       0.033  rise  u2:Y (INVX1)
        pin       0.000      25.597       0.000  rise  u3:A (INVX2)
        pin       0.032      25.629       0.016  fall  u3:Y (INVX2)
       port       0.007      25.636       0.000  fall  out
    arrival                  25.636        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                  -5.636        VIOLATED

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.239      25.239       0.144  rise  f1:Q (DFFNEGX1)
        pin       0.248      25.487       0.000  rise  u2:A (INVX1)
        pin       0.086      25.573       0.005  fall  u2:Y (INVX1)
        pin       0.000      25.573       0.000  fall  u3:A (INVX2)
        pin       0.041      25.614       0.050  rise  u3:Y (INVX2)
       port       0.007      25.621       0.000  rise  out
    arrival                  25.621        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                  -5.621        VIOLATED

Path 2: Startpoint    : f1:CLK
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.228      25.228       0.139  fall  f1:Q (DFFNEGX1)
        pin       0.481      25.709       0.000  fall  u4:B (NOR2X1)
        pin       0.137      25.847       0.060  rise  u4:Y (NOR2X1)
        pin       0.029      25.876       0.000  rise  f1:D (DFFNEGX1)
    arrival                  25.876        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.181      74.819        library setup_falling
   required                  74.819        data required time
------------------------------------------------------
      slack                  48.943        MET

Path 3: Startpoint    : f1:CLK
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.239      25.239       0.144  rise  f1:Q (DFFNEGX1)
        pin       0.481      25.720       0.000  rise  u4:B (NOR2X1)
        pin       0.121      25.841       0.002  fall  u4:Y (NOR2X1)
        pin       0.029      25.870       0.000  fall  f1:D (DFFNEGX1)
    arrival                  25.870        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.182      74.818        library setup_falling
   required                  74.818        data required time
------------------------------------------------------
      slack                  48.948        MET

Path 4: Startpoint    : inp1
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
       port       5.000       5.000       0.000  fall  inp1
        pin       0.427       5.427       0.000  fall  u1:A (NAND2X1)
        pin       0.182       5.610       0.060  rise  u1:Y (NAND2X1)
        pin       0.043       5.653       0.000  rise  u4:A (NOR2X1)
        pin       0.098       5.750       0.015  fall  u4:Y (NOR2X1)
        pin       0.029       5.779       0.000  fall  f1:D (DFFNEGX1)
    arrival                   5.779        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.182      74.818        library setup_falling
   required                  74.818        data required time
------------------------------------------------------
      slack                  69.039        MET

Path 5: Startpoint    : inp1
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
       port       5.000       5.000       0.000  rise  inp1
        pin       0.430       5.430       0.000  rise  u1:A (NAND2X1)
        pin       0.076       5.505       0.004  fall  u1:Y (NAND2X1)
        pin       0.044       5.549       0.000  fall  u4:A (NOR2X1)
        pin       0.087       5.636       0.067  rise  u4:Y (NOR2X1)
        pin       0.029       5.665       0.000  rise  f1:D (DFFNEGX1)
    arrival                   5.665        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.181      74.819        library setup_falling
   required                  74.819        data required time
------------------------------------------------------
      slack                  69.153        MET

Path 6: Startpoint    : inp2
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
       port       1.000       1.000       0.000  fall  inp2
        pin       0.117       1.117       0.000  fall  u1:B (NAND2X1)
        pin       0.098       1.216       0.036  rise  u1:Y (NAND2X1)
        pin       0.043       1.259       0.000  rise  u4:A (NOR2X1)
        pin       0.098       1.356       0.015  fall  u4:Y (NOR2X1)
        pin       0.029       1.385       0.000  fall  f1:D (DFFNEGX1)
    arrival                   1.385        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.182      74.818        library setup_falling
   required                  74.818        data required time
------------------------------------------------------
      slack                  73.433        MET

Path 7: Startpoint    : inp2
Endpoint      : f1:D
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
       port       1.000       1.000       0.000  rise  inp2
        pin       0.117       1.117       0.000  rise  u1:B (NAND2X1)
        pin       0.069       1.186       0.008  fall  u1:Y (NAND2X1)
        pin       0.044       1.230       0.000  fall  u4:A (NOR2X1)
        pin       0.087       1.317       0.067  rise  u4:Y (NOR2X1)
        pin       0.029       1.346       0.000  rise  f1:D (DFFNEGX1)
    arrival                   1.346        data arrival time

related pin      75.000      75.000  fall  f1:CLK (DFFNEGX1)
 constraint      -0.181      74.819        library setup_falling
   required                  74.819        data required time
------------------------------------------------------
      slack                  73.473        MET

------ Report Timing (Min) ------
Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.239      25.239       0.144  rise  f1:Q (DFFNEGX1)
        pin       0.248      25.487       0.000  rise  u2:A (INVX1)
        pin       0.086      25.573       0.005  fall  u2:Y (INVX1)
        pin       0.000      25.573       0.000  fall  u3:A (INVX2)
        pin       0.041      25.614       0.050  rise  u3:Y (INVX2)
       port       0.007      25.621       0.000  rise  out
    arrival                  25.621        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  15.621        MET

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.228      25.228       0.139  fall  f1:Q (DFFNEGX1)
        pin       0.248      25.476       0.000  fall  u2:A (INVX1)
        pin       0.120      25.597       0.033  rise  u2:Y (INVX1)
        pin       0.000      25.597       0.000  rise  u3:A (INVX2)
        pin       0.032      25.629       0.016  fall  u3:Y (INVX2)
       port       0.007      25.636       0.000  fall  out
    arrival                  25.636        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  15.636        MET

# pt
  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: out (output port clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: max

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.14 &    25.14 r
  n3 (net)                       2
  u2/A (INVX1)                             0.20 &    25.34 r
  u2/Y (INVX1)                             0.09      25.44 f
  n4 (net)                       1
  u3/A (INVX2)                             0.00      25.44 f
  u3/Y (INVX2)                             0.10 &    25.54 r
  out (net)                      1
  out (out)                                5.67 &    31.21 r
  data arrival time                                  31.21

  clock tau2015_clk (rise edge)           50.00      50.00
  clock network delay (ideal)              0.00      50.00
  clock reconvergence pessimism            0.00      50.00
  output external delay                  -30.00      20.00
  data required time                                 20.00
  ---------------------------------------------------------------
  data required time                                 20.00
  data arrival time                                 -31.21
  ---------------------------------------------------------------
  slack (VIOLATED)                                  -11.21
  
  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: min

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.13 &    25.13 f
  n3 (net)                       2
  u4/B (NOR2X1)                            0.43 &    25.56 f
  u4/Y (NOR2X1)                            0.08 &    25.64 r
  n2 (net)                       1
  f1/D (DFFNEGX1)                          0.03 &    25.66 r
  data arrival time                                  25.66

  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                                  25.00 f
  clock reconvergence pessimism            0.00      25.00
  library hold time                       -0.00      25.00
  data required time                                 25.00
  ---------------------------------------------------------------
  data required time                                 25.00
  data arrival time                                 -25.66
  ---------------------------------------------------------------
  slack (MET)                                         0.66
