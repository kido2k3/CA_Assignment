`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2023 08:45:31 PM
// Design Name: 
// Module Name: REG
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


module REG(
input [5:0] REG_address1,
input [5:0] REG_address2, 
input [5:0] REG_address_wr, 
input REG_write_1, 
input [31:0] REG_data_wb_in1, 
//input clk,
output[31:0] REG_data_out1, 
output[31:0] REG_data_out2
    );
    reg [31:0] register [0:31];
    initial register[0] = 32'b0;
    assign REG_data_out1 = register[REG_address1];
    assign REG_data_out2 = register[REG_address2];
    //always @(posedge clk)
    always @(*)
    begin 
    if(REG_write_1)
        #10 register[REG_address_wr] = REG_data_wb_in1;
    else
        #10 register[REG_address_wr] = register[REG_address_wr];
    end
endmodule
