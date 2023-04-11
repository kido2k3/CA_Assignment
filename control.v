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
    input [31 :0] instruction, 
    output reg [10:0] control_signal
    );
    wire [5:0] opcode;
    assign opcode = instruction[31:26];

    always@(*)
    begin
        if (!instruction)
            control_signal = 11'b000_000_000_00;

        else if(!opcode[5:2])
        begin
            if(!opcode[1:0]) // R-format
            begin
                control_signal[10:4] = 7'b0000010;
                control_signal[2:0] = 3'b011;
                control_signal[3]   = 0;
            end
            else if(opcode[1:0] == 2) // Jump
                control_signal[10:0] = 11'b10000010000;
            else
                control_signal[10:0] = 11'b00000001000;
        end

        else if (opcode == 6'h1c) //mul
        begin
            control_signal[10:4] = 7'b0000010;
            control_signal[2:0] = 3'b011;
            control_signal[3]   = 0;
        end

        else if(opcode[5:2]==4'b1000)// Load
        begin
            control_signal[10:6] = 7'b00101;
            control_signal[2:0] = 3'b110;
            if(opcode[1:0]==2'b11) // word
            begin
                control_signal[5:4] = 2'b00;
                control_signal[3] = 0;
            end
            else if(opcode[1:0]==2'b01) //half
            begin
                control_signal[5:4] = 2'b11;
                control_signal[3] = 0;
            end
            else
            begin
                control_signal[5:4] = 2'b00;
                control_signal[3] = 1;
            end
        end

        else if(opcode[5:2]==4'b1010)// store
        begin
            control_signal[10:6] = 7'b00010;
            control_signal[2:0] = 3'b100;
            if(opcode[1:0]==2'b11)//word
            begin
                control_signal[5:4] = 2'b00;
                control_signal[3] = 0;
            end
            else if(opcode[1:0]==2'b01)//half
            begin
                control_signal[5:4] = 2'b11;
                control_signal[3] = 0;
            end
            else
            begin
                control_signal[5:4] = 2'b00;
                control_signal[3] = 1;
            end
        end

        else if(opcode==6'h4 || opcode == 6'h5) // beq and bne
            control_signal[10:0] = 11'b01000010000;
            
        else if(opcode==6'b001000) // addi
            begin
            control_signal[10: 4] = 7'b0000000; //thử xem 5:4 là 00 xem có được phép cộng không
            control_signal[2:0] = 3'b110;
            control_signal[3] = 0;
            end
        else
            control_signal[10:0] = 11'b00000001000;
    end
    // assign IsAddi = (opcode==6'b001000);
endmodule




