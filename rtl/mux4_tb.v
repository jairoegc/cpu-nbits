module mux4_tb;

logic [7:0] din1, din2, din3, din4;
logic [1:0] select;
logic [7:0] dout;

mux4 #(8) U1 (.din1(din1),.din2(din2),.din3(din3),.din4(din4),.select(select),.dout(dout));


initial
begin
	$monitor (" Select: %d, dout: %d", select, dout);

	din1 = 8'd1;
	din2 = 8'd2;
	din3 = 8'd3;
	din4 = 8'd4;

	#10 select = 2'd0;
	#10 select = 2'd1;
	#10 select = 2'd2;
	#10 select = 2'd3;
end
endmodule