`timescale 1ns / 1ps
module instruction_fetch_unit (
    input         clk,
    input         rst,
    input         PCSrc,
    input  [31:0] pc_target,
    output [31:0] pc,
    output [31:0] pc_plus4
);
    reg [31:0] pc_reg;
    assign pc       = pc_reg;
    assign pc_plus4 = pc_reg + 32'd4;
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_reg <= 32'h00000000;
        else
            pc_reg <= PCSrc ? pc_target : pc_plus4;
    end
endmodule