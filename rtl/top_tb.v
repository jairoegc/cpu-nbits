module top_tb;

    logic clk, rst;
    logic [6:0] cmdin;
    logic signed [7:0] din_1, din_2, din_3;
    logic signed [7:0] dout_low, dout_high;
    logic zero, error;

    top #(8) DUT (clk, rst, cmdin, din_1, din_2, din_3, dout_low, dout_high, zero, error);

    initial
    begin
        $monitor("Time: %t, clk: %d, rst: %d, cmdin: %b, din_1: %d, din_2: %d, din_3: %d, dout_low: %d, dout_high: %d, zero: %d, error: %d", $time, clk, rst, cmdin, din_1, din_2, din_3, dout_low, dout_high, zero, error);
        rst = 0;
        cmdin = 0;
        din_1 = 10;
        din_2 = 3;
        din_3 = 0;
        #500 $finish;
    end

    initial
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    always@(clk)
    begin
        case ($time)
            30 : cmdin= 7'b0001_0_00; // suma a1 y b2
            50 : cmdin= 7'b0000_1_00; // NOP 100
            90 : cmdin= 7'b0000_1_10; // guarda en memoria
            110 : cmdin= 7'b0000_1_00; // NOP 100
            150 : cmdin= 7'b0111_0_10; // multiplica a2 y b4
            170 : cmdin= 7'b0000_1_00; // NOP 100
            210 : cmdin= 7'b0000_1_01; // lee memoria
            230 : cmdin= 7'b0000_1_00; // NOP 100
            270 : cmdin= 7'b1110_0_11; // Dision por cero
            290 : cmdin= 7'b0000_1_00; // NOP 100
            330 : cmdin= 7'b0011_0_01; // operación invalida
            350 : cmdin= 7'b0000_1_00; // NOP 100
            390 : cmdin= 7'b1010_0_01; // resultado 0
            410 : cmdin= 7'b0000_1_00; // NOP 100
            450 : rst = 1; // Reset global
            470 : rst = 0; // Reset global
        endcase
    end

    
endmodule