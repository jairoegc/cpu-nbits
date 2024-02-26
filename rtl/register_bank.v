/*
register_bank U1 #(WIDTH = 8)(
	.clk(),
	.rst(),
	.wr_en(),
	.in(),	//WIDTH bits
	.out()	//WIDTH bits
);
*/
module register_bank #(
	parameter WIDTH = 8
	)(
	input logic clk,
	input logic rst,
	input logic wr_en,
	input logic [WIDTH-1:0] in,
	output logic [WIDTH-1:0] out
);


//logic [WIDTH-1:0] out_next;



always_ff@(posedge clk or posedge rst)
begin
	if (rst)
		out <= 'd0;
	else if (wr_en)
		out <= in;
	else
		out <= out;
end

//assign out = out_next;

endmodule