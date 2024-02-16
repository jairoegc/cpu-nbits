module memory_tb;

logic clk, memoryWrite, memoryRead;
logic [15:0] memoryWriteData;
logic [7:0] memoryAddress;
logic [15:0] memoryOutData;

memory #(8) U4 (clk, memoryWrite, memoryRead, memoryWriteData, memoryAddress, memoryOutData);

initial
begin
    $monitor("Time: %t, clk: %d, memoryWrite %d, memoryRead: %d, memoryWriteData: %b, memoryAddress: %b, memoryOutData: %b", $time, clk, memoryWrite, memoryRead, memoryWriteData, memoryAddress, memoryOutData);
    memoryWrite = 0;
    memoryRead = 0;
    memoryWriteData = 0;
    memoryAddress = 0;
    #300 $finish;
end

always@(clk)
begin
    case ($time)
        20 : begin
            memoryWrite = 1;
            memoryAddress = 25;
            memoryWriteData = 69;
        end
        40 : memoryWrite = 0;
        60 : memoryRead = 1;
    endcase
end

initial
begin
    clk = 0;
    forever #10 clk = ~clk;
end
    
endmodule