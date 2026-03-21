`timescale 1ns / 1ps
module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7_5,
    output reg   RegWrite,
    output reg   ALUSrc,
    output reg   MemWrite,
    output reg   MemRead,
    output reg   MemToReg,
    output reg   Branch,
    output reg   Jump,
    output reg [3:0] ALUControl
);
    always @(*) begin
        RegWrite=0; ALUSrc=0; MemWrite=0; MemRead=0;
        MemToReg=0; Branch=0; Jump=0; ALUControl=4'b0000;
        case (opcode)
            7'b0110011: begin
                RegWrite=1;
                case (funct3)
                    3'b000: ALUControl = funct7_5 ? 4'b0001 : 4'b0000;
                    3'b001: ALUControl = 4'b0101;
                    3'b010: ALUControl = 4'b1000;
                    3'b011: ALUControl = 4'b1001;
                    3'b100: ALUControl = 4'b0100;
                    3'b101: ALUControl = funct7_5 ? 4'b0111 : 4'b0110;
                    3'b110: ALUControl = 4'b0011;
                    3'b111: ALUControl = 4'b0010;
                    default: ALUControl = 4'b0000;
                endcase
            end
            7'b0010011: begin
                RegWrite=1; ALUSrc=1;
                case (funct3)
                    3'b000: ALUControl = 4'b0000;
                    3'b001: ALUControl = 4'b0101;
                    3'b010: ALUControl = 4'b1000;
                    3'b011: ALUControl = 4'b1001;
                    3'b100: ALUControl = 4'b0100;
                    3'b101: ALUControl = funct7_5 ? 4'b0111 : 4'b0110;
                    3'b110: ALUControl = 4'b0011;
                    3'b111: ALUControl = 4'b0010;
                    default: ALUControl = 4'b0000;
                endcase
            end
            7'b0000011: begin RegWrite=1; ALUSrc=1; MemRead=1; MemToReg=1; ALUControl=4'b0000; end
            7'b0100011: begin ALUSrc=1; MemWrite=1; ALUControl=4'b0000; end
            7'b1100011: begin
                Branch=1;
                case (funct3)
                    3'b000: ALUControl=4'b0001;
                    3'b001: ALUControl=4'b0001;
                    3'b100: ALUControl=4'b1000;
                    3'b101: ALUControl=4'b1000;
                    3'b110: ALUControl=4'b1001;
                    3'b111: ALUControl=4'b1001;
                    default: ALUControl=4'b0001;
                endcase
            end
            7'b1101111: begin RegWrite=1; Jump=1; ALUControl=4'b0000; end
            7'b1100111: begin RegWrite=1; ALUSrc=1; Jump=1; ALUControl=4'b0000; end
            7'b0110111: begin RegWrite=1; ALUSrc=1; ALUControl=4'b0000; end
            7'b0010111: begin RegWrite=1; ALUSrc=1; ALUControl=4'b0000; end
            default: begin end
        endcase
    end
endmodule