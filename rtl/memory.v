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