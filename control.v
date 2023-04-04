`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2023 02:47:59 PM
// Design Name: 
// Module Name: control
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


module control(
    input [5 :0] opcode, 
    input [4 :0] rd,
    input [4 :0] rt,
    output [10:0] control_signal,
    output IsAddi
    );
    reg [10:0] out;
    always@(*)
    begin
        if(!opcode[5:2])
        begin
            if(!opcode[1:0]) // R-format
            begin
                out[10:4] = 7'b0000010;
                out[2:0] = 3'b011;
                out[3] = !rd;
            end
            else if(opcode[1:0] == 2) // Jump
                out[10:0] = 11'b10000010000;
            else
                out[10:0] = 11'b00000001000;
        end
        else if(opcode[5:2]==4'b1000)// Load
        begin
            out[10:6] = 7'b00101;
            out[2:0] = 3'b110;
            if(opcode[1:0]==2'b11) // word
            begin
                out[5:4] = 2'b00;
                out[3] = !rt;
            end
            else if(opcode[1:0]==2'b01) //half
            begin
                out[5:4] = 2'b11;
                out[3] = !rt;
            end
            else
            begin
                out[5:4] = 2'b00;
                out[3] = 1;
            end
        end
        else if(opcode[5:2]==4'b1010)// store
        begin
            out[10:6] = 7'b00010;
            out[2:0] = 3'b100;
            if(opcode[1:0]==2'b11)//word
            begin
                out[5:4] = 2'b00;
                out[3] = 0;
            end
            else if(opcode[1:0]==2'b01)//half
            begin
                out[5:4] = 2'b11;
                out[3] = 0;
            end
            else
            begin
                out[5:4] = 2'b00;
                out[3] = 1;
            end
        end
        else if(opcode==6'b000100) // beq
            out[10:0] = 11'b01000010000;
        else if(opcode==6'b001000) // addi
            begin
            out[10: 4] = 7'b0000010;
            out[2:0] = 3'b110;
            out[3] = !rt;
            end
        else
            out[10:0] = 11'b00000001000;
    end
    assign IsAddi = (opcode==6'b001000);
    assign control_signal = out;
endmodule
