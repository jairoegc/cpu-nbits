/*
mux4_registered #(WIDTH=8) U1 (
	.clk(),
	.rst(),
	.wr_en(),
	.sel(),	// 2 bits
	.in1(),	// WIDTH bits
	.in2(),	// WIDTH bits
	.in3(),	// WIDTH bits
	.in4(),	// WIDTH bits
	.out()	// WIDTH bits
);
*/

module mux4_registered #(
	parameter WIDTH=8
	)(
	input logic clk, rst, wr_en,
	input logic [1:0] sel,
	input logic [WIDTH-1:0] in1, in2, in3, in4,
	output logic [WIDTH-1:0] out
);

logic [WIDTH-1:0] mux4_out;

mux4 #(WIDTH) U1 (.din1(in1),.din2(in2),.din3(in3),.din4(in4),.select(sel),.dout(mux4_out));

register_bank #(WIDTH) U2 (clk, rst, wr_en, mux4_out, out);

endmodule


