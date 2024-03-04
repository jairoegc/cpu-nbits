/*
memory #(WIDTH = 8) U1(
    .clk(),
    .memoryWrite(),
    .memoryRead(),
    .memoryWriteData(),  // 2*WIDTH bits
    .memoryAddress(),      // WIDTH bits
    .memoryOutData()    // 2*WIDTH bits
);
*/

module memory #(
    parameter WIDTH = 8
)(
    input logic clk, memoryWrite, memoryRead,
    input logic [2*WIDTH-1:0] memoryWriteData,
    input logic [7:0] memoryAddress,
    output logic [2*WIDTH-1:0] memoryOutData
);
/*
SRAMLP2RW128x16 inst_SRAM1(
    .A1(memoryAddress[6:0]),    // 7bits address
    .CE1(clk),                  // CLK
    .CSB1(~memoryAddress[7]),   // enable ram1
    .WE1(memoryWrite),          // Write enable 1
    .OEB1(memoryRead),          // Read enable 1
    .I1(memoryWriteData),       // 16bits
    .O1(memoryOutData),         // 16bits
    .LS1(1'd0),
    .DS1(1'd0),
    .A2(memoryAddress[6:0]),    // 7bits adress
    .CE2(clk),                  // CLK
    .CSB2(memoryAddress[7]),    // enable ram2
    .WE2(memoryWrite),          // Write enable 2
    .OEB2(memoryRead),          // Read enable 2
    .I2(memoryWriteData),       // 16bits
    .O2(memoryOutData),         // 16bits
    .LS2(1'd0),
    .DS2(1'd0),
    .SD(1'd0)
);
*/

logic [2*WIDTH:0] mem [255:0];

assign memoryOutData = (memoryRead && !memoryWrite)? mem[memoryAddress]:0;

logic [2*WIDTH-1:0] mem_next;

always_comb
begin
    if (memoryWrite && !memoryRead)
        mem_next = memoryWriteData;
    else
        mem_next = mem[memoryAddress];
end


always_ff@(posedge clk)
begin
    mem[memoryAddress] <= mem_next;
end


endmodule