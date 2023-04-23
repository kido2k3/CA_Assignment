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


// module IMEM(
// input [7:0] IMEM_PC,
// //input clk,
// output [31:0] IMEM_instruction
//     );
//     reg [31:0] ins [0:63];
//     integer i;
//     initial begin
//         //$readmemb("input.mem", ins);
//         for(i=0; i<64 ;i=i+1)
//         begin
//             ins[i] = 0;
//         end
//         $readmemh("./input_text.txt", ins);
        
//     end
//     assign IMEM_instruction = ins[IMEM_PC>>2];
// endmodule
module IMEM(
    input [7:0] IMEM_PC, //address
    output [31:0] IMEM_instruction //
);
    // parameter start_address = 32'h00400000 >> 2;
    reg [31:0] ins [0:63]; //có 64 câu lệnh, mỗi lệnh có 32 bit chứa trong 32 register
    assign IMEM_instruction = ins[IMEM_PC];

    integer i;
    initial begin
        for(i=0; i<64 ;i=i+1)
        begin
            ins[i] = 0;
        end
        $readmemh("C:/Users/tuankiet/Desktop/MIPS CPU/input_text.txt", ins);
    end
endmodule
