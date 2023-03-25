`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2023 08:59:29 PM
// Design Name: 
// Module Name: ALU_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU_control(input [1:0] ALUop, input [5:0] func_in,input addi ,output [3:0] control_out, output ex);
    reg [3:0] ALU_control_out;
    assign control_out = ALU_control_out;
    always @(*)
        begin
        if(!addi)
            if(ALUop == 0)
                ALU_control_out = 12;//lw/sw
            else if(ALUop == 3)
                ALU_control_out = 13;//lh/sh
            else if(ALUop == 1) ALU_control_out = 6;//beq
            else if(ALUop == 2)
                begin
                    case (func_in)
                        6'b100000: ALU_control_out = 2;//add
                        6'b100010: ALU_control_out = 6;//sub
                        6'b100100: ALU_control_out = 0;//and
                        6'b100101: ALU_control_out = 1;//or
                        6'b101010: ALU_control_out = 7;//slt
                        6'b011000: ALU_control_out = 5;//mul
                        6'h1a: ALU_control_out = 4;//div
                        6'h0:   ALU_control_out = 8;//sll
                        6'h02:   ALU_control_out = 9;//srl
                        6'h26:   ALU_control_out = 10;//xor
                        6'h27:   ALU_control_out = 11;//nor
                        default: ALU_control_out = 3;//no operator
                    endcase
                end
             else ALU_control_out = 3;
           else
           begin
            ALU_control_out = 2;//addi
           end  
        end
       assign ex = (ALU_control_out == 3);
endmodule
