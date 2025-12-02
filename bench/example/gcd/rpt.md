## pt

  Startpoint: _414_ (rising edge-triggered flip-flop clocked by clk)
  Endpoint: _418_ (rising edge-triggered flip-flop clocked by clk)
  Path Group: clk
  Path Type: max

  Point                                      Fanout       Incr       Path
  ------------------------------------------------------------------------------
  clock clk (rise edge)                                   0.00       0.00
  clock network delay (ideal)                             0.00       0.00
  _414_/CLK (sky130_fd_sc_hd__dfxtp_4)                    0.00       0.00 r
  _414_/Q (sky130_fd_sc_hd__dfxtp_4)                      0.32 &     0.32 f
  dpath.a_lt_b$in1[0] (net)                     3
  _214_/B_N (sky130_fd_sc_hd__nor2b_4)                    0.00 &     0.32 f
  _214_/Y (sky130_fd_sc_hd__nor2b_4)                      0.12 &     0.45 f
  _052_ (net)                                   2
  _215_/C (sky130_fd_sc_hd__maj3_2)                       0.00 &     0.45 f
  _215_/X (sky130_fd_sc_hd__maj3_2)                       0.32 &     0.77 f
  _053_ (net)                                   2
  _216_/C (sky130_fd_sc_hd__maj3_2)                       0.00 &     0.77 f
  _216_/X (sky130_fd_sc_hd__maj3_2)                       0.33 &     1.10 f
  _054_ (net)                                   2
  _217_/C (sky130_fd_sc_hd__maj3_2)                       0.00 &     1.10 f
  _217_/X (sky130_fd_sc_hd__maj3_2)                       0.36 &     1.46 f
  _055_ (net)                                   2
  _218_/C (sky130_fd_sc_hd__maj3_2)                       0.00 &     1.46 f
  _218_/X (sky130_fd_sc_hd__maj3_2)                       0.38 &     1.84 f
  _056_ (net)                                   2
  _219_/C (sky130_fd_sc_hd__maj3_2)                       0.00 &     1.84 f
  _219_/X (sky130_fd_sc_hd__maj3_2)                       0.40 &     2.23 f
  _057_ (net)                                   3
  _222_/A2 (sky130_fd_sc_hd__o211ai_4)                    0.00 &     2.23 f
  _222_/Y (sky130_fd_sc_hd__o211ai_4)                     0.25 &     2.48 r
  _060_ (net)                                   3
  _225_/A3 (sky130_fd_sc_hd__a311oi_4)                    0.00 &     2.48 r
  _225_/Y (sky130_fd_sc_hd__a311oi_4)                     0.16 &     2.64 f
  _063_ (net)                                   4
  _228_/A3 (sky130_fd_sc_hd__o311ai_4)                    0.00 &     2.64 f
  _228_/Y (sky130_fd_sc_hd__o311ai_4)                     0.34 &     2.98 r
  _066_ (net)                                   3
  _231_/A3 (sky130_fd_sc_hd__a311oi_4)                    0.00 &     2.98 r
  _231_/Y (sky130_fd_sc_hd__a311oi_4)                     0.17 &     3.15 f
  _069_ (net)                                   2
  _292_/A3 (sky130_fd_sc_hd__o311a_2)                     0.00 &     3.15 f
  _292_/X (sky130_fd_sc_hd__o311a_2)                      0.43 &     3.58 f
  _110_ (net)                                   3
  _295_/A3 (sky130_fd_sc_hd__o31ai_4)                     0.00 &     3.58 f
  _295_/Y (sky130_fd_sc_hd__o31ai_4)                      0.73 &     4.31 r
  _113_ (net)                                  11
  split1/A (sky130_fd_sc_hd__buf_4)                       0.00 &     4.31 r
  split1/X (sky130_fd_sc_hd__buf_4)                       0.37 &     4.68 r
  net1 (net)                                   10
  _316_/A2 (sky130_fd_sc_hd__a221oi_1)                    0.00 &     4.68 r
  _316_/Y (sky130_fd_sc_hd__a221oi_1)                     0.11 &     4.79 f
  _007_ (net)                                   1
  _418_/D (sky130_fd_sc_hd__dfxtp_1)                      0.00 &     4.79 f
  data arrival time                                                  4.79

  clock clk (rise edge)                                   5.00       5.00
  clock network delay (ideal)                             0.00       5.00
  _418_/CLK (sky130_fd_sc_hd__dfxtp_1)                               5.00 r
  clock reconvergence pessimism                           0.00       5.00
  library setup time                                     -0.16       4.84
  data required time                                                 4.84
  ------------------------------------------------------------------------------
  data required time                                                 4.84
  data arrival time                                                 -4.79
  ------------------------------------------------------------------------------
  slack (MET)                                                        0.04

  Startpoint: _412_ (rising edge-triggered flip-flop clocked by clk)
  Endpoint: _412_ (rising edge-triggered flip-flop clocked by clk)
  Path Group: clk
  Path Type: min

  Point                                      Fanout       Incr       Path
  ------------------------------------------------------------------------------
  clock clk (rise edge)                                   0.00       0.00
  clock network delay (ideal)                             0.00       0.00
  _412_/CLK (sky130_fd_sc_hd__dfxtp_1)                    0.00       0.00 r
  _412_/Q (sky130_fd_sc_hd__dfxtp_1)                      0.30 &     0.30 r
  ctrl.state.out[1] (net)                       2
  _290_/B2 (sky130_fd_sc_hd__a32o_1)                      0.00 &     0.30 r
  _290_/X (sky130_fd_sc_hd__a32o_1)                       0.12 &     0.42 r
  _001_ (net)                                   1
  _412_/D (sky130_fd_sc_hd__dfxtp_1)                      0.00 &     0.42 r
  data arrival time                                                  0.42

  clock clk (rise edge)                                   0.00       0.00
  clock network delay (ideal)                             0.00       0.00
  _412_/CLK (sky130_fd_sc_hd__dfxtp_1)                               0.00 r
  clock reconvergence pessimism                           0.00       0.00
  library hold time                                      -0.04      -0.04
  data required time                                                -0.04
  ------------------------------------------------------------------------------
  data required time                                                -0.04
  data arrival time                                                 -0.42
  ------------------------------------------------------------------------------
  slack (MET)                                                        0.46

