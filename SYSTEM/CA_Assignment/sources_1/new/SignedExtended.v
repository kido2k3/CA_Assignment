`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2023 01:37:16 PM
// Design Name: 
// Module Name: SignedExtended
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


module SignedExtended
    #(  parameter IN_WIDTH = 16,
        parameter OUT_WIDTH = 32)(
        input [IN_WIDTH-1:0] in,
        output [OUT_WIDTH-1:0] out
    );
   
    assign out = {{(OUT_WIDTH-IN_WIDTH){in[IN_WIDTH-1]}},in[IN_WIDTH-1:0]};
endmodule
