`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2023 09:27:42 AM
// Design Name: 
// Module Name: Exception
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


module Exception(
    input FromControl,
    input FromALUControl,
    input FromALU2,
    input FromALU3,
    input FromALU6,
    output out
    );
    assign out =    FromControl ||
                    FromALUControl ||
                    FromALU2 ||
                    FromALU3 ||
                    FromALU6;
endmodule
