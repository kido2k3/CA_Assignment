`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2023 02:23:23 PM
// Design Name: 
// Module Name: ex26to28
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


module Ex4to6(
<<<<<<< HEAD
    input [3:0] in,
    output [5:0] out
=======
    input [4:0] in,
    output [6:0] out
>>>>>>> ae4e827ea83e695fdba129fee93925c2b852a390
    );
    assign out = {in, {2{1'b0}}};
endmodule
