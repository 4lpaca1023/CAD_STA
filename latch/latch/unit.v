module simple (
inp1,
tau2015_clk,
out
);

// Start PIs
input inp1;
input tau2015_clk;

// Start POs
output out;

// Start wires
wire inp1;
wire inp2;
wire tau2015_clk;
wire out;

// Start cells
sky130_fd_sc_hd__dlxtn_1 l1 ( .D(inp1), .GATE_N(tau2015_clk), .Q(out));

endmodule

