`timescale 1ns / 1ps
module data_memory (
    input         clk,
    input         MemWrite,
    input         MemRead,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end
    assign read_data = MemRead ? mem[addr[31:2]] : 32'b0;
    always @(posedge clk) begin
        if (MemWrite)
            mem[addr[31:2]] <= write_data;
    end
endmodule