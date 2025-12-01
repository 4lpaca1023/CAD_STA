# unit without spef
## openSTA
Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Endpoint: out (output port clocked by tau2015_clk)
Path Group: tau2015_clk
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00 v f1/CLK (DFFNEGX1)
   0.14   25.14 ^ f1/Q (DFFNEGX1)
   0.05   25.20 v u2/Y (INVX1)
   3.51   28.71 ^ u3/Y (INVX2)
   0.00   28.71 ^ out (out)
          28.71   data arrival time

  50.00   50.00   clock tau2015_clk (rise edge)
   0.00   50.00   clock network delay (ideal)
   0.00   50.00   clock reconvergence pessimism
 -30.00   20.00   output external delay
          20.00   data required time
---------------------------------------------------------
          20.00   data required time
         -28.71   data arrival time
---------------------------------------------------------
          -8.71   slack (VIOLATED)


Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
Path Group: tau2015_clk
Path Type: min

  Delay    Time   Description
---------------------------------------------------------
  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00 v f1/CLK (DFFNEGX1)
   0.13   25.13 v f1/Q (DFFNEGX1)
   0.05   25.18 ^ u4/Y (NOR2X1)
   0.00   25.18 ^ f1/D (DFFNEGX1)
          25.18   data arrival time

  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00   clock reconvergence pessimism
          25.00 v f1/CLK (DFFNEGX1)
   0.04   25.04   library hold time
          25.04   data required time
---------------------------------------------------------
          25.04   data required time
         -25.18   data arrival time
---------------------------------------------------------
           0.14   slack (MET)

## openTimer
Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.144      25.144       0.142  rise  f1:Q (DFFNEGX1)
        pin       0.000      25.144       0.000  rise  u2:A (INVX1)
        pin       0.054      25.198       0.009  fall  u2:Y (INVX1)
        pin       0.000      25.198       0.000  fall  u3:A (INVX2)
        pin       3.513      28.711       0.074  rise  u3:Y (INVX2)
       port       0.000      28.711       0.000  rise  out
    arrival                  28.711        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                  -8.711        VIOLATED

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.134      25.134       0.136  fall  f1:Q (DFFNEGX1)
        pin       0.000      25.134       0.000  fall  u2:A (INVX1)
        pin       0.063      25.196       0.023  rise  u2:Y (INVX1)
        pin       0.000      25.196       0.000  rise  u3:A (INVX2)
        pin       3.197      28.394       0.001  fall  u3:Y (INVX2)
       port       0.000      28.394       0.000  fall  out
    arrival                  28.394        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                  -8.394        VIOLATED

Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.134      25.134       0.136  fall  f1:Q (DFFNEGX1)
        pin       0.000      25.134       0.000  fall  u2:A (INVX1)
        pin       0.063      25.196       0.023  rise  u2:Y (INVX1)
        pin       0.000      25.196       0.000  rise  u3:A (INVX2)
        pin       3.197      28.394       0.001  fall  u3:Y (INVX2)
       port       0.000      28.394       0.000  fall  out
    arrival                  28.394        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  18.394        MET

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.144      25.144       0.142  rise  f1:Q (DFFNEGX1)
        pin       0.000      25.144       0.000  rise  u2:A (INVX1)
        pin       0.054      25.198       0.009  fall  u2:Y (INVX1)
        pin       0.000      25.198       0.000  fall  u3:A (INVX2)
        pin       3.513      28.711       0.074  rise  u3:Y (INVX2)
       port       0.000      28.711       0.000  rise  out
    arrival                  28.711        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  18.711        MET


