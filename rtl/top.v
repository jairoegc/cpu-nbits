module top #(
    parameter WIDTH = 8
    )(
    input logic clk, rst,
    input logic [6:0] cmdin,
    input logic [WIDTH-1:0] din_1, din_2, din_3,
    output logic [WIDTH-1:0] dout_low, dout_high,
    output logic zero, error
);

// Nets

logic [6:0] datain;
logic [2*WIDTH-1:0] alu_out_reg;
logic selmux2;
logic [WIDTH-1:0] mux_a_out;
logic [WIDTH-1:0] mux_b_out;
logic [2*WIDTH-1:0] mux2_out;
logic [1:0] opcode;
logic invalid_data;
logic [2*WIDTH-1:0] alu_out;
logic [2*WIDTH-1:0] memoryOutData;
logic [1:0] in_select_a, in_select_b;
logic aluin_reg_en, aluout_reg_en, datain_reg_en, 
        zero_flag, error_flag, zero_flag_out,error_flag_out,
        memoryWrite, memoryRead;

// Assigns

assign zero = zero_flag_out;
assign error = error_flag_out;
assign dout_low = alu_out_reg[WIDTH-1:0];
assign dout_high = alu_out_reg[2*WIDTH-1:WIDTH];


// Control Unit

control ctrl_inst (
    .clk(clk),
    .rst(rst),
    .p_error(error_flag_out),
    .cmd_in(datain), // 7 bits
    .aluin_reg_en(aluin_reg_en),
    .datain_reg_en(datain_reg_en),
    .aluout_reg_en(aluout_reg_en),
    .memoryWrite(memoryWrite),
    .memoryRead(memoryRead),
    .selmux2(selmux2),
    .invalid_data(invalid_data),
    .in_select_a(in_select_a), // 2 bits
    .in_select_b(in_select_b), // 2 bits
    .opcode(opcode)       // 2 bits
);

// Registers

register_bank #(7) datain_reg ( //Fixed width
	.clk(clk),
	.rst(rst),
	.wr_en(datain_reg_en),
	.in(cmdin),	//WIDTH bits
	.out(datain)	//WIDTH bits
);


register_bank #(2*WIDTH) aluout_reg (
	.clk(clk),
	.rst(rst),
	.wr_en(aluout_reg_en),
	.in(mux2_out),	//WIDTH bits
	.out(alu_out_reg)	//WIDTH bits
);

register_bank #(2) flags_reg (
	.clk(clk),
	.rst(rst),
	.wr_en(aluout_reg_en),
	.in({zero_flag,error_flag}),	//WIDTH bits
	.out({zero_flag_out,error_flag_out})	//WIDTH bits
);

// Registered Muxes

mux4_registered #(WIDTH) mux_a_reg (
	.clk(clk),
	.rst(rst),
	.wr_en(aluin_reg_en),
	.sel(in_select_a),	// 2 bits
	.in1(din_1),	// WIDTH bits
	.in2(din_2),	// WIDTH bits
	.in3(din_3),	// WIDTH bits
	.in4(alu_out_reg[2*WIDTH-1:WIDTH]),	// WIDTH bits, alu_out_reg HIGH
	.out(mux_a_out)	// WIDTH bits
);

mux4_registered #(WIDTH) mux_b_reg (
	.clk(clk),
	.rst(rst),
	.wr_en(aluin_reg_en),
	.sel(in_select_b),	// 2 bits
	.in1(din_1),	// WIDTH bits
	.in2(din_2),	// WIDTH bits
	.in3(din_3),	// WIDTH bits
	.in4(alu_out_reg[WIDTH-1:0]),	// WIDTH bits, alu_out_reg LOW
	.out(mux_b_out)	// WIDTH bits
);

// Mux2
assign mux2_out = (selmux2)?alu_out:memoryOutData;

/* 
mux4 #(2*WIDTH) mux2 (
	.din1(alu_out),	// WIDTH bits
	.din2(memoryOutData),	// WIDTH bits
	.din3('d0),	// WIDTH bits
	.din4('d0),	// WIDTH bits
	.select({1'b0,selmux2}),	// 2 bits
	.dout(mux2_out)		// WIDTH bits
); */

// ALU

ALU #(WIDTH) ALU_inst (
    .in1(mux_a_out), // WIDTH bits
    .in2(mux_b_out), // WIDTH bits
    .op(opcode),  // 2 bits
    .invalid_data(invalid_data),
    .out(alu_out), // 2*WIDTH
    .zero(zero_flag),
    .error(error_flag)
);

//Memory

memory #(WIDTH) mem_inst (
    .clk(clk),
    .memoryWrite(memoryWrite),
    .memoryRead(memoryRead),
    .memoryWriteData(alu_out_reg),  // 2*WIDTH bits
    .memoryAddress(din_1),      // WIDTH bits
    .memoryOutData(memoryOutData)    // 2*WIDTH bits
);

endmodule