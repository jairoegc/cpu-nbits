module control_tb;

    logic clk, rst, p_error;
    logic [6:0] cmd_in;
    logic aluin_reg_en, datain_reg_en, aluout_reg_en;
    logic memoryWrite, memoryRead, selmux2;
    logic invalid_data;
    logic [1:0] in_select_a, in_select_b;
    logic [1:0] opcode;

    control DUT (clk, rst, p_error, cmd_in, aluin_reg_en, datain_reg_en, aluout_reg_en, memoryWrite, memoryRead, selmux2, invalid_data, in_select_a, in_select_b, opcode);

    initial
    begin
        $monitor("Time: %t, clk: %d, rst: %d, ee: %d, cmd_in: %b, aluin_en: %d, datain_en: %d, aluout_en: %d, W: %d, R: %d, selmux: %d, invalid: %d, sel_a: %b, sel_B: %b, op: %b", $time, clk, rst, p_error, cmd_in, aluin_reg_en, datain_reg_en, aluout_reg_en, memoryWrite, memoryRead, selmux2, invalid_data, in_select_a, in_select_b, opcode);
        rst = 0;
        p_error = 0;
        cmd_in = 'd0;
        #2500 $finish;
    end

    always@(clk)
    begin
        case ($time)
            10 : cmd_in= 7'b0000_0_00; // suma a0 y b0
            110 : cmd_in= 7'b0101_0_00; // suma a1 y b1
            210 : cmd_in= 7'b1010_0_00; // suma a2 y b2
            310 : cmd_in= 7'b1111_0_00; // suma a3 y b3
            410 : cmd_in= 7'b0000_0_01; // resta a0 y b0
            510 : cmd_in= 7'b0101_0_01; // resta a1 y b1
            610 : cmd_in= 7'b1010_0_01; // resta a2 y b2
            710 : cmd_in= 7'b1111_0_01; // resta a3 y b3
            810 : cmd_in= 7'b0000_0_10; // multiplicación a0 y b0
            910 : cmd_in= 7'b0101_0_10; // multiplicación a1 y b1
            1010 : cmd_in= 7'b1010_0_10; // multiplicación a2 y b2
            1110 : cmd_in= 7'b1111_0_10; // multiplicación a3 y b3
            1210 : cmd_in= 7'b0000_0_11; // división a0 y b0
            1310 : cmd_in= 7'b0101_0_11; // división a1 y b1
            1410 : cmd_in= 7'b1010_0_11; // división a2 y b2
            1510 : cmd_in= 7'b1111_0_11; // división a3 y b3
            1610 : cmd_in= 7'b0000_1_00; // NOP 100
            1710 : cmd_in= 7'b0000_1_01; // Leer
            1810 : cmd_in= 7'b0000_1_10; // Escribir
            1910 : cmd_in= 7'b0000_0_00; // NOP 111
        endcase
    end

    initial
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

endmodule