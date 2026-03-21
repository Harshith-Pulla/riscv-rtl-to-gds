`timescale 1ns / 1ps
module register_file (
    input         clk,
    input         RegWrite,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end
    assign read_data1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];
    always @(posedge clk) begin
        if (RegWrite && rd != 5'b0)
            regs[rd] <= write_data;
    end
endmodule