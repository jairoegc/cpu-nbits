/*
control U1 (
    .clk(),
    .rst(),
    .p_error(),
    .cmd_in(cmdin), // 7 bits
    .aluin_reg_en(),
    .datain_reg_en(),
    .aluout_reg_en(),
    .memoryWrite(),
    .memoryRead(),
    .selmux2(),
    .invalid_data(),
    .in_select_a(), // 2 bits
    .in_select_b(), // 2 bits
    .opcode()       // 2 bits
);
*/

module control (
    input logic clk, rst, p_error,
    input logic [6:0] cmd_in,
    output logic aluin_reg_en, datain_reg_en, aluout_reg_en,
    output logic memoryWrite, memoryRead, selmux2,
    output logic invalid_data,
    output logic [1:0] in_select_a, in_select_b,
    output logic [1:0] opcode
);

    //FSM

    typedef enum logic [1:0]{INIT,FETCH,EXECUTE,STORE} state_type;

    state_type state, nextstate;

    always_comb
        case (state)
            INIT: nextstate = FETCH;
            FETCH: nextstate = EXECUTE;
            EXECUTE: nextstate = STORE;
            STORE: nextstate = FETCH;
            default: nextstate = INIT;
        endcase

    always_ff@(posedge clk or posedge rst)
        if(rst)
            state <= INIT;
        else
            state <= nextstate;

    //output logic
    always_comb
        case (state)
            INIT:   begin
                        aluin_reg_en = 1'b0;
                        aluout_reg_en = 1'b0;
                        datain_reg_en = 1'b1; //store cmd_ind
                        memoryWrite = 1'b0;
                        memoryRead = 1'b0;
                        selmux2 = 1'd0;
                        invalid_data = 1'd0;
                        in_select_a = 2'd0;
                        in_select_b = 2'd0;
                        opcode = 2'd0;
                    end
            FETCH:  begin
                        aluin_reg_en = ((cmd_in==3'b111)||(cmd_in==3'b100))?1'b0:1'b1; //NOP conditional
                        aluout_reg_en = 1'b0;
                        datain_reg_en = 1'b0;
                        memoryWrite = 1'b0;
                        memoryRead = 1'b0;
                        selmux2 = 1'd0;
                        invalid_data = 1'd0;
                        in_select_a = cmd_in[6:5];
                        in_select_b = cmd_in[4:3];
                        opcode = 2'd0;
                    end
            EXECUTE:begin
                        if (!cmd_in[2]) //ALU
                        begin
                            aluin_reg_en = 1'b0;
                            aluout_reg_en = ((cmd_in[2:0]==3'b111)||(cmd_in[2:0]==3'b100))?1'b0:1'b1; //NOP conditional
                            datain_reg_en = 1'b0;
                            memoryWrite = 1'b0;
                            memoryRead = 1'b0;
                            selmux2 = 1'd0;
                            invalid_data = ((cmd_in[6:5]==2'b11)||(cmd_in[4:3]==2'b11))?p_error:1'b0;
                            in_select_a = 2'd0;
                            in_select_b = 2'd0;
                            opcode = cmd_in[1:0];
                        end
                        else
                        begin
                            if (cmd_in[2:0]==3'b111 || cmd_in[2:0]==3'b100) //NOP
                            begin
                                aluin_reg_en = 1'b0;
                                aluout_reg_en = 1'b0;
                                datain_reg_en = 1'b0;
                                memoryWrite = 1'd0;
                                memoryRead = 1'd0;
                                selmux2 = 1'd0;
                                invalid_data = 1'b0;
                                in_select_a = 2'd0;
                                in_select_b = 2'd0;
                                opcode = 2'd0;
                            end
                            else
                            begin //memory
                                aluin_reg_en = 1'b0;
                                aluout_reg_en = ((cmd_in[2:0]==3'b111)||(cmd_in[2:0]==3'b100)||cmd_in[1])?1'b0:1'b1; //NOP conditional or write
                                datain_reg_en = 1'b0;
                                memoryWrite = cmd_in[1];
                                memoryRead = cmd_in[0];
                                selmux2 = 1'b1;
                                invalid_data = 1'b0;
                                in_select_a = 2'd0;
                                in_select_b = 2'd0;
                                opcode = 2'd0;
                            end
                        end
                    end
            STORE:  begin
                        aluin_reg_en = 1'b0;
                        aluout_reg_en = 1'b0;
                        datain_reg_en = 1'b1; //store cmd_ind
                        memoryWrite = 1'b0;
                        memoryRead = 1'b0;
                        selmux2 = 1'd0;
                        invalid_data = 1'd0;
                        in_select_a = 2'd0;
                        in_select_b = 2'd0;
                        opcode = 2'd0;
                    end      
            default:begin
                        aluin_reg_en = 1'b0;
                        aluout_reg_en = 1'b0;
                        datain_reg_en = 1'b1; //store cmd_ind
                        memoryWrite = 1'b0;
                        memoryRead = 1'b0;
                        selmux2 = 1'd0;
                        invalid_data = 1'd0;
                        in_select_a = 2'd0;
                        in_select_b = 2'd0;
                        opcode = 2'd0;
                    end
        endcase
            

endmodule