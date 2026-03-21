`timescale 1ns / 1ps
module data_path (
    input         clk,
    input         rst,
    input  [31:0] pc,
    input  [31:0] pc_plus4,
    input  [31:0] instruction,
    input         RegWrite,
    input         ALUSrc,
    input         MemWrite,
    input         MemRead,
    input         MemToReg,
    input         Branch,
    input         Jump,
    input  [3:0]  ALUControl,
    output        PCSrc,
    output [31:0] pc_target,
    output [31:0] alu_result
);
    wire [31:0] read_data1, read_data2, imm;
    wire [31:0] alu_a, alu_b, alu_out;
    wire        zero;
    wire [31:0] mem_read_data, write_back_data;
    wire        branch_taken;
    wire [4:0]  rs1 = instruction[19:15];
    wire [4:0]  rs2 = instruction[24:20];
    wire [4:0]  rd  = instruction[11:7];
    wire [6:0]  opcode = instruction[6:0];
    wire [2:0]  funct3 = instruction[14:12];

    imm_gen IMMGEN (.instruction(instruction), .imm(imm));

    register_file RF (
        .clk(clk), .RegWrite(RegWrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .write_data(write_back_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );

    assign alu_a = (opcode == 7'b0010111) ? pc :
                   (opcode == 7'b0110111) ? 32'b0 : read_data1;
    assign alu_b = ALUSrc ? imm : read_data2;

    alu ALU (.a(alu_a), .b(alu_b), .ALUControl(ALUControl),
             .result(alu_out), .zero(zero));

    assign alu_result = alu_out;

    data_memory DMEM (
        .clk(clk), .MemWrite(MemWrite), .MemRead(MemRead),
        .addr(alu_out), .write_data(read_data2),
        .read_data(mem_read_data)
    );

    assign write_back_data = Jump     ? pc_plus4      :
                             MemToReg ? mem_read_data  : alu_out;

    assign branch_taken =
        (funct3==3'b000) ?  zero       :
        (funct3==3'b001) ? !zero       :
        (funct3==3'b100) ?  alu_out[0] :
        (funct3==3'b101) ? !alu_out[0] :
        (funct3==3'b110) ?  alu_out[0] :
        (funct3==3'b111) ? !alu_out[0] : 1'b0;

    assign PCSrc     = Jump | (Branch & branch_taken);
    assign pc_target = (opcode==7'b1100111) ?
                       {alu_out[31:1],1'b0} : pc + imm;
endmodule