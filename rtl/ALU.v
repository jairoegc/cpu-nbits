/*
ALU #(WIDTH = 8) U1 (
    .in1(), // WIDTH bits
    .in2(), // WIDTH bits
    .op(),  // 2 bits
    .invalid_data(),
    .out(), // 2*WIDTH
    .zero(),
    .error()
);
*/

module ALU #(
    parameter WIDTH = 8
)(
    input logic signed [WIDTH-1:0] in1, in2,
    input logic [1:0] op,
    input logic invalid_data,
    output logic signed [2*WIDTH-1:0] out,
    output logic zero,
    output logic error
);

//Error
always_comb
begin
    if (invalid_data || ((op==2'b11)&&(in2==0))) //error al dividir por negativos
        error = 1;
    else
        error = 0;
end

//Operation
always_comb
begin
    case (op)
        2'b00: out = (!error)?in1+in2:-1;
        2'b01: out = (!error)?in1-in2:-1;
        2'b10: out = (!error)?in1*in2:-1;
        2'b11: out = (!error)?in1/in2:-1; 
        default: out = -1;
    endcase
end

//Zero
always_comb
begin
    if (out==0)
        zero = 1;
    else
        zero = 0;
end


endmodule