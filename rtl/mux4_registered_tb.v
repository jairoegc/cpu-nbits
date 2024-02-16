module mux4_registered_tb;

logic clk, rst, wr_en;
logic [1:0] sel;
logic [7:0] in1, in2, in3, in4, out;

mux4_registered #(8) U3(clk, rst, wr_en, sel, in1, in2, in3, in4, out);

initial
begin
    $monitor("Time: %t, clk: %d, sel: $drst: %d, In1: %d, In2: %d, In3: %d, In4: %d, Out: %d", $time, clk, rst, sel, in1, in2, in3, in4, out);
    rst = 0;
    wr_en = 1;
    sel = 0;
    in1 = 11;
    in2 = 12;
    in3 = 13;
    in4 = 14;
    #300 $finish;
end

always@(clk)
begin
    case ($time)
        20 : sel = 1;
        60 : sel = 2;
        100 : rst = 1;
        120 : rst = 0;
        180 : sel = 3;
        250 : sel = 4;
    endcase
end

initial
begin
    clk = 0;
    forever #10 clk = ~clk;
end

endmodule