# opensta
Startpoint: _414_ (rising edge-triggered flip-flop clocked by clk)
Endpoint: _418_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock clk (rise edge)
   0.00    0.00   clock network delay (ideal)
   0.00    0.00 ^ _414_/CLK (sky130_fd_sc_hd__dfxtp_4)
   0.32    0.32 v _414_/Q (sky130_fd_sc_hd__dfxtp_4)
   0.12    0.45 v _214_/Y (sky130_fd_sc_hd__nor2b_4)
   0.32    0.77 v _215_/X (sky130_fd_sc_hd__maj3_2)
   0.32    1.10 v _216_/X (sky130_fd_sc_hd__maj3_2)
   0.36    1.46 v _217_/X (sky130_fd_sc_hd__maj3_2)
   0.38    1.83 v _218_/X (sky130_fd_sc_hd__maj3_2)
   0.40    2.23 v _219_/X (sky130_fd_sc_hd__maj3_2)
   0.25    2.48 ^ _222_/Y (sky130_fd_sc_hd__o211ai_4)
   0.16    2.63 v _225_/Y (sky130_fd_sc_hd__a311oi_4)
   0.34    2.97 ^ _228_/Y (sky130_fd_sc_hd__o311ai_4)
   0.17    3.14 v _231_/Y (sky130_fd_sc_hd__a311oi_4)
   0.43    3.58 v _292_/X (sky130_fd_sc_hd__o311a_2)
   0.72    4.30 ^ _295_/Y (sky130_fd_sc_hd__o31ai_4)
   0.37    4.66 ^ split1/X (sky130_fd_sc_hd__buf_4)
   0.11    4.78 v _316_/Y (sky130_fd_sc_hd__a221oi_1)
   0.00    4.78 v _418_/D (sky130_fd_sc_hd__dfxtp_1)
           4.78   data arrival time

   5.00    5.00   clock clk (rise edge)
   0.00    5.00   clock network delay (ideal)
   0.00    5.00   clock reconvergence pessimism
           5.00 ^ _418_/CLK (sky130_fd_sc_hd__dfxtp_1)
  -0.16    4.84   library setup time
           4.84   data required time
---------------------------------------------------------
           4.84   data required time
          -4.78   data arrival time
---------------------------------------------------------
           0.06   slack (MET)


Startpoint: _412_ (rising edge-triggered flip-flop clocked by clk)
Endpoint: _412_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: min

  Delay    Time   Description
---------------------------------------------------------
   0.00    0.00   clock clk (rise edge)
   0.00    0.00   clock network delay (ideal)
   0.00    0.00 ^ _412_/CLK (sky130_fd_sc_hd__dfxtp_1)
   0.30    0.30 ^ _412_/Q (sky130_fd_sc_hd__dfxtp_1)
   0.12    0.42 ^ _290_/X (sky130_fd_sc_hd__a32o_1)
   0.00    0.42 ^ _412_/D (sky130_fd_sc_hd__dfxtp_1)
           0.42   data arrival time

   0.00    0.00   clock clk (rise edge)
   0.00    0.00   clock network delay (ideal)
   0.00    0.00   clock reconvergence pessimism
           0.00 ^ _412_/CLK (sky130_fd_sc_hd__dfxtp_1)
  -0.04   -0.04   library hold time
          -0.04   data required time
---------------------------------------------------------
          -0.04   data required time
          -0.42   data arrival time
---------------------------------------------------------
           0.45   slack (MET)