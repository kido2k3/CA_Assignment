`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2023 08:07:00 PM
// Design Name: 
// Module Name: IMEM
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


module IMEM(
input [7:0] IMEM_PC,
//input clk,
output [31:0] IMEM_instruction
    );
    reg [31:0] ins [0:63];
    integer i;
    initial begin
        //$readmemb("input.mem", ins);
        for(i=0; i<64 ;i=i+1)
        begin
            ins[i] = 0;
        end
        $readmemh("D:\\DaiHoc\\HK222\\KTMT\\BTL\\SYSTEM\\CA_Assignment\\sources_1\\new\\input_text.txt", ins);
        
    end
    assign IMEM_instruction = ins[IMEM_PC>>2];
endmodule
