`timescale 1ns / 1ps
module top (
    input  clk,
    input  rst,
    output [31:0] pc_out,
    output [31:0] alu_result_out,
    output        reg_write_out,
    output        mem_write_out,
    output        branch_out,
    output        pcsrc_out
);
    wire [31:0] pc, pc_plus4, instruction, pc_target;
    wire        PCSrc;
    wire        RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump;
    wire [3:0]  ALUControl;
    wire [31:0] alu_result;

    assign pc_out        = pc;
    assign alu_result_out= alu_result;
    assign reg_write_out = RegWrite;
    assign mem_write_out = MemWrite;
    assign branch_out    = Branch;
    assign pcsrc_out     = PCSrc;

    instruction_fetch_unit IFU (
        .clk(clk), .rst(rst),
        .PCSrc(PCSrc), .pc_target(pc_target),
        .pc(pc), .pc_plus4(pc_plus4)
    );
    instruction_memory IMEM (
        .addr(pc), .instruction(instruction)
    );
    control_unit CU (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .MemToReg(MemToReg), .Branch(Branch),
        .Jump(Jump), .ALUControl(ALUControl)
    );
    data_path DP (
        .clk(clk), .rst(rst),
        .pc(pc), .pc_plus4(pc_plus4),
        .instruction(instruction),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .MemToReg(MemToReg), .Branch(Branch),
        .Jump(Jump), .ALUControl(ALUControl),
        .PCSrc(PCSrc), .pc_target(pc_target),
        .alu_result(alu_result)
    );
endmodule
