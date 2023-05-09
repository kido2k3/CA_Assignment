`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2023 09:50:08 PM
// Design Name: 
// Module Name: DMEM
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


module DMEM(
input [31:0] DMEM_address, 
input [31:0] DMEM_data_in, 
input DMEM_mem_write, 
input DMEM_mem_read,
input clk,
input SYS_reset,
output[31:0] DMEM_data_out
    );
   integer i; 
    reg [31:0] data [0:255];
    wire [31:0] address;
    assign address = DMEM_address;
    assign DMEM_data_out = (DMEM_mem_read)?data[address]:32'b0;

    always@(negedge clk, posedge SYS_reset)
    begin
        if (SYS_reset)
        begin
            $readmemh("C:/Users/tuankiet/Desktop/MIPS CPU/CA_Assignment/input_data.txt", data);
        end

        else
        begin
            if(DMEM_mem_write)
                data[address] = DMEM_data_in;
            else
                data[address] = data[address];
        end
    end
endmodule
