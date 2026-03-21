`timescale 1ns / 1ps
module instruction_memory (
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];
    initial begin
        $readmemh("program.hex", mem);
    end
    assign instruction = mem[addr[31:2]];
endmodule