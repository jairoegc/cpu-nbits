module ALU_tb;

logic signed [7:0] in1, in2;
logic [1:0] op;
logic invalid_data, zero, error;
logic signed [15:0] out;

ALU #(8) U3 (in1, in2, op, invalid_data, out, zero, error);


initial
begin
    $monitor("Time: %t, in1: %d, in2: %d, op: %d, invalid_data: %b, zero: %b, error: %b, out: %d", $time, in1, in2, op, invalid_data, zero, error, out);    
    in1 = 0;
    in2 = 0;
    op = 1;
    invalid_data = 0;
    #10 op = 1; in1 = 15; in2 = 15; // suma normal
    #20 op = 1; in1 = 255; in2 = 255; // suma grande
    #30 op = 2; in1 = 10; in2 = 5;// resta, resultado positivo
    #40 op = 2; in1 = 30; in2 = 60;// resta, resultado negativo
    #50 op = 2; in1 = 255; in2 = 255;// resta, resultado cero
    #60 invalid_data = 1; op = 4; in1 = 10; in2 = -10;// invalid data
    #70 invalid_data = 0; op = 3; in1 = 255; in2 = 255;// multiplicación positiva grande
    #80 op = 4; in1 = 10; in2 = -10;// multiplicación negativa
    #90 op = 4; in1 = 25; in2 = -5;// division exacta
    #100 op = 4; in1 = 13; in2 = 3;// division inexacta
    #110 op = 4; in1 = 10; in2 = 0;// division por cero
end


endmodule