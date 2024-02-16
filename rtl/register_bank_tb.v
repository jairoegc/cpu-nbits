module register_bank_tb;

logic clk, rst, wr_en;
logic [7:0] in, out;

register_bank #(8) U2 (clk, rst, wr_en, in, out);

initial
begin
	$monitor("Time: %t, clk: %d, rst: %d, wr_en: %d, In: %b, Out: %b", $time, clk, rst, wr_en, in, out);
	clk = 0;
	rst = 0;
	wr_en = 0;
	in = 0;
	#10 clk = 1;
	#10 clk = 0;
	#10 clk = 1; in = {$random} % 15;
	#10 clk = 0;
	#10 clk = 1; in = 'd0;
	#10 clk = 0;
	#10 clk = 1; wr_en = 1; in = {$random} % 15;
	#10 clk = 0;
	#10 clk = 1; wr_en = 0; in = 'd0;
	#10 clk = 0;
	#10 clk = 1;
	#10 clk = 0;
	#10 clk = 1;rst = 1;
	#10 clk = 0;
	#10 clk = 1;rst=0;
	#10 clk = 0;
	#10 clk = 1;
	#10 clk = 0;
end

endmodule