## prine time
**只有最糟的兩條**
  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: out (output port clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: max

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.14      25.14 r
  n3 (net)                       2
  u2/A (INVX1)                             0.00      25.14 r
  u2/Y (INVX1)                             0.05      25.20 f
  n4 (net)                       1
  u3/A (INVX2)                             0.00      25.20 f
  u3/Y (INVX2)                             3.51      28.71 r
  out (net)                      1
  out (out)                                0.00      28.71 r
  data arrival time                                  28.71

  clock tau2015_clk (rise edge)           50.00      50.00
  clock network delay (ideal)              0.00      50.00
  clock reconvergence pessimism            0.00      50.00
  output external delay                  -30.00      20.00
  data required time                                 20.00
  ---------------------------------------------------------------
  data required time                                 20.00
  data arrival time                                 -28.71
  ---------------------------------------------------------------
  slack (VIOLATED)                                   -8.71

  Startpoint: inp1 (input port clocked by tau2015_clk)
  Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: max

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (rise edge)            0.00       0.00
  clock network delay (ideal)              0.00       0.00
  input external delay                     5.00       5.00 f
  inp1 (in)                                0.00       5.00 f
  inp1 (net)                     1
  u1/A (NAND2X1)                           0.00       5.00 f
  u1/Y (NAND2X1)                           0.06       5.06 r
  n1 (net)                       1
  u4/A (NOR2X1)                            0.00       5.06 r
  u4/Y (NOR2X1)                            0.06       5.12 f
  n2 (net)                       1
  f1/D (DFFNEGX1)                          0.00       5.12 f
  data arrival time                                   5.12

  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                                  25.00 f
  clock reconvergence pessimism            0.00      25.00
  library setup time                      -0.19      24.81
  data required time                                 24.81
  ---------------------------------------------------------------
  data required time                                 24.81
  data arrival time                                  -5.12
  ---------------------------------------------------------------
  slack (MET)                                        19.70

  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: min

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.13      25.13 f
  n3 (net)                       2
  u4/B (NOR2X1)                            0.00      25.13 f
  u4/Y (NOR2X1)                            0.05      25.18 r
  n2 (net)                       1
  f1/D (DFFNEGX1)                          0.00      25.18 r
  data arrival time                                  25.18

  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                                  25.00 f
  clock reconvergence pessimism            0.00      25.00
  library hold time                        0.05      25.05
  data required time                                 25.05
  ---------------------------------------------------------------
  data required time                                 25.05
  data arrival time                                 -25.18
  ---------------------------------------------------------------
  slack (MET)                                         0.13

  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: out (output port clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: min

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.13      25.13 f
  n3 (net)                       2
  u2/A (INVX1)                             0.00      25.13 f
  u2/Y (INVX1)                             0.06      25.19 r
  n4 (net)                       1
  u3/A (INVX2)                             0.00      25.19 r
  u3/Y (INVX2)                             3.20      28.39 f
  out (net)                      1
  out (out)                                0.00      28.39 f
  data arrival time                                  28.39

  clock tau2015_clk (rise edge)            0.00       0.00
  clock network delay (ideal)              0.00       0.00
  clock reconvergence pessimism            0.00       0.00
  output external delay                   10.00      10.00
  data required time                                 10.00
  ---------------------------------------------------------------
  data required time                                 10.00
  data arrival time                                 -28.39
  ---------------------------------------------------------------
  slack (MET)                                        18.39

# unit with spef
## openSTA
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
   0.39   25.54 v u2/Y (INVX1)
   2.37   27.91 ^ u3/Y (INVX2)
   4.78   32.69 ^ out (out)
          32.69   data arrival time

  50.00   50.00   clock tau2015_clk (rise edge)
   0.00   50.00   clock network delay (ideal)
   0.00   50.00   clock reconvergence pessimism
 -30.00   20.00   output external delay
          20.00   data required time
---------------------------------------------------------
          20.00   data required time
         -32.69   data arrival time
---------------------------------------------------------
         -12.69   slack (VIOLATED)


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
   0.64   25.78 ^ u4/Y (NOR2X1)
   0.03   25.81 ^ f1/D (DFFNEGX1)
          25.81   data arrival time

  25.00   25.00   clock tau2015_clk (fall edge)
   0.00   25.00   clock network delay (ideal)
   0.00   25.00   clock reconvergence pessimism
          25.00 v f1/CLK (DFFNEGX1)
  -0.08   24.92   library hold time
          24.92   data required time
---------------------------------------------------------
          24.92   data required time
         -25.81   data arrival time
---------------------------------------------------------
           0.90   slack (MET)

## openTimer
Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.274      25.274       0.145  rise  f1:Q (DFFNEGX1)
        pin       0.342      25.616       0.000  rise  u2:A (INVX1)
        pin       0.093      25.709       0.004  fall  u2:Y (INVX1)
        pin       0.000      25.709       0.000  fall  u3:A (INVX2)
        pin       3.528      29.237       0.062  rise  u3:Y (INVX2)
       port       5.607      34.844       0.000  rise  out
    arrival                  34.844        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                 -14.844        VIOLATED

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : max
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.262      25.262       0.139  fall  f1:Q (DFFNEGX1)
        pin       0.342      25.605       0.000  fall  u2:A (INVX1)
        pin       0.135      25.740       0.037  rise  u2:Y (INVX1)
        pin       0.000      25.740       0.000  rise  u3:A (INVX2)
        pin       3.213      28.953       0.007  fall  u3:Y (INVX2)
       port       5.607      34.560       0.000  fall  out
    arrival                  34.560        data arrival time

       port      20.000      20.000        output port delay
   required                  20.000        data required time
------------------------------------------------------
      slack                 -14.560        VIOLATED

Path 0: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.262      25.262       0.139  fall  f1:Q (DFFNEGX1)
        pin       0.342      25.605       0.000  fall  u2:A (INVX1)
        pin       0.135      25.740       0.037  rise  u2:Y (INVX1)
        pin       0.000      25.740       0.000  rise  u3:A (INVX2)
        pin       3.213      28.953       0.007  fall  u3:Y (INVX2)
       port       5.607      34.560       0.000  fall  out
    arrival                  34.560        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  24.560        MET

Path 1: Startpoint    : f1:CLK
Endpoint      : out
Analysis type : min
------------------------------------------------------
       Type       Delay        Time   Dir  Description
------------------------------------------------------
        pin      25.000      25.000       0.000  fall  f1:CLK (DFFNEGX1)
        pin       0.274      25.274       0.145  rise  f1:Q (DFFNEGX1)
        pin       0.342      25.616       0.000  rise  u2:A (INVX1)
        pin       0.093      25.709       0.004  fall  u2:Y (INVX1)
        pin       0.000      25.709       0.000  fall  u3:A (INVX2)
        pin       3.528      29.237       0.062  rise  u3:Y (INVX2)
       port       5.607      34.844       0.000  rise  out
    arrival                  34.844        data arrival time

       port      10.000      10.000        output port delay
   required                  10.000        data required time
------------------------------------------------------
      slack                  24.844        MET

## prine time
**只有最糟的兩條**
  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: out (output port clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: max

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.15 &    25.15 r
  n3 (net)                       2
  u2/A (INVX1)                             0.29 &    25.43 r
  u2/Y (INVX1)                             0.10      25.54 f
  n4 (net)                       1
  u3/A (INVX2)                             0.00      25.54 f
  u3/Y (INVX2)                             0.11 &    25.65 r
  out (net)                      1
  out (out)                                5.67 &    31.31 r
  data arrival time                                  31.31

  clock tau2015_clk (rise edge)           50.00      50.00
  clock network delay (ideal)              0.00      50.00
  clock reconvergence pessimism            0.00      50.00
  output external delay                  -30.00      20.00
  data required time                                 20.00
  ---------------------------------------------------------------
  data required time                                 20.00
  data arrival time                                 -31.31
  ---------------------------------------------------------------
  slack (VIOLATED)                                  -11.31

  Startpoint: inp1 (input port clocked by tau2015_clk)
  Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: max

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (rise edge)            0.00       0.00
  clock network delay (ideal)              0.00       0.00
  input external delay                     5.00       5.00 f
  inp1 (in)                                0.00 &     5.00 f
  inp1 (net)                     1
  u1/A (NAND2X1)                           0.31 &     5.31 f
  u1/Y (NAND2X1)                           0.20 &     5.52 r
  n1 (net)                       1
  u4/A (NOR2X1)                            0.04 &     5.56 r
  u4/Y (NOR2X1)                            0.10 &     5.66 f
  n2 (net)                       1
  f1/D (DFFNEGX1)                          0.03 &     5.69 f
  data arrival time                                   5.69

  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                                  25.00 f
  clock reconvergence pessimism            0.00      25.00
  library setup time                      -0.18      24.82
  data required time                                 24.82
  ---------------------------------------------------------------
  data required time                                 24.82
  data arrival time                                  -5.69
  ---------------------------------------------------------------
  slack (MET)                                        19.13

  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: min

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.14 &    25.14 f
  n3 (net)                       2
  u4/B (NOR2X1)                            0.51 &    25.65 f
  u4/Y (NOR2X1)                            0.08 &    25.73 r
  n2 (net)                       1
  f1/D (DFFNEGX1)                          0.03 &    25.75 r
  data arrival time                                  25.75

  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                                  25.00 f
  clock reconvergence pessimism            0.00      25.00
  library hold time                        0.00      25.00
  data required time                                 25.00
  ---------------------------------------------------------------
  data required time                                 25.00
  data arrival time                                 -25.75
  ---------------------------------------------------------------
  slack (MET)                                         0.75

  Startpoint: f1 (falling edge-triggered flip-flop clocked by tau2015_clk)
  Endpoint: out (output port clocked by tau2015_clk)
  Path Group: tau2015_clk
  Path Type: min

  Point                       Fanout       Incr       Path
  ---------------------------------------------------------------
  clock tau2015_clk (fall edge)           25.00      25.00
  clock network delay (ideal)              0.00      25.00
  f1/CLK (DFFNEGX1)                        0.00      25.00 f
  f1/Q (DFFNEGX1)                          0.14 &    25.14 f
  n3 (net)                       2
  u2/A (INVX1)                             0.28 &    25.42 f
  u2/Y (INVX1)                             0.08      25.49 r
  n4 (net)                       1
  u3/A (INVX2)                             0.00      25.49 r
  u3/Y (INVX2)                             0.05 &    25.55 f
  out (net)                      1
  out (out)                                5.39 &    30.94 f
  data arrival time                                  30.94

  clock tau2015_clk (rise edge)            0.00       0.00
  clock network delay (ideal)              0.00       0.00
  clock reconvergence pessimism            0.00       0.00
  output external delay                   10.00      10.00
  data required time                                 10.00
  ---------------------------------------------------------------
  data required time                                 10.00
  data arrival time                                 -30.94
  ---------------------------------------------------------------
  slack (MET)                                        20.